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
create or replace TRIGGER ASSIGNACION_REPARTIDOR
FOR INSERT OR UPDATE  ON PEDIDO_TAB
COMPOUND TRIGGER
    

    TYPE TID_PEDIDO IS TABLE OF PEDIDO_TAB.id_pedido%TYPE INDEX BY BINARY_INTEGER;
    VTPEDIDO_ID TID_PEDIDO;
    
    TYPE TDISTANCIAS IS TABLE OF PEDIDO_TAB.distancia%TYPE INDEX BY BINARY_INTEGER;
    VTDISTANCIAS TDISTANCIAS;
    TYPE MATRICULAS_ELECTRICOS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
    VMATRICULAS_ELECTRICOS MATRICULAS_ELECTRICOS;


    TYPE AUTONOMIAS_ELECTRICOS IS TABLE OF NUMBER(3,0);
    VAUTONOMIAS_ELECTRICOS AUTONOMIAS_ELECTRICOS;
    
    IND BINARY_INTEGER := 0;

    repartidor_id  REPARTIDOR_TAB.id_usuario%TYPE;
    fechabaja_repartidor REPARTIDOR_TAB.fechabaja%TYPE;
    vehiculo_matricula  VEHICULO_TAB.matricula%TYPE;
    currentdisp_vehiculo VEHICULO_TAB.disponibilidad%TYPE;

    type estados is table of varchar2(30) index by binary_integer;
    VESTADOS estados;
    NUEVO_ESTADO varchar2(30);
    esElectrico NUMBER(1);
    indiceElectrico NUMBER(20);
    BEFORE STATEMENT IS
     BEGIN
        --obtener matriculas de todos los electricos
        select treat(value(v) as vehelectrico_obj).matricula, treat(value(v) as vehelectrico_obj).autonomia BULK COLLECT INTO VMATRICULAS_ELECTRICOS, VAUTONOMIAS_ELECTRICOS
        from vehiculo_tab v
        where treat(value(v) as vehelectrico_obj).matricula <> 'null' ;
     END BEFORE STATEMENT;

     BEFORE EACH ROW IS
     BEGIN
        IND := IND +1;
        VTPEDIDO_ID(IND) := :new.id_pedido;
        VESTADOS(IND):= :new.estado;
        VTDISTANCIAS(IND):= :new.distancia;
     END BEFORE EACH ROW;


AFTER STATEMENT IS
BEGIN
FOR i IN 1..IND LOOP
    esElectrico := 0;
    indiceElectrico := 0;
    NUEVO_ESTADO:= VESTADOS(i);
    SELECT value(p).repartidor.id_usuario, value(p).repartidor.fechabaja into repartidor_id, fechabaja_repartidor FROM PEDIDO_TAB p WHERE ID_PEDIDO =  VTPEDIDO_ID(i);
    SELECT value(r).vehiculo.matricula, value(r).vehiculo.disponibilidad  into vehiculo_matricula, currentdisp_vehiculo FROM REPARTIDOR_TAB r WHERE r.id_usuario = repartidor_id; 

    FOR j IN 1..VMATRICULAS_ELECTRICOS.COUNT LOOP
        IF vehiculo_matricula =  VMATRICULAS_ELECTRICOS(j) THEN  
            esElectrico := 1;
            indiceElectrico := j;
        END IF;
    END LOOP;
    
     
    IF INSERTING then
        IF currentdisp_vehiculo = 0 then
            RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que ya está repartiendo!');
        ELSIF fechabaja_repartidor < SYSDATE then
            RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que está fuera de contrato!');
        END IF;
        IF esElectrico = 1 THEN 
            IF VAUTONOMIAS_ELECTRICOS(indiceElectrico) < VTDISTANCIAS(i) THEN 
                RAISE_APPLICATION_ERROR (-20001, 'No se puede asignar este pedido a este repartirdor. Su autonomia (' || VAUTONOMIAS_ELECTRICOS(indiceElectrico) || ') es menor que la distancia (' || VTDISTANCIAS(i) || ').');
            END IF;
        END IF;
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
