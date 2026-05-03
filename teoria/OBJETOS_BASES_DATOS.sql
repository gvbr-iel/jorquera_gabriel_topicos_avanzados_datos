--Sesion 6

--Revisión de cursores explicitos
DECLARE
    CURSOR pedido_cursor IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE ClienteID = 1;
    v_pedido_id NUMBER;
    v_total NUMBER;
BEGIN 
    OPEN pedido_cursor;
    LOOP
        FETCH pedido_cursor INTO v_pedido_id, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || ', Total: ' || v_total);
    END LOOP;
    CLOSE pedido_cursor;
END;
/

--Uso de cursores con multiples tablas. Procesamiento condicional y actualizaciones masivas.
DECLARE
    CURSOR ciudad_cursor IS
    SELECT c.Ciudad, SUM(p.Total) AS total_gastado
    FROM Clientes c
    JOIN Pedidos p ON c.ClienteID = p.ClienteID
    GROUP BY c.Ciudad;
    v_ciudad VARCHAR2(50);
    v_total_gastado NUMBER;
BEGIN
    OPEN ciudad_cursor;
    LOOP
        FETCH ciudad_cursor INTO v_ciudad, v_total_gastado;
        EXIT WHEN ciudad_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Ciudad: ' || v_ciudad || ', Total: ' || v_total_gastado);
    END LOOP;
    CLOSE ciudad_cursor;
END;
/

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
            IF v_precio < 50 THEN
            UPDATE Productos
            SET Precio = v_precio * 1.2
            WHERE CURRENT OF producto_cursor;
            DBMS_OUTPUT.PUT_LINE('Precio del producto ' || v_productoid || ' aumentado a ' || (v_precio * 1.2));
        END IF;
    END LOOP;
    CLOSE producto_cursor;
END;
/

--Introdoucción a objetos de bases de datos
--Los objetos de bases de datos son estructuras definidas por el usuario que extienden las capacidades de las bases de datos relacionales,
--como tipos de objetos, tablas basadas en objetos y metodos. 

--Beneficios: Modelado más cerccano a la realidad (por ejemplo, objetos con atributos y comportamientos). Reutilización de código y encapsulación.

CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER, 
    nombre VARCHAR2(50),
    ciudad VARCHAR2(50),
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

CREATE OR REPLACE TYPE BODY cliente_obj AS MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || cliente_id || ', Nombre: ' || nombre || ', Ciudad: ' || ciudad;
    END;
END;
/

--Tipos y utilidad de objetos de bases de datos
--Tipos de objetos: Estructuras personalizadas (como cliente_obj). 
--Tablas que almacenan instancias de tipos de objetos 
--Funciones o procedimientos asociados a objetos. 

--Utilidad: Modelado de datos complejos (por ejemplo, jerarquias o relaciones anidadas)
--Mejora del rendimiento en aplicaciones orientadas a objetos

CREATE TABLE clientes_obj OF cliente_obj (
    cliente_id PRIMARY KEY
);
INSERT INTO clientes_obj VALUES (1, 'Juan Perez', 'Santiago');
INSERT INTO clientes_obj VALUES (2, 'Maria Gomez', 'Valparaiso');
SELECT c.get_info() FROM clientes_obj c;

DECLARE 
    CURSOR cliente_cursor IS
    SELECT VALUE(c) FROM clientes_obj c;
    v_cliente cliente_obj;
BEGIN 
    OPEN cliente_cursor;
    LOOP
        FETCH cliente_cursor INTO v_cliente;
        EXIT WHEN cliente_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(v_cliente.get_info());
    END LOOP;
    CLOSE cliente_cursor;
END;
/
    