-- =============================================================================
-- REVISIÓN PARA LA PRUEBA 1: TÓPICOS AVANZADOS DE DATOS
-- Este script incluye consultas SQL, subconsultas, vistas, bloques PL/SQL,
-- manejo de excepciones, cursores explícitos y objetos de bases de datos.
-- =============================================================================

--------------------------------------------------------------------------------
-- 1. CONSULTAS SQL Y SUBCONSULTAS
--------------------------------------------------------------------------------

-- Ejemplo 1: Lista los clientes con pedidos superiores al promedio[cite: 2].
SELECT Nombre
FROM Clientes
WHERE ClienteID IN (
    SELECT ClienteID
    FROM Pedidos
    WHERE Total > (SELECT AVG(Total) FROM Pedidos)
);

-- Ejemplo 2: Cuenta los pedidos por ciudad usando una vista[cite: 2].
CREATE OR REPLACE VIEW PedidosPorCiudad AS
SELECT c.Ciudad, COUNT(p.PedidoID) AS TotalPedidos
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Ciudad;

SELECT * FROM PedidosPorCiudad;

--------------------------------------------------------------------------------
-- 2. BLOQUES ANÓNIMOS Y EXCEPCIONES
--------------------------------------------------------------------------------

-- Ejemplo 1: Bloque con estructura CASE y excepción predefinida[cite: 2].
DECLARE
    v_total NUMBER := 600;
    v_clasificacion VARCHAR2(20);
BEGIN
    v_clasificacion := CASE
        WHEN v_total > 1000 THEN 'Alto'
        WHEN v_total > 500 THEN 'Medio'
        ELSE 'Bajo'
    END;
    DBMS_OUTPUT.PUT_LINE('Clasificación: ' || v_clasificacion);
EXCEPTION
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Problema con los datos.');
END;
/

-- Ejemplo 2: Excepción de TimesTen (Violación de clave única TT8001)[cite: 2].
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -8001);
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad)
    VALUES (1, 'Carlos Ruiz', 'Concepción'); -- Simula que ID 1 ya existe
    DBMS_OUTPUT.PUT_LINE('Inserción exitosa.');
EXCEPTION
    WHEN unique_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violación de clave única (TT8001).');
END;
/

--------------------------------------------------------------------------------
-- 3. CURSORES EXPLÍCITOS
--------------------------------------------------------------------------------

-- Ejemplo: Actualización masiva de precios usando FOR UPDATE[cite: 2].
DECLARE
    CURSOR producto_cursor IS
        SELECT ProductoID, Precio
        FROM Productos
        WHERE Precio < 1000
        FOR UPDATE;
    v_productoid NUMBER;
    v_precio NUMBER;
BEGIN
    OPEN producto_cursor;
    LOOP
        FETCH producto_cursor INTO v_productoid, v_precio;
        EXIT WHEN producto_cursor%NOTFOUND;
        
        UPDATE Productos
        SET Precio = v_precio * 1.1
        WHERE CURRENT OF producto_cursor;
        
        DBMS_OUTPUT.PUT_LINE('Producto ' || v_productoid || ' actualizado.');
    END LOOP;
    CLOSE producto_cursor;
END;
/

--------------------------------------------------------------------------------
-- 4. EJERCICIOS PRÁCTICOS DE CURSORES
--------------------------------------------------------------------------------

-- Ejercicio 3: Listar clientes con total de pedidos mayor a 1000[cite: 2].
DECLARE
    CURSOR cliente_cursor IS
        SELECT c.Nombre AS NombreCliente, SUM(p.Total) AS TotalPedidos
        FROM Clientes c
        JOIN Pedidos p ON c.ClienteID = p.ClienteID
        GROUP BY c.Nombre
        HAVING SUM(p.Total) > 1000;
    v_nombre_cliente Clientes.Nombre%TYPE;
    v_total_pedidos NUMBER;
BEGIN
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_nombre_cliente, v_total_pedidos;
        EXIT WHEN cliente_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cliente || ', Total: ' || v_total_pedidos);
    END LOOP;
    CLOSE cliente_cursor;
END;
/

-- Ejercicio 4: Actualizar cantidad en DetallesPedidos (Fechas < 02-Mar-2025)[cite: 2].
DECLARE
    CURSOR detalle_cursor IS
        SELECT dp.DetalleID, dp.Cantidad
        FROM DetallesPedidos dp
        JOIN Pedidos p ON dp.PedidoID = p.PedidoID
        WHERE p.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
        FOR UPDATE OF dp.Cantidad;
    v_detalle_id DetallesPedidos.DetalleID%TYPE;
    v_cantidad DetallesPedidos.Cantidad%TYPE;
BEGIN
    OPEN detalle_cursor;
    LOOP
        FETCH detalle_cursor INTO v_detalle_id, v_cantidad;
        EXIT WHEN detalle_cursor%NOTFOUND;
        
        UPDATE DetallesPedidos
        SET Cantidad = v_cantidad + 1
        WHERE CURRENT OF detalle_cursor;
    END LOOP;
    CLOSE detalle_cursor;
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        IF detalle_cursor%ISOPEN THEN CLOSE detalle_cursor; END IF;
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--------------------------------------------------------------------------------
-- 5. OBJETOS DE BASE DE DATOS
--------------------------------------------------------------------------------

-- Creación de tipo de objeto y tabla basada en objeto[cite: 2].
CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || TO_CHAR(cliente_id) || ', Nombre: ' || nombre;
    END get_info;
END;
/

-- Creación de tabla y transferencia de datos[cite: 2].
CREATE TABLE Clientes_Obj OF cliente_obj (cliente_id PRIMARY KEY);

INSERT INTO Clientes_Obj (cliente_id, nombre)
SELECT ClienteID, Nombre FROM Clientes;

-- Listar información usando cursor y método del objeto[cite: 2].
DECLARE
    CURSOR cliente_cursor IS
        SELECT VALUE(c) FROM Clientes_Obj c;
    v_cli_obj cliente_obj;
BEGIN
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_cli_obj;
        EXIT WHEN cliente_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cli_obj.get_info());
    END LOOP;
    CLOSE cliente_cursor;
END;
/