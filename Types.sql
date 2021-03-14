DROP TYPE CLIENTE_OBJ FORCE;
DROP TYPE CONTRAREEMBOLSO_OBJ FORCE;
DROP TYPE FACTURA_OBJ FORCE;
DROP TYPE LPEDIDO_OBJ FORCE;
DROP TYPE MECANICO_OBJ FORCE;
DROP TYPE METODOPAGO_OBJ FORCE;
DROP TYPE PEDIDO_OBJ FORCE;
DROP TYPE PRODUCTO_OBJ FORCE;
DROP TYPE REPARTIDOR_OBJ FORCE;
DROP TYPE RESTAURANTE_OBJ FORCE;
DROP TYPE TARJETA_OBJ FORCE;
DROP TYPE USUARIO_OBJ FORCE;
DROP TYPE VEHELECTRICO_OBJ FORCE;
DROP TYPE VEHGASOLINA_OBJ FORCE;
DROP TYPE VEHICULO_OBJ FORCE;
DROP TYPE LFACTURA_OBJ FORCE;
DROP TYPE LPEDIDO_NTABTYP FORCE;
DROP TYPE LFACTURA_NTABTYP FORCE;

CREATE  OR REPLACE TYPE RESTAURANTE_OBJ AS OBJECT(
id_restaurante NUMBER(10,0),
nombre VARCHAR2(20),
direccion VARCHAR2(200),
ciudad VARCHAR(30),
codigo_postal NUMBER(5),
telefono NUMBER(9),
tipo_restaurante VARCHAR(30),
hora_apertura TIMESTAMP (1),
hora_cierre TIMESTAMP(1),
calificacion NUMBER(1)
);


CREATE OR REPLACE TYPE PRODUCTO_OBJ AS OBJECT(
id_producto NUMBER(10),
nombre VARCHAR(20),
descripcion VARCHAR2(200),
precio_unit NUMBER(6,2),
stock NUMBER(6),
tipo_producto VARCHAR2(40),
peso_gramos NUMBER(3),
calorias NUMBER(3),
restaurante REF RESTAURANTE_OBJ
);



CREATE OR REPLACE TYPE MECANICO_OBJ AS OBJECT(
    dni VARCHAR2(9),
    nombre VARCHAR2(20),
    apellidos VARCHAR2(30),
    periodo DATE, 
    empresa VARCHAR2(30)
);

CREATE OR REPLACE TYPE LFACTURA_OBJ AS OBJECT(
    id_factura NUMBER(10),
    descripcion VARCHAR2(20),
    precio NUMBER(8,2),
    IVA NUMBER (5,2),
    cantidad NUMBER(3)
    
);

CREATE OR REPLACE TYPE USUARIO_OBJ AS OBJECT(
id_usuario NUMBER(6),
nombre VARCHAR2(30),
apellidos VARCHAR2(50),
telefono NUMBER(9),
correoE VARCHAR2(60),
ciudad VARCHAR2(20),
pais VARCHAR2(20)
)NOT FINAL;



CREATE OR REPLACE TYPE OFERTA_OBJ AS OBJECT(
codigo_oferta NUMBER(6),
descuento NUMBER(2),
maximo_descuento NUMBER(2),
finalizacion DATE,
producto REF PRODUCTO_OBJ
);


CREATE OR REPLACE TYPE CLIENTE_OBJ UNDER USUARIO_OBJ(
direccion VARCHAR2(60),
codigo_postal NUMBER(5), 
oferta REF OFERTA_OBJ
);


CREATE OR REPLACE TYPE VEHICULO_OBJ AS OBJECT(
    matricula VARCHAR2(7),
    modelo VARCHAR2(20),
    marca VARCHAR2(30),
    disponibilidad NUMBER(2,0),
    peso NUMBER(7,2),
    mecanico REF MECANICO_OBJ

)NOT FINAL;

CREATE OR REPLACE TYPE VEHGASOLINA_OBJ UNDER VEHICULO_OBJ (
    tipolicencia VARCHAR(2),
    emisiones NUMBER(5,2)
);


CREATE OR REPLACE TYPE VEHELECTRICO_OBJ UNDER VEHICULO_OBJ (
    autonomia NUMBER(3,0),
    emisiones NUMBER(5,2)
);

CREATE OR REPLACE TYPE REPARTIDOR_OBJ UNDER USUARIO_OBJ (
    dni VARCHAR2(9),
    numeross NUMBER(12,0),
    fechaalta DATE, 
    fechabaja DATE,
    vehiculo REF VEHICULO_OBJ
);






CREATE OR REPLACE TYPE LPEDIDO_OBJ AS OBJECT(
id_lpedido NUMBER(6),
cantidad NUMBER(3),
producto REF PRODUCTO_OBJ,
lfactura REF LFACTURA_OBJ
);
CREATE TYPE LPEDIDO_NTABTYP AS TABLE OF LPEDIDO_OBJ;

CREATE OR REPLACE TYPE PEDIDO_OBJ AS OBJECT(
id_pedido NUMBER(9),
precio NUMBER(3),
distancia NUMBER(6,2),
fecha DATE,
pagado NUMBER(1),
urgencia NUMBER(1),
estado VARCHAR2(20),
lpedido LPEDIDO_NTABTYP,
repartidor REF REPARTIDOR_OBJ,
pedido REF CLIENTE_OBJ
);

CREATE OR REPLACE TYPE LFACTURA_NTABTYP AS TABLE OF LFACTURA_OBJ;

CREATE OR REPLACE TYPE FACTURA_OBJ AS OBJECT(
    id_factura NUMBER(10,0),
    descripcion VARCHAR2(20),
    importe NUMBER(8,2),
    lfactura LFACTURA_NTABTYP,
    mecanico REF MECANICO_OBJ
);





CREATE OR REPLACE TYPE METODOPAGO_OBJ AS OBJECT(
    idpago NUMBER(10),
    fecha DATE,
    cliente REF CLIENTE_OBJ
)NOT FINAL;
 



CREATE OR REPLACE TYPE TARJETA_OBJ UNDER METODOPAGO_OBJ (
    numero NUMBER(16),
    fecha_caducidad NUMBER(4),
    cvv NUMBER(3),
    propiertario VARCHAR2(50)
);


CREATE OR REPLACE TYPE CONTRAREEMBOLSO_OBJ UNDER METODOPAGO_OBJ (
    observaciones VARCHAR2(300),
    cambio NUMBER(5,2)
);
