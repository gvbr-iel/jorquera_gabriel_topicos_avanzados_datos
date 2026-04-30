--Creación de tablas

--Clientes
CREATE TABLE Clientes (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad varchar2(50),
    FechaNacimiento DATE
);

--Pedidos
CREATE TABLE Pedidos (
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER, 
    FechaPedido DATE,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

--Productos
CREATE TABLE Productos (
    ProductoID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Proveedor VARCHAR2(50),
    Precio NUMBER
);

--DetallePedidos
CREATE TABLE DetallePedidos(
    PedidoID NUMBER,
    ProductoID NUMBER,
    Cantidad NUMBER,
    PRIMARY KEY (PedidoID, ProductoID),
    CONSTRAINT fk_pedido_id FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    CONSTRAINT fk_producto_id FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

--Insertar Clientes
INSERT INTO Clientes VALUES (1,'Isidora','Temuco',TO_DATE('02-04-1990','DD-MM-YYYY'));
INSERT INTO Clientes VALUES (2,'Carlos','Magallanes',TO_DATE('01-06-1999','DD-MM-YYYY'));
INSERT INTO Clientes VALUES (3,'Alexander','La Serena',TO_DATE('05-05-2000','DD-MM-YYYY'));

--Insertar Pedidos
INSERT INTO Pedidos VALUES (1,1,124980,TO_DATE('10-03-2026','DD-MM-YYYY'));
INSERT INTO Pedidos VALUES (2,2,80980,TO_DATE('11-03-2026','DD-MM-YYYY'));
INSERT INTO Pedidos VALUES (3,3,61990,TO_DATE('20-04-2026','DD-MM-YYYY'));

--Insertar Productos
INSERT INTO Productos VALUES (1,'Kit de Destornilladores 48 Puntas', 'iFixit Mahi', 62990);
INSERT INTO Productos VALUES (2,'Teclado Magnético Gamer Royal Kludge RK68 HE 8KHz Hall Effect', 'Royal Kludge', 61990);
INSERT INTO Productos VALUES (3,'Módulo LoRaWAN SX1262 868MHz para Raspberry Pi Pico – Comunicación IoT', 'LoRa', 18990);

--Insertar DetallePedidos
INSERT INTO DetallePedidos VALUES (1,1,1);
INSERT INTO DetallePedidos VALUES (1,2,1);
INSERT INTO DetallePedidos VALUES (2,1,1);
INSERT INTO DetallePedidos VALUES (2,3,1);
INSERT INTO DetallePedidos VALUES (3,2,1);

COMMIT;

--Sesion 2 Consultas y subconsultas SQL

--Consultas básicas
--Selecciona el nombre y la ciudad de los clientes que viven en La Serena
SELECT Nombre, Ciudad
FROM Clientes
WHERE Ciudad = 'La Serena'
ORDER BY Nombre;

--Selecciona el id y el total de los pedidos cuyo total es mayor a 500 pesos
--y los ordena de mayor a menor.
SELECT PedidoID, Total
FROM Pedidos
WHERE Total > 500
ORDER BY Total DESC;

--Selecciona el total de clientes que se encuentran en cada ciudad que tenga más de 2 clientes.
SELECT COUNT(*) AS TotalClientes, Ciudad
FROM Clientes
GROUP BY Ciudad
HAVING COUNT(*) > 2;

--Subconsultas
--Consulta el nombre de los clientes cuyos pedidos tienen un total de más del promedio del total de pedidos existentes
SELECT Nombre
FROM Clientes
WHERE ClienteID IN (
    SELECT ClienteID
    FROM Pedidos
    WHERE Total > (
        SELECT AVG(Total)
        FROM Pedidos
    )
);

--Consulta sobre el nombre del producto cuyo precio es el máximo de todos los demás productos existentes.
SELECT Nombre
FROM Productos
WHERE Precio = (
    SELECT MAX(Precio)
    FROM Productos
);

--Funciones de agregación (COUNT, SUM, AVG, MAX/MIN)
--Consulta sobre las ciudades que tienen un total de clientes mayor a 1
SELECT Ciudad, COUNT(*) AS TotalClientes
FROM Clientes
GROUP BY Ciudad
HAVING COUNT(*) > 1;

--Consulta sobre el nombre, total gastado por pedidos, promedio gastado por pedido de los clientes exustentes.
SELECT c.Nombre, SUM(p.Total) AS TotalGastado, AVG(p.Total) AS PromedioPorPedido
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre;

--Alias (AS en SELECT)
--Consulta sobre el nombre como NombreCliente y ciudad como Ubicacion de todos los clientes
SELECT Nombre AS NombreCliente, Ciudad AS Ubicacion
FROM Clientes;

--Consulta sobre el nombre de los clientes y el total de cada pedido que tiene cuyo valor sea mayor a 500 pesos
SELECT c.Nombre, p.Total
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.Total > 500;

--Expresiones regulares (Patrones para buscar y filtrar en cadenas de texto)
--Consulta sobre el nombre de los clientes que empiezan con la letra J.
SELECT Nombre
FROM Clientes
WHERE REGEXP_LIKE(Nombre, '^J');

--Consulta sobre el nombre y la ciudad de los clientes cuya ciudad contenga ai en el nombre de la ciudad.
SELECT Nombre. Ciudad
FROM Clientes
WHERE REGEXP_LIKE(Ciudad, 'ai');

--Vistas (Consulta almacenada que se comporta como una tabla virtual)
--Vista que me muestra el nombre de los clientes y el total de los pedidos de dichos clientes que sean superiores a 500
CREATE OR REPLACE VIEW PedidosCaros AS (
    SELECT c.Nombre, p.Total
    FROM Clientes c
    JOIN Pedidos p ON c.ClienteID = p.ClienteID
    WHERE p.Total > 500
);

--Practica sesion 2
--Consulta sobre la cantidad de productos por proveedor ordenados de menor a mayor de acuerdo a la cantidad de productos
SELECT Proveedor, COUNT(*) AS CantidadProductos
FROM Productos
GROUP BY Proveedor
ORDER BY COUNT(*) ASC;

--Consulta sobre los pedidos que se han realizado en 2026
SELECT * FROM Pedidos
WHERE FechaPedido >= TO_DATE('01-01-2026','DD-MM-YYYY');

--Consulta sobre el productos que más veces se han comprado
--Consulta moderna ORACLE 12+
SELECT p.Nombre AS NombreProductos, SUM(dp.Cantidad) AS Cantidad_Productos_Vendidos
FROM Productos p
INNER JOIN DetallePedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre
ORDER BY SUM(dp.Cantidad) DESC
FETCH FIRST 1 ROWS ONLY;

--Consulta clásica
SELECT p.Nombre AS NombreProducto, SUM(dp.Cantidad) AS CantidadProducto
FROM Productos p
LEFT JOIN DetallePedidos dp ON p.ProductoID = dp.ProductoID
GROUP BY p.Nombre
HAVING SUM(dp.Cantidad) = (
    SELECT MAX(SUM(Cantidad))
    FROM DetallePedidos
    GROUP BY ProductoID
);

--Consulta sobre el nombre de los productos y la cantidad de clientes diferentes que han comprado dicho producto
SELECT p.Nombre AS NombreProducto, COUNT(DISTINCT Pedidos.ClienteID)
FROM Productos p
LEFT JOIN DetallePedidos dp ON p.ProductoID = dp.ProductoID
LEFT JOIN Pedidos ON Pedidos.PedidoID = dp.PedidoID
GROUP BY p.Nombre;

--Consulta sobre nombres de productos que contengan 'Tarjeta' en el nombre
SELECT Nombre AS NombreProducto
FROM Productos
WHERE REGEXP_LIKE(Nombre, 'Tarjeta');

--Consulta sobre nombres de proveedores que comiencen con la letra C.
SELECT Proveedor
FROM Productos
WHERE REGEXP_LIKE(Proveedor, '^C');

--Vista que muestre el promedio de ventas de los productos por pedido
CREATE OR REPLACE VIEW PromedioVentasProducto AS
    SELECT p.Nombre AS NombreProducto, AVG(p.Precio * dp.Cantidad) AS PromedioVenta
    FROM Productos p
    LEFT JOIN DetallePedidos dp ON p.ProductoID = dp.ProductoID
    GROUP BY p.Nombre;

--Vista que muestre la cantidad total de ventas realizadas por ciudad
CREATE OR REPLACE VIEW CantidadVentasCiudad AS
    SELECT c.Ciudad, COUNT(p.ClienteID) AS CantidadVentas
    FROM Clientes c
    LEFT JOIN Pedidos p ON p.ClienteID = c.ClienteID
    GROUP BY c.Ciudad;

COMMIT;

--Sesion 3 Introduccion PL/SQ
--Lenguaje de programación de Oracle que combina SQL con estructuras de programación procedural
--Permite escribir código para automatizar tareas, manejar lógica de negocio y mejorar el rendimiento de las consultas
--Ventajas:
--Procesamiento en el servidor: Reduce tráfico entre el cliente y el servidor.
--Estructuras de control: Permite bucles, condicionales y manejo de excepciones.
--Reutilización: Se pueden crear procedimientos y funciones almacenados.

BEGIN 
    DBMS_OUTPUT.PUT_LINE('¡Hola, Bienvenidos a PL/SQL');
END;
/

--Para ver los mensajes output debemos hacer SET SERVEROUTPUT ON;

--Estructura de un bloque PL/SQL
--Declare: Se declaran variables, constantes y cursores.
--Begin: Contiene la lógica del programa.
--EXCETPION: Maneja erroes.
--END: Cierra el bloque.

DECLARE
    v_mensaje VARCHAR2(50);
BEGIN
    v_mensaje := 'Aprendiendo PL/SQL'; --Defino mi variable declarada, tambien se pudo hacer v_mensaje VARCHAR2(50) := 'Aprendiendo PL/SQL;
    DBMS_OUTPUT.PUT_LINE(v_mensaje);
END;
/

--Bloques anónimos: Bloque PL/SQL que no tiene nombre y no se almacena en la base de datos
--Ideal para pruebas rapidas o tareas puntuales

--Bloque anónimo que realiza la suma del total de todos los pedidos de un cliente en especifico, si no existe lanza mensaje de error
DECLARE
    v_cliente_id NUMBER := 1;
    v_total_pedidos NUMBER;
BEGIN
    SELECT SUM(Total) INTO v_total_pedidos
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado por el cliente ' || v_cliente_id || ': ' || v_total_pedidos);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || v_cliente_id);
END;
/

--Bloque anónimo que entrega el nombre del cliente cuyo id es igual a 2
DECLARE
    v_nombre VARCHAR2(50);
    v_cliente_id NUMBER := 2;
BEGIN
    SELECT Nombre INTO v_nombre
    FROM Clientes
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Cliente encontrado: ' || v_nombre);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente_id || ' no encontrado.');
END;
/

--Manejo de variables y constantes en PL/SQL
--Variables: Declaración: nombre_variable TIPO_DATO (:= valor_inicial);
--Tipos comúnes: NUMBER, VARCHAR2, DATE.
--Constantes: Declaración: nombre_constante CONSTANT
--TIPO_DATO := valor;
--No se pueden modificar despues de asignarles un valor

--Bloque anónimo que muestra por pantalla el precio original y el precio final según las variables declaradas
DECLARE
    v_precio NUMBER := 1200;
    v_descuento NUMBER := 0.1;
    v_precio_final NUMBER;
BEGIN
    v_precio_final := v_precio - (v_precio * v_descuento);
    DBMS_OUTPUT.PUT_LINE('Precio original: ' || v_precio);
    DBMS_OUTPUT.PUT_LINE('Precio con descuento: ' || v_precio_final);
END;
/

--Bloque anónimo que muestra por pantalla el precio final con iva a partir de las variables declaradas
DECLARE
    v_precio NUMBER := 1000;
    c_iva CONSTANT NUMBER := 0.19;
    v_total_con_iva NUMBER;
BEGIN
    v_total_con_iva := v_precio + (v_precio * c_iva);
    DBMS_OUTPUT.PUT_LINE('Precio con IVA: ' || v_total_con_iva);
END;
/

--Estructuras de control en bloques anónimos
--Bloque anónimo que clasifica el total de pedidos a partir de la variable declarada
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

--Bloque anónimo que procesa pedidos hasta llegar a un maximo definido por las variables declaradas
DECLARE
    v_contador NUMBER := 0;
    v_max_pedidos NUMBER := 3;
BEGIN
    LOOP
    v_contador := v_contador + 1;
    DBMS_OUTPUT.PUT_LINE('Procesando pedidos: ' || v_contador);
    EXIT WHEN v_contador >= v_max_pedidos;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Procesamiento completado.');
END;
/

DECLARE
    v_cliente_id NUMBER := 1;
    v_nombre VARCHAR2(50);
    v_cantidad NUMBER;
BEGIN

    SELECT Nombre, SUM(cantidad) INTO v_nombre, v_cantidad
    FROM DetallePedidos dp
    JOIN Pedidos p ON dp.PedidoID = p.PedidoID
    JOIN Clientes c ON c.ClienteID = p.ClienteID
    WHERE c.ClienteID = v_cliente_id
    GROUP BY Nombre;

    IF v_cantidad > 20 THEN
    DBMS_OUTPUT.PUT_LINE('Total de productos comprados por el cliente ' || v_nombre ||': ' || v_cantidad);
    ELSIF v_cantidad > 8 THEN
    DBMS_OUTPUT.PUT_LINE('Pedido mediano: ' || v_cantidad);
    ELSE
    DBMS_OUTPUT.PUT_LINE('Pedido pequeño: ' || v_cantidad);
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente_id || ' no encontrado.');
END;
/


--Introducción a EXCEPTIONS en PL/SQL
--Definición: Es un evento de error que ocurre durante la ejecución de un programa PL/SQL
--Interrumpiendo el flujo normal
--Ejemplo: INtentar seleccionar datos que no existen genera un error (NO_DATA_FOUND).

--¿Por qué manejar excepciones?
--Evita que el programa termine abruptamente.
--Permite mostrar mensajes personalizados al usuario.
--Facilita la depuración y el manejo de errores.

--Bloque anónimo que muestra por pantalla el nombre del cliente con id igual a 1, si no se encuentra lanza una excepción.
DECLARE
    v_nombre VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Iniciando ejecución ...');
    SELECT Nombre INTO v_nombre
    FROM Clientes
    WHERE ClienteID = 1;
    DBMS_OUTPUT.PUT_LINE('Cliente encontrado: ' || v_nombre);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Cliente no encontrado.');
END;
/

--Tipos de excepciones
--Predefinidas: Son erroes comunes definidos por Oracle, ejemplos: NO_DATA_FOUND, TOO_MANY_ROWS, ZERO_DIVIDE, VALUE_ERROR
--Definidas por el usuario: Se crean para manejar errores específicos.

--Bloque anónimo que muestra el precio del producto con id igual a 1 y lanza una excepción cuando no se encuentra 
--en los registros o cuando el precio del producto es negativo

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

--Nota: Las excepciones creadas por el usuario se lanzan con RAISE y en la mayoría de casos es sencillo realizarlo con
-- condicionales.

--Excepciones de TimesTen
--TimesTen es una base de datos en memoria de Oracle, optimizada para aplicaciones de alto rendimiento.
--Introduce códigos de error específicos (TTXXXX), que se pueden capturar y manejar en PL/SQL.
--Ejemplos: TT80000: Memory overflow, TT8001: Unique constraint violation, TT8002: Error de conexión o transacción

--Para manejar estas excepciones, se usa PRAGMA EXCEPTION_INIT para asociar un código de error de TimesTen con una excepción
--personalizada.


--Bloque anónimo que inserta un registro en la tabla Clientes y lanza un error TimesTen TT8001 cuando se inserta un registro que ya
-- existe bajo el nombre de unique_violation
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation, -8001);
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad) VALUES (1, 'Carlos Ruiz', 'Concepcion'); --ClienteID 1 ya existe
    DBMS_OUTPUT.PUT_LINE('Cliente insertado correctamente.');
EXCEPTION
    WHEN unique_violation THEN
    DBMS_OUTPUT.PUT_LINE('Error de TimesTen: Violación de clave única (TT8001).');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--Manejo de bloques
--Se pueden manejar múltiples excepciones en un solo bloque.
--WHEN OTHERS: Captura todas las excepciones no manejadas específicamente.

--Bloque anónimo que muestra por pantalla el total gastado de un cliente con id igual a 999, lanza excepciones cuando el cliente
-- con ese id no exite, cuando el valor ingresado no es nu numero y cuando ocurren otras excepciones integradas en oracle.
DECLARE
    v_total NUMBER;
    v_cliente_id NUMBER := 999; -- Cliente inexistente
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado: ' || v_total);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente: ' || v_cliente_id);
    WHEN VALUE_ERROR THEN
    DBMS_OUTPUT.PUT_LINE('Error de valor en los datos. ');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inseperado: ' || SQLERRM);
END;
/ 

--Bloque anónimo que muestra por pantalla el precio del producto con id igual a 2. Lanza excepciones si no se encuentra el producto
--con ese id, memoria insuficiente cuando 
DECLARE
    v_precio NUMBER;
    precio_bajo EXCEPTION;
    memory_overflow EXCEPTION;
    PRAGMA EXCEPTION_INIT(memory_overflow, -8000); -- Código TT8000
BEGIN
    SELECT Precio INTO v_precio
    FROM Productos
    WHERE ProductoID = 2;

    IF v_precio < 50 THEN
    RAISE precio_bajo;
    END IF;

    --Simulación de un error de memoria (por ejemplo, consulta masiva en TimesTen)
    DBMS_OUTPUT.PUT_LINE('Procesando datos masivos...');
    DBMS_OUTPUT.PUT_LINE('Precio valido: ' || v_precio);
EXCEPTION
    WHEN precio_bajo THEN
    DBMS_OUTPUT.PUT_LINE('Error: El precio es demasiado bajo: (' || v_precio || ').');
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado');
    WHEN memory_overflow THEN
    DBMS_OUTPUT.PUT_LINE('Error TimesTen: Memoria insuficiente (TT8000)');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--Práctica
--Bloque anónimo que evalúa si la cantidad de productos del pedido con id 1 y producto con id 1 es correcta.
DECLARE
    cantidad_invalida EXCEPTION;
    v_cantidad NUMBER;
    v_pedido_id NUMBER := 1;
    v_producto_id NUMBER := 1;
BEGIN
    SELECT Cantidad INTO v_cantidad
    FROM DetallePedidos
    WHERE PedidoID = v_pedido_id AND ProductoID = v_producto_id;

    IF v_cantidad < 0 THEN
    RAISE cantidad_invalida;
    END IF;

    DBMS_OUTPUT.PUT_LINE('La cantidad de productos del pedido: ' || v_pedido_id || 'y producto: ' || v_producto_id || ' es igual
    a: ' || v_cantidad);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('El pedido con ID: ' || v_pedido_id || 'y producto: ' || v_producto_id || 'no fué encontrado.');
    WHEN cantidad_invalida THEN
    DBMS_OUTPUT.PUT_line('La cantidad de producto del pedido es invalido');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error: ' || SQLERRM);
END;
/

--Bloque anonimo que intenta introducir un producto ya existente, lanza error de duplicacion.
DECLARE
    unique_violation EXCEPTION;
    PRAGMA EXCEPTION_INIT(unique_violation,-8001);
BEGIN
    INSERT INTO Productos (ProductoID,Nombre, Proveedor, Precio) VALUES (1,'Kit de Componentes Electrónicos con Tarjeta ESP32', 'MCI Electronics',
    25990);
    DBMS_OUTPUT.PUT_LINE('Producto insertado correctamente.');
EXCEPTION
    WHEN unique_violation THEN
    DBMS_OUTPUT.PUT_LINE('Error: Producto con ID duplicada');
END;
/

--Sesión 5
--Revisión de bloques anónimos en PL/SQL
--Bloque anónimo que calcula el total gastado por el cliente y lo muestra por pantalla, lanza un error si el cliente no tiene pedidos
DECLARE 
    v_total NUMBER;
    v_cliente_id NUMBER := 1;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = v_cliente_id;

    DBMS_OUTPUT.PUT_LINE('Total gastado por el cliente ' || v_cliente_id  || ' : ' || NVL(v_total, 0));
EXCEPTION
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No se encontraron pedidos para el cliente ' || v_cliente_id);
END;
/

--Manipulación avanzada de bloques anónimos
--Variables complejad: Registro (ROW%TYPE) y tablas anidadas.
--Estructuras de control avanzadas: Bucles anidados (LOOP, WHILE, FOR).
--Condicionales múltiples con CASE

--Bloque anónimo que muestra por pantalla el nombre y la ciudad de un cliente haciendo uso de una variable tipo registro
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

--Bloque anónimo que clasifica a partir de un CASE un valor total
DECLARE
    v_total NUMBER := 600;
    v_clasificacion VARCHAR2(50);
BEGIN
    v_clasificacion := CASE
        WHEN v_total > 1000 THEN 'Alto'
        WHEN v_total > 500 THEN 'Medio'
        ELSE 'Bajo'
    END;

    DBMS_OUTPUT.PUT_LINE('Clasificacion del pedido: ' || v_clasificacion);
END;
/

--Introducción a cursores explicitos
--Definición: Es un puntero que permite procesar filas devueltas por una consulta SQL una por una.
--Tipos: Implicitos (manejados por PL/SQL) y Explicitos (definidos y controlados manualmente).

--Cursores explicitos: Se declaran, se leen con FETCH y se cierran manualmente.

--Cursor que procesa a todos los clientes y muestra por pantalla por medio de las variables declaradas el id y el nombre
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
        DBMS_OUTPUT.PUT_LINE('ID: ' || ', Nombre: ' || v_nombre);
    END LOOP;
    CLOSE cliente_cursor;
END;
/

--Aplicacion de cursores explicitos
--Uso avanzado de cursores: Combinación con estructuras de control y excepciones, uso de parámetros en
--cursores para filtrar datos.

--Cursor que procesa y muestra por pantalla todos los pedidos del cliente con id igual a 1, más el total de ellos.
DECLARE 
    CURSOR pedido_cursor(p_cliente_id NUMBER) IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE ClienteID = p.cliente_id;
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

--Cursor que procesa todos los pedidos con un total mayor a 400 y los actualiza añadiendo un 10% de su valor actual 
DECLARE
    CURSOR pedido_cursor IS
    SELECT PedidoID, Total
    FROM Pedidos
    WHERE Total > 400
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
        DBMS_OUTPUT.PUT_LINE('Pedido: ' || v_pedido_id || ' actualizado a: ' || (v_total * 1.1));
    END LOOP;
    CLOSE pedido_cursor;
END;
/

--Práctica
--Cursor que procesa ciudades y cantidad de clientes en ellas, las ordena según la cantidad de clientes de mayor a menor
DECLARE
    CURSOR ciudades_cursor IS
    SELECT Ciudad, COUNT(*)
    FROM Clientes
    GROUP BY Ciudad
    ORDER BY COUNT(*) DESC;
    v_ciudad VARCHAR2(50);
    v_cantidad NUMBER;
BEGIN
    OPEN ciudades_cursor;
    LOOP 
        FETCH ciudades_cursor INTO v_ciudad, v_cantidad;
        EXIT WHEN ciudades_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Ciudad: ' || v_ciudad || ', Cantidad: ' || v_cantidad);
    END LOOP;
    CLOSE ciudades_cursor;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ocurrió algo inesperado: ' || SQLERRM);
    IF ciudades_cursor%ISOPEN THEN
    CLOSE ciudades_cursor;
    END IF;
END;
/

--Cursor que aumenta el 10% el total del pedido con mayor cantidad de productos de los clientes si la cantidad de productos comprados sobrepasa 4.
/*DECLARE
    CURSOR aumento_cursor(v_cliente_id NUMBER) IS
    SELECT SUM(cantidad)
    FROM DetallePedidos dp
    JOIN Pedidos p ON dp.PedidoID = p.PedidoID
    WHERE p.ClienteID = v_cliente_id

    GROUP BY dp.PedidoID, c.ClienteID
    FOR UPDATE OF Pedidos;
    v_pedido_id NUMBER;
    v_cliente_id NUMBER := 1;
    v_cantidad NUMBER;
    v_total NUMBER;
BEGIN
    OPEN aumento_cursor(v_cliente_id);
    LOOP
        FETCH aumento_cursor INTO v_cantidad;
        EXIT WHEN aumento_cursor%NOTFOUND;
        IF v_cantidad > 4 THEN
        SELECT Total, p.PedidoID INTO v_total, v_pedido_id
        FROM Pedidos p
        JOIN DetallePedidos dp ON dp.PedidoID = p.PedidoID
        WHERE ClienteID = v_cliente_id AND p.PedidoID IN (
            SELECT PedidoID
            FROM DetallePedidos
            WHERE Cantidad = (
                SELECT MAX(Cantidad)
                FROM DetallePedidos dp
                JOIN Pedidos p ON p.PedidoID = dp.PedidoID
                WHERE p.ClienteID = v_cliente_id 
            )
        );

        UPDATE Pedidos
        SET Total = v_total * 1.1
        WHERE PedidoID = v_pedido_id AND ClienteID = v_cliente_id;
        DBMS_OUTPUT.PUT_LINE("Total original del pedido " || v_pedido_id || ': ' || v_total || ', Total actualizado: 
        ' || v_total * 1.1);

    END LOOP;

    CLOSE aumento_cursor;
EXCEPTION
    WHEN aumento_cursor%ISOPEN THEN
    CLOSE aumento_cursor;
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Ha ocurrido un error inesperado: ' || SQLERRM);
*/
--No me salió la consulta
--Prueba con otro enfoque

/*DECLARE
    v_cliente_id_buscado NUMBER := 1;
    
    -- El cursor ya identifica el pedido "ganador" (el de mayor cantidad de productos)
    CURSOR aumento_cursor(p_id_cliente NUMBER) IS
        SELECT p.PedidoID, p.Total, SUM(dp.Cantidad) as suma_items
        FROM Pedidos p
        JOIN DetallePedidos dp ON p.PedidoID = dp.PedidoID
        WHERE p.ClienteID = p_id_cliente
        GROUP BY p.PedidoID, p.Total
        HAVING SUM(dp.Cantidad) > 4
        ORDER BY SUM(dp.Cantidad) DESC
        FETCH FIRST 1 ROWS ONLY -- Solo queremos el que tiene la mayor cantidad
        FOR UPDATE OF p.Total;

BEGIN
    -- Usamos un FOR LOOP para evitar el OPEN/FETCH/CLOSE manual
    FOR reg IN aumento_cursor(v_cliente_id_buscado) LOOP
        
        UPDATE Pedidos
        SET Total = Total * 1.1
        WHERE CURRENT OF aumento_cursor; -- Actualiza exactamente la fila donde está el cursor
        
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || reg.PedidoID);
        DBMS_OUTPUT.PUT_LINE('Total original: ' || reg.Total);
        DBMS_OUTPUT.PUT_LINE('Total actualizado (10%): ' || (reg.Total * 1.1));
        
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
*/

--Sesion 6
--Revisión de cursores explicitos

--Cursor que muestra por pantalla los pedidos y el total del cliente con id igual a 1
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
        FETCH pedido_cursor INTO v_pedido_is, v_total;
        EXIT WHEN pedido_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Pedido ID: ' || v_pedido_id || 'Total: ' || v_total);
    END LOOP;
    CLOSE pedido_cursor;
END;
/

--Ejercicios complejos de modelamiento con cursores explicitos
--Uso de cursores con multiples tablas (JOINS)
--Procesamiento condicional y actualizaciones masivas

--Cursor que procesa las ciudades y el total gastado por cada una de ellas
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
        DBMS_OUTPUT.PUT_LINE('Ciudad: ' || v_ciudad || ', Total gastado: ' || v_total_gastado);
    END LOOP;
    CLOSE ciudad_cursor;
END;
/

--Cursor que actualiza el precio de los productos que tienen un valor debajo de 50
DECLARE
    CURSOR procuto_cursor IS
    SELECT ProductoID, Precio
    FROM Productos
    WHERE Precio < 1000
    FOR UPDATE OF Productos;
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
        DBMS_OUTPUT.PUT_LINE('Precio de producto ' || v_productoid || ' aumentado a: ' || (v_precio * 1.2));
        END IF;
    END LOOP;
    CLOSE producto_cursor;
END;
/

--Introducción a objetos de bases de datos
--Definición: Son estructuras definidas por el usuario que extienden las capacidades de las bases de datos relacionales
-- como tipos de objetos, tablas basadas en objetos y métodos.
-- Beneficios: Modelado más cercano a la realidad (por ejemplo, objetos con atributos y comportamientos).
--Reutilización de código y encapsulación. 

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

--Tipos de objetos:
--Estructuras personalizadas (como cliente_obj)
--Tablas que almacenan instancias de tipos de objetos.
--Funciones o procedimientos asociados a objetos.

--Utilidad:
--Modelado de datos complejos (por ejemplo, jerarquías o relaciones anidadas).
--Mejora del rendimiento en aplicaciones orientadas a objetos.

CREATE TABLE clientes_obj OF cliente_obj (
    cliente_id PRIMARY KEY
);

INSERT INTO clientes_obj
VALUES (1, 'Juan Perez', 'Santiago');
INSERT INTO clientes_obj
VALUES (2, 'Maria Gomez', 'Valparaiso');

SELECT c.get_info() FROM clientes_obj c;

--Cursor que muestra por pantalla la salida de la función get_info() en todas las instancias del objeto clientes_obj
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
END;
/

--Practica
--

--Sesión 7: Introducción a Procedimientos Almacenados
--Un procedimiento almacenado es un bloque PL/SQL con nombre que se almacena en la base de datos
--Permite ejecutar acciones (INSERT, UPDATE, DELETE) y lógica de negocio de manera reutilizable
--Ventajas:
--Modularidad: El código se escribe una vez y se invoca desde cualquier lugar.
--Seguridad: Permite restringir el acceso directo a las tablas, obligando a usar el procedimiento.
--Rendimiento: Se compila una vez y se guarda el plan de ejecución en el servidor.

--Configuración inicial del esquema (Tablas de apoyo)
--CREATE TABLE Clientes (ClienteID NUMBER PRIMARY KEY, Nombre VARCHAR2(50), Ciudad VARCHAR2(50), FechaNacimiento DATE);
--CREATE TABLE Productos (ProductoID NUMBER PRIMARY KEY, Nombre VARCHAR2(50), Precio NUMBER);
--CREATE TABLE Pedidos (PedidoID NUMBER PRIMARY KEY, ClienteID NUMBER, Total NUMBER, FechaPedido DATE);

--Ejemplo 1: Creación de un procedimiento básico sin parámetros
--Este procedimiento inserta un cliente de prueba en la tabla
CREATE OR REPLACE PROCEDURE insertar_cliente_test AS
BEGIN
    INSERT INTO Clientes (ClienteID, Nombre, Ciudad, FechaNacimiento)
    VALUES (99, 'Cliente de Prueba', 'Santiago', SYSDATE);
    DBMS_OUTPUT.PUT_LINE('Cliente de prueba insertado correctamente.');
    COMMIT;
END;
/

--Para ejecutar un procedimiento usamos: EXEC nombre_procedimiento;
--EXEC insertar_cliente_test;

--Manejo de Parámetros en Procedimientos
--IN: El valor entra al procedimiento (es de solo lectura).
--OUT: El procedimiento devuelve un valor al llamador.
--IN OUT: El valor entra, se modifica y se devuelve.

--Ejemplo 2: Procedimiento con parámetros de entrada (IN)
--Aumenta el precio de un producto específico según un porcentaje
CREATE OR REPLACE PROCEDURE aumentar_precio_producto(
    p_producto_id IN NUMBER, 
    p_porcentaje IN NUMBER
) AS
BEGIN
    UPDATE Productos
    SET Precio = Precio * (1 + p_porcentaje / 100)
    WHERE ProductoID = p_producto_id;

    --Uso de SQL%ROWCOUNT para verificar si se actualizó algo
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Producto con ID ' || p_producto_id || ' no encontrado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' actualizado.');
    END IF;
    COMMIT;
END;
/

--Ejecución: EXEC aumentar_precio_producto(1, 15); --Aumenta 15% al producto 1

--Ejemplo 3: Procedimiento con parámetros de salida (OUT)
--Cuenta cuántos pedidos tiene un cliente y devuelve el valor
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id IN NUMBER,
    p_cantidad OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
END;
/

--Para probar un procedimiento con parámetro OUT se requiere un bloque anónimo:
DECLARE
    v_total_pedidos NUMBER;
BEGIN
    contar_pedidos_cliente(1, v_total_pedidos);
    DBMS_OUTPUT.PUT_LINE('El cliente 1 tiene ' || v_total_pedidos || ' pedidos.');
END;
/

--Manejo de Excepciones en Procedimientos
--Es fundamental para evitar que errores en tiempo de ejecución detengan procesos críticos

--Ejemplo 4: Procedimiento con manejo de excepciones (RAISE_APPLICATION_ERROR)
--Actualiza el nombre de un cliente, validando su existencia
CREATE OR REPLACE PROCEDURE actualizar_nombre_cliente(
    p_cliente_id IN NUMBER,
    p_nuevo_nombre IN VARCHAR2
) AS
BEGIN
    UPDATE Clientes
    SET Nombre = p_nuevo_nombre
    WHERE ClienteID = p_cliente_id;

    IF SQL%ROWCOUNT = 0 THEN
        --Lanza un error personalizado (Rango -20000 a -20999)
        RAISE_APPLICATION_ERROR(-20001, 'El ID de cliente proporcionado no existe.');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Nombre actualizado con éxito.');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error detectado: ' || SQLERRM);
        ROLLBACK;
END;
/

--Actividad Práctica Sesión 7: Ejercicios de Procedimientos
--1. Procedimiento para eliminar un pedido validando que el ID exista.
--2. Procedimiento que reciba ID de producto y devuelva su nombre (OUT).

CREATE OR REPLACE PROCEDURE eliminar_pedido(p_pedido_id IN NUMBER) AS
BEGIN
    DELETE FROM Pedidos WHERE PedidoID = p_pedido_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No se pudo eliminar: Pedido ' || p_pedido_id || ' no existe.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' eliminado satisfactoriamente.');
        COMMIT;
    END IF;
END;
/

--Sesión 8: Revisión para la Prueba 1: Temas Clave
--Esta sesión consolida los conocimientos fundamentales de programación en el servidor
--Temas principales:
--1. Consultas SQL Avanzadas y Subconsultas
--2. Bloques Anónimos y Manejo de Excepciones
--3. Cursores Explícitos
--4. Introducción a Objetos de Bases de Datos (Programación Orientada a Objetos en SQL)

--Para habilitar la visualización de mensajes en consola:
SET SERVEROUTPUT ON;

--1. REVISIÓN DE CONSULTAS SQL Y SUBCONSULTAS
--Las subconsultas permiten realizar comparaciones dinámicas contra conjuntos de datos
--Ejemplo: Listar productos cuyo precio es mayor al promedio de todos los productos
SELECT Nombre, Precio
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos);

--Uso de Vistas: Permiten encapsular la complejidad de un JOIN para su reutilización
CREATE OR REPLACE VIEW Vista_Resumen_Pedidos AS
SELECT c.Nombre AS Cliente, p.PedidoID, p.Total
FROM Clientes c
JOIN Pedidos p ON c.ClienteID = p.ClienteID;

--2. REVISIÓN DE BLOQUES ANÓNIMOS Y EXCEPCIONES
--Las excepciones permiten controlar el flujo cuando ocurre un error esperado o inesperado
DECLARE
    v_nombre VARCHAR2(50);
    v_id NUMBER := 999; -- ID que probablemente no existe
BEGIN
    SELECT Nombre INTO v_nombre FROM Clientes WHERE ClienteID = v_id;
    DBMS_OUTPUT.PUT_LINE('Nombre: ' || v_nombre);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró el cliente con ID ' || v_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

--3. CURSORES EXPLÍCITOS
--Se utilizan cuando una consulta devuelve más de una fila y necesitamos procesarlas una por una
--Pasos: DECLARE -> OPEN -> FETCH -> CLOSE
DECLARE
    -- Definición del cursor
    CURSOR c_productos IS
        SELECT Nombre, Precio FROM Productos WHERE Precio > 100;
    
    v_nom Productos.Nombre%TYPE;
    v_pre Productos.Precio%TYPE;
BEGIN
    OPEN c_productos;
    LOOP
        FETCH c_productos INTO v_nom, v_pre;
        EXIT WHEN c_productos%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Producto: ' || v_nom || ' | Precio: ' || v_pre);
    END LOOP;
    CLOSE c_productos;
END;
/

--4. OBJETOS DE BASES DE DATOS (POO)
--Permite definir tipos de datos complejos que agrupan atributos y métodos
--Definición de la especificación del objeto
CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
    cliente_id NUMBER,
    nombre VARCHAR2(50),
    -- Definición de un método (Función miembro)
    MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

--Definición del cuerpo del objeto (Lógica del método)
CREATE OR REPLACE TYPE BODY cliente_obj AS
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    BEGIN
        RETURN 'ID: ' || TO_CHAR(cliente_id) || ', Nombre: ' || nombre;
    END get_info;
END;
/

--Creación de una Tabla de Objetos
--A diferencia de una tabla normal, cada fila es una instancia del objeto definido
CREATE TABLE Clientes_Obj OF cliente_obj (
    cliente_id PRIMARY KEY
);

--Insertar datos en una tabla de objetos (usando el constructor del tipo)
INSERT INTO Clientes_Obj VALUES (cliente_obj(1, 'Félix Nilo'));

--Consulta de objetos usando la función VALUE(c)
--Ideal para recuperar la instancia completa dentro de un bloque PL/SQL
DECLARE
    v_cli cliente_obj;
BEGIN
    SELECT VALUE(c) INTO v_cli FROM Clientes_Obj c WHERE cliente_id = 1;
    DBMS_OUTPUT.PUT_LINE(v_cli.get_info());
END;
/
--Sesión 10: Revisión para la Prueba: Procedimientos Almacenados y Transacciones
--Esta sesión consolida los conocimientos sobre lógica persistente en el servidor
--Temas principales:
--1. Procedimientos Almacenados con Parámetros (IN, OUT, IN OUT)
--2. Lógica Condicional y Bucles en PL/SQL
--3. Gestión de Transacciones (COMMIT, ROLLBACK)
--4. Control de Excepciones y Cursores de Actualización

--Para habilitar la visualización de mensajes en consola:
SET SERVEROUTPUT ON;

--1. PROCEDIMIENTOS CON PARÁMETROS (IN / OUT)
--Los parámetros permiten que el código sea reutilizable. 
--IN recibe datos, OUT devuelve valores al bloque que hace la llamada.
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(
    p_cliente_id IN NUMBER, 
    p_cantidad OUT NUMBER
) AS
BEGIN
    SELECT COUNT(*) INTO p_cantidad
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    
    DBMS_OUTPUT.PUT_LINE('Procesado: Cliente ' || p_cliente_id || ' tiene ' || p_cantidad || ' pedidos.');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_cantidad := 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en conteo: ' || SQLERRM);
END;
/

--2. LÓGICA CONDICIONAL (IF / ELSIF / ELSE)
--Permite tomar decisiones dentro del servidor basadas en los datos recuperados.
CREATE OR REPLACE PROCEDURE clasificar_cliente(p_cliente_id IN NUMBER) AS
    v_total NUMBER := 0;
    v_clasificacion VARCHAR2(20);
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    
    v_total := NVL(v_total, 0); -- Manejo de nulos

    IF v_total > 1000 THEN
        v_clasificacion := 'Premium';
    ELSIF v_total > 500 THEN
        v_clasificacion := 'Regular';
    ELSE
        v_clasificacion := 'Básico';
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('Resultado: Cliente ' || p_cliente_id || ' es nivel ' || v_clasificacion);
END;
/

--3. CURSORES Y BUCLES (FOR LOOP / UPDATE)
--Se utilizan para aplicar lógica masiva fila por fila sobre un conjunto de resultados.
CREATE OR REPLACE PROCEDURE aplicar_descuento_general(p_porcentaje IN NUMBER) AS
    CURSOR c_productos IS
        SELECT ProductoID, Precio
        FROM Productos
        FOR UPDATE; -- Bloquea las filas para actualización segura
BEGIN
    FOR r_prod IN c_productos LOOP
        UPDATE Productos
        SET Precio = Precio * (1 - p_porcentaje / 100)
        WHERE CURRENT OF c_productos; -- Actualiza la fila actual del cursor
    END LOOP;
    COMMIT; -- Confirma los cambios de forma permanente
    DBMS_OUTPUT.PUT_LINE('Descuento del ' || p_porcentaje || '% aplicado a todos los productos.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Deshace cambios en caso de error
        DBMS_OUTPUT.PUT_LINE('Transacción abortada: ' || SQLERRM);
END;
/

--4. GESTIÓN DE TRANSACCIONES Y ATOMICIDAD
--Garantiza que un conjunto de operaciones (como insertar un pedido y su detalle) ocurra completo o no ocurra.
CREATE OR REPLACE PROCEDURE insertar_pedido_seguro(
    p_pedido_id IN NUMBER,
    p_cliente_id IN NUMBER,
    p_total IN NUMBER,
    p_producto_id IN NUMBER,
    p_cantidad IN NUMBER
) AS
BEGIN
    -- Operación 1: Encabezado del pedido
    INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido)
    VALUES (p_pedido_id, p_cliente_id, p_total, SYSDATE);

    -- Operación 2: Detalle del pedido
    INSERT INTO DetallesPedidos (PedidoID, ProductoID, Cantidad)
    VALUES (p_pedido_id, p_producto_id, p_cantidad);

    COMMIT; -- Solo si ambas inserciones son exitosas
    DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedido_id || ' registrado con éxito.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Si falla cualquier operación, no se guarda nada
        DBMS_OUTPUT.PUT_LINE('Error en registro. Transacción revertida.');
END;
/

--EJEMPLO DE EJECUCIÓN (Bloque Anónimo de Prueba)
DECLARE
    v_conteo NUMBER;
BEGIN
    -- Probar procedimiento con parámetro OUT
    contar_pedidos_cliente(1, v_conteo);
    
    -- Probar lógica condicional
    clasificar_cliente(1);
END;
/

--Sesión 11: Funciones Almacenadas en PL/SQL
--Esta sesión profundiza en la creación de bloques de código que retornan valores únicos.
--Temas principales:
--1. Estructura de una Función Almacenada (CREATE FUNCTION)
--2. Parámetros de entrada y cláusula RETURN
--3. Diferencias entre Funciones y Procedimientos
--4. Integración de Funciones en consultas SQL (SELECT)

--Para habilitar la visualización de mensajes en consola:
SET SERVEROUTPUT ON;

--1. INTRODUCCIÓN A FUNCIONES (FUNCIÓN SIMPLE)
--Una función siempre debe devolver un valor utilizando la sentencia RETURN.
CREATE OR REPLACE FUNCTION saludar RETURN VARCHAR2 AS
BEGIN
    RETURN '¡Hola, bienvenidos a la Sesión 11!';
END;
/

--2. FUNCIONES CON PARÁMETROS Y LÓGICA DE NEGOCIO
--Cálculo del total acumulado de pedidos para un cliente específico.
CREATE OR REPLACE FUNCTION total_pedidos(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_total NUMBER;
BEGIN
    SELECT SUM(Total) INTO v_total
    FROM Pedidos
    WHERE ClienteID = p_cliente_id;
    
    -- Manejo de valores nulos para asegurar un retorno numérico
    IF v_total IS NULL THEN
        RETURN 0;
    END IF;
    
    RETURN v_total;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error en función total_pedidos: ' || SQLERRM);
        RETURN -1;
END;
/

--3. GESTIÓN DE EXCEPCIONES Y CÁLCULOS DINÁMICOS
--Calcula el costo total de una línea de detalle validando la existencia del producto.
CREATE OR REPLACE FUNCTION calcular_costo_detalle(p_detalle_id IN NUMBER) RETURN NUMBER AS
    v_precio NUMBER;
    v_cantidad NUMBER;
    v_costo NUMBER;
BEGIN
    SELECT p.Precio, d.Cantidad INTO v_precio, v_cantidad
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.DetalleID = p_detalle_id;

    v_costo := v_precio * v_cantidad;
    RETURN v_costo;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
END;
/

--4. FUNCIONES EN CONSULTAS SQL (REUTILIZACIÓN)
--Las funciones permiten extender las capacidades de las sentencias SELECT estándar.

--Ejemplo: Listar clientes y su gasto total usando la función creada:
--SELECT ClienteID, Nombre, total_pedidos(ClienteID) AS GastoTotal FROM Clientes;

--5. ACTIVIDAD PRÁCTICA: LÓGICA DE FECHAS
--Función para determinar la edad de un cliente.
CREATE OR REPLACE FUNCTION calcular_edad_cliente(p_cliente_id IN NUMBER) RETURN NUMBER AS
    v_fecha_nacimiento DATE;
    v_edad NUMBER;
BEGIN
    SELECT FechaNacimiento INTO v_fecha_nacimiento
    FROM Clientes
    WHERE ClienteID = p_cliente_id;

    v_edad := FLOOR(MONTHS_BETWEEN(SYSDATE, v_fecha_nacimiento) / 12);
    RETURN v_edad;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Cliente no existe.');
END;
/

--EJEMPLO DE EJECUCIÓN (Bloque Anónimo de Prueba)
DECLARE
    v_msg VARCHAR2(100);
    v_gasto NUMBER;
    v_edad NUMBER;
BEGIN
    -- Probar función simple
    v_msg := saludar;
    DBMS_OUTPUT.PUT_LINE(v_msg);
    
    -- Probar función con lógica de base de datos
    v_gasto := total_pedidos(1);
    DBMS_OUTPUT.PUT_LINE('El gasto total del cliente 1 es: ' || v_gasto);
    
    -- Probar función de edad
    v_edad := calcular_edad_cliente(1);
    DBMS_OUTPUT.PUT_LINE('La edad del cliente 1 es: ' || v_edad);
END;
/

--Sesión 12: Triggers y Lógica Programable Avanzada
--Esta sesión integra el uso de funciones, procedimientos y disparadores automáticos.
--Temas principales:
--1. Repaso de Procedimientos y Funciones Almacenadas
--2. Integración: Uso de funciones dentro de procedimientos
--3. Introducción a Triggers (BEFORE/AFTER, ROW/STATEMENT)
--4. Casos de Uso: Validación de datos y Auditoría

--Para habilitar la visualización de mensajes en consola:
SET SERVEROUTPUT ON;

--1. REPASO: FUNCIONES Y PROCEDIMIENTOS
--Las funciones devuelven un valor (RETURN) y se pueden usar en SELECT o PL/SQL.
CREATE OR REPLACE FUNCTION calcular_costo_pedido(p_pedido_id IN NUMBER) RETURN NUMBER AS
    v_costo NUMBER := 0;
BEGIN
    SELECT SUM(p.Precio * d.Cantidad) INTO v_costo
    FROM DetallesPedidos d
    JOIN Productos p ON d.ProductoID = p.ProductoID
    WHERE d.PedidoID = p_pedido_id;
    
    RETURN NVL(v_costo, 0);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0;
END;
/

--2. INTEGRACIÓN DE LÓGICA (LLAMADA A FUNCIÓN)
--Un procedimiento puede llamar a una función para procesar datos antes de una actualización.
CREATE OR REPLACE PROCEDURE actualizar_total_pedido(p_pedido_id IN NUMBER) AS
    v_nuevo_total NUMBER;
BEGIN
    v_nuevo_total := calcular_costo_pedido(p_pedido_id);
    
    IF v_nuevo_total = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'No se encontraron detalles para el pedido ' || p_pedido_id);
    END IF;

    UPDATE Pedidos
    SET Total = v_nuevo_total
    WHERE PedidoID = p_pedido_id;
    
    DBMS_OUTPUT.PUT_LINE('Total del pedido ' || p_pedido_id || ' actualizado a: ' || v_nuevo_total);
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/

--3. TRIGGERS DE VALIDACIÓN (BEFORE ROW)
--Garantizan la integridad de los datos antes de que se consoliden en la tabla.
CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
    IF :NEW.Cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');
    END IF;
END;
/

--4. TRIGGERS DE AUDITORÍA (AFTER ROW)
--Permiten registrar automáticamente cambios históricos en tablas auxiliares.
--Requisito: Tener creada la tabla AuditoriaPrecios.
CREATE OR REPLACE TRIGGER auditar_precio_producto
AFTER UPDATE OF Precio ON Productos
FOR EACH ROW
BEGIN
    INSERT INTO AuditoriaPrecios (ProductoID, PrecioAntiguo, PrecioNuevo, FechaCambio)
    VALUES (:OLD.ProductoID, :OLD.Precio, :NEW.Precio, SYSDATE);
END;
/

--EJEMPLO DE EJECUCIÓN (Bloque Anónimo de Prueba)
BEGIN
    -- Probar validación del Trigger (debería lanzar error si cantidad es <= 0)
    DBMS_OUTPUT.PUT_LINE('--- Iniciando pruebas ---');
    
    -- Intento de actualización de total
    actualizar_total_pedido(101);
    
    -- Simulación de cambio de precio para activar auditoría
    UPDATE Productos SET Precio = Precio * 1.10 WHERE ProductoID = 1;
END;
/

--Sesion 13
-- Actividad Práctica 1: Procedimiento para actualizar inventario con Savepoints[cite: 2]
CREATE OR REPLACE PROCEDURE actualizar_inventario_pedido(p_pedido_id IN NUMBER) AS
    CURSOR detalle_cursor IS
        SELECT ProductoID, Cantidad
        FROM DetallesPedidos
        WHERE PedidoID = p_pedido_id;
    v_cantidad_actual NUMBER;
BEGIN
    FOR detalle IN detalle_cursor LOOP
        -- Verificar cantidad disponible
        SELECT Cantidad INTO v_cantidad_actual
        FROM Inventario
        WHERE ProductoID = detalle.ProductoID;
        
        SAVEPOINT antes_reducir;
        
        IF v_cantidad_actual < detalle.Cantidad THEN
            RAISE_APPLICATION_ERROR(-20001, 'No hay suficiente inventario para el producto ' || detalle.ProductoID);
        END IF;
        
        UPDATE Inventario
        SET Cantidad = Cantidad - detalle.Cantidad
        WHERE ProductoID = detalle.ProductoID;
        
        DBMS_OUTPUT.PUT_LINE('Inventario actualizado para producto ' || detalle.ProductoID);
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Producto no encontrado en inventario.');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK TO antes_reducir;
        COMMIT; -- Confirma lo realizado hasta antes del error
END;
/

-- Actividad Práctica 2: Diseño de Data Warehouse (Modelo Estrella)[cite: 2]

-- 1. Tablas de Dimensiones
CREATE TABLE Dim_Cliente (
    ClienteID NUMBER PRIMARY KEY,
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50)
);

INSERT INTO Dim_Cliente SELECT ClienteID, Nombre, Ciudad FROM Clientes;

CREATE TABLE Dim_Ciudad (
    CiudadID NUMBER PRIMARY KEY,
    Ciudad VARCHAR2(50)
);

INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad FROM (SELECT DISTINCT Ciudad FROM Clientes);

CREATE TABLE Dim_Tiempo (
    FechaID NUMBER PRIMARY KEY,
    Fecha DATE,
    Año NUMBER,
    Mes NUMBER,
    Día NUMBER
);

INSERT INTO Dim_Tiempo (FechaID, Fecha, Año, Mes, Día)
SELECT ROWNUM, FechaPedido, EXTRACT(YEAR FROM FechaPedido), EXTRACT(MONTH FROM FechaPedido), EXTRACT(DAY FROM FechaPedido)
FROM (SELECT DISTINCT FechaPedido FROM Pedidos);

-- 2. Tabla de Hechos para Pedidos
CREATE TABLE Fact_Pedidos (
    PedidoID NUMBER,
    ClienteID NUMBER,
    CiudadID NUMBER,
    FechaID NUMBER,
    Total NUMBER,
    CONSTRAINT fk_fp_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
    CONSTRAINT fk_fp_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
    CONSTRAINT fk_fp_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);

INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

COMMIT;

-- Consulta Analítica: Total de ventas por ciudad y año[cite: 2]
SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;
