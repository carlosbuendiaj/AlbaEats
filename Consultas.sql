-- Alberto
-- Ofertas con finalizacion de hoy + restaurante
CREATE OR REPLACE VIEW OFERTAS_HOY AS 
SELECT oft.codigo_oferta AS CODIGO, pro.nombre AS PRODUCTO, oft.descuento, oft.finalizacion AS FECHA, VALUE(pro).restaurante.nombre AS RESTAURANTE
FROM producto_tab pro, TABLE(pro.oferta) oft 
WHERE oft.finalizacion = '12/11/21'; --SYSDATE

--Repartidor con más KM acumulados
CREATE OR REPLACE VIEW REPARTIDORES_CON_MAS_KM AS
SELECT  value(ped).repartidor.nombre AS NOMBRE_REPARTIDOR, value(ped).repartidor.numeross AS NUMERO_SS, ROUND(sum(ped.distancia), 3) as KM_TOTALES
FROM PEDIDO_TAB ped 
WHERE ped.estado='en camino' or ped.estado='completado no pagado' or ped.estado = 'completado' GROUP BY value(ped).repartidor 
ORDER BY KM_TOTALES DESC
FETCH FIRST 1 ROWS ONLY;  

-- Lineas producto
CREATE OR REPLACE VIEW LINEAS_PEDIDO_TOTALES AS
SELECT ped.id_pedido, ped.fecha, ped.pagado, ped.precio, value(ped).pedido.nombre AS CLIENTE, value(ped).repartidor.nombre AS REPARTIDOR,  COUNT(*) AS LINEAS
FROM PEDIDO_TAB ped, 
TABLE (SELECT lpedido FROM PEDIDO_TAB WHERE id_pedido = ped.id_pedido)lp
GROUP BY ped.id_pedido, ped.fecha, ped.pagado, ped.precio, value(ped).pedido.nombre,  value(ped).repartidor.nombre



-- Eliminar pedidos ya completados
DECLARE
CURSOR mycursor IS
SELECT id_pedido, estado, pagado
FROM PEDIDO_TAB
FOR UPDATE NOWAIT;
BEGIN
    FOR ped IN mycursor LOOP
        IF (ped.estado = 'completado' or ped.estado = 'completado no pagado' ) THEN
            IF (ped.pagado = 0) THEN
                UPDATE PEDIDO_TAB SET estado = 'completado no pagado' WHERE CURRENT OF mycursor;
            ELSE 
                DELETE FROM PEDIDO_TAB WHERE CURRENT OF mycursor;
            END IF;
        END IF;
    END LOOP; -- se ejecuta close implícitamente
END;


