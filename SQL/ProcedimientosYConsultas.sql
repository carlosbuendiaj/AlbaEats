--Alberto

--Funcion que, dado un numero de pedido, calcula el precio total del pedido, sumando el precio multiplicado por la cantidad y aplicando el porcentaje IVA.
--Recibe un numero de pedido y devuelve el total.

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
        
        DBMS_OUTPUT.PUT_LINE(CHR(9)|| 'Fecha '|| pfecha ||CHR(9)||'Precio Total: ' || precioCalculado ||'€');
        IF ( pprecio != precioCalculado) then
            DBMS_OUTPUT.PUT_LINE('Precio no coincide, actualizando base de datos');
            UPDATE PEDIDO_TAB x SET precio = precioCalculado WHERE x.id_pedido = pid;
        END IF;
        
        
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('-');
    
END;

                                        
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
     
-- CARLOS

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

--CASO DE PRUEBA:

DECLARE
NombreRestaurante VARCHAR2(100);
IdRestaurante NUMBER;
BEGIN
NombreRestaurante:='Dominos Pizza';
IdRestaurante:=2;

EliminarRestaurante(
NombreRestaurante => NombreRestaurante , IdRestaurante => IdRestaurante
);
END;
