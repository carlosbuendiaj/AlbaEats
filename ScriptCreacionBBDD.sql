--**********************************************
-- TYPES
--**********************************************

DROP TYPE CLIENTE_OBJ FORCE;/
DROP TYPE CONTRAREEMBOLSO_OBJ FORCE;/
DROP TYPE FACTURA_OBJ FORCE;/
DROP TYPE LPEDIDO_OBJ FORCE;/
DROP TYPE MECANICO_OBJ FORCE;/
DROP TYPE METODOPAGO_OBJ FORCE;/
DROP TYPE PEDIDO_OBJ FORCE;/
DROP TYPE PRODUCTO_OBJ FORCE;/
DROP TYPE REPARTIDOR_OBJ FORCE;/
DROP TYPE RESTAURANTE_OBJ FORCE;/
DROP TYPE TARJETA_OBJ FORCE;/
DROP TYPE USUARIO_OBJ FORCE;/
DROP TYPE VEHELECTRICO_OBJ FORCE;/
DROP TYPE VEHGASOLINA_OBJ FORCE;/
DROP TYPE VEHICULO_OBJ FORCE;/
DROP TYPE LFACTURA_OBJ FORCE;/
DROP TYPE LPEDIDO_NTABTYP FORCE;/
DROP TYPE OFERTA_OBJ FORCE;/
DROP TYPE OFERTA_NTABTYP FORCE;/

CREATE OR REPLACE TYPE RESTAURANTE_OBJ AS OBJECT(
id_restaurante NUMBER(10,0),
nombre VARCHAR2(20),
direccion VARCHAR2(200),
ciudad VARCHAR(30),
codigo_postal NUMBER(5),
telefono NUMBER(9),
tipo_restaurante VARCHAR(30),
hora_apertura TIMESTAMP (1),
hora_cierre TIMESTAMP(1),
calificacion NUMBER(1),
ORDER MEMBER FUNCTION CompareRestaurantes(r RESTAURANTE_OBJ) RETURN INTEGER
);
/


CREATE OR REPLACE TYPE BODY RESTAURANTE_OBJ AS
	ORDER MEMBER FUNCTION CompareRestaurantes(r RESTAURANTE_OBJ) RETURN INTEGER IS
	BEGIN
		IF id_restaurante = r.id_restaurante THEN
			IF nombre< r.nombre THEN RETURN 1;
			ELSIF nombre > r.nombre THEN RETURN -1;
			ELSE RETURN 0;
			END IF;
		ELSE
			IF id_restaurante < r.id_restaurante THEN RETURN 1;
			ELSIF id_restaurante > r.id_restaurante THEN RETURN -1;
			ELSE RETURN 0;
			END IF;
		END IF;
	END;
END;
/

CREATE OR REPLACE TYPE OFERTA_OBJ AS OBJECT(
codigo_oferta NUMBER(6),
descuento NUMBER(2),
maximo_descuento NUMBER(2),
finalizacion DATE
);
/

CREATE TYPE OFERTA_NTABTYP AS TABLE OF OFERTA_OBJ;
/

CREATE OR REPLACE TYPE PRODUCTO_OBJ AS OBJECT(
id_producto NUMBER(10),
nombre VARCHAR(20),
descripcion VARCHAR2(200),
precio_unit NUMBER(6,2),
stock NUMBER(6),
tipo_producto VARCHAR2(40),
peso_gramos NUMBER(3),
calorias NUMBER(3),
restaurante REF RESTAURANTE_OBJ,
oferta OFERTA_NTABTYP
);
/


CREATE OR REPLACE TYPE MECANICO_OBJ AS OBJECT(
    dni VARCHAR2(9),
    nombre VARCHAR2(20),
    apellidos VARCHAR2(30),
    periodo DATE, 
    empresa VARCHAR2(30)
);
/
CREATE OR REPLACE TYPE LPEDIDO_OBJ AS OBJECT(
id_lpedido NUMBER(6),
cantidad NUMBER(3),
precio NUMBER(3),
iva NUMBER(2),
descripcion VARCHAR(200),
producto REF PRODUCTO_OBJ
);
/
CREATE TYPE LPEDIDO_NTABTYP AS TABLE OF LPEDIDO_OBJ;
/


CREATE OR REPLACE TYPE USUARIO_OBJ AS OBJECT(
id_usuario NUMBER(6),
nombre VARCHAR2(30),
apellidos VARCHAR2(50),
telefono NUMBER(9),
correoE VARCHAR2(60),
ciudad VARCHAR2(20),
pais VARCHAR2(20)
)NOT FINAL;
/




CREATE OR REPLACE TYPE METODOPAGO_OBJ AS OBJECT(
    idpago NUMBER(10),
    fecha DATE
)NOT FINAL;
/


CREATE OR REPLACE TYPE TARJETA_OBJ UNDER METODOPAGO_OBJ (
    numero NUMBER(16),
    fecha_caducidad NUMBER(4),
    cvv NUMBER(3),
    propiertario VARCHAR2(50)
);
/

CREATE OR REPLACE TYPE CONTRAREEMBOLSO_OBJ UNDER METODOPAGO_OBJ (
    observaciones VARCHAR2(300),
    daPropina NUMBER(1)
);
/
CREATE OR REPLACE TYPE CLIENTE_OBJ UNDER USUARIO_OBJ(
direccion VARCHAR2(60),
codigo_postal NUMBER(5), 
metodoPago REF METODOPAGO_OBJ
);
/

CREATE OR REPLACE TYPE VEHICULO_OBJ AS OBJECT(
    matricula VARCHAR2(7),
    modelo VARCHAR2(20),
    marca VARCHAR2(30),
    disponibilidad NUMBER(2,0),
    peso NUMBER(7,2),
    mecanico REF MECANICO_OBJ,
	ORDER MEMBER FUNCTION CompareMatricula(v VEHICULO_OBJ) RETURN INTEGER
		
)NOT FINAL;
/

CREATE OR REPLACE TYPE BODY VEHICULO_OBJ AS
	ORDER MEMBER FUNCTION CompareMatricula(v VEHICULO_OBJ) RETURN INTEGER IS
	BEGIN
		IF matricula < v.matricula THEN
			RETURN -1;
		ELSIF matricula > v.matricula THEN
			RETURN 1;
		ELSE
			RETURN 0;
		END IF;
	END;
END;
/
		
		
CREATE OR REPLACE TYPE VEHGASOLINA_OBJ UNDER VEHICULO_OBJ (
    tipolicencia VARCHAR(2),
    emisiones NUMBER(5,2)
);
/

CREATE OR REPLACE TYPE VEHELECTRICO_OBJ UNDER VEHICULO_OBJ (
    autonomia NUMBER(3,0),
    emisiones NUMBER(5,2)
);
/
CREATE OR REPLACE TYPE REPARTIDOR_OBJ UNDER USUARIO_OBJ (
    dni VARCHAR2(9),
    numeross NUMBER(12,0),
    fechaalta DATE, 
    fechabaja DATE,
    vehiculo REF VEHICULO_OBJ
);
/




CREATE OR REPLACE TYPE PEDIDO_OBJ AS OBJECT(
id_pedido NUMBER(9),
precio NUMBER(5,2),
distancia NUMBER(6,2),
fecha DATE,
pagado NUMBER(1),
urgencia NUMBER(1),
estado VARCHAR2(20),
lpedido LPEDIDO_NTABTYP,
repartidor REF REPARTIDOR_OBJ,
pedido REF CLIENTE_OBJ
);
/

CREATE OR REPLACE TYPE FACTURA_OBJ AS OBJECT(
    id_factura NUMBER(10,0),
    descripcion VARCHAR2(50),
    importe NUMBER(8,2),
    mecanico REF MECANICO_OBJ,
    vehiculo REF VEHICULO_OBJ
);
/

--**********************************************
-- TABLAS
--**********************************************

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
    );
/



--**********************************************
-- INSERTS
--**********************************************

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(1,'Pizzeria Antonio','Calle Falsa 123','Madrid', 00037, 666444777, 'Pizzeria', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 7)); /

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(2,'Dominos Pizza','Avenida España','Albacete', 15637, 644775693, 'Pizzeria', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 4));/


INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(3,'Big Bang Burger','Calle Nueva','Cuenca', 13695, 699885214, 'Comida rápida', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 8));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(4,'KFC','Calle Imaginalia','Albacete', 15695, 655325214, 'Comida rápida', TO_DATE ('12:00:00', 'HH24:MI:SS'), TO_DATE ('17:30:00', 'HH24:MI:SS'), 9));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(5,'Taco Bell','Calle Princesa','Albacete', 15644, 688521499, 'Comida rápida', TO_DATE ('14:00:00', 'HH24:MI:SS'), TO_DATE ('17:30:00', 'HH24:MI:SS'), 9));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(6,'WOK','Calle Antonio Machado ','Madrid', 00044, 652149988, 'Comida asiatica', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 7));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(7,'Honk Kong','Avenida de los Reyes Catolicos','Cuenca', 13674, 688149952, 'Comida asiatica', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 5));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(8,'Restaurante barrio','Calle Fermin Caballero','Cuenca', 13616, 677164237, 'Restaurante', TO_DATE ('13:00:00', 'HH24:MI:SS'), TO_DATE ('16:30:00', 'HH24:MI:SS'), 3));
/

INSERT INTO RESTAURANTE_TAB VALUES (RESTAURANTE_OBJ
(9,'Restaurante Poli','Paseo de los Estudiantes ','Albacete', 15617, 646275978, 'Restaurante',TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 9));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(1, 'Pizza BBQ', 'Pizza con queso, jamon y salsa barbacoa', 12.00, 40, 'Pizza', 310, 210, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '1' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(2, 'Pizza Carbonara', 'Pizza con queso, jamon, tomate, peperoni y aceitunas', 11.00, 30, 'Pizza', 340, 220, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '1' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(3, 'Pizza Jamon y queso', 'Pizza con queso, jamon y tomate',8.00, 30, 'Pizza', 250, 190, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '2' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(4, 'Pizza Cuatro quesos', 'Pizza con varios quesos y tomate', 8.00, 50, 'Pizza', 200, 210, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '2' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(5, 'H queso', 'Hamburgesa con queso, lechuga y tomate', 2.50, 90, 'Carne',300, 190, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '3' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(6, 'H Big Bang', '3 hamburgesas con queso, lechuga, tomate y huevo', 3.99, 40, 'Carne', 500, 230, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '3' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(7, 'Alitas de pollo', 'Racion de 12 alitas de pollo', 2.99, 60, 'Carne', 400, 240, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '4' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(8, 'Muslos de pollo', 'Racion de 12 muslos de pollo', 3.99, 45, 'Carne', 450, 240, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '4' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(9, 'Taco', 'Taco con carne picada, verduras y salsa a elegir', 2.99, 70, 'Carne y verduras', 250, 220, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '5' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(10, 'Taco picante', 'Taco con carne picada, verduras y guacamole', 4.99, 63, 'Carne y verduras', 350, 240, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '5' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(11, 'Pollo al limón', 'Pollo con salsa al limón', 5.90, 125, 'Carne', 350, 215, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '6' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(12, 'Rollitos primavera', 'Ración de 2 piezas de hojaldre relleno de verduras. Incluye salsa agridulce o soja', 4.90, 250, 'Verdura',225, 205, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '6' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(13, 'Sushi', 'Racion de 6 trozos de pescado fresco sin cocinar con arroz', 4.57, 97, 'Pescado', 142, 182, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '7' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(14, 'Curry', 'Salsa especiada con arroz', 3.57, 230, 'Arroz', 160, 189, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '7' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(15, 'Filete con patatas', 'Filete de ternera con una racion de patatas', 7.50, 35, 'Carne', 300, 215,(SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '8' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(16, 'Cordero asado', 'Cordero asado con una racion de patatas', 8.57, 27, 'Carne', 260, 209,(SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '8' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(17, 'Paella', 'Arroz con trozos de pollo, pimiento, gisantes y gambas', 4.20, 40, 'Arroz', 220, 200, (SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '9' ), OFERTA_NTABTYP()));
/
INSERT INTO PRODUCTO_TAB VALUES (PRODUCTO_OBJ
(18, 'Pechugas con salsa', 'Pechugas con salsa de setas', 4.57, 45, 'Carne', 260, 209,(SELECT REF(r) FROM RESTAURANTE_TAB r WHERE r.ID_RESTAURANTE = '9' ), OFERTA_NTABTYP()));
/
INSERT INTO TABLE (SELECT oferta FROM PRODUCTO_TAB  WHERE id_producto  =1 ) VALUES(OFERTA_OBJ
(000001, 15, 30, TO_DATE ('2021/11/12', 'yyyy/mm/dd,' )));
/
INSERT INTO TABLE (SELECT oferta FROM PRODUCTO_TAB  WHERE id_producto  =3 ) VALUES(OFERTA_OBJ
(000031, 10, 24, TO_DATE ('2021/11/12', 'yyyy/mm/dd,' )));
/
INSERT INTO TABLE (SELECT oferta FROM PRODUCTO_TAB  WHERE id_producto  =7 ) VALUES(OFERTA_OBJ
(000200, 10, 10, TO_DATE ('2021-08-27', 'yyyy/mm/dd,' )));
/
INSERT INTO TABLE (SELECT oferta FROM PRODUCTO_TAB  WHERE id_producto  =8 ) VALUES(OFERTA_OBJ
(000456, 20, 40, TO_DATE ('2021/06/03', 'yyyy/mm/dd,' )));
/
INSERT INTO TABLE (SELECT oferta FROM PRODUCTO_TAB  WHERE id_producto  =14 ) VALUES(OFERTA_OBJ
(456781, 5, 25,  TO_DATE ('2021/11/1', 'yyyy/mm/dd,' )));
/

INSERT INTO MECANICO_TAB VALUES (MECANICO_OBJ
('45678321L', 'Fernando', 'Perez Fernandez', TO_DATE('31/01/2025', 'dd/mm/yyyy'), 'GenRush'));
/
INSERT INTO MECANICO_TAB VALUES (MECANICO_OBJ
('56217971E', 'Manolo', 'Gomez Romero', TO_DATE('30/06/2026', 'dd/mm/yyyy'), 'Motores manolo'));
/
INSERT INTO MECANICO_TAB VALUES (MECANICO_OBJ
('41247895J', 'Diego', 'Rodrigez Lopez', TO_DATE('30/06/2026', 'dd/mm/yyyy'), 'Reparaciones rodrigez'));
/

INSERT INTO METODOPAGO_TAB VALUES (CONTRAREEMBOLSO_OBJ
(1, TO_DATE('21/07/2021 21:00:00', 'dd/mm/yyyy hh24:mi:ss'), '', 0 ));
/
INSERT INTO METODOPAGO_TAB VALUES (CONTRAREEMBOLSO_OBJ
(2, TO_DATE('21/07/2021 20:00:00', 'dd/mm/yyyy hh24:mi:ss'), 'Habitacion 273', 1));
/

INSERT INTO METODOPAGO_TAB VALUES (TARJETA_OBJ
(3, TO_DATE('21/07/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss'),  1111222233334444, 0725, 111, 'Antonio'));
/
INSERT INTO METODOPAGO_TAB VALUES (TARJETA_OBJ
(4, TO_DATE('12/03/2021 20:30:00', 'dd/mm/yyyy hh24:mi:ss'), 5362133333334444, 0227, 934, 'Don Pepe'));
/
INSERT INTO METODOPAGO_TAB VALUES (TARJETA_OBJ
(5, TO_DATE('14/03/2021 15:00:00', 'dd/mm/yyyy hh24:mi:ss'), 5325452663534345, 0227, 934, 'Don Valentiniano'));
/

INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
(1, 'Antonio', 'Perez Gomez', 612345679, 'antoniopg@gmail.com', 'Albacete', 'España', 'Calle 111', 00202, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = 1 )));
/
INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
(2, 'Lucia', 'Fajardo Gonzalez', 645782391, 'luciafg@gmail.com', 'Albacete', 'España', 'Calle 222', 00202, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = 2 )));
/

INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
(3, 'Mario', 'Gomez Martinez', 698754324, 'mariogm@gmail.com', 'Cuenca', 'España', 'Calle 333', 13655, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = 3 )));
/
INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
(4, 'Alicia', 'Romero Tortola', 677248798, 'aliciart@gmail.com', 'Cuenca', 'España', 'Calle 444', 13684, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = 4 )));
/
INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
(5, 'Rebeca', 'Navarro Gomez', 654778968, 'rebecang@gmail.com', 'Madrid', 'España', 'Calle 555', 00045, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = 5 )));
/



INSERT INTO VEHICULO_TAB VALUES ( VEHGASOLINA_OBJ
('1111abc', '245RP4', 'Suzuki', 1 , 210.96, (SELECT REF(m) FROM MECANICO_TAB m WHERE m.dni = '45678321L' ),'B', 250.12));
/
INSERT INTO VEHICULO_TAB VALUES ( VEHGASOLINA_OBJ
('2222def', '946LT7', 'Renault', 1 , 200.12, (SELECT REF(m) FROM MECANICO_TAB m WHERE m.dni = '56217971E' ),'C', 305.45));
/


INSERT INTO VEHICULO_TAB VALUES( VEHELECTRICO_OBJ
('3333ghi', '327TFT7', 'Toyota', 1 , 225.47, (SELECT REF(m) FROM MECANICO_TAB m WHERE m.dni = '45678321L' ),300, 100.02));
/
INSERT INTO VEHICULO_TAB VALUES( VEHELECTRICO_OBJ
('4444jkl', '429BC45', 'BMW', 1 , 213.23, (SELECT REF(m) FROM MECANICO_TAB m WHERE m.dni = '41247895J' ),200, 075.43));
/

INSERT INTO REPARTIDOR_TAB VALUES( REPARTIDOR_OBJ
(6, 'Juan', 'Gonzalez Romero', 673215984, 'juangr@gmail.com', 'Albacete', 'España', '44444447F',444444444444, TO_DATE('21/01/2021', 'dd/mm/yyyy'), TO_DATE('21/01/2022', 'dd/mm/yyyy'), (SELECT REF(V) FROM VEHICULO_TAB v WHERE v.matricula = '3333ghi')));
/
INSERT INTO REPARTIDOR_TAB VALUES( REPARTIDOR_OBJ
(7, 'Marta', 'Sevilla Martinez', 628497533, 'martasm@gmail.com', 'Cuenca', 'España', '22222224T',222222222222, TO_DATE('16/03/2021', 'dd/mm/yyyy'), TO_DATE('16/03/2022', 'dd/mm/yyyy'), (SELECT REF(V) FROM VEHICULO_TAB v WHERE v.matricula = '4444jkl')));
/
INSERT INTO REPARTIDOR_TAB VALUES( REPARTIDOR_OBJ
(8, 'Pedro', 'Plaza Fernandez', 629477821, 'pedropf@gmail.com', 'Madrid', 'España', '33333339N',333333333333, TO_DATE('09/01/2021', 'dd/mm/yyyy'), TO_DATE('09/06/2022', 'dd/mm/yyyy'), (SELECT REF(V) FROM VEHICULO_TAB v WHERE v.matricula = '1111abc')));
/
INSERT INTO REPARTIDOR_TAB VALUES( REPARTIDOR_OBJ
(9, 'Antonio', 'Martinez Fernandez', 623748202, 'antoniooof@gmail.com', 'Albacete', 'España', '2232333j',232332323, TO_DATE('09/01/2021', 'dd/mm/yyyy'), TO_DATE('09/06/2022', 'dd/mm/yyyy'), (SELECT REF(V) FROM VEHICULO_TAB v WHERE v.matricula = '4444jkl')));
/



INSERT INTO PEDIDO_TAB VALUES( PEDIDO_OBJ
(1, 12.30,12, TO_DATE('21/07/2021 22:00:00', 'dd/mm/yyyy hh24:mi:ss') ,0,2, 'en camino',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 6),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 1) ));
/
INSERT INTO PEDIDO_TAB VALUES(PEDIDO_OBJ
(2, 21.30,12, TO_DATE('21/07/2021 23:00:00', 'dd/mm/yyyy hh24:mi:ss') ,1,1, 'en preparacion',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 6),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 2) ));
/
INSERT INTO PEDIDO_TAB VALUES(PEDIDO_OBJ
(3, 37.16,3.4, TO_DATE('31/07/2021 12:00:00', 'dd/mm/yyyy hh24:mi:ss') ,1,1, 'completado',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 8),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 4) ));
/
INSERT INTO PEDIDO_TAB VALUES(PEDIDO_OBJ
(4, 13.2,5.3, TO_DATE('12/03/2021 12:00:00', 'dd/mm/yyyy hh24:mi:ss') ,1,3, 'completado',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 7),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 3) ));
/
INSERT INTO PEDIDO_TAB VALUES(PEDIDO_OBJ
(5, 11.30,2.7, TO_DATE('21/07/2021 23:00:00', 'dd/mm/yyyy hh24:mi:ss') ,0,1, 'completado',LPEDIDO_NTABTYP(), (SELECT REF(r) FROM REPARTIDOR_TAB r WHERE r.ID_USUARIO = 6),(SELECT REF(c) FROM CLIENTE_TAB c WHERE c.ID_USUARIO = 2) ));
/



INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO ='1') VALUES(
1, 1, 13.45, 12, 'x1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 1)
);
/ 
       
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO ='1') VALUES(
2, 3, 4.10, 12, 'x4', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 5)
);
/      
   
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO ='2') VALUES(
3, 2, 8.45, 12, 'X2', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 4)
);
/
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO =3) VALUES(
4, 4, 2.35, 13, 'X4', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 4)
);
/
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO =4) VALUES(
5, 1, 5.5, 13, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 1)
);
/
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO =4) VALUES(
6, 1, 8.3, 12, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 9)
);
/
INSERT INTO TABLE (SELECT p.LPEDIDO 
FROM PEDIDO_TAB p WHERE p.ID_PEDIDO =4) VALUES(
7, 1, 2.3, 12, 'X1', (SELECT REF(pro)FROM PRODUCTO_TAB pro
WHERE pro.ID_PRODUCTO = 11)
);
/

INSERT INTO FACTURA_TAB VALUES ( FACTURA_OBJ
(000001, 'Cambio ruedas', 450.52,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = '56217971E'), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = '4444jkl')));
/


INSERT INTO FACTURA_TAB VALUES ( FACTURA_OBJ
(000002, 'Rep. motor', 1200.49,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = '56217971E'), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = '3333ghi')));
/


INSERT INTO FACTURA_TAB VALUES ( FACTURA_OBJ
(000003, 'Rep. dirección', 450.52,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = '41247895J'), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = '2222def')));
/

--**********************************************
-- CONSULTAS
--**********************************************

-- Alberto
-- Ofertas con finalizacion de hoy + restaurante
CREATE OR REPLACE VIEW OFERTAS_HOY AS 
SELECT oft.codigo_oferta AS CODIGO, pro.nombre AS PRODUCTO, oft.descuento, oft.finalizacion AS FECHA, VALUE(pro).restaurante.nombre AS RESTAURANTE
FROM producto_tab pro, TABLE(pro.oferta) oft 
WHERE oft.finalizacion = '12/11/21'; 
/
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
/
-- Lineas producto
CREATE OR REPLACE VIEW LINEAS_PEDIDO_TOTALES AS
SELECT ped.id_pedido, ped.fecha, ped.pagado, ped.precio, value(ped).pedido.nombre AS CLIENTE, value(ped).repartidor.nombre AS REPARTIDOR,  COUNT(*) AS LINEAS
FROM PEDIDO_TAB ped, 
TABLE (SELECT lpedido FROM PEDIDO_TAB WHERE id_pedido = ped.id_pedido)lp
GROUP BY ped.id_pedido, ped.fecha, ped.pagado, ped.precio, value(ped).pedido.nombre,  value(ped).repartidor.nombre;

/
--clientes con tarjeta
CREATE OR REPLACE VIEW CLIENTE_CON_TARJETA AS
SELECT nombre, apellidos, telefono, correoE, direccion,  
TREAT(DEREF(metodopago)AS TARJETA_OBJ).numero as numeroTarjeta,
TREAT(DEREF(metodopago)AS TARJETA_OBJ).cvv as CVV,
TREAT(DEREF(metodopago)AS TARJETA_OBJ).fecha_caducidad as FechaCaducidad,
TREAT(DEREF(metodopago)AS TARJETA_OBJ).propiertario as Propietario
FROM CLIENTE_TAB clie 
WHERE value(clie).metodopago.idpago  IN (
    SELECT TREAT(VALUE(mp) AS tarjeta_obj).idpago FROM metodopago_tab mp
    WHERE TREAT(VALUE(mp) AS tarjeta_obj).numero IS NOT NULL
);
/
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
/

--CARLOS
--Mostrar pedido cuyo precio sea superior a 10€ y que estan disponibles y el repartidor actualmente esta trabajando
CREATE VIEW PedMayor10 AS
    SELECT p.id_pedido, p.precio, p.pagado, p.estado, r.fechabaja
    FROM PEDIDO_TAB p, repartidor_tab r
    WHERE Precio > 10 and r.vehiculo.disponibilidad = 1 and r.fechabaja > sysdate;
    

--Mostrar los restaurantes pertenecientes a Madrid que tengan pizzas
CREATE OR REPLACE VIEW RestMyP AS 
    (SELECT p.restaurante.nombre, p.restaurante.direccion
    FROM PRODUCTO_TAB p
    WHERE  p.tipo_producto='Pizza'  ) 
    INTERSECT
    (SELECT nombre, direccion
    FROM RESTAURANTE_TAB 
    WHERE ciudad='Madrid');

--Mostrar productos con un precio menor a 5 euros, esten el Albacete y muestre los mas baratos primero 
CREATE or replace VIEW MostrarPreciosBajos AS
    SELECT p.nombre, p.descripcion, p.stock, p.restaurante.nombre, p.precio_unit
    FROM Producto_TAB p
    WHERE p.precio_unit<5 and p.restaurante.ciudad= 'Albacete'
    order by p.precio_unit asc;


--Sumar todo el dinero gastado por Lucia
CREATE OR REPLACE VIEW DINERO_LUCIA AS
(SELECT p.pedido.id_usuario, p.pedido.nombre, p.pedido.apellidos, p.precio
FROM PEDIDO_TAB p
WHERE p.PAGADO = 1
GROUP BY p.pedido.id_usuario, p.pedido.nombre, p.pedido.apellidos, p.precio
HAVING COUNT(p.PRECIO) > 0)
INTERSECT
(SELECT id_usuario, nombre, apellidos, p.precio
FROM CLIENTE_TAB , pedido_tab p
WHERE nombre = 'Lucia' );


--Mostrar las ofertas de pizzas que no han acabado
CREATE OR REPLACE VIEW OFERTAS_SIN_FINALIZAR AS
SELECT p.nombre, p.id_producto, o.finalizacion
FROM producto_tab p,
TABLE 
(SELECT oferta
FROM PRODUCTO_TAB 
WHERE producto_tab.id_producto = p.id_producto
)o
WHERE p.tipo_producto = 'Pizza' AND o.finalizacion > sysdate
ORDER BY(o.FINALIZACION)
;


--BORRAR LOS PRODUCTOS QUE TENGAN 0 de stock y que esten en madrid
DELETE 
FROM PRODUCTO_TAB p
WHERE p.stock <0 OR p.stock =0 and p.restaurante.ciudad = 'Madrid';

/



-- Alfonso
-- 1.- Mostrar los Mecánicos que actualmente estén en periodo de contratación y haya realizado una reparación 

create view MECANICOS_VIGENTES as				
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
/

--2.- Mostrar todos los vehículos eléctricos cuya autonomia sea superior a 190km y la persona que lo repara es 'Fernando'

create view AUTONOMIA_F as
select treat(value(v) as vehelectrico_obj).matricula as matricula , treat(value(v) as vehelectrico_obj).autonomia as autonomia, 
treat(value(v) as vehelectrico_obj).emisiones as emisiones ,v.modelo, v.marca, v.disponibilidad
from vehiculo_tab v
where treat(value(v) as vehelectrico_obj).matricula <> 'null'  
and treat(value(v) as vehelectrico_obj).autonomia > 190
and v.mecanico.nombre = (select nombre from mecanico_tab
                         where nombre = 'Fernando')
/

--3.- Mostrar las facturas del vehículo con matrícula x y reparados por el mecánico y.

create view FACTURAS_MECANICO as
select f.id_factura, f.descripcion, f.importe, f.mecanico.dni, f.vehiculo.matricula 
from FACTURA_TAB f
where f.mecanico.dni in (select dni from MECANICO_TAB where dni = '56217971E' ) 
      and
      f.vehiculo.matricula in (select matricula from VEHICULO_TAB where matricula = '4444jkl')

/
--4.- Mostrar los vehículos que están en uso (Pedido en camino).

create view VEHICULOS_USO as
select * from
	(select * from
		(select r.id_usuario from repartidor_tab r)
		intersect
		(select p.repartidor.id_usuario as idup from pedido_tab p
		where p.estado = 'en camino'))
	natural join
	(select re.id_usuario, re.vehiculo.matricula as matricula from repartidor_tab re);
 
/
-- 5.- Mostrar los restaurantes que tengan carne como producto y se localicen en Cuenca o Albacete

create view PRODUCTOS_CA as
(select p.restaurante.nombre, p.restaurante.ciudad from producto_tab p
where p.tipo_producto = 'Carne' )
intersect
(select nombre, ciudad from restaurante_tab
where ciudad = 'Cuenca' or ciudad = 'Albacete')

/
--6.- Sumar todos los productos de los restaurantes pertenecientes a Albacete.

create view PRODUCTOSA as
select count(p.id_producto), p.restaurante.ciudad 
from producto_tab p
where p.restaurante.ciudad = 'Albacete'
group by p.restaurante.ciudad
Having count(p.id_producto) > 0;

/
--**********************************************
--DISPARADORES (TRIGGERS)
--**********************************************

-- Alberto
CREATE OR REPLACE TRIGGER ASSIGNACION_REPARTIDOR
FOR INSERT OR UPDATE  ON PEDIDO_TAB
COMPOUND TRIGGER
    
    -- Coleccion que almacena los ID de los pedidos que son insertados
    TYPE TID_PEDIDO IS TABLE OF PEDIDO_TAB.id_pedido%TYPE INDEX BY BINARY_INTEGER;
    VTPEDIDO_ID TID_PEDIDO; 
    
    -- Coleccion que almacena las distancias de los pedidos que son insertados
    TYPE TDISTANCIAS IS TABLE OF PEDIDO_TAB.distancia%TYPE INDEX BY BINARY_INTEGER;
    VTDISTANCIAS TDISTANCIAS; 
    
    -- Coleccion que almacena los estados de los pedidos que son insertados
    TYPE estados IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
    VESTADOS estados;
    
    -- Indice para la insercicion de los filas iinsertadas en las colecciones
    IND BINARY_INTEGER := 0;
    
    -- Coleccion que almacena las matriculas de todos los vehiculos de tipo electrico
    TYPE MATRICULAS_ELECTRICOS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
    VMATRICULAS_ELECTRICOS MATRICULAS_ELECTRICOS;

    -- Coleccion que almacena la autonomia de todos los vehiculos de tipo electrico
    TYPE AUTONOMIAS_ELECTRICOS IS TABLE OF NUMBER(3,0);
    VAUTONOMIAS_ELECTRICOS AUTONOMIAS_ELECTRICOS;
    
    
    -- Variables necesarias para la ejecucion del trigger
    repartidor_id  REPARTIDOR_TAB.id_usuario%TYPE;
    fechabaja_repartidor REPARTIDOR_TAB.fechabaja%TYPE;
    vehiculo_matricula  VEHICULO_TAB.matricula%TYPE;
    currentdisp_vehiculo VEHICULO_TAB.disponibilidad%TYPE;
    NUEVO_ESTADO varchar2(30);
    esElectrico NUMBER(1); 
    indiceElectrico NUMBER(20);
    
    
    BEFORE STATEMENT IS
    BEGIN
        
        --OBTENEMOS LAS MATRICULAS DE TODOS LOS ELECTRICOS Y LAS ALMACENAMOS EN LA COLLECCION
        SELECT TREAT(VALUE(v) AS vehelectrico_obj).matricula, TREAT(VALUE(v) AS vehelectrico_obj).autonomia 
        BULK COLLECT INTO VMATRICULAS_ELECTRICOS, VAUTONOMIAS_ELECTRICOS
        FROM vehiculo_tab v
        WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula <> 'null' ;
        
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        
        -- ALMACENAMOS EL ID, ESTADO Y DISTANCIA DE CADA NUEVO PEDIDO EN SUS COLECCIONES
        IND := IND +1;
        VTPEDIDO_ID(IND) := :new.id_pedido;
        VESTADOS(IND):= :new.estado;
        VTDISTANCIAS(IND):= :new.distancia;
        
    END BEFORE EACH ROW;


    AFTER STATEMENT IS
    BEGIN
        -- Recorremos todos los datos almacenados
        FOR i IN 1..IND LOOP
            esElectrico := 0;
            indiceElectrico := 0;
            NUEVO_ESTADO:= VESTADOS(i);
            
            -- Obtenemos el id y la fecha de baja del repartidor de esta iteracion
            SELECT VALUE(p).repartidor.id_usuario, VALUE(p).repartidor.fechabaja 
            INTO repartidor_id, fechabaja_repartidor 
            FROM PEDIDO_TAB p 
            WHERE ID_PEDIDO =  VTPEDIDO_ID(i);

            -- Obtenemos el la matricula y la disponibilidad del vehiculo de esta iteracion
            SELECT VALUE(r).vehiculo.matricula, VALUE(r).vehiculo.disponibilidad  
            INTO vehiculo_matricula, currentdisp_vehiculo 
            FROM REPARTIDOR_TAB r 
            WHERE r.id_usuario = repartidor_id; 

            -- Recorremos todas las matriculas almacenadas de los vehiculos que son electricos
            FOR j IN 1..VMATRICULAS_ELECTRICOS.COUNT LOOP
                -- Si una de ellas coincide con la matricula actual, el vehiculo es electrico
                IF vehiculo_matricula =  VMATRICULAS_ELECTRICOS(j) THEN  
                    esElectrico := 1;
                    indiceElectrico := j;
                END IF;
            END LOOP;
    
            --En caso de que estemos insertando
            IF INSERTING then
                --Comprobamos si el vehiculo esta disponible y si el repartidor esta en nomina
                IF currentdisp_vehiculo = 0 THEN
                    RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que ya está repartiendo!');
                ELSIF fechabaja_repartidor < SYSDATE THEN
                    RAISE_APPLICATION_ERROR (-20001, '¡No se puede asignar un pedido a un repartidor que está fuera de contrato!');
                END IF;
                
                --Si el vehiculo es electrico, comprobamos si su autonomia es menor que la distancia del pedido
                IF esElectrico = 1 THEN 
                    IF VAUTONOMIAS_ELECTRICOS(indiceElectrico) < VTDISTANCIAS(i) THEN 
                    RAISE_APPLICATION_ERROR (-20001, 'No se puede asignar este pedido a este repartirdor. Su autonomia (' || VAUTONOMIAS_ELECTRICOS(indiceElectrico) || ') es menor que la distancia (' || VTDISTANCIAS(i) || ').');
                END IF;
            END IF;
            
            --En caso de actualizar, cambiamos la diponibilidad del vehiculo
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

/

create or replace TRIGGER insert_on_cliente_tarjeta
INSTEAD OF INSERT
ON CLIENTE_CON_TARJETA
DECLARE

BEGIN

    INSERT INTO METODOPAGO_TAB VALUES (TARJETA_OBJ
    (:new.idpago, SYSDATE,  :new.numerotarjeta, :new.fecha_caducidad, :new.cvv, :new.propietario));
    
    INSERT INTO CLIENTE_TAB VALUES (CLIENTE_OBJ
    ( :new.id_usuario,:new.nombre, :new.apellidos, :new.telefono, :new.CORREOE, :new.ciudad, 'N/A', :new.direccion,
    :new.codigo_postal, (SELECT REF(m) FROM METODOPAGO_TAB m WHERE m.idpago = :new.idpago )));
        
END;
 /
--Carlos
create or replace TRIGGER ACTUALIZACION_PRECIO
FOR INSERT OR UPDATE  ON  PEDIDO_TAB
COMPOUND TRIGGER
   
     --GUARDO MATRICULA de VEHICULO_TAB
      TYPE MATRICULAS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
            V_MATRICULAS MATRICULAS;
            
      TYPE R_MATRICULAS IS TABLE OF VEHICULO_TAB.matricula%TYPE;
            R_VELECTRICO R_MATRICULAS;
            
      --GUARDO DNI REPARTIDOR
      TYPE DNI_REP IS TABLE OF REPARTIDOR_TAB.DNI%TYPE;
            V_DNI_REP DNI_REP;
            
    --GUARDO LA ID DE PEDIDO
      TYPE IDPEDIDO IS TABLE OF pedido_tab.id_pedido%TYPE;
            V_IDPEDIDO IDPEDIDO;     

      TYPE repartidores_con_v_e IS TABLE OF repartidor_tab.vehiculo%type;
            v_repartidores_con_v_e repartidores_con_v_e;


      --GUARDO LA AUTONOMIA DE LOS VEHICULOS ELECTRICOS
      TYPE AUTONOMIA_E IS TABLE OF NUMBER(3);
        V_AUTONOMIA_E AUTONOMIA_E;

    --VARIABLES
       v_precio pedido_tab.precio%TYPE;
       v_distancia pedido_tab.distancia%TYPE;
       v_count binary_integer := 0; 
     --Executed before DML statement
     BEFORE STATEMENT IS
     BEGIN
            --OBTENGO MATRICULAS Y AUTONOMIA DE LOS VEHICULOS ELECTRICOS
            SELECT TREAT(VALUE(v) AS vehelectrico_obj).matricula, TREAT(VALUE(v) AS vehelectrico_obj).autonomia 
            BULK COLLECT INTO  V_MATRICULAS, V_AUTONOMIA_E
            FROM vehiculo_tab v
            WHERE TREAT(VALUE(v) AS vehelectrico_obj).matricula is not null ; 
            
            --OBTENGO LOS DNIS DE LOS REPARTIDORES
            SELECT DNI
            BULK COLLECT INTO V_DNI_REP
            FROM REPARTIDOR_TAB
            WHERE DNI IS NOT NULL;
     END BEFORE STATEMENT;

     --Executed before each row change- :NEW, :OLD are available
     BEFORE EACH ROW IS
     BEGIN
        v_count := v_count +1;
     END BEFORE EACH ROW;


     --Executed after DML statement
     AFTER STATEMENT IS
     BEGIN
        FOR v_i in 1..V_MATRICULAS.count loop
           SELECT r.vehiculo.matricula into R_VELECTRICO(v_i) FROM REPARTIDOR_TAB r  WHERE r.vehiculo.matricula = V_MATRICULAS(v_i); --OBTENGO LOS REPARTIDORES CON VEHICULOS ELECTRICOS;
            
            FOR v_j in 1..V_DNI_REP.count loop
               -- SELECT FROM WHERE --
                SELECT p.id_pedido, p.precio, p.distancia into V_IDPEDIDO(v_j), v_precio, v_distancia   FROM PEDIDO_TAB p WHERE p.repartidor.DNI = V_DNI_REP(v_j); --AQUI GUARDO TODOS LOS DNIS, DEBERIAN DE SER LOS DNIS DE LOS REPARTIDORES QUE TENGAN UN VEHICULO ELECTRICO

                UPDATE PEDIDO_TAB set PRECIO = (v_precio * (1+ (v_distancia)/4)/ V_AUTONOMIA_E(v_i)) ;--where  = V_DNI_REP(v_j) ;
            end loop;

        end loop;


     END AFTER STATEMENT;

END ACTUALIZACION_PRECIO;
/

--Cada vez que se inserta una nueva factura, si el importe total supero los 4100 euros, 
--se le divide a la mitad el precio de dicho importe, y se genera otra factura

create or replace trigger NuevaFacturaReducida
AFTER INSERT ON factura_tab
declare
id_factura_aux factura_tab.id_factura%type;
descripcion_aux factura_tab.descripcion%type;
importe_aux factura_tab.importe%type;
mecanico_ref ref mecanico_obj;
vehiculo_ref ref vehiculo_obj;

BEGIN
select f.id_factura, f.descripcion, f.importe, f.mecanico, f.vehiculo 
into id_factura_aux,descripcion_aux,importe_aux, mecanico_ref, vehiculo_ref 
from factura_tab f   where (rownum)=1 order by f.id_factura desc;
--DBMS_OUTPUT.PUT_LINE('entra en el if ' ||importe_aux);
if (importe_aux >= 4100.00) then
--DBMS_OUTPUT.PUT_LINE('entra en el if ');
update factura_tab set importe = importe /2 where id_factura = id_factura_aux;
--DBMS_OUTPUT.PUT_LINE('pasa el update ');
insert into factura_tab values(id_factura_aux +1,descripcion_aux || 'new',importe_aux/2, mecanico_ref, vehiculo_ref);
end if;

END;
/
--Alfonso

/*Asignación automática de ids para los restaurantes nuevos
                         
EVENTO: Insertar un restaurante y modificar al id correspondiente automaticamente      

PRECONDICIÓN: 
	Alternativa 1. La tabla que contiene los restaurantes debe de estár totalmente vacia.
	Alternativa 2. Modificar el contador incial de la secuencia a la cantidad total de restaurantes añadidos.

PASOS:
	1. Insertamos los datos necesarios del restaurante mediante el uso de la vista. Es imprescindible poner el primer valor a null. 
	   (Se puede ver un ejemplo al final de este código)
	2. El trigger comprueba los ids mediante una secuencia.
	3. Se añade el valor de la secuencia como id junto con el resto de datos y se guarda en la tabla correspondiente.

*/

-- Creamos una secuencia para añadir los ids
DROP SEQUENCE RESTAURANTE_SEQ;/
DROP VIEW RESTAURANTES;/

CREATE SEQUENCE RESTAURANTE_SEQ INCREMENT BY 1 START WITH 1 MINVALUE 1;/
   
  CREATE OR REPLACE TRIGGER Numero_restaurante
  BEFORE INSERT ON RESTAURANTE_TAB
  FOR EACH ROW
  BEGIN
    :NEW.id_restaurante := RESTAURANTE_SEQ.NEXTVAL;
  END;
  /

--Creamos la vista con los restaurantes para que pueda modificarse por el trigger
CREATE OR REPLACE VIEW RESTAURANTES AS ( SELECT * FROM RESTAURANTE_TAB );/

--Trigger encargado de actualizar los ids de los restaurantes
create or replace TRIGGER Añadir_restaurante
  INSTEAD OF INSERT ON RESTAURANTES
  FOR EACH ROW
  
  DECLARE
    V_NR number;
      
  BEGIN

    --LLamada a la actualización de ids
    V_NR := RESTAURANTE_SEQ.nextval;
    
    --Recogida de los datos para el insert
    INSERT INTO RESTAURANTE_TAB VALUES
    (V_NR,:new.nombre,:new.direccion,:new.ciudad, :new.codigo_postal, :new.telefono, :new.tipo_restaurante, :new.hora_apertura, :new.hora_cierre, :new.calificacion);
  
  
  END;
  /
  
  -- Ejemplo muestra
    /*  INSERT INTO RESTAURANTES VALUES
        (null,'Test','Test123','Madrid', 00037, 666444777, 'Pizzeria', TO_DATE ('20:00:00', 'HH24:MI:SS'), TO_DATE ('23:30:00', 'HH24:MI:SS'), 7);
	*/

/*Asignación automática de ids para las nuevas facturas
                         
EVENTO: Insertar una factura y modificar al id correspondiente automaticamente. Ademas la disponibilidad del vehiculo X cambia a 0 simulando que
        está siendo reparado.

PRECONDICIÓN: 
	Alternativa 1. La tabla que contiene las facturas debe de estár totalmente vacia.
	Alternativa 2. Modificar el contador incial de la secuencia a la cantidad total de facturas añadidas.

PASOS:
	1. Insertamos los datos necesarios de la factura mediante el uso de la vista. Es imprescindible poner el primer valor a null. 
	   (Se puede ver un ejemplo al final de este código)
	2. El trigger comprueba los ids mediante una secuencia.
	3. Se añade el valor de la secuencia como id junto con el resto de datos y se guarda en la tabla correspondiente.
	4. Se actualiza la disponibilidad del vehiculo X a 0.

*/
-- Creamos una secuencia para añadir los ids
DROP SEQUENCE FACTURA_SEQ;/
DROP VIEW FACTURAS;/

CREATE SEQUENCE FACTURA_SEQ INCREMENT BY 1 START WITH 1 MINVALUE 1;/

   
  CREATE OR REPLACE TRIGGER Numero_factura
  BEFORE INSERT ON FACTURA_TAB
  FOR EACH ROW
  BEGIN
    :NEW.id_factura := FACTURA_SEQ.NEXTVAL;
  END;
  /

--Creamos la vista con las facturas para que pueda modificarse por el trigger
CREATE OR REPLACE VIEW FACTURAS AS ( SELECT * FROM FACTURA_TAB );/


--Trigger encargado de actualizar los ids de las facturas
create or replace TRIGGER Añadir_factura
  INSTEAD OF INSERT ON FACTURAS
  FOR EACH ROW
  
  DECLARE
    V_NF number;
      
  BEGIN

    --LLamada a la actualización de ids
    V_NF := FACTURA_SEQ.nextval;
    
    INSERT INTO FACTURA_TAB VALUES 
    (V_NF, :new.descripcion, :new.importe,:new.mecanico,:new.vehiculo);
    
    UPDATE vehiculo_tab V SET disponibilidad = 0 WHERE REF(V) = :new.vehiculo;

  END;
  /
  
 -- EJEMPLO INSERT FACTURA_TAB 
 /*INSERT INTO FACTURA_TAB 
 VALUES (NULL, 'TEST', 79.78,(SELECT REF(m) FROM MECANICO_TAB m WHERE m.DNI = '41247895J'), (SELECT REF(v) FROM VEHICULO_TAB v WHERE v.matricula = '3333ghi'));*/


--**********************************************
--PROCEDIMIENTOS (PROCEDURE)
--**********************************************

--Alberto
create or replace FUNCTION CALCULAR_PRECIO_PEDIDO (varid NUMBER) RETURN NUMBER IS 
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
    RETURN total;
    
END;


END CALCULAR_PRECIO_PEDIDO;


/
create or replace PROCEDURE MOSTRAR_HISTORIAL (correo VARCHAR2) IS 
    --muestra el historial de pedidos de un cliente
    TYPE PED_TAB IS TABLE OF REF PEDIDO_OBJ;
    TPED PED_TAB;
    
    cnombre CLIENTE_tab.nombre%TYPE;
    capellidos CLIENTE_tab.apellidos%TYPE;
    ctelefono  CLIENTE_tab.telefono%TYPE; 
    cdireccion CLIENTE_tab.direccion%TYPE;

    pid PEDIDO_TAB.id_pedido%TYPE;
    pprecio PEDIDO_TAB.precio%TYPE;
    pfecha PEDIDO_TAB.fecha%TYPE;
    
    productoNombre PRODUCTO_TAB.nombre%TYPE;
    precioCalculado NUMBER(8,2);
    
    indiceLinea number(3);
    BEGIN

    SELECT c.nombre, c.apellidos, c.telefono, c.direccion into  cnombre, capellidos, ctelefono, cdireccion
    FROM CLIENTE_TAB c WHERE c.correoe = correo;
        
    DBMS_OUTPUT.PUT_LINE(cnombre || ' ' || capellidos);
    DBMS_OUTPUT.PUT_LINE(ctelefono);
    DBMS_OUTPUT.PUT_LINE(cdireccion);


    SELECT REF(p) BULK COLLECT INTO TPED
    FROM PEDIDO_TAB p
    WHERE PEDIDO = /*deberia de ser cliente, pero se llama pedido*/ (SELECT REF(c) FROM CLIENTE_TAB c
                          WHERE correoe = correo);

    FOR I IN 1..TPED.COUNT LOOP
        indicelinea:=0;
        SELECT DEREF(TPED(I)).id_pedido, DEREF(TPED(I)).precio, DEREF(TPED(I)).fecha  INTO pid,pprecio, pfecha FROM DUAL;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');        
        DBMS_OUTPUT.PUT_LINE('nPedido: ' || pid );
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('   	PRODUCTO        CTD     PRECIO      IVA');

        FOR linea in (
            SELECT lp.*
            FROM PEDIDO_TAB ped, TABLE (SELECT lpedido FROM PEDIDO_TAB WHERE id_pedido = ped.id_pedido)lp
            WHERE ped.id_pedido = DEREF(TPED(I)).id_pedido)
        LOOP

            --Buscamos el nombre del producto
            SELECT pr.nombre into productoNombre
            FROM PRODUCTO_TAB pr
            WHERE id_producto =  DEREF(linea.producto).id_producto;

            indicelinea := indicelinea + 1;
            DBMS_OUTPUT.PUT_LINE('  ' || indicelinea || chr(9)||productoNombre || CHR(9)||'x'|| linea.cantidad || chr(9)|| linea.precio ||CHR(9)||linea.iva);
        
        END LOOP;
        precioCalculado := CALCULAR_PRECIO_PEDIDO(pid);
        
        DBMS_OUTPUT.PUT_LINE(CHR(9)|| 'Fecha '|| pfecha ||CHR(9)||'Precio Total: ' || precioCalculado ||'');
        IF ( pprecio != precioCalculado) then
            DBMS_OUTPUT.PUT_LINE('Precio no coincide, actualizando base de datos');
            UPDATE PEDIDO_TAB x SET precio = precioCalculado WHERE x.id_pedido = pid;
        END IF;
        
        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('-');
    
END;

/                                
create or replace PROCEDURE DESPEDIR_REPARTIDOR (dniFired VARCHAR2) IS

BEGIN

DECLARE

     repart REF REPARTIDOR_OBJ;
     idREP  REPARTIDOR_TAB.id_usuario%TYPE;
     dniREP REPARTIDOR_TAB.dni%TYPE;
     
     vehi REF VEHICULO_OBJ;
     matriculaVEH   VEHICULO_TAB.matricula%TYPE;
BEGIN
    --Buscamos y almacenamos la ref del repartidor
    SELECT REF(c) INTO repart FROM REPARTIDOR_TAB c WHERE dniFired = c.dni;
    
    --almacenamos la ref del vehiculo del repartidor
    SELECT DEREF(repart).vehiculo INTO vehi FROM dual;
    
    --buscamos el vehiculo del repartidor y guardamos su matricula.
    SELECT DEREF(vehi).matricula into matriculaVEH from dual;
    
    --Actualizamos la fecha de baja del repartidor a hoy y eliminamos el vehiculo de la lista.
    
    DBMS_OUTPUT.PUT_LINE('Actualizando fecha de baja del repartidor');
    UPDATE REPARTIDOR_TAB SET fechabaja = '01/01/2024' WHERE  id_usuario= idREP;
    DBMS_OUTPUT.PUT_LINE('Eliminando vehiculo del repartidor de la DB');
    DELETE FROM VEHICULO_TAB WHERE matricula = matriculaVEH;


END;
END DESPEDIR_REPARTIDOR;
/

--Alfonso
-- Función que creará una nueva factura con los parámetros y relaciones que se le pasen
create or replace PROCEDURE CREAR_FACTURA(nid_factura number, ndescripcion varchar2, nimporte number,
m_dni varchar2, v_matricula varchar2) IS
BEGIN
DECLARE

BEGIN

    INSERT INTO FACTURA_TAB VALUES ( nid_factura, ndescripcion, nimporte,
    (SELECT ref(m) FROM MECANICO_TAB m WHERE m.dni = m_dni ),
    (SELECT ref(v) FROM VEHICULO_TAB v WHERE v.matricula = v_matricula));

     DBMS_OUTPUT.PUT_LINE('Factura creada');

END;
END CREAR_FACTURA;
/
     
-- Función que despedirá a un mecánico
create or replace PROCEDURE DESPEDIR_MECANICO (dnim VARCHAR2) IS
BEGIN
DECLARE

dnimecan MECANICO_TAB.dni%TYPE;
mvehiculo  VEHICULO_TAB.matricula%TYPE;

BEGIN
    --Almacenamos los vehiculos con el dni pasado
    SELECT v.matricula INTO mvehiculo FROM VEHICULO_TAB v WHERE v.mecanico.dni = dnim;

    --Desvinculamos el vehiculo del mecanico y eliminamos al mecánico
    DBMS_OUTPUT.PUT_LINE('Actualizando vehiculo del repartido de la DB');
    UPDATE VEHICULO_TAB SET mecanico = Null WHERE matricula = mvehiculo;
    DBMS_OUTPUT.PUT_LINE('Eliminando al mecanico');
    DELETE FROM MECANICO_TAB m WHERE m.dni = dnim;
    DBMS_OUTPUT.PUT_LINE('MECANICO ELIMINADO');

END;
END DESPEDIR_MECANICO;
/   

--Asocia un mecánico con un vehiculo que no tenga mecánico
create or replace PROCEDURE ASOCIAR_MECANICO (dnim VARCHAR2) IS
BEGIN
DECLARE

     meca REF MECANICO_OBJ;
     dnimecan MECANICO_TAB.dni%TYPE;
     mvehiculo  VEHICULO_TAB.matricula%TYPE;

BEGIN
    --Buscamos la referencia del mécanco asociado al dni del parámetro
    SELECT REF(m) INTO meca FROM MECANICO_TAB m WHERE m.dni = dnim;

    --Almacenamos los vehiculos que no tienen mecánico asociado
    SELECT v.matricula INTO mvehiculo FROM VEHICULO_TAB v WHERE v.mecanico IS NULL;

    --Actualizamos la fecha de despido y desvinculamos el vehiculo del mecanico;
    DBMS_OUTPUT.PUT_LINE('Actualizando vehiculo de la DB');
    UPDATE VEHICULO_TAB SET mecanico = meca WHERE matricula = mvehiculo;

END;
END ASOCIAR_MECANICO;
/

--Carlos
--Funcion que eliminara a un restaurante dado su nombre y su id
create or replace PROCEDURE EliminarRestaurante(NombreRestaurante VARCHAR2, IdRestaurante NUMBER) IS
BEGIN
DECLARE
NombreRest restaurante_tab.nombre%type;
IdRest restaurante_tab.id_restaurante%type;

BEGIN
    --
    SELECT t.nombre, t.id_restaurante into NombreRest, Idrest FROM RESTAURANTE_TAB t 
    WHERE t.nombre=NombreRestaurante and t.id_restaurante = IdRestaurante ;
    DBMS_OUTPUT.PUT_LINE('Eliminando restaurante de la DB');
    DELETE FROM RESTAURANTE_TAB WHERE nombre=NombreRest and id_restaurante= IdRest;
END;

END EliminarRestaurante;
/
--Cambiar el metodo de pago de un cliente, si tiene contrareembolso, cambiarlo a tarjeta de credito y viceversa. 
--Nos tendran que proporcionar el id del cliente, y los datos para cambiarlo.

create or replace procedure CambiarMetodoPago(IdCliente Number) IS
BEGIN
DECLARE
idCli cliente_tab.id_usuario%type;
NumeroTarjeta Number(16);

--declaracion de datos de contrareembolso
NuevoObservacion  VARCHAR2(300);
NuevoDaPropina NUMBER(1);
--declaracion de datos de tarjetaCredito
NuevoNumero Number(16) ;
NuevoFechaCaducidad NUMBER(4) ;
NuevoCvv NUMBER(3);
NuevoPropietario VARCHAR2(50) ;

BEGIN
    --Selecciono el cliente el cual, voy a cambiar su ,etodo de pago
    SELECT c.id_usuario into idCli FROM cliente_tab c WHERE c.id_usuario = IdCliente;
    --obtenemos el numero de tarjeta del cliente pasado por parametro
    SELECT TREAT(VALUE(m) AS Tarjeta_obj).numero into NumeroTarjeta 
    FROM cliente_tab c, metodopago_tab m 
    WHERE c.id_usuario = IdCliente;
    
    if (NumeroTarjeta=null) then
        NuevoNumero :='&numero_tarjeta_credito';
        NuevoFechaCaducidad :='&caducidad_tarjeta_credito';
        NuevoCvv :='&cvv_tarjeta_credito';
        NuevoPropietario :='&propietario_tarjeta_credito';
        UPDATE metodopago_tab set numero=NuevoNumero, fecha_caducidad=NuevoFechaCaducidad, cvv=NuevoCvv, propiertario = NuevoPropietario WHERE idCli=IdCliente;
    else    
        NuevoObservacion :='&observacion_contrareembolso';
        NuevoDaPropina :='& propina_contrareembolso';
        UPDATE metodopago_tab set observaciones=NuevoObservacion, daPropina = NuevoDaPropina WHERE idCli=IdCliente;
    end if;
END;
END CambiarMetodoPago;
/
--Subir precios de un restaurante, hasta un precio tope, si lo supera, hacemos la mitad aumento de precio
--Le pasamos por parametro el porcentaje de precio que subira y el precio maximo por el que un producto no sera subido

create or replace procedure subidaPrecio(PorcentajeSubido Number, PrecioMaximo Number, nombreRestaurante VARCHAR2) IS
BEGIN
DECLARE
TYPE Precios_productos IS TABLE OF producto_tab.precio_unit%TYPE;
    precios Precios_productos ;

BEGIN
    --obtener el precio menor de precio maximo
    select precio_unit bulk collect into precios  from producto_tab ;

    for i in 1..precios.count loop
        if((precios(i)+(precios(i)*0.1)) <= PrecioMaximo) then
           DBMS_OUTPUT.PUT_LINE('entra en el if ' || to_char((precios(i)+(precios(i)*0.1))));
           update producto_tab  set precio_unit= precio_unit + (precio_unit*(PorcentajeSubido)) 
           where coalesce (producto_tab.precio_unit, 1)= 1
           and exists ( Select r.nombre from restaurante_tab r where r.nombre = nombreRestaurante);
        else
            DBMS_OUTPUT.PUT_LINE('entra en el else ' || to_char((precios(i)+(precios(i)*0.1))));
            update producto_tab set precio_unit= precio_unit + ((precio_unit*(PorcentajeSubido)/2)) 
            where coalesce (producto_tab.precio_unit, 1)= 1
           and exists ( Select r.nombre from restaurante_tab r where r.nombre = nombreRestaurante);
        end if;

    end loop;

END;
END subidaPrecio;
/
     
--**********************************************
-- XML
--**********************************************
-----------------
-- XML Alfonso
----------------

drop table provrest force;/
drop table product force;/

-----------------------
--TABLA PROVEEDORES
----------------------

begin
DBMS_XMLSCHEMA.REGISTERSCHEMA(SCHEMAURL=>'proveedores.xsd',
SCHEMADOC=>'<?xml version="1.0"
encoding="utf-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
     <xs:element name="proveedores">
        <xs:complexType>
            <xs:sequence>
                <xs:element maxOccurs="unbounded" name="proveedor">
                     <xs:complexType>
                        <xs:sequence>
                             <xs:element name="dni" type="xs:string"/>
                             <xs:element name="nombre" type="xs:string"/>
                             <xs:element name="apellidos" type="xs:string"/>
							 <xs:element name="ciudad" type="xs:string"/>
                             <xs:element name="empresa" type="xs:string"/>
                             <xs:element name="telefono" type="xs:decimal"/>
                             <xs:element name="correo" type="xs:string"/>
                        </xs:sequence>
                        <xs:attribute name="idp" type="xs:integer" use="required"/>
                     </xs:complexType>
                </xs:element>
            </xs:sequence>
         </xs:complexType>
     </xs:element>
</xs:schema>', LOCAL=>true, GENTYPES=>false, GENBEAN=>false,
GENTABLES=>false, FORCE=>false, OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML,
OWNER=>USER);
commit;
end;
/

CREATE TABLE DDBBLOCAL.PROVREST(id number, proveedor xmltype)
XMLTYPE COLUMN proveedor
STORE AS BINARY XML
XMLSCHEMA "proveedores.xsd"
ELEMENT "proveedores";/


--INSERT Proveedores

insert into ddbblocal.provrest values(1, 
'<?xml version="1.0"?>
    <proveedores>
    <proveedor idp="1">
            <dni>77777777T</dni>
            <nombre>Pedro</nombre>
            <apellidos>Fernandez Garcia</apellidos>
			<ciudad>Albacete</ciudad>
            <empresa>DLC</empresa>
            <telefono>777777888</telefono>
            <correo>pfg@gmail.es</correo>
    </proveedor>
    </proveedores>');/

insert into ddbblocal.provrest values(2, 
'<?xml version="1.0"?>
    <proveedores>
    <proveedor idp="2">
            <dni>11111111E</dni>
            <nombre>Antonio</nombre>
            <apellidos>Rodrigez Lopez</apellidos>
			<ciudad>Cuenca</ciudad>
            <empresa>Repartos rapidos</empresa>
            <telefono>111222333</telefono>
            <correo>arl@gmail.es</correo>
    </proveedor>
    </proveedores>');/
	
insert into ddbblocal.provrest values(3, 
'<?xml version="1.0"?>
    <proveedores>
    <proveedor idp="3">
            <dni>22222222G</dni>
            <nombre>Maria</nombre>
            <apellidos>Martinez Martinez</apellidos>
			<ciudad>Cuenca</ciudad>
            <empresa>Repartos rapidos</empresa>
            <telefono>789406123</telefono>
            <correo>mmm@gmail.es</correo>
    </proveedor>
    </proveedores>');/


insert into ddbblocal.provrest values(4, 
'<?xml version="1.0"?>
    <proveedores>
    <proveedor idp="4">
            <dni>12456732G</dni>
            <nombre>Juan</nombre>
            <apellidos>Garcia Martinez</apellidos>
			<ciudad>Madrid</ciudad>
            <empresa>Transportes Garcia</empresa>
            <telefono>453297813</telefono>
            <correo>jgm@gmail.es</correo>
    </proveedor>
    </proveedores>');/
	

--INDICES	
create index idx_proveedor ON ddbblocal.provrest(proveedor) INDEXTYPE IS
XDB.XMLINDEX PARAMETERS ('PATHS (INCLUDE (/proveedores/proveedor/dni))');/



-----------------------
--PRODUCTOS
-----------------------
begin
DBMS_XMLSCHEMA.REGISTERSCHEMA(SCHEMAURL=>'productosbase.xsd',
SCHEMADOC=>'<?xml version="1.0"
encoding="utf-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
     <xs:element name="productos">
        <xs:complexType>
            <xs:sequence>
                <xs:element maxOccurs="unbounded" name="producto">
                     <xs:complexType>
                        <xs:sequence>
							 <xs:element name="idprod" type="xs:string"/>
                             <xs:element name="nombre" type="xs:string"/>
                             <xs:element name="descripcion" type="xs:string"/>
							 <xs:element name="precio_unit" type="xs:decimal"/>
                             <xs:element name="tipo_prod">
                                <xs:simpleType>
                                    <xs:restriction base="xs:string">
                                    <xs:enumeration value="Carne"/>
                                    <xs:enumeration value="Pescado"/>
                                    <xs:enumeration value="Verduras"/>
                                    <xs:enumeration value="Lacteos"/>
									<xs:enumeration value="Cereales"/>
                                    </xs:restriction>
                                </xs:simpleType>
                             </xs:element>
                             <xs:element name="peso" type="xs:decimal"/>
                             <xs:element name="cantidad" default="0">
                                <xs:simpleType>
                                    <xs:restriction base="xs:unsignedByte">
                                    <xs:minInclusive value="0"/>
                                    <xs:maxInclusive value="100"/>
                                    </xs:restriction>
                                </xs:simpleType>
                            </xs:element>                           
                        </xs:sequence>
                        <xs:attribute name="idp" type="xs:integer" use="required"/>
                     </xs:complexType>
                </xs:element>
            </xs:sequence>
         </xs:complexType>
     </xs:element>
</xs:schema>', LOCAL=>true, GENTYPES=>false, GENBEAN=>false,
GENTABLES=>false, FORCE=>false, OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML,
OWNER=>USER);
commit;
end;
/

CREATE TABLE DDBBLOCAL.PRODUCT(id number, producto xmltype)
XMLTYPE COLUMN producto
STORE AS BINARY XML
XMLSCHEMA "productosbase.xsd"
ELEMENT "productos";
/


--INSERT Productos
insert into ddbblocal.product values(1, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="1">
			<idprod>1</idprod>
            <nombre>Harina</nombre>
            <descripcion>Harina de trigo de 1 kilo</descripcion>
			<precio_unit>10.30</precio_unit>
            <tipo_prod>Cereales</tipo_prod>
            <peso>1000</peso>
            <cantidad>4</cantidad>
    </producto>
    </productos>');/
	
insert into ddbblocal.product values(2, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="2">
			<idprod>2</idprod>
            <nombre>Queso</nombre>
            <descripcion>Queso para pizzas 1kg</descripcion>
			<precio_unit>14.10</precio_unit>
            <tipo_prod>Lacteos</tipo_prod>
            <peso>1000</peso>
            <cantidad>6</cantidad>
    </producto>
    </productos>');	/
	
insert into ddbblocal.product values(3, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="3">
			<idprod>3</idprod>
            <nombre>Carne picada</nombre>
            <descripcion>Carne picada de cerdo 10kg</descripcion>
			<precio_unit>34.57</precio_unit>
            <tipo_prod>Carne</tipo_prod>
            <peso>10000</peso>
            <cantidad>3</cantidad>
    </producto>
    </productos>');/
	
insert into ddbblocal.product values(4, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="4">
			<idprod>4</idprod>
            <nombre>Muslos pollo</nombre>
            <descripcion>Muslos de pollo 20ud</descripcion>
			<precio_unit>15.57</precio_unit>
            <tipo_prod>Carne</tipo_prod>
            <peso>3450</peso>
            <cantidad>30</cantidad>
    </producto>
    </productos>');/
	
insert into ddbblocal.product values(5, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="5">
			<idprod>5</idprod>
            <nombre>Salmon fresco</nombre>
            <descripcion>Salmon fresco 5kg</descripcion>
			<precio_unit>76.73</precio_unit>
            <tipo_prod>Pescado</tipo_prod>
            <peso>5000</peso>
            <cantidad>10</cantidad>
    </producto>
    </productos>');/
	
insert into ddbblocal.product values(6, 
'<?xml version="1.0"?>
    <productos>
    <producto idp="6">
			<idprod>6</idprod>
            <nombre>Lechuga</nombre>
            <descripcion>Lechuga romana 5ud</descripcion>
			<precio_unit>6.73</precio_unit>
            <tipo_prod>Verduras</tipo_prod>
            <peso>1353</peso>
            <cantidad>10</cantidad>
    </producto>
    </productos>');/

--INDICES

create index idx_producto ON ddbblocal.product(producto) INDEXTYPE IS
XDB.XMLINDEX PARAMETERS ('PATHS (INCLUDE (/productos/producto/idprod))');/


--Consultas

--Proveedores pertenecientes a Cuenca y Albacete
create or replace view proveedoresca as
select id, p.proveedor.extract('/proveedores/proveedor/nombre/text()').getStringVal() 
from provrest p where p.proveedor.extract('/proveedores/proveedor/ciudad/text()').getStringVal() = 'Cuenca' 
or p.proveedor.extract('/proveedores/proveedor/ciudad/text()').getStringVal() = 'Albacete';/

--Mostrar los productos que sean del tipo 'Carne' y se compré más de 10 unidades
create or replace view prodcarne as
select id, p.producto.extract('/productos/producto/nombre/text()').getStringVal() 
from product p where p.producto.extract('/productos/producto/tipo_prod/text()').getStringVal() = 'Carne' 
and  p.producto.extract('/productos/producto/cantidad/text()').getStringVal() > 10;/


--Obtener el total de tipos de producto que tengan una cantidad mayor o igual a 5 y menor o igual a 15.
create or replace view prodtotales as
select count(*) as total_productos, p.producto.extract('/productos/producto/tipo_prod/text()').getStringVal() as tipo_producto
from product p where p.producto.extract('/productos/producto/cantidad/text()').getStringVal() <= 15
and p.producto.extract('/productos/producto/cantidad/text()').getStringVal() >= 5
group by p.producto.extract('/productos/producto/tipo_prod/text()').getStringVal();
/



----------------
--XML Alberto
----------------
DROP TABLE Incidencias_tab FORCE;
/

begin
    dbms_xmlschema.registerschema(schemaurl=>'Incidencias.xsd', 
    schemadoc=> '<?xml version="1.0" encoding="UTF-8"?> 
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="incidencia" type="Incidencia">
    <xs:key name= "ID">
        <xs:selector xpath= "xs:Incidencia" />
		<xs:field xpath="xs:IDIncidencia"/> 
    </xs:key>
</xs:element>

<xs:complexType name="Incidencia">
	<xs:sequence>
		<xs:element name="IDIncidencia" type="xs:integer" />
        <xs:element name="IDPedido" type="xs:integer" />
		<xs:element name="causa" type="Causa" minOccurs="1"/>
		<xs:element name="administrador" type="Administrador" minOccurs="1" maxOccurs="unbounded"/>
		<xs:element name="estado" type="Estado" />
        <xs:element name="comentario" type="Comentario" maxOccurs="unbounded" />
	</xs:sequence>
</xs:complexType>

<xs:complexType name="Causa">
		<xs:sequence>
			<xs:element name="tipo">
				<xs:simpleType>
					<xs:restriction base="xs:string">
						<xs:enumeration value="Pedido"/>
						<xs:enumeration value="Pago"/>
					</xs:restriction>
				</xs:simpleType>
			</xs:element>
			<xs:element name="descripcion" type="xs:string"/>
			<xs:element name="fecha" type="xs:date"/>
		</xs:sequence>
</xs:complexType>

<xs:complexType name="Administrador">
	<xs:sequence>
        <xs:element name="nombre" type="xs:string"/>
            <xs:element name="DNI">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
						<xs:length value="9"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:element>
        <xs:element name="numeroSS" type="xs:string"/>
	</xs:sequence>
</xs:complexType>

<xs:complexType name="Estado">
	<xs:sequence>
		<xs:element name="estado_actual">
			<xs:simpleType>
				<xs:restriction base="xs:string">
					<xs:enumeration value="Iniciada"/>
					<xs:enumeration value="En proceso"/>
					<xs:enumeration value="Resuelto_Aceptado"/>
					<xs:enumeration value="Resuelto_Rechazado"/>
					<xs:enumeration value="Cancelado"/>
				</xs:restriction>
			</xs:simpleType>
		</xs:element>
        <xs:element name="ultima_modificacion" type="xs:date"/>
	</xs:sequence>
	
	
</xs:complexType>

<xs:complexType name="Comentario">
		<xs:sequence>
			<xs:element name="texto" type="xs:string"/>
			<xs:element name="fecha" type="xs:date"/>
		</xs:sequence>
</xs:complexType>

</xs:schema>',
local=> true, gentypes => false, genbean=> false, gentables=> false, force => false, 
options => dbms_xmlschema.register_binaryxml, owner=> user);

commit;

end;
/
DROP TABLE  Incidencias_tab FORCE;
CREATE TABLE Incidencias_tab (ID NUMBER, DATOS XMLTYPE)
  XMLTYPE COLUMN DATOS STORE AS BINARY XML
  XMLSCHEMA "Incidencias.xsd" ELEMENT "incidencia";
/

/
COMMIT;
/
insert into INCIDENCIAS_TAB values (1, '<?xml version="1.0" encoding="UTF-8"?>
<incidencia>
    <IDIncidencia>1</IDIncidencia>
    <IDPedido>1</IDPedido>
	<causa>
        <tipo>Pedido</tipo>
		<descripcion>Falta varias partes del pedido</descripcion>
		<fecha>2021-09-12</fecha>
	</causa>

	<administrador>
		<nombre>Perico Martinez</nombre>
		<DNI>29457381G</DNI>
		<numeroSS>134345343</numeroSS>
	</administrador>

	<estado>
		<estado_actual>En proceso</estado_actual>
        <ultima_modificacion>2021-09-16</ultima_modificacion>
	</estado>			
    
    <comentario>
		<texto>Se ha iniciado el proceso de pago</texto>
        <fecha>2021-09-16</fecha>
	</comentario>	
    <comentario>
		<texto>Se necesita mas informacion sobre las partes restante</texto>
        <fecha>2021-09-16</fecha>
	</comentario>
</incidencia>');
/	
        
insert into INCIDENCIAS_TAB values (2, '<?xml version="1.0" encoding="UTF-8"?>
<incidencia>
    <IDIncidencia>2</IDIncidencia>
    <IDPedido>2</IDPedido>
	<causa>
        <tipo>Pago</tipo>
		<descripcion>No se ha devuelto todo el dinero</descripcion>
		<fecha>2021-08-14</fecha>
	</causa>

	<administrador>
		<nombre>Perico Martinez</nombre>
		<DNI>29457381G</DNI>
		<numeroSS>134345343</numeroSS>
	</administrador>

	<estado>
		<estado_actual>Resuelto_Aceptado</estado_actual>
        <ultima_modificacion>2021-08-17</ultima_modificacion>
	</estado>	
    <comentario>
		<texto>Se ha iniciado el proceso de pago</texto>
        <fecha>2021-08-16</fecha>
	</comentario>	
    <comentario>
		<texto>Se ha comprobado que el cliente lleva razon. Se devolvera el dinero restante</texto>
        <fecha>2021-09-16</fecha>
	</comentario>	
</incidencia>');
/		
         
        
insert into INCIDENCIAS_TAB values (3, '<?xml version="1.0" encoding="UTF-8"?>
<incidencia>
    <IDIncidencia>3</IDIncidencia>
    <IDPedido>3</IDPedido>
	<causa>
        <tipo>Pedido</tipo>
		<descripcion>La hamburguesa no contenia bacon</descripcion>
		<fecha>2021-05-16</fecha>
	</causa>

	<administrador>
		<nombre>Adolfo Cabrales</nombre>
		<DNI>31343312E</DNI>
		<numeroSS>42422452</numeroSS>
	</administrador>

	<estado>
		<estado_actual>Resuelto_Aceptado</estado_actual>
        <ultima_modificacion>2021-05-12</ultima_modificacion>
	</estado>		
    <comentario>
		<texto>Se ha iniciado el proceso</texto>
        <fecha>2021-08-16</fecha>
	</comentario>	
    <comentario>
		<texto>Se ha comprobado que el cliente lleva razon. Se le suministrara un cupon</texto>
        <fecha>2021-09-16</fecha>
	</comentario>	
</incidencia>');
/		
        
insert into INCIDENCIAS_TAB values (4, '<?xml version="1.0" encoding="UTF-8"?>
<incidencia>
    <IDIncidencia>4</IDIncidencia>
    <IDPedido>4</IDPedido>
	<causa>
        <tipo>Pago</tipo>
		<descripcion>Pago realizado, pero el pedido se ha cancelado</descripcion>
		<fecha>2021-06-03</fecha>
	</causa>

	<administrador>
		<nombre>Sandra Garrido</nombre>
		<DNI>13424423K</DNI>
		<numeroSS>314234211</numeroSS>
	</administrador>

	<estado>
		<estado_actual>Cancelado</estado_actual>
        <ultima_modificacion>2021-06-10</ultima_modificacion>
	</estado>		
    <comentario>
		<texto>Se ha iniciado el proceso de pago</texto>
        <fecha>2021-08-16</fecha>
	</comentario>	
    <comentario>
		<texto>El cliente ha cancelado la incidencia</texto>
        <fecha>2021-09-16</fecha>
	</comentario>	
</incidencia>');
/	

COMMIT;

/



--Consultas

UPDATE INCIDENCIAS_TAB 
SET datos = INSERTCHILDXML(datos, '/incidencia', 'comentario', xmltype('   
    <comentario>
		<texto>Se ha iniciado el proceso de pago</texto>
        <fecha>2021-08-16</fecha>
	</comentario>	
    '))
WHERE id = 4;
/

CREATE OR REPLACE VIEW vista_datos_pedido_incidencia_pago AS
Select p.id_pedido, p.precio, p.distancia, p.pagado,
extract(datos,'//causa/tipo/text()').getStringVal() AS "Tipo Incidencia",
extract(datos,'//causa/descripcion/text()').getStringVal()AS "Descripcion Incidencia",
extract(datos,'//administrador/nombre/text()').getStringVal() AS "Nombre administrador",
extract(datos,'//administrador/DNI/text()').getStringVal()AS "DNI Administrador",
extract(datos,'//estado/estado_actual/text()').getStringVal()AS "Estado acual incidencia"
from PEDIDO_TAB p , INCIDENCIAS_TAB i
Where p.id_pedido = extract(i.datos,'//IDPedido/text()').getStringVal()
and extract(datos, '/incidencia/causa/tipo/text()').getStringVal() = 'Pago';

/
  

								       
CREATE OR REPLACE VIEW INCIDENCIA_NECESITA_REVISIO AS 
  SELECT id as id,
    EXTRACTVALUE(datos, '/incidencia/estado/estado_actual') as estado_actual,
    
    XMLQuery(
    'for $i in /incidencia
    let $date := xs:dateTime($i/estado/ultima_modificacion)
    let $status := $i/estado/estado_actual
    where  $date <xs:dateTime("2021-06-13")
    return 
        <Revision>
            <Estado>{$status}</Estado>
            <Ultima_modificacion>{$date}</Ultima_modificacion>
            <Necesita_Revision>
               {
               if ($status = "Iniciada" or $status = "En proceso" ) 
                then "true" 
                else "false"
               }
            </Necesita_Revision>
        </Revision>' PASSING datos RETURNING CONTENT) "Necesita_REV"
   FROM incidencias_tab
   WHERE extract(datos, '/incidencia/causa/tipo/text()').getStringVal() = 'Pedido'
   ;
/
								       
CREATE OR REPLACE VIEW GET_STATS_FROM_INCIDENCIAS AS
SELECT 
    COUNT ( 
        CASE WHEN 
            extract(datos,'//causa/tipo/text()').getStringVal() = 'Pago'
        THEN 1 ELSE null END
    ) "Tipo Pago", 

    SUM(extract(datos,'count(/incidencia/causa[tipo="Pago"]/../comentario)').getStringVal()) 
    AS "Num Comentarios Pago",
    
    COUNT (
        CASE WHEN 
            extract(datos,'//causa/tipo/text()').getStringVal() = 'Pedido'   
        THEN 1 ELSE null END
    ) "Tipo Pedido",
    
    SUM(extract(datos,'count(/incidencia/causa[tipo="Pedido"]/../comentario)').getStringVal()) 
    AS "Num Comentarios Pedido"
FROM INCIDENCIAS_TAB  i ; 								       
/								       
								       
								       
								       
								       




----------------
--XML Carlos
----------------
DROP table taller_tab force;/

BEGIN
DBMS_XMLSCHEMA.REGISTERSCHEMA(SCHEMAURL=>'Taller.xsd',
SCHEMADOC=>'<?xml version="1.0" encoding="utf-8"?>
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
        <xs:element name="taller" type="Taller">
            <xs:key name= "Id">
                <xs:selector xpath= "xs:Taller" />
                <xs:field xpath="xs:Id_taller"/> 
            </xs:key>
        </xs:element>

<xs:complexType name="Taller">
  <xs:sequence>
    <xs:element name="Id_taller" type="xs:integer"/>
    <xs:element name="Nombre" type="xs:string"/>
    <xs:element name="Direccion" type="xs:string"/>
    <xs:element name="CodigoPostal">
        <xs:simpleType>  
            <xs:restriction base="xs:positiveInteger">
                    <xs:totalDigits value="5" />
            </xs:restriction>
        </xs:simpleType>
    </xs:element>
    <xs:element name="admin" type="administrador" minOccurs="1"/>
    <xs:element name="st" type="estadoTaller" minOccurs="1" maxOccurs="2"/>
    <xs:element name="ab" type="abogado" minOccurs="1" maxOccurs="30"/>
  </xs:sequence>
</xs:complexType>

<xs:complexType name="administrador">
	<xs:sequence>
    <xs:element name="Nombre" type="xs:string"/>
    <xs:element name="Apellidos" type="xs:string"/>
    <xs:element name="DNI" type="xs:string"/>
    <xs:element name="ExperienciaLaboral">
        <xs:simpleType>  
            <xs:restriction base="xs:positiveInteger">
                    <xs:totalDigits value="2" />
            </xs:restriction>
        </xs:simpleType>
    </xs:element>
    </xs:sequence>
</xs:complexType>

<xs:complexType name="estadoTaller">
	<xs:sequence>
		<xs:element name="estado_taller">
			<xs:simpleType>
				<xs:restriction base="xs:string">
					<xs:enumeration value="Libre"/>
					<xs:enumeration value="Ocupado"/>
					<xs:enumeration value="Cerrado"/>
				</xs:restriction>
			</xs:simpleType>
		</xs:element>
	</xs:sequence>
</xs:complexType>

<xs:complexType name="abogado">
	<xs:sequence>
    <xs:element name="Nombre" type="xs:string"/>
    <xs:element name="Apellidos" type="xs:string"/>
    <xs:element name="DNI" type="xs:string"/>
    <xs:element name="NumeroSS" type="xs:string"/>
    <xs:element name="ExperienciaLaboral">
        <xs:simpleType>  
            <xs:restriction base="xs:positiveInteger">
                    <xs:totalDigits value="2" />
            </xs:restriction>
        </xs:simpleType>
    </xs:element>
    <xs:element name="case" type="caso" minOccurs="1" maxOccurs="5"/>
    </xs:sequence>
</xs:complexType>

<xs:complexType name="caso">
    <xs:sequence>
       <xs:element name="ID" type="xs:integer"/>
       <xs:element name="Fecha" type="xs:date"/>
       <xs:element name="Nombre" type="xs:string"/>
    </xs:sequence>
</xs:complexType>

</xs:schema>', LOCAL=>true, GENTYPES=>false, GENBEAN=>false,
GENTABLES=>false,
 FORCE=>false, OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML,
OWNER=>USER);
commit;
end;
/

CREATE TABLE taller_tab (Id NUMBER, taller XMLTYPE)
  XMLTYPE COLUMN taller STORE AS BINARY XML
  XMLSCHEMA "Taller.xsd" ELEMENT "taller"
/
insert into TALLER_TAB values (1,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
    <Id_taller>1</Id_taller>
    <Nombre>Talleres Antonio</Nombre>
    <Direccion>Calle Sanchez 23</Direccion>
    <CodigoPostal>8</CodigoPostal>
    
    <admin>
        <Nombre>John</Nombre>
        <Apellidos>Garcia Garcia</Apellidos>
        <DNI>4936672P</DNI>
        <ExperienciaLaboral>1</ExperienciaLaboral>
    </admin>
    
    <st>
        <estado_taller>Libre</estado_taller>
    </st>
    
    <ab>
        <Nombre>Ramon</Nombre>
        <Apellidos>Sanchez Rodriguez</Apellidos>
        <DNI>7136622P</DNI>
        <NumeroSS>32165198165198</NumeroSS>
        <ExperienciaLaboral>6</ExperienciaLaboral>
        
        <case>
            <ID>1</ID>
            <Fecha>2021-03-19</Fecha>
            <Nombre>TalleresAntonioContraNavarro</Nombre>
            
        </case>
    </ab>
</taller>');
/

insert into TALLER_TAB values (2,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
  <Id_taller>2</Id_taller>
  <Nombre>ReparaCar</Nombre>
  <Direccion>Calle Benito 2</Direccion>
  <CodigoPostal>36</CodigoPostal>
  <admin>
    <Nombre>Julian</Nombre>
    <Apellidos>Carro Sanchez</Apellidos>
    <DNI>4139677P</DNI>
    <ExperienciaLaboral>12</ExperienciaLaboral>
  </admin>
  <st>
    <estado_taller>Ocupado</estado_taller>
  </st>
  <ab>
    <Nombre>Julio</Nombre>
    <Apellidos>Rodriguez Alvarez</Apellidos>
    <DNI>7030329Z</DNI>
    <NumeroSS>14160998169133</NumeroSS>
    <ExperienciaLaboral>8</ExperienciaLaboral>
    <case>
      <ID>34</ID>
      <Fecha>2021-08-20</Fecha>
      <Nombre>ReparaCar34</Nombre>
    </case>
    <case>
      <ID>35</ID>
      <Fecha>2021-09-30</Fecha>
      <Nombre>ReparaCar35</Nombre>
    </case>
  </ab>
</taller>');
/


insert into TALLER_TAB values (3,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
  <Id_taller>3</Id_taller>
  <Nombre>ReparaCar</Nombre>
  <Direccion>Calle Benito 36</Direccion>
  <CodigoPostal>156</CodigoPostal>
  <admin>
    <Nombre>Pepe</Nombre>
    <Apellidos>Carro Sanchez</Apellidos>
    <DNI>4938676J</DNI>
    <ExperienciaLaboral>18</ExperienciaLaboral>
  </admin>
  <st>
    <estado_taller>Libre</estado_taller>
  </st>
  <ab>
    <Nombre>Ramon</Nombre>
    <Apellidos>Ramirez Cifuentes</Apellidos>
    <DNI>3610900B</DNI>
    <NumeroSS>83161988769073</NumeroSS>
    <ExperienciaLaboral>32</ExperienciaLaboral>
    <case>
      <ID>80</ID>
      <Fecha>2019-07-28</Fecha>
      <Nombre>ReparaCar80</Nombre>
    </case>
  </ab>
</taller>');
/

insert into TALLER_TAB values (4,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
  <Id_taller>4</Id_taller>
  <Nombre>Talleres Joaquin</Nombre>
  <Direccion>Avenida España 19</Direccion>
  <CodigoPostal>346</CodigoPostal>
  <admin>
    <Nombre>Joaquin</Nombre>
    <Apellidos>Gamez Moro</Apellidos>
    <DNI>7931677Z</DNI>
    <ExperienciaLaboral>15</ExperienciaLaboral>
  </admin>
  <st>
    <estado_taller>Cerrado</estado_taller>
  </st>
  <ab>
    <Nombre>Cristian</Nombre>
    <Apellidos>Lopez Cifuentes</Apellidos>
    <DNI>1696996P</DNI>
    <NumeroSS>93160923366090</NumeroSS>
    <ExperienciaLaboral>19</ExperienciaLaboral>
    <case>
      <ID>33</ID>
      <Fecha>2001-08-30</Fecha>
      <Nombre>TalleresJoaquinContraAnastasia</Nombre>
    </case>
  </ab>
</taller>');
/
insert into TALLER_TAB values (5,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
  <Id_taller>5</Id_taller>
  <Nombre>ReparaCar</Nombre>
  <Direccion>Avenida España 37</Direccion>
  <CodigoPostal>1862</CodigoPostal>
  <admin>
    <Nombre>Benito</Nombre>
    <Apellidos>Perez Navarro</Apellidos>
    <DNI>0811673J</DNI>
    <ExperienciaLaboral>18</ExperienciaLaboral>
  </admin>
  <st>
    <estado_taller>Libre</estado_taller>
  </st>
  <ab>
    <Nombre>Eddieson</Nombre>
    <Apellidos>Ledesma Sirac</Apellidos>
    <DNI>3093790M</DNI>
    <NumeroSS>69170903636801</NumeroSS>
    <ExperienciaLaboral>39</ExperienciaLaboral>
    <case>
      <ID>156</ID>
      <Fecha>2003-03-13</Fecha>
      <Nombre>ReparaCar156</Nombre>
    </case>
    <case>
      <ID>190</ID>
      <Fecha>2004-09-02</Fecha>
      <Nombre>ReparaCar190</Nombre>
    </case>
    <case>
      <ID>300</ID>
      <Fecha>2008-01-02</Fecha>
      <Nombre>ReparaCar300</Nombre>
    </case>
     <case>
      <ID>308</ID>
      <Fecha>2008-12-24</Fecha>
      <Nombre>ReparaCar308</Nombre>
    </case>
  </ab>
</taller>');
/

insert into TALLER_TAB values (6,'<?xml version="1.0" encoding="UTF-8"?> 
<taller>
    <Id_taller>6</Id_taller>
    <Nombre>Taller Ramon</Nombre>
    <Direccion>Avenida de la Alegria 48</Direccion>
    <CodigoPostal>2369</CodigoPostal>
    
    <admin>
        <Nombre>Ramon</Nombre>
        <Apellidos>Piernas Sarrion</Apellidos>
        <DNI>9761671J</DNI>
        <ExperienciaLaboral>1</ExperienciaLaboral>
    </admin>
    
    <st>
        <estado_taller>Ocupado</estado_taller>
    </st>
    
    <ab>
        <Nombre>Cristian</Nombre>
        <Apellidos>Sarrion Ramos</Apellidos>
        <DNI>8903711L</DNI>
        <NumeroSS>29396913536481</NumeroSS>
        <ExperienciaLaboral>45</ExperienciaLaboral>
        
        <case>
            <ID>99</ID>
            <Fecha>2008-04-16</Fecha>
            <Nombre>TalleresRamonContraLaDespensa</Nombre>
            
        </case>
    </ab>
</taller>');
/

--Obtener Nombre, apellidos y nombre del caso de los abogados que llevan Reparacar y no esten cerrados
create or replace view Casos_Talleres_ReparacarNoCerrados as
select Id, t.taller.extract('/taller/ab/Nombre/text()').getStringVal()  "Nombre Administrador",t.taller.extract('/taller/ab/Apellidos/text()').getStringVal() "Apellidos", t.taller.extract('/taller/ab/case/Nombre/text()').getStringVal() "Nombre Caso"
from taller_tab t
where t.taller.extract('/taller/Nombre/text()').getStringVal() = 'ReparaCar' and t.taller.extract('/taller/st/estado_taller/text()').getStringVal() != 'Cerrado'  ;
/

--Obtener los talleres que estan ocupados(SE DEBERIA DE PODER QUITAR EL XMLTYPE DE ESTA OCUPADO)
create or replace view TalleresOcupados as
select id as id, t.taller.extract('/taller/Nombre/text()').getStringVal() "Nombre Taller", 
XMLQUERY(
'for $i in /taller/st
return
<estado>
{
if ($i/estado_taller="Ocupado")
then "true"
else "false"
}
</estado>
'PASSING taller RETURNING CONTENT) "Esta Ocupado"
from taller_tab t;
/

--Obtener el numero de casos que tiene ReparaCar
create or replace view CasosReparaCar2008 as
SELECT COUNT 
(CASE WHEN 
t.taller.extract('/taller/ab/case/ID/text()').getStringVal() > 0 
and 
t.taller.extract('/taller/ab/case/Fecha/text()').getStringVal() > '2008-01-01'  
THEN 1 
ELSE NULL 
END ) "Casos de 2008 ReparaCar"
FROM TALLER_TAB t
WHERE t.taller.extract('/taller/Nombre/text()').getStringVal() = 'ReparaCar';
/


--Un Update 
UPDATE TALLER_TAB
SET taller= INSERTCHILDXML(taller , '/taller' , 'ab' , xmltype('
    <ab>
        <Nombre>Jesus</Nombre>
        <Apellidos>Sanchez Cebrian</Apellidos>
        <DNI>0103669U</DNI>
        <NumeroSS>69096911596387</NumeroSS>
        <ExperienciaLaboral>15</ExperienciaLaboral>
        
        <case>
            <ID>208</ID>
            <Fecha>2021-04-16</Fecha>
            <Nombre>TalleresRamonContraLaDespensa</Nombre>
            
        </case>
    </ab>
'))
Where id = 2;
/

