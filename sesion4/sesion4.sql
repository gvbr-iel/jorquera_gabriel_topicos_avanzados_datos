--Sesión 4: Excepciones en PL/SQL
-- docker exec -it oracle_db_course sqlplus -s jorquera/curso2025@//localhost:1521/XEPDB1

--Excepciones
--Definición: Una excepción es un evento de error que ocurre durante una ejecución de un programa PL/SQL, interrumpiendo el flujo normal
--Ejemplo: Intentar seleccionar datos que no existen genera un error de "no_data_found".

--Sintáxis
/*

EXCEPTION
    WHEN nombre_exepcion THEN
        --Instrucciones para manejar la excepción

*/

--Ejemplo de manejo de excepciones
DECLARE
    v_nombre VARCHAR2(50);
BEGIN 
    DBMS_OUTPUT.PUT_LINE('Iniciando ejecución');
    SELECT Nombre INTO v_nombre
    FROM Clientes
    WHERE ClienteID = 1; -- Existe
    DBMS_OUTPUT.PUT_LINE('Cliente encontrado: ' || v_nombre);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Cliente no encontrado.');
END;
/

--Tipos de excepciones (Errores comúnes definidos por Oracle)
--Ejemplos comúnes: NO_DATA_FOUND, TOO_MANY_ROWS, ZERO_DIVIDE, VALUE_ERROR, OTHERS

--Tipos de excepciones (Excepciones definidas por el usuario)
--Pasos ara crear una excepción personalizada:
--1. Declarar la excepción en el bloque DECLARE
--2. Lanzar la excepción usando RAISE
--3. Manejar la excepción en el bloque EXCEPTION

--Ejemplo de excepción personalizada
DECLARE 
    v_precio NUMBER;
    precio_invalido EXCEPTION;
BEGIN
    SELECT Precio INTO v_precio
    FROM Productos
    WHERE ProductoID = 1;

    IF v_precio < 0 THEN
        RAISE precio_invalido;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio del producto: ' || v_precio);
EXCEPTION
    WHEN precio_invalido THEN
        DBMS_OUTPUT.PUT_LINE('Error: El precio no puede ser negativo.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado.');
END;
/

--Excepciones TimesTen
--Definición: Es una base de datos en memoria de Oracle, optimizada para aplicaciones de alto rendimiento.
--Intrduce códigos de error específicos (TTXXXX), que se pueden capturar y manejar en PL/SQL.
--Ejemplos comúnes: TT0802 (memory overflow), TT8001 (unique constraint violation), TT8002 (deadlock detected)
--Para manejar estas excepciones se usa PRAGMA EXCEPTION_INIT para asociar el código de error de TimesTen con una excepción personalizada.

--Ejemplo de manejo de excepciones TimesTen
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -00001); --Error TT8001: unique constraint violation
BEGIN
    INSERT INTO Clientes(ClienteID, Nombre, Ciudad) VALUES (1, 'Carlos Ruíz', 'Concepción'); -- ClienteID 1 ya existe
    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente');
EXCEPTION
    WHEN unique_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violación de clave única (TT8001). El ClienteID ya existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--Manejo de excepciones en bloques
--Se pueden manejar múltiples excepciones en un mismo bloque EXCEPTION, permitiendo una gestión más detallada de los errores.
--WHEN OTHERS: Es una cláusula que captura cualquier excepción no manejada previamente, proporcionando una forma de manejar errores inesperados.

--Ejemplo de manejo de múltiples excepciones
DECLARE
    v_total NUMBER;
    v_cliente_id NUMBER := 999; --Cliente inexistente
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado: ' || v_total);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontraron pedidos para el cliente con ID' || v_cliente_id);
    WHEN VALUER_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error de valor en los datos.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

DECLARE
    v_precio NUMBER;
    precio_bajo EXCEPTION;
    memory_overflow EXCEPTION;
    PRAGMA EXCEPTION_INIT(memory_overflow, -01422); --Error TT0802: memory overflow
BEGIN
    SELECT Precio INTO v_precio 
    FROM Productos;
    --WHERE ProductoID = 2;

    IF v_precio < 50 THEN
        RAISE precio_bajo;
    END IF;

    --Simulación de un error de memoria (en un entorno real, esto podría ocurrir por una consulta que devuelve demasiados datos)
    DBMS_OUTPUT.PUT_LINE('Procesando datos masivos...');
    DBMS_OUTPUT.PUT_LINE('Precio válido: ' || v_precio);
EXCEPTION
    WHEN precio_bajo THEN
        DBMS_OUTPUT.PUT_LINE('Error: El precio es demasiado bajo ('|| v_precio ||').');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado.');
    WHEN memory_overflow THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: Desbordamiento de memoria (TT0802).');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--Práctica

--1. Bloque PL/SQL que maneje la cantidad de productos en un pedido, lanzando una excepción personalizada si la cantidad supera un límite establecido (por ejemplo, 100 unidades).

--Primero creo una vista para que muestre el detalle de los pedidos.
CREATE OR REPLACE VIEW VER_DETALLES_PEDIDOS AS
    SELECT dp.PedidoID, pe.FechaPedido AS Fecha_Pedido, c.Nombre AS Nombre_Cliente, p.Nombre AS Nombre_Producto, dp.Cantidad
    FROM DetallesPedidos dp
    INNER JOIN Pedidos pe ON dp.PedidoID = pe.PedidoID
    INNER JOIN Clientes c ON pe.ClienteID = c.ClienteID
    INNER JOIN Productos p ON dp.ProductoID = p.ProductoID;

--Ahora construyo el bloque PL/SQL para manejar la cantidad de productos en un pedido.
DECLARE
    v_cantidad NUMBER;
    v_cantidad_maxima CONSTANT NUMBER := 100;
    v_contador NUMBER := 0;
    cantidad_excedida EXCEPTION;
    dato_no_encontrado EXCEPTION;
    PRAGMA EXCEPTION_INIT(dato_no_encontrado, -8000); --TT8000

BEGIN

    SELECT Cantidad INTO v_cantidad
    FROM VER_DETALLES_PEDIDOS
    WHERE Nombre_Cliente = 'Johann' AND REGEXP_LIKE(Nombre_Producto, '.*HP*');

    IF v_cantidad > v_cantidad_maxima THEN
        RAISE cantidad_excedida;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Procesando cantidad de productos...');
    DBMS_OUTPUT.PUT_LINE('Cantidad válida: ' || v_cantidad);

EXCEPTION
    WHEN cantidad_excedida THEN
        DBMS_OUTPUT.PUT_LINE('Error: La cantidad de productos ('|| v_cantidad ||') excede el límite permitido de ' || v_cantidad_maxima || ' unidades.');
    WHEN dato_no_encontrado THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: No se encontraron datos para el cliente o producto especificado (TT8000).');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--2. Bloque PL/SQL que intente insertar un producto con un ID que ya existe
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -00001);
BEGIN
    INSERT INTO Productos VALUES (1, 'Laptop HP', 'Paris', 1200); -- ProductoID 1 ya existe
    DBMS_OUTPUT.PUT_LINE('Producto insertado correctamente');
EXCEPTION    
    WHEN unique_violation THEN
        DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violación de clave única (TT8001). El ProductoID ya existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

COMMIT;
    

