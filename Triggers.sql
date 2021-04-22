-- Alberto

/*
EVENTO: Insertar o actualizar un pedido en PEDIDOS_TAB
ACCIÓN: 
        - Si se inserta pedido:
          - Comprueba que el repartidor asignado al pedido está fuera de 
*/
create or replace TRIGGER ASIGNACION_REPARTIDOR
FOR INSERT OR UPDATE  ON PEDIDO_TAB
COMPOUND TRIGGER
    

    TYPE TID_PEDIDO IS TABLE OF PEDIDO_TAB.id_pedido%TYPE INDEX BY BINARY_INTEGER;
    VTPEDIDO_ID TID_PEDIDO;
    IND BINARY_INTEGER := 0;

    repartidor_id  REPARTIDOR_TAB.id_usuario%TYPE;
    fechabaja_repartidor REPARTIDOR_TAB.fechabaja%TYPE;
    vehiculo_matricula  VEHICULO_TAB.matricula%TYPE;
    currentdisp_vehiculo VEHICULO_TAB.disponibilidad%TYPE;

    NUEVO_ESTADO  varchar2(100);

     BEFORE EACH ROW IS
     BEGIN
        IND := IND +1;
        VTPEDIDO_ID(IND) := :new.id_pedido;
        NUEVO_ESTADO := :new.estado;
     END BEFORE EACH ROW;


AFTER STATEMENT IS
BEGIN
FOR i IN 1..IND LOOP

    SELECT value(p).repartidor.id_usuario, value(p).repartidor.fechabaja into repartidor_id, fechabaja_repartidor FROM PEDIDO_TAB p WHERE ID_PEDIDO =  VTPEDIDO_ID(IND);
    SELECT value(r).vehiculo.matricula, value(r).vehiculo.disponibilidad  into vehiculo_matricula, currentdisp_vehiculo FROM REPARTIDOR_TAB r WHERE r.id_usuario = repartidor_id; 


    IF INSERTING then
        IF currentdisp_vehiculo = 0 then
            RAISE_APPLICATION_ERROR (-20001, 'No se puede asignar un pedido a un repartidor que ya está repartiendo!');
        ELSIF fechabaja_repartidor < SYSDATE then
            RAISE_APPLICATION_ERROR (-20001, 'No se puede asignar un pedido a un repartidor que está fuera de contrato!');
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

END ASIGNACION_REPARTIDOR;
