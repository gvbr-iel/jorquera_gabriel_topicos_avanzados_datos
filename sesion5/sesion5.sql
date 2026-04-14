--docker exec -it oracle_db_course sqlplus -s jorquera/curso2025@//localhost:1521/XEPDB1

--Revisión de bloques anónimos en PL/SQL
DECLARE 
    v_total NUMBER;
    v_cliente_id NUMBER := 1;
    v_cliente_nombre VARCHAR2(50);
BEGIN
    SELECT Nombre INTO v_cliente_nombre
    FROM Clientes
    WHERE ClienteID = v_cliente_id;

    BEGIN
        SELECT SUM(total) INTO v_total
        FROM Pedidos
        WHERE ClienteID = v_cliente_id;

        DBMS_OUTPUT.PUT_LINE('Total gastado por el cliente ' || v_cliente_nombre || ': ' || NVL(v_total, 0));
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || v_cliente_nombre);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
    END;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontró el cliente con ID ' || v_cliente_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);

END;
/

--Manipulación avanzada de bloques anónimos
--Variables complejas: Uso de tipos de registro (%ROWTYPE) y tablas anidadas.
--Estructuras de control avanzadas: Bucles anidados, manejo de excepciones dentro de bucles, etc. Condicionales múltiples con CASE.

--Ejemplo 1
DECLARE
    v_cliente Clientes%ROWTYPE;
BEGIN
    SELECT * INTO v_cliente
    FROM Clientes
    WHERE ClienteID = 1;

    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente.Nombre || ', Ciudad: ' || v_cliente.Ciudad);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cliente no encontrado');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/

--Ejemplo 2
DECLARE
    v_total NUMBER := 600;
    v_clasificacion VARCHAR2(20);
BEGIN
    v_clasificacion := CASE
        WHEN v_total > 1000 THEN 'Alto'
        WHEN v_total > 500 THEN 'Medio'
        ELSE 'Bajo'
    END;
    DBMS_OUTPUT.PUT_LINE('La clasificación del cliente es: ' || v_clasificacion);
END;
/

--Introducción a cursores explicitos
--Definición: Un cursor es un puntero que permite procesar filas devueltas por una consulta SQL una por una).
--Tipos: Implícitos (Manejados por PL/SQL) y Explícitos (Definidos por el programador y controlados manualmente).

--Cursores explícitos: Se declaran, abren, se leen con FETCH, y se cierran manualmente.
/*

DECLARE
    CURSOR nombre_cursor IS consulta;
BEGIN
    OPEN nombre_cursor;
    --Procesar filas con FETCH
    CLOSE nombre_cursor;
END;

*/

--Ejemplo de cursor explícito
DECLARE
    CURSOR clientes_cursor IS
        SELECT ClienteID, Nombre
        FROM Clientes;
    v_id NUMBER;
    v_nombre VARCHAR2(50);
BEGIN
    OPEN clientes_cursor;
    LOOP
        FETCH clientes_cursor INTO v_id, v_nombre;
        EXIT WHEN clientes_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || v_id || ', Nombre: ' || v_nombre);
    END LOOP;
    CLOSE clientes_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
END;
/

--Aplicación de cursores explícitos
--Uso avanzado de cursores: Combinación con estructuras de control y manejo de excepciones. Uso de parámetros en cursores para filtrar datos.

--Ejemplo 1
DECLARE 
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE ClienteID = p_cliente_id;
    v_pedido_id NUMBER;
    v_total NUMBER;
BEGIN
    OPEN pedido_cursor(2);
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ', Total: ' || v_total);
    END LOOP;
    CLOSE pedido_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
    IF pedido_cursor%ISOPEN THEN
        CLOSE pedido_cursor;
    END IF;
END;
/

--Ejemplo 2
DECLARE
    CURSOR pedidos_cursor IS
        SELECT PedidoID, Total
        FROM Pedidos
        WHERE total < 6000
        FOR UPDATE; --Permite actualizar los registros seleccionados
    v_pedido_id NUMBER;
    v_total NUMBER;
BEGIN
    OPEN pedidos_cursor;
    LOOP
        FETCH pedidos_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedidos_cursor%NOTFOUND;
        UPDATE Pedidos
        SET Total = Total * 1.1
        WHERE CURRENT OF pedidos_cursor; --Actualiza la fila actual del cursor
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ' actualizado a Total: ' || (v_total * 1.1));
    END LOOP;
    CLOSE pedidos_cursor;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
    IF pedidos_cursor%ISOPEN THEN
        CLOSE pedidos_cursor;
    END IF;
END;
/

SELECT * FROM Pedidos;

--Práctica

--1. Crear un cursor explicito que liste de menor a mayor a los clientes y la cantidad de pedidos que han hecho
DECLARE
    CURSOR clientes_cant_pedidos IS
        SELECT Nombre, COUNT(PedidoID)
        FROM Clientes c
        LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY Nombre
        ORDER BY  COUNT(PedidoID) ASC;
    v_nombre VARCHAR(50);
    v_cant NUMBER;
BEGIN
    OPEN clientes_cant_pedidos;
    LOOP
        FETCH clientes_cant_pedidos INTO v_nombre, v_cant;
        EXIT WHEN clientes_cant_pedidos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Nombre Cliente: ' || v_nombre || ', Cantidad de pedidos: ' || NVL(v_cant, 0));
    END LOOP;
    CLOSE clientes_cant_pedidos;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrió un error: ' || SQLERRM);
    IF clientes_cant_pedidos%ISOPEN THEN
        CLOSE clientes_cant_pedidos;
    END IF;
END;
/


--2. Crear un cursor explicito que permita aplicar descuento a los pedidos de una ciudad en particular
DECLARE
    CURSOR dcto_ciudad(v_ciudad VARCHAR2) IS
        SELECT PedidoID, Total
        FROM Pedidos p
        INNER JOIN Clientes c ON c.ClienteID = p.ClienteID
        WHERE REGEXP_LIKE(c.Ciudad, v_ciudad)
        FOR UPDATE;
    v_pedido_id NUMBER;
    v_total NUMBER;
BEGIN
    OPEN dcto_ciudad('Coquimbo');
    LOOP
        FETCH dcto_ciudad INTO v_pedido_id, v_total;
        EXIT WHEN dcto_ciudad%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ' valor original: ' || v_total);
        UPDATE Pedidos
        SET Total = Total - (Total * 0.15)
        WHERE CURRENT OF dcto_ciudad;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ' actualizado a Total: ' || (v_total - (v_total * 0.15)));
    END LOOP;
    CLOSE dcto_ciudad;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Ocurrio un error: ' || SQLERRM);
    IF dcto_ciudad%ISOPEN THEN
        CLOSE dcto_ciudad;
    END IF;
END;
/ 

COMMIT;

        

