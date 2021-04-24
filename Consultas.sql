-- Alberto
-- Ofertas con finalizacion de hoy + restaurante
CREATE OR REPLACE VIEW OFERTAS_HOY AS 
SELECT oft.codigo_oferta AS CODIGO, pro.nombre AS PRODUCTO, oft.descuento, oft.finalizacion AS FECHA, VALUE(pro).restaurante.nombre AS RESTAURANTE
FROM producto_tab pro, TABLE(pro.oferta) oft 
WHERE oft.finalizacion = '12/11/21'; 

--Vehiculos que aún no han repartido
CREATE VIEW VEHICULOS_SIN_USO AS
SELECT value(r).vehiculo.matricula as Matricula, value(r).vehiculo.marca as Marca, value(r).vehiculo.modelo as Modelo, r.nombre
from repartidor_tab r WHERE id_usuario NOT IN (
SELECT value(p).repartidor.id_usuario FROM PEDIDO_TAB p    group by value(p).repartidor.id_usuario
);

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

--clientes con tarjeta
CREATE OR REPLACE VIEW CLIENTE_CON_TARJETA AS
SELECT nombre, apellidos, telefono, correoE, direccion
FROM CLIENTE_TAB clie 
WHERE value(clie).metodopago.idpago  IN (
    SELECT TREAT(VALUE(mp) AS tarjeta_obj).idpago FROM metodopago_tab mp
    WHERE TREAT(VALUE(mp) AS tarjeta_obj).numero IS NOT NULL
)

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


--Carlos
--Mostrar pedidos cuyo precio sea superior a 10€
CREATE VIEW PedMayor10 AS
    SELECT id_pedido, precio, pagado, estado
    FROM PEDIDO_TAB
    WHERE Precio > 10;
    
 --Mostrar productos con un stock menor de 5€  
CREATE VIEW StockMAY5 AS
    SELECT nombre, descripcion, stock
    FROM Producto_TAB
    WHERE Stock<5;


-- Alfonso
-- 1.- Mostrar los Mecánicos que actualmente estén en periodo de contratación y haya realizado una reparación 

create view mecrep as				
select * from
	(select * from
		(select f.mecanico.dni as dni, f.mecanico.nombre as nombre, f.mecanico.empresa as empresa from factura_tab f)
		intersect
		(select dni, nombre, empresa from mecanico_tab
		where periodo > sysdate))
	natural join 
	(select  f.mecanico.dni as dni, f.mecanico.nombre as nombre, f.mecanico.empresa as empresa, count(f.mecanico.dni) as facturas_totales
	from factura_tab f
	group by f.mecanico.dni, f.mecanico.nombre, f.mecanico.empresa
	having count(f.mecanico.dni) > 0)


--2.- Mostrar todos los vehículos eléctricos cuya autonomia sea superior a 190km y la persona que lo repara es 'Fernando'

create view autonomia as
select treat(value(v) as vehelectrico_obj).matricula as matricula , treat(value(v) as vehelectrico_obj).autonomia as autonomia, 
treat(value(v) as vehelectrico_obj).emisiones as emisiones ,v.modelo, v.marca, v.disponibilidad
from vehiculo_tab v
where treat(value(v) as vehelectrico_obj).matricula <> 'null'  
and treat(value(v) as vehelectrico_obj).autonomia > 190
and v.mecanico.nombre = (select nombre from mecanico_tab
                         where nombre = 'Fernando')


--3.- Mostrar las facturas del vehículo con matrícula x y reparados por el mecánico y.

create view factmec as
select f.id_factura, f.descripcion, f.importe, f.mecanico.dni, f.vehiculo.matricula 
from FACTURA_TAB f
where f.mecanico.dni in (select dni from MECANICO_TAB where dni = '56217971E' ) 
      and
      f.vehiculo.matricula in (select matricula from VEHICULO_TAB where matricula = '4444jkl')


--4.- Mostrar los vehículos que están en uso (Pedido en camino).

create view vuso as
select * from
	(select * from
		(select r.id_usuario from repartidor_tab r)
		intersect
		(select p.repartidor.id_usuario as idup from pedido_tab p
		where p.estado = 'en camino'))
	natural join
	(select re.id_usuario, re.vehiculo.matricula as matricula from repartidor_tab re);
 

-- 5.- Mostrar los restaurantes que tengan carne como producto y se localicen en Cuenca o Albacete
-- y el producto tenga al menos una oferta. SIN TERMINAR

create view pcca as
(select p.restaurante.nombre, p.restaurante.ciudad from producto_tab p
where p.tipo_producto = 'Carne' )
intersect
(select nombre, ciudad from restaurante_tab
where ciudad = 'Cuenca' or ciudad = 'Albacete')


--6.- Sumar todos los productos de los restaurantes pertenecientes a Albacete.

create view sumaab as
select count(p.id_producto), p.restaurante.ciudad 
from producto_tab p
where p.restaurante.ciudad = 'Albacete'
group by p.restaurante.ciudad
Having count(p.id_producto) > 0;




