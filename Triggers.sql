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

                         
--Alfonso
/*Cambiar la disponibilidad del vehículo cuando se lleve a un mecánico y generar una factura de la reparación.
                         
EVENTO: Insertar una factura y actualizar los datos del vehiculo                          

PASOS:
	1. Insertar una mátricula y comprobar que su disponibilidad está a 1.
	2. Cambiar la disponibilidad a 0 de ese vehiculo.
	3. Generar una factura con datos insertados que añadamos.
           3.1. En caso de insertar mal los datos saltará una excepción o datos inexistentes.

*/
CREATE OR REPLACE TRIGGER reparacion
FOR INSERT OR UPDATE ON VEHICULO_TAB
COMPOUND TRIGGER
    
    -- Coleccion que almacena las matriculas de todos los vehiculos de tipo electrico
    TYPE MATRICULAS_ELECTRICOS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
    VMATRICULAS_ELECTRICOS MATRICULAS_ELECTRICOS;
    
    -- Coleccion que almacena la disponibilidad de todos los vehiculos de tipo electrico
    TYPE DISPONIBILIDAD_ELECTRICOS IS TABLE OF VEHICULO_TAB.disponibilidad%TYPE;
    VDISP_ELECTRICOS DISPONIBILIDAD_ELECTRICOS;
    
    -- Coleccion que almacena los dni de los mecanicos de todos los vehiculos de tipo electrico
    TYPE MECANICODNI_ELECTRICOS IS TABLE OF VEHICULO_TAB.mecanico%TYPE;
    VMDNI_ELECTRICOS MECANICODNI_ELECTRICOS;
    
    -- Coleccion que almacena las matriculas de todos los vehiculos de tipo gasolina
    TYPE MATRICULAS_GASOLINA IS TABLE OF VEHICULO_TAB.matricula%TYPE;
    VMATRICULAS_GASOLINA MATRICULAS_GASOLINA;
    
    -- Coleccion que almacena las matriculas de todos los vehiculos de tipo gasolina
    TYPE DISPONIBILIDAD_GASOLINA IS TABLE OF VEHICULO_TAB.disponibilidad%TYPE;
    VDISP_GASOLINA DISPONIBILIDAD_GASOLINA;
    
    -- Coleccion que almacena los dni de los mecanicos de todos los vehiculos de tipo electrico
    TYPE MECANICODNI_GASOLINA IS TABLE OF VEHICULO_TAB.mecanico%TYPE;
    VMDNI_GASOLINA MECANICODNI_GASOLINA;
    
    -- Coleccion que almacena los dni de todos los mecanicos
    TYPE DNI_MECANICO IS TABLE OF MECANICO_TAB.dni%TYPE;
    DNIM DNI_MECANICO;
    
    -- Coleccion que almacena los id de todas las facturas
    TYPE ID_FACTURA IS TABLE OF FACTURA_TAB.id_factura%TYPE;
    IDF ID_FACTURA;
    
      
    --Otras variables
    vehiculo_matricula  VEHICULO_TAB.matricula%TYPE;
    esElectrico NUMBER(1);
    mat VARCHAR2(7);
    contfactura NUMBER(10);
    auxloop NUMBER(10);
    nid_factura NUMBER(10,0);
    ndescripcion VARCHAR2(20);
    nimporte NUMBER(8,2);
    guardadni varchar2(9);
    
    BEFORE STATEMENT IS
    BEGIN
        --Obtenemos las matriculas de todos los electricos y las almacenamos en la coleccion
        SELECT TREAT(VALUE(v) AS vehelectrico_obj).matricula, TREAT(VALUE(v) AS vehelectrico_obj).disponibilidad, TREAT(VALUE(v) AS vehelectrico_obj).mecanico
        BULK COLLECT INTO VMATRICULAS_ELECTRICOS, VDISP_ELECTRICOS, VMDNI_ELECTRICOS
        FROM vehiculo_tab v
        WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula <> 'null' ;
        
        --Obtenemos las matriculas de todos los gasolina y las almacenamos en la coleccion
        SELECT TREAT(VALUE(v) AS vehgasolina_obj).matricula, TREAT(VALUE(v) AS vehgasolina_obj).disponibilidad, TREAT(VALUE(v) AS vehgasolina_obj).mecanico
        BULK COLLECT INTO VMATRICULAS_GASOLINA, VDISP_GASOLINA, VMDNI_GASOLINA
        FROM vehiculo_tab v
        WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula <> 'null' ;
        
        --Obtenemos los dni de todos los mecanicos y los almacenaos en la coleccion
        SELECT VALUE(m).dni
        BULK COLLECT INTO DNIM
        FROM MECANICO_TAB m
        WHERE VALUE(m).dni IS NOT NULL;
        
        --Obtenemos los dni de todos los mecanicos y los almacenaos en la coleccion
        SELECT VALUE(f).id_factura
        BULK COLLECT INTO IDF
        FROM FACTURA_TAB f
        WHERE VALUE(f).id_factura IS NOT NULL;
        
    END BEFORE STATEMENT;
    
    AFTER STATEMENT IS
    BEGIN
    
    contfactura := 1;
    
    --Añadimos la matrícula del vehiculo a reparar y si es electrico o no (1 --> SI, 0 -->NO)
    mat := '2222def';
    esElectrico := 0;
    
    
    --Comprobamos si es electrico o de gasolina
    IF esElectrico = 1 THEN
        -- Recorremos todas las matriculas almacenadas de los vehiculos que son electricos
        FOR i IN 1..VMATRICULAS_ELECTRICOS.COUNT LOOP
            -- Comprobacion de que esta la matricula y el vehiculo esta disponible
            IF mat =  VMATRICULAS_ELECTRICOS(i) THEN  
                IF VDISP_ELECTRICOS(i) = 1 THEN
                   UPDATE VEHICULO_TAB SET DISPONIBILIDAD = 0 where mat = VMATRICULAS_ELECTRICOS(i);
                END IF;
            END IF;
        END LOOP;
     
     
    ELSE
    -- Recorremos todas las matriculas almacenadas de los vehiculos que son gasolina
        FOR i IN 1..VMATRICULAS_GASOLINA.COUNT LOOP
            -- Comprobacion de que esta la matricula y el vehiculo esta disponible
            IF mat =  VMATRICULAS_GASOLINA(i) THEN  
                IF VDISP_GASOLINA(i) = 1 THEN
                   UPDATE VEHICULO_TAB SET DISPONIBILIDAD = 0 where mat = VMATRICULAS_GASOLINA(i);
                END IF;
             END IF;
        END LOOP;
     END IF;
    
    --Agregamos los datos que queremos generar en la factura
    nid_factura := 000001;
    ndescripcion := 'Rep. frenos';
    nimporte :=  600;
    
    --Realiza un blucle para evitar duplicados de id
    FOR j IN 1..IDF.COUNT LOOP
        IF nid_factura = IDF(j) THEN
            nid_factura := nid_factura + 000001;
        END IF;
    END LOOP;
    
    --Llamada al procedimiento para añadir los datos
    IF esElectrico = 1 THEN
        FOR k IN 1..VMATRICULAS_ELECTRICOS.COUNT LOOP
            IF mat =  VMATRICULAS_ELECTRICOS(k) THEN
                FOR ki IN 1..DNIM.COUNT LOOP
                   FOR kj IN 1..VMDNI_ELECTRICOS.COUNT LOOP 
                        IF DNIM(k) = VMDNI_ELECTRICOS(kj) THEN
                        CREAR_FACTURA(nid_factura, ndescripcion, nimporte, mat, DNIM(ki));
                        END IF;
                    END LOOP;
                END LOOP;
            END IF;
        END LOOP;
    ELSE
         FOR k IN 1..VMATRICULAS_GASOLINA.COUNT LOOP
            IF mat =  VMATRICULAS_GASOLINA(k) THEN
                FOR ki IN 1..DNIM.COUNT LOOP
                   FOR kj IN 1..VMDNI_GASOLINA.COUNT LOOP 
                        IF DNIM(ki) = VMDNI_GASOLINA(kj) THEN
                        CREAR_FACTURA(nid_factura, ndescripcion, nimporte, mat, DNIM(ki));
                        END IF;
                    END LOOP;
                END LOOP;
            END IF;
        END LOOP;
    END IF;
    END AFTER STATEMENT;
END reparacion;
                        
                         
                         
                         
                         
                         
                         
                         
                         
