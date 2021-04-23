create or replace PROCEDURE ACTUALIZAR_PRECIO_PEDIDO (ID_PED NUMBER) AS 
BEGIN
  
DECLARE
cantidadLinea  NUMBER (8,2);
total NUMBER (10,2);
CURSOR mycursor IS

SELECT lp.precio, lp.cantidad, lp.iva 
FROM PEDIDO_TAB ped, 
TABLE (SELECT lpedido FROM PEDIDO_TAB WHERE id_pedido = ped.id_pedido)lp
WHERE ped.id_pedido = ID_PED;
BEGIN
    total:= 0;
    for i in mycursor loop
        cantidadLinea := i.precio * i.cantidad;
        cantidadLinea := cantidadLinea + (cantidadLinea*(i.iva/100));
        total := total + cantidadLinea;
        cantidadLinea := 0;
    end loop;
    UPDATE PEDIDO_TAB SET PRECIO = 1 where id_pedido = ID_PED;
END;
  
  
END ACTUALIZAR_PRECIO_PEDIDO;
