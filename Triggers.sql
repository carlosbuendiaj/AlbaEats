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
