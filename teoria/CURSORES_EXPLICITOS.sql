--Sesion 5
--Revision de blqoues anonimos en PL/SQL

DECLARE
    v_total NUMBER;
    v_cliente_id NUMBER := 1;
BEGIN 
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado por el cliente ' || v_cliente_id || ': ' || NVL(v_total, 0));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente: ' || v_cliente_id);
END;
/

--Manipulacion avanzada de bloques anonimos
--Variables complejas: Uso de tipos de registro (%ROWTYPE) y tablas anidadas
--Estructuras de control avanzadas: Bucles nidados, Condicionales múltiples con CASE.

DECLARE 
    v_cliente Clientes%ROWTYPE;
BEGIN
    SELECT * INTO v_cliente
    FROM Clientes
    WHERE ClienteID = 1;

    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente.Nombre || ', Ciudad: ' || v_cliente.Ciudad);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cliente no encontrado.');
END;
/

DECLARE 
    v_total NUMBER := 600;
    v_clasificacion VARCHAR2(50);
BEGIN
    v_clasificacion := CASE
        WHEN v_total > 1000 THEN 'Alto'
        WHEN v_total > 500 THEN 'Medio'
        ELSE 'Bajo'
    END;
    DBMS_OUTPUT.PUT_LINE('Clasificación del pedido: ' || v_clasificacion);
END;
/

--Introduccion a cursores explicitos
--Un cursor es un puntero qeu permite procesar filas devueltas por una consulta SQL una por una.
--Tipos: Implicitos (manejados por PL/SQL) y explicitos (Definidos y controlados manualmente).
--Cursores explicitos: Se declaran, abren, se leen con FETCH y se cierran manualmente.

DECLARE
    CURSOR cliente_cursor IS 
    SELECT ClienteID, Nombre
    FROM Clientes;
    v_id NUMBER;
    v_nombre VARCHAR2(50);
BEGIN
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_id, v_nombre;
        EXIT WHEN cliente_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ', Nombre: ' || v_nombre);
    END LOOP;
    CLOSE cliente_cursor;
END;
/

--Aplicacion de cursores explicitos: Combinacion de estructuras de control y excepciones. Uso de parametros en cursores para filtrar datos

DECLARE 
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id; 
    v_pedido_id NUMBER;
    v_total NUMBER; 
BEGIN
    OPEN pedido_cursor(1);
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ', Total: ' || v_total);
    END LOOP;
    CLOSE pedido_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        IF pedido_cursor%ISOPEN THEN
        CLOSE pedido_cursor;
        END IF;
END;
/

DECLARE
    CURSOR pedido_cursor IS 
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE Total < 400
    FOR UPDATE;
    v_pedido_id NUMBER;
    v_total NUMBER;
BEGIN 
    OPEN pedido_cursor;
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;
        UPDATE Pedidos
        SET Total = v_total * 1.1
        WHERE CURRENT OF pedido_cursor;
        DBMS_OUTPUT.PUT_LINE('Pedido: ' || v_pedido_id || ' actualizado a ' || (v_total * 1.1));
    END LOOP;
    CLOSE pedido_cursor;
END;
/