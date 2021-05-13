DROP TABLE RESTAURANTE_TAB FORCE;/
DROP TABLE MECANICO_TAB FORCE;/
DROP TABLE METODOPAGO_TAB FORCE;/
DROP TABLE PRODUCTO_TAB FORCE;/
DROP TABLE OFERTA_TAB FORCE;/
DROP TABLE CLIENTE_TAB FORCE;/
DROP TABLE VEHICULO_TAB FORCE;/
DROP TABLE REPARTIDOR_TAB FORCE;/
DROP TABLE PEDIDO_TAB FORCE;/
DROP TABLE LINEASPEDIDO_TAB FORCE;/
DROP TABLE FACTURA_TAB FORCE;/
DROP TABLE LRECIBO_TAB FORCE;/

CREATE TABLE RESTAURANTE_TAB OF RESTAURANTE_OBJ (
    id_restaurante PRIMARY KEY,
    nombre NOT NULL,
    direccion NOT NULL,
    ciudad NOT NULL,
    telefono NOT NULL
);/

CREATE TABLE MECANICO_TAB OF MECANICO_OBJ (
    dni PRIMARY KEY,
    nombre NOT NULL,
    empresa NOT NULL
);/

CREATE TABLE METODOPAGO_TAB OF METODOPAGO_OBJ(
    idpago PRIMARY KEY,
    fecha NOT NULL
);/

CREATE TABLE PRODUCTO_TAB OF PRODUCTO_OBJ (
    id_producto PRIMARY KEY,
    nombre NOT NULL,
    CHECK(precio_unit >0),
    CHECK(stock >0),
    restaurante SCOPE IS RESTAURANTE_TAB)
    NESTED TABLE oferta STORE AS OFERTA_TAB;
    
ALTER TABLE OFERTA_TAB ADD (PRIMARY KEY (codigo_oferta ),     CHECK (descuento>0),
    CHECK (maximo_descuento>0));

CREATE TABLE CLIENTE_TAB OF CLIENTE_OBJ (
    id_usuario  PRIMARY KEY,
    nombre NOT NULL,
    telefono NOT NULL,
    correoE NOT NULL,
    ciudad NOT NULL,
    direccion NOT NULL,
    codigo_postal NOT NULL,
    SCOPE FOR (metodoPago) IS METODOPAGO_TAB
    
);/



CREATE TABLE VEHICULO_TAB OF VEHICULO_OBJ(
    matricula PRIMARY KEY,
    SCOPE FOR (mecanico) IS MECANICO_TAB
);/


CREATE TABLE REPARTIDOR_TAB OF REPARTIDOR_OBJ(
    id_usuario  PRIMARY KEY,
    nombre NOT NULL,
    telefono NOT NULL,
    correoE NOT NULL,
    ciudad NOT NULL,
    dni  UNIQUE,
    numeross UNIQUE,
    fechaalta NOT NULL,
    SCOPE FOR (vehiculo) IS VEHICULO_TAB
);/



CREATE TABLE PEDIDO_TAB OF PEDIDO_OBJ(
    id_pedido PRIMARY KEY,
    precio NOT NULL,
    fecha NOT NULL,
    urgencia NOT NULL,
    CHECK (urgencia > 0),
    CHECK (urgencia <=4),
    SCOPE FOR (repartidor) IS REPARTIDOR_TAB)
    NESTED TABLE lpedido STORE AS LINEASPEDIDO_TAB;/
    
ALTER TABLE LINEASPEDIDO_TAB ADD (SCOPE FOR (producto) IS  PRODUCTO_TAB, PRIMARY KEY (id_lpedido), CHECK(cantidad > 0));/



CREATE TABLE FACTURA_TAB OF FACTURA_OBJ(
    id_factura PRIMARY KEY,
    importe NOT NULL,
    CHECK(importe >= 0),
    SCOPE FOR (mecanico) IS MECANICO_TAB,
    SCOPE FOR (vehiculo) IS VEHICULO_TAB
    );/
    

