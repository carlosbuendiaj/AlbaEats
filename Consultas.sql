-- Alberto
-- Ofertas con finalizacion de hoy + restaurante
select oft.codigo_oferta as CODIGO, pro.nombre as PRODUCTO, oft.descuento, oft.finalizacion as FECHA, value(pro).restaurante.nombre as RESTAURANTE
from producto_tab pro, table(pro.oferta) oft 
where oft.finalizacion = '12/11/21'
