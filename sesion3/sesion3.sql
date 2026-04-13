--docker exec -it oracle_db_course bash
--sqlplus -s jorquera/curso2025@//localhost:1521/XEPDB1

--Hola mundo
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hola, bienvenidos a PL/SQL');
END;
/
/*

ESTRUCTURA DE UN BLOQUE PL/SQL
DECLARE (OPCIONAL)
    -- Declaración de variables, cursores, tipos de datos, etc.

BEGIN (OBLIGATORIO)
    -- Código ejecutable: sentencias SQL, lógica de programación, etc.

EXCEPTION (OPCIONAL)
    -- Manejo de excepciones: captura y manejo de errores.
END;
/

*/
--Estructura de un bloque PL/SQL con declaración de variables
DECLARE
    v_mensaje VARCHAR2(50);
BEGIN
    v_mensaje := 'Aprendiendo PL/SQL!';
    DBMS_OUTPUT.PUT_LINE(v_mensaje);
END;
/

--Ejemplo del libro
--Creación de sequencia para generar IDs únicos
/* CREATE SEQUENCE clientes_seq START WITH 3 INCREMENT BY 1; */
/* ALTER SEQUENCE clientes_seq RESTART START WITH 4; -> Alterar la secuencia */ 

DECLARE
    v_NuevaCiudad VARCHAR2(50) := 'Vallenar';
    v_NombreCliente VARCHAR2(50) := 'Mr.Discipline';
BEGIN
    UPDATE Clientes
    SET Ciudad = v_NuevaCiudad
    WHERE REGEXP_LIKE(Nombre, v_NombreCliente, 'i');
    IF SQL%NOTFOUND THEN
        INSERT INTO Clientes VALUES (clientes_seq.NEXTVAL, v_NombreCliente, v_NuevaCiudad, 
        TO_DATE('2000-05-11', 'YYYY-MM-DD'));
    END IF;
END;
/
--Bloques anónimos: Declaración y uso
--Definición: Un bloque anónimo es un bloque PL/SQL que no tiene un nombre y no se almacena en la base de datos.
--Ideal para pruebas rápidas, scripts ad-hoc o tareas que no requieren reutilización.

DECLARE
    v_cliente_id NUMBER := 1;
    v_total_pedidos NUMBER;
    v_nombre_cliente VARCHAR2(50);

BEGIN
    SELECT SUM(Total) INTO v_total_pedidos
    FROM Pedidos 
    WHERE ClienteID = v_cliente_id;

    SELECT Nombre INTO v_nombre_cliente
    FROM Clientes
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado por el cliente: ' || v_nombre_cliente || ': ' || v_total_pedidos);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente de id: ' || v_cliente_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);

END;
/

DECLARE
    v_nombre VARCHAR2(50);
    v_cliente_id NUMBER := 5;

BEGIN
    SELECT Nombre INTO v_nombre
    FROM Clientes
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('El nombre del cliente con ID ' || v_cliente_id || ' es: ' || v_nombre);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró un cliente con ID: ' || v_cliente_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/

--Manejo de variables y constantes en PL/SQL
/* Tipos comunes: NUMBER, VARCHAR2, DATE, BOOLEAN */
/* Constantes: nombre_constante CONSTANT tipo_dato := valor; */

DECLARE
    v_nombre_cliente VARCHAR2(50) := 'Johann';
    v_total_pedidos NUMBER;
    v_descuento NUMBER := 0.1;
BEGIN

    SELECT SUM(Total) INTO v_total_pedidos
    FROM Pedidos
    WHERE ClienteID = (
        SELECT ClienteID
        FROM Clientes
        WHERE Nombre = v_nombre_cliente
    );

    DBMS_OUTPUT.PUT_LINE('Total original de los pedidos: ' || v_total_pedidos);

    DBMS_OUTPUT.PUT_LINE('Total con descuento aplicado: ' || (v_total_pedidos - (v_total_pedidos * v_descuento)));

END;
/

--Estructuras de control en bloques anónimos
--Condicionales: IF, ELSIF, ELSE
DECLARE
    v_total NUMBER := 600;
BEGIN
    IF v_total > 1000 THEN
        DBMS_OUTPUT.PUT_LINE('Pedido grande: ' || v_total);
    ELSIF v_total > 500 THEN
        DBMS_OUTPUT.PUT_LINE('Pedido mediano: ' || v_total);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pedido pequeño: ' || v_total);
    END IF;
END;
/

DECLARE
    v_total NUMBER := 600;
BEGIN
    CASE
        WHEN v_total > 1000 THEN
            DBMS_OUTPUT.PUT_LINE('Pedido grande: ' || v_total);
        WHEN v_total > 1500 THEN
            DBMS_OUTPUT.PUT_LINE('Pedido mediano: ' || v_total);
        ELSE
            DBMS_OUTPUT.PUT_LINE('Pedido pequeño: ' || v_total);
    END CASE;
END;
/

--Bucles: FOR, WHILE, LOOP
DECLARE
    v_contador NUMBER := 0;
    v_max_pedidos NUMBER := 3;
BEGIN
    LOOP
        v_contador := v_contador + 1;
        DBMS_OUTPUT.PUT_LINE('Procesando pedido: ' || v_contador);
        EXIT WHEN v_contador >= v_max_pedidos;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Procesamiento completado.');
END;
/

DECLARE
    v_contador NUMBER := 1;
BEGIN
    WHILE v_contador <= 5 LOOP
        DBMS_OUTPUT.PUT_LINE('Contador: ' || v_contador);
        v_contador := v_contador + 1;
    END LOOP;
END;
/

DECLARE
    v_total_pedidos NUMBER := 5;
BEGIN
    FOR i IN 1..v_total_pedidos LOOP
        DBMS_OUTPUT.PUT_LINE('Procesando pedido número: ' || i);
    END LOOP;
END;
/

--Práctica
--Bloque anónimo para calcular el total de pedidos por los primeros 2 clientes y aplicar un descuento si el total supera los 1000
DECLARE
    v_cliente_id NUMBER := 1;
    v_cliente_nombre VARCHAR2(50);
    v_total_pedidos NUMBER;
    v_descuento CONSTANT NUMBER := 0.15; -- 15% de descuento
BEGIN
    LOOP 
        
        SELECT Nombre INTO v_cliente_nombre
        FROM Clientes
        WHERE ClienteID = v_cliente_id;
        DBMS_OUTPUT.PUT_LINE('Calculando total de pedidos para el cliente: ' || v_cliente_nombre);

        SELECT SUM(Total) INTO v_total_pedidos
        FROM Pedidos
        WHERE ClienteID = v_cliente_id;

        IF v_total_pedidos > 1000 THEN
            DBMS_OUTPUT.PUT_LINE('Total original: ' || v_total_pedidos);
            DBMS_OUTPUT.PUT_LINE('Total con descuento aplicado: ' || (v_total_pedidos - (v_total_pedidos * v_descuento)));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Total de pedidos: ' || v_total_pedidos || '. No se aplica descuento.');
        END IF;

        v_cliente_id := v_cliente_id + 1;
        EXIT WHEN v_cliente_id > 2;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Proceso completado para los primeros 2 clientes.');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/

--Bloque anónimo que clasifica a los productos por la cantidad de ventas
DECLARE
    v_producto_id NUMBER := 1;
    v_producto_nombre VARCHAR2(50);
    v_total_ventas NUMBER;

BEGIN
    LOOP
        SELECT Nombre INTO v_producto_nombre
        FROM Productos
        WHERE ProductoID = v_producto_id;

        SELECT SUM(Cantidad) INTO v_total_ventas
        FROM DetallesPedidos
        WHERE ProductoID = v_producto_id;

        IF v_total_ventas > 5 THEN
            DBMS_OUTPUT.PUT_LINE('Producto: ' || v_producto_nombre || ' - Ventas: ' || v_total_ventas || ' (Producto estrella)');
        ELSIF v_total_ventas > 3 THEN
            DBMS_OUTPUT.PUT_LINE('Producto: ' || v_producto_nombre || ' - Ventas: ' || v_total_ventas || ' (Producto regular)');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Producto: ' || v_producto_nombre || ' - Ventas: ' || v_total_ventas || ' (Producto bajo)');
        END IF;

        v_producto_id := v_producto_id + 1;
        EXIT WHEN v_producto_id > 3;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Proceso de clasificación completado para productos.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/


