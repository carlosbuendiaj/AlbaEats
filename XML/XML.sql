-----------------
--XML alfonso
----------------

--TABLA PROVEEDORES


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
ELEMENT "proveedores";
/
-----------------
--XML Alberto
----------------


begin
    dbms_xmlschema.registerschema(schemaurl=>'Incidencias.xsd', 
    schemadoc=> '<?xml version="1.0" encoding="UTF-8"?> 
<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
<xs:element name="incidencias" type="Incidencia">
    <xs:key name= "ID">
        <xs:selector xpath= "xs:Incidencia" />
		<xs:field xpath="xs:IDIncidencia"/> 

    </xs:key>
</xs:element>

<xs:complexType name="Incidencia">
	<xs:sequence>
		<xs:element name="IDIncidencia" type="xs:integer" />
		<xs:element name="causa" type="Causa" minOccurs="1"/>
		<xs:element name="administrador" type="Administrador" minOccurs="1" maxOccurs="unbounded"/>
		<xs:element name="impositor" type="Estado" />
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
			<xs:element name="Descripcion" type="xs:string"/>
			<xs:element name="Fecha" type="xs:string"/>
		</xs:sequence>
</xs:complexType>

<xs:complexType name="Administrador">
	<xs:sequence>
        <xs:element name="Nombre" type="xs:string"/>
            <xs:element name="DNI">
                <xs:simpleType>
                    <xs:restriction base="xs:string">
						<xs:length value="9"/>
                    </xs:restriction>
                </xs:simpleType>
            </xs:element>
        <xs:element name="NumeroSS" type="xs:string"/>
	</xs:sequence>
</xs:complexType>

<xs:complexType name="Estado">
	<xs:sequence>
		<xs:element name="Estado">
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
	</xs:sequence>
	
	
</xs:complexType>

</xs:schema>',
local=> true, gentypes => false, genbean=> false, gentables=> false, force => false, 
options => dbms_xmlschema.register_binaryxml, owner=> user);

commit;

end;











----------------------------------
-- INSERT XML
-------------------------------


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
    </proveedores>');

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
    </proveedores>');
	
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
    </proveedores>');


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
    </proveedores>');
	
	
--INDICES	
create index idx_proveedor ON ddbblocal.provrest(proveedor) INDEXTYPE IS
XDB.XMLINDEX PARAMETERS ('PATHS (INCLUDE (/proveedores/proveedor/dni))');


--Mostrar valor
select extract(proveedor, '/proveedores/proveedor/dni/text()') 
from provrest p where id = 4;

select
id, r.proveedor.extract('/proveedores/proveedor').getStringVal() 
from provrest r where id = 2;



--Consultas

select id, p.proveedor.extract('/proveedores/proveedor/nombre/text()').getStringVal() 
from provrest p where p.proveedor.extract('/proveedores/proveedor/ciudad/text()').getStringVal() = 'Cuenca';









