--Dado el id de un pedido, calcula el precio total del pedido (sumatorio de los importes de cada pedido * cantidad + iva añadido) y actualiza el pedido con este valor.

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

--next
   --DADO EL NOMBRE DE UNA CIUDAD, MOSTRAR LA INFORMACION. Esta informacion mostrara el nombre de los clientes, asi como el ultimo metodo de pago que tiene cada cliente registrado,
   --un porcentage de tarjeta/efectuvo y el total recaudad (suma del importe de todos los pedidos)
