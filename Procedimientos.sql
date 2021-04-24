--Dado el id de un pedido, calcula el precio total del pedido (sumatorio de los importes de cada pedido * cantidad + iva añadido) y actualiza el pedido con este valor.

create or replace PROCEDURE ACTUALIZAR_PRECIO_PEDIDO (varid NUMBER) IS 
BEGIN

DECLARE
cantidadLinea  NUMBER (8,2);
total NUMBER (10,2);
CURSOR mycursor IS

SELECT lp.precio, lp.cantidad, lp.iva 
FROM PEDIDO_TAB ped, 
TABLE (SELECT lpedido FROM PEDIDO_TAB WHERE id_pedido = ped.id_pedido)lp
WHERE ped.id_pedido = varid;
BEGIN
    IF (varid is null) or (varid < 1) then
        RAISE_APPLICATION_ERROR (-20001, 'Error: ID del pedido es nulo o menor que 1');
    END IF;
    total:= 0;
    for i in mycursor loop
        cantidadLinea := i.precio * i.cantidad;
        cantidadLinea := cantidadLinea + (cantidadLinea*(i.iva/100));
        total := total + cantidadLinea;
        cantidadLinea := 0;
    end loop;
    DBMS_OUTPUT.PUT_LINE('UPDATING precio = '||total||' en PEDIDO_TAB con id = '||varid);
    UPDATE PEDIDO_TAB SET PRECIO = total where id_pedido = varid;

END;


END;
