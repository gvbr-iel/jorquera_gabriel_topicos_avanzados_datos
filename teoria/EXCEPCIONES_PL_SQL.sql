--Sesion 4

--Introducción a Exceptions en PL/SQL
--Una excepción es un evento de error que ocurre durante la ejecución de un programa PL/SQL interrumpiendo el flujo normal.
--Ejemplo: Intentar seleccionar datos que no existen (NO_DATA_FOUND).

--¿Por qué manejar excepciones?: Evita que el programa termine abruptamente.
--Permite mostrar mensaje personalizados al usuario
--Facilita la depuración y el manejo de errores.

DECLARE 
    v_nombre VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando ejeución...');
    SELECT Nombre INTO v_nombre FROM Clientes WHERE ClienteID = 1; -- Existe
    DBMS_OUTPUT.PUT_LINE('Cliente encontrado: ' || v_nombre);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Cliente no encontrado.');
END;
/

--Tipos de exceptions
--Predefinidas: Definidas por Oracle (NO_DATA_FOUND, TOO_MANY_ROWS, ZERO_DIVIDE, VALUE_ERROR)
--Definidas: Creadas por el Usuario 

DECLARE
    v_precio NUMBER;
    precio_invalido EXCEPTION
BEGIN
    SELECT Precio INTO v_precio 
    FROM Productos
    WHERE ProductoID = 1;

    IF v_precio < 0 THEN
    RAISE precio_invalido
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio del producto: ' || v_precio);
EXCEPTION 
    WHEN precio_invalido THEN
        DBMS_OUTPUT.PUT_LINE('Error: El precio no puede ser negativo.');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado');
END;
/

--Excepciones TimesTen: Base de datos en memoria que introduce códigos de error específicos que se pueden capturar y manejar
--en PL/SQL
--Ejemplos: TT8000 (memory overflow), TT8001 (unique constraint violation), TT8002 (Error de conexión o transacción)

DECLARE 
    unique_violation EXCEPTION
    PRAGMA EXCEPTION_INIT(unique_violation, -8001); 
BEGIN 
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad) VALUES (1, 'Carlos Ruiz', 'Concepcion'); 
EXCEPTION
    WHEN unique_violation THEN 
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Violacion de clave unica (TT8001).');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--Manejo en bloques
DECLARE
    v_total NUMBER;
    v_cliente_id NUMBER := 999;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado: ' || v_total);
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente' || v_cliente_id);
    WHEN VALUE_ERROR THEN 
    DBMS_OUTPUT.PUT_LINE('Error de valor en los datos.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

DECLARE
    v_precio NUMBER;
    precio_bajo EXCEPTION;
    memory_overflow EXCEPTION;
    PRAGMA EXCEPTION_INIT(memory_overflow, '-8000');
BEGIN
    SELECT Precio INTO v_precio 
    FROM Productos 
    WHERE ProductoID = 2;
    
    IF v_precio < 50 THEN
    RAISE precio_bajo;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Precio valido: ' || v_precio);
EXCEPTION
    WHEN precio_bajo THEN
    DBMS_OUTPUT.PUT_LINE('Error: El precio es demasiado bajo (' ||v_precio|| ')');
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado');
    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Memoria insuficiente');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/