-----------------
--XML Alfonso
----------------


drop table provrest force;/
drop table product force;/

********************
--TABLA PROVEEDORES
********************

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



*******************
--PRODUCTOS
*******************
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
CREATE TABLE Incidencias_tab (ID NUMBER, DATOS XMLTYPE)
  XMLTYPE COLUMN DATOS STORE AS BINARY XML
  XMLSCHEMA "Incidencias.xsd" ELEMENT "incidencia";
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

CREATE VIEW vista_datos_pedido_incidencia_pago AS
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
								       
CREATE VIEW GET_STATS_FROM_INCIDENCIAS AS
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
								       
								       
DROP table taller_tab force;/

----------------
--XML Carlos
----------------

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
								       




