-- Alberto

/*
ASSIGNACION_REPARTIDOR

EVENTO: Insertar o actualizar un pedido en PEDIDOS_TAB
ACCIÓN: 
        - Si se inserta pedido:
          1. Comprueba que el repartidor asignado al pedido esta dado de alta (fecha de baja < hoy). Si no lo está, lanzará una excepción.
          2. Comprueba que el vehiculo del repartidor esta disponible en este momento.  Si no lo está, lanzará una excepción.
          3. Comprueba si el vehiculo del reparidor es electrico. Si es de tipo electrico, compueba si la autonomia del vehiculo es menor que la distancia.
             Si es menor, lanzará una excepción.
         
         - Si se actualiza la columna de estado de PEDIDOS_TAB:
           1. Si el pedido cambia a 'en camino', ajusta la disponibilidad del vehiculo a 0.
           2. Si por el contrario cambia a otro estado (cancelado, en preparacion,...) pone la disponibilidad del vehiculo a 1.
*/


CREATE OR REPLACE TRIGGER ASSIGNACION_REPARTIDOR
FOR INSERT OR UPDATE  ON PEDIDO_TAB
COMPOUND TRIGGER
    
    -- Coleccion que almacena los ID de los pedidos que son insertados
    TYPE TID_PEDIDO IS TABLE OF PEDIDO_TAB.id_pedido%TYPE INDEX BY BINARY_INTEGER;
    VTPEDIDO_ID TID_PEDIDO; 
    
    -- Coleccion que almacena las distancias de los pedidos que son insertados
    TYPE TDISTANCIAS IS TABLE OF PEDIDO_TAB.distancia%TYPE INDEX BY BINARY_INTEGER;
    VTDISTANCIAS TDISTANCIAS; 
    
    -- Coleccion que almacena los estados de los pedidos que son insertados
    TYPE estados IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    VESTADOS estados;
    
    -- Indice para la insercicion de los filas iinsertadas en las colecciones
    IND BINARY_INTEGER := 0;
    
    -- Coleccion que almacena las matriculas de todos los vehiculos de tipo electrico
    TYPE MATRICULAS_ELECTRICOS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
    VMATRICULAS_ELECTRICOS MATRICULAS_ELECTRICOS;

    -- Coleccion que almacena la autonomia de todos los vehiculos de tipo electrico
    TYPE AUTONOMIAS_ELECTRICOS IS TABLE OF NUMBER(3,0);
    VAUTONOMIAS_ELECTRICOS AUTONOMIAS_ELECTRICOS;
    
    
    -- Variables necesarias para la ejecucion del trigger
    repartidor_id  REPARTIDOR_TAB.id_usuario%TYPE;
    fechabaja_repartidor REPARTIDOR_TAB.fechabaja%TYPE;
    vehiculo_matricula  VEHICULO_TAB.matricula%TYPE;
    currentdisp_vehiculo VEHICULO_TAB.disponibilidad%TYPE;
    NUEVO_ESTADO varchar2(30);
    esElectrico NUMBER(1); 
    indiceElectrico NUMBER(20);
    
    
    BEFORE STATEMENT IS
    BEGIN
        
        --OBTENEMOS LAS MATRICULAS DE TODOS LOS ELECTRICOS Y LAS ALMACENAMOS EN LA COLLECCION
        SELECT TREAT(VALUE(v) AS vehelectrico_obj).matricula, TREAT(VALUE(v) AS vehelectrico_obj).autonomia 
        BULK COLLECT INTO VMATRICULAS_ELECTRICOS, VAUTONOMIAS_ELECTRICOS
        FROM vehiculo_tab v
        WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula <> 'null' ;
        
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        
        -- ALMACENAMOS EL ID, ESTADO Y DISTANCIA DE CADA NUEVO PEDIDO EN SUS COLECCIONES
        IND := IND +1;
        VTPEDIDO_ID(IND) := :new.id_pedido;
        VESTADOS(IND):= :new.estado;
        VTDISTANCIAS(IND):= :new.distancia;
        
    END BEFORE EACH ROW;


    AFTER STATEMENT IS
    BEGIN
        -- Recorremos todos los datos almacenados
        FOR i IN 1..IND LOOP
            esElectrico := 0;
            indiceElectrico := 0;
            NUEVO_ESTADO:= VESTADOS(i);
            
            -- Obtenemos el id y la fecha de baja del repartidor de esta iteracion
            SELECT VALUE(p).repartidor.id_usuario, VALUE(p).repartidor.fechabaja 
            INTO repartidor_id, fechabaja_repartidor 
            FROM PEDIDO_TAB p 
            WHERE ID_PEDIDO =  VTPEDIDO_ID(i);

            -- Obtenemos el la matricula y la disponibilidad del vehiculo de esta iteracion
            SELECT VALUE(r).vehiculo.matricula, VALUE(r).vehiculo.disponibilidad  
            INTO vehiculo_matricula, currentdisp_vehiculo 
            FROM REPARTIDOR_TAB r 
            WHERE r.id_usuario = repartidor_id; 

            -- Recorremos todas las matriculas almacenadas de los vehiculos que son electricos
            FOR j IN 1..VMATRICULAS_ELECTRICOS.COUNT LOOP
                -- Si una de ellas coincide con la matricula actual, el vehiculo es electrico
                IF vehiculo_matricula =  VMATRICULAS_ELECTRICOS(j) THEN  
                    esElectrico := 1;
                    indiceElectrico := j;
                END IF;
            END LOOP;
    
            --En caso de que estemos insertando
            IF INSERTING then
                --Comprobamos si el vehiculo esta disponible y si el repartidor esta en nomina
                IF currentdisp_vehiculo = 0 THEN
                    RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que ya está repartiendo!');
                ELSIF fechabaja_repartidor < SYSDATE THEN
                    RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que está fuera de contrato!');
                END IF;
                
                --Si el vehiculo es electrico, comprobamos si su autonomia es menor que la distancia del pedido
                IF esElectrico = 1 THEN 
                    IF VAUTONOMIAS_ELECTRICOS(indiceElectrico) < VTDISTANCIAS(i) THEN 
                    RAISE_APPLICATION_ERROR (-20001, 'No se puede asignar este pedido a este repartirdor. Su autonomia (' || VAUTONOMIAS_ELECTRICOS(indiceElectrico) || ') es menor que la distancia (' || VTDISTANCIAS(i) || ').');
                END IF;
            END IF;
            
            --En caso de actualizar, cambiamos la diponibilidad del vehiculo
            ELSIF UPDATING ('estado') then
                IF (NUEVO_ESTADO) = 'en camino' then
                    UPDATE VEHICULO_TAB SET DISPONIBILIDAD = 0 where matricula = vehiculo_matricula;
                ELSE 
                    UPDATE VEHICULO_TAB SET DISPONIBILIDAD = 1 where matricula = vehiculo_matricula;
                END IF;
            END IF;
        END LOOP;
        
    END AFTER STATEMENT;
END ASSIGNACION_REPARTIDOR;




-- TRIGGER INSTEAD OF QUE INSERTA EN CLIENTE Y TARJETA EN VEZ DE LA VISTA CLIENTE_CON_TARJETA

create or replace TRIGGER insert_on_cliente_tarjeta
INSTEAD OF INSERT
ON CLIENTE_CON_TARJETA
DECLARE

BEGIN

    INSERT INTO METODOPAGO_TAB VALUES (TARJETA_OBJ
    (:new.idpago, SYSDATE,  :new.numerotarjeta, :new.fecha_caducidad, :new.cvv, :new.propietario));
    
    INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
    ( :new.id_usuario,:new.nombre, :new.apellidos, :new.telefono, :new.CORREOE, :new.ciudad, 'N/A', :new.direccion,
    :new.codigo_postal, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = :new.idpago )));
        
END;
			 
			 
			 
--Creamos la vista PEDIDOS donde insertaremos los nuevos pedidos
CREATE OR REPLACE  VIEW PEDIDOS AS ( SELECT * FROM PEDIDO_TAB );
/

--creamos el trigger comprobar_mismo_restaurante
create or replace TRIGGER comprobar_mismo_restaurante
INSTEAD OF INSERT 
ON NESTED TABLE LPEDIDO OF PEDIDOS
FOR EACH ROW
    DECLARE    
    TYPE NOMBRE_RESTAURANTE IS TABLE OF RESTAURANTE_TAB.nombre%TYPE INDEX BY BINARY_INTEGER;
    VNOMBRE_RESTAURANTE NOMBRE_RESTAURANTE; 

     product REF PRODUCTO_OBJ;
     restaurant REF RESTAURANTE_OBJ;
     nombre RESTAURANTE_TAB.nombre%TYPE;

BEGIN

    --Buscamos y almacenamos el nombre del restaurante de cada producto en todas las lineas de un pedido
    SELECT distinct deref(rest).nombre bulk collect into VNOMBRE_RESTAURANTE from (
        SELECT deref(lp.producto).restaurante as rest 
        FROM PEDIDO_TAB ped, TABLE(LPEDIDO) lp
        WHERE ped.id_pedido = :PARENT.id_pedido
    ) restaurant;

    --Si ya hay mas de una restaurante, cancelamos la ejecucion
    IF VNOMBRE_RESTAURANTE.COUNT >1 THEN
        RAISE_APPLICATION_ERROR (-20001, 'Error, actualmente, existen productos de diferentes restaurantes en este pedido. Cancalando...' 
        || VNOMBRE_RESTAURANTE(1) || VNOMBRE_RESTAURANTE(2)  );

    ELSIF VNOMBRE_RESTAURANTE.COUNT = 0 THEN
        -- Si no hay ningun restaurante, no hay lineas de pedido, por lo que insertamos
        INSERT INTO TABLE (
            SELECT p.LPEDIDO FROM PEDIDO_TAB p WHERE id_pedido = :PARENT.id_pedido)
            VALUES (:NEW.id_lpedido, :NEW.cantidad, :NEW.precio, :NEW.iva, :NEW.descripcion, :NEW.producto ); 
    ELSE
        --Obtenemos el restaurante del producto a insertar
        product := :new.producto;
        SELECT DEREF(product).restaurante INTO restaurant FROM dual;
        SELECT DEREF(restaurant).nombre INTO nombre FROM dual;

        -- Si el restaurante coincide con el de anteriores lineas. insertamos
        IF nombre = VNOMBRE_RESTAURANTE(1) then        
            INSERT INTO TABLE (
                SELECT p.LPEDIDO FROM PEDIDO_TAB p WHERE id_pedido = :PARENT.id_pedido)
                VALUES (:NEW.id_lpedido, :NEW.cantidad, :NEW.precio, :NEW.iva, :NEW.descripcion, :NEW.producto );    
        --Si no, cancelamos la ejecucion, pues son restaurantes diferentes
        ELSE RAISE_APPLICATION_ERROR (-20001, 'ERROR, el restaurante del nuevo producto escogido no coincide con el de anteriores productos');

        END IF;


    END IF;


END;
/


--Creamos un nuevo pedido donde vamos a insertar los productos
-- SI APARACE UN ERROR, PROBAR A DESACTIVAR/ELIMINAR EL TRIGGER ACTUALIZACION_PRECIO, 
-- YA QUE EL TRIGGER ESTA INCOMPLETO Y PUEDE DAR ERROR AL INSERTAR UN PEDIDO
INSERT INTO PEDIDO_TAB VALUES(PEDIDO_OBJ
(20, 11.30,2.7, TO_DATE('21/07/2021 23:00:00', 'dd/mm/yyyy hh24:mi:ss') ,0,1, 'completado',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 6),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 2) ));
/

--Insertamos el primer producto del restaurante Taco Bell.
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDOS p WHERE p.ID_PEDIDO =20) VALUES(
200, 1, 8.3, 12, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 9)
);
/
--Intentamos insertar  un segundo  producto del restaurante Pizzeria Antonio. Obtenemos error y no se realiza la insercion

INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDOS p WHERE p.ID_PEDIDO =20) VALUES(
201, 1, 8.3, 12, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 1)
);
/

--Insertamos otro producto del restaurante Taco Bell. Esta vez si es insertado, ya que un producto de Taco Bell fue insertado antes
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDOS p WHERE p.ID_PEDIDO =20) VALUES(
201, 1, 8.3, 12, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 10)
);

/

--Carlos
create or replace TRIGGER ACTUALIZACION_PRECIO
FOR INSERT OR UPDATE ON  PEDIDO_TAB
COMPOUND TRIGGER
   
     --GUARDO MATRICULA de VEHICULO_TAB
      TYPE MATRICULAS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
            V_MATRICULAS MATRICULAS;
      --GUARDO DNI REPARTIDOR
      TYPE DNI_REP IS TABLE OF REPARTIDOR_TAB.DNI%TYPE;
            V_DNI_REP DNI_REP;
    --GUARDO LA ID DE PEDIDO
      TYPE IDPEDIDO IS TABLE OF pedido_tab.id_pedido%TYPE;
            V_IDPEDIDO IDPEDIDO;     

      TYPE repartidores_con_v_e IS TABLE OF repartidor_tab.vehiculo%type;
            v_repartidores_con_v_e repartidores_con_v_e;


      --GUARDO LA AUTONOMIA DE LOS VEHICULOS ELECTRICOS
      TYPE AUTONOMIA_E IS TABLE OF NUMBER(3);
        V_AUTONOMIA_E AUTONOMIA_E;

    --VARIABLES
       v_precio pedido_tab.precio%TYPE;
       v_distancia pedido_tab.distancia%TYPE;
       v_count binary_integer := 0; 
     --Executed before DML statement
     BEFORE STATEMENT IS
     BEGIN
            --OBTENGO MATRICULAS Y AUTONOMIA DE LOS VEHICULOS ELECTRICOS
            SELECT TREAT(VALUE(v) AS vehelectrico_obj).matricula, TREAT(VALUE(v) AS vehelectrico_obj).autonomia 
            BULK COLLECT INTO  V_MATRICULAS, V_AUTONOMIA_E
            FROM vehiculo_tab v
            WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula is not null ; --POSIBLE ERROR EN EL IS NOT NULL

            --OBTENGO LOS DNIS DE LOS REPARTIDORES
            SELECT DNI
            BULK COLLECT INTO V_DNI_REP
            FROM REPARTIDOR_TAB
            WHERE DNI IS NOT NULL;
     END BEFORE STATEMENT;
                         



--Alfonso

/*Asignación automática de ids para los restaurantes nuevos
                         
EVENTO: Insertar una factura y modificar al id correspondiente automaticamente      

PRECONDICIÓN: 
	Alternativa 1. La tabla que contiene los restaurantes debe de estár totalmente vacia.
	Alternativa 2. Modificar el contador incial de la secuencia a la cantidad total de restaurantes añadidos.

PASOS:
	1. Insertamos los datos necesarios del restaurante mediante el uso de la vista. Es imprescindible poner el primer valor a null. 
	   (Se puede ver un ejemplo al final de este código)
	2. El trigger comprueba los ids mediante una secuencia.
	3. Se añade el valor de la secuencia como id junto con el resto de datos y se guarda en la tabla correspondiente.

*/

-- Creamos una secuencia para añadir los ids
CREATE SEQUENCE RESTAURANTE_SEQ INCREMENT BY 1 START WITH 1 MINVALUE 1;
   
  CREATE OR REPLACE TRIGGER Numero_restaurante
  BEFORE INSERT ON RESTAURANTE_TAB
  FOR EACH ROW
  BEGIN
    :NEW.id_restaurante := RESTAURANTE_SEQ.NEXTVAL;
  END;

--Creamos la vista con los restaurantes para que pueda modificarse por el trigger
CREATE OR REPLACE VIEW RESTAURANTES AS ( SELECT * FROM RESTAURANTE_TAB );

--Trigger encargado de actualizar los ids de los restaurantes
create or replace TRIGGER Añadir_restaurante
  INSTEAD OF INSERT ON RESTAURANTES
  FOR EACH ROW
  
  DECLARE
    V_NR number;
      
  BEGIN

    --LLamada a la actualización de ids
    V_NR := RESTAURANTE_SEQ.nextval;
    
    --Recogida de los datos para el insert
    INSERT INTO RESTAURANTE_TAB VALUES
    (V_NR,:new.nombre,:new.direccion,:new.ciudad, :new.codigo_postal, :new.telefono, :new.tipo_restaurante, :new.hora_apertura, :new.hora_cierre, :new.calificacion);
  
  
  END;
  
  -- Ejemplo muestra
      INSERT INTO RESTAURANTES VALUES
        (null,'Test','Test123','Madrid', 00037, 666444777, 'Pizzeria', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 7);






/*Asignación automática de ids para las facturas
                         
EVENTO: Insertar una factura y modificar al id correspondiente                        

PASOS:
	1. Insertamos la factura.
	2. Comprobamos los ids.
	3. Añadimos el id correspondiente y lo guardamos.

*/
CREATE SEQUENCE FACTURA_SEQ INCREMENT BY 1 START WITH 1 MINVALUE 1;
   
  CREATE OR REPLACE TRIGGER Numero_factura
  BEFORE INSERT ON FACTURA_TAB
  FOR EACH ROW
  BEGIN
    :NEW.id_factura := FACTURA_SEQ.NEXTVAL;
  END;
  
INSERT INTO FACTURA_TAB VALUES ( FACTURA_OBJ (4,'Cambio aceite',75.26,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = '56217971E'), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = '2222def')));

CREATE OR REPLACE VIEW FACTURAS AS ( SELECT * FROM FACTURA_TAB );

create or replace TRIGGER Añadir_factura
  INSTEAD OF INSERT ON FACTURAS
  FOR EACH ROW
  
  DECLARE
    TYPE Facturaid IS TABLE OF FACTURAS.id_factura%TYPE;
    vfacturaid Facturaid;
    
    countid NUMBER;
    V_idfact FACTURAS.id_factura%type;
    auxfact number;
    
  BEGIN

    SELECT f.id_factura BULK COLLECT INTO vfacturaid
    FROM FACTURAS f
    WHERE f.id_factura IS NOT NULL;
  
   select count(id_factura) into countid from facturas;
   select id_factura into V_idfact from facturas;
  
   FOR j IN 1..countid LOOP
        IF :new.id_factura = vfacturaid(j) THEN
            auxfact := FACTURA_SEQ.NEXTVAL;
        END IF;
    END LOOP;
  
    INSERT INTO FACTURA_TAB 
		VALUES (auxfact, :NEW.descripcion, :NEW.importe,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = :new.dni), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = :new.matricula));
        
  END;
                         
                         
                         
                         
                         
                         
                         
                         
