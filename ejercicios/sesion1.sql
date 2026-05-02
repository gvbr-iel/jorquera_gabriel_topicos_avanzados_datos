--Práctica sesión 1
--Crear tabla intermedia 'DetallesPedidos'
CREATE TABLE DetallePedidos(
    PedidoID NUMBER,
    ProductoID NUMBER,
    Cantidad NUMBER,
    PRIMARY KEY (PedidoID, ProductoID),
    CONSTRAINT fk_pedido_id FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
    CONSTRAINT fk_producto_id FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID)
);

--1. 

--Insertar 3 registros en cada tabla
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

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesión 2
--1

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

--2

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

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesión 3
--1

--Bloque anónimo que clasifica el cliente de acuerdo al total gastado
SET SERVEROUTPUT ON;

DECLARE
    -- 1. Declaración de variables
    v_cliente_id    NUMBER := 1; -- ID del cliente a evaluar (puede cambiarse)
    v_total_gastado NUMBER;
    v_categoria     VARCHAR2(20);
    v_nombre_cli    VARCHAR2(100);
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Iniciando Clasificación de Cliente ---');

    SELECT Nombre INTO v_nombre_cli FROM Clientes WHERE ClienteID = v_cliente_id;
    
    -- Reutilizamos la lógica de sumar totales de pedidos del cliente
    SELECT SUM(Total) INTO v_total_gastado 
    FROM Pedidos 
    WHERE ClienteID = v_cliente_id;

    -- Manejo de valor nulo si el cliente no tiene pedidos
    v_total_gastado := NVL(v_total_gastado, 0);

    -- 3. Lógica de clasificación basada en los criterios documentados
    IF v_total_gastado > 1000000 THEN
        v_categoria := 'ALTO (VIP)';
    ELSIF v_total_gastado > 500000 THEN
        v_categoria := 'MEDIO (Regular)';
    ELSE
        v_categoria := 'BAJO (Ocasional)';
    END IF;

    -- 4. Mostrar resultados
    DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cli);
    DBMS_OUTPUT.PUT_LINE('Total Acumulado: $' || TO_CHAR(v_total_gastado, '999,999,999'));
    DBMS_OUTPUT.PUT_LINE('Categoría Asignada: ' || v_categoria);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: El Cliente ID ' || v_cliente_id || ' no existe.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesión 4
--1

--Bloque anónimo que examina el precio de un producto bajo una condición bias, si no se cumple entonces lanza una excepción
SET SERVEROUTPUT ON;

DECLARE
    -- Definición de la excepción personalizada
    e_precio_insuficiente EXCEPTION;
    v_bias      NUMBER := 1000; -- Valor mínimo permitido
    v_precio    NUMBER;
    v_prod_id   NUMBER := 50;   -- ID a consultar
BEGIN
    -- Intentar obtener el precio del producto
    SELECT Precio INTO v_precio 
    FROM Productos 
    WHERE ProductoID = v_prod_id;

    -- Verificación contra el bias
    IF v_precio < v_bias THEN
        RAISE e_precio_insuficiente;
    END IF;

    DBMS_OUTPUT.PUT_LINE('El producto ' || v_prod_id || ' tiene un precio válido de: ' || v_precio);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No se encontró el producto con ID ' || v_prod_id);
    WHEN e_precio_insuficiente THEN
        DBMS_OUTPUT.PUT_LINE('Alerta de Negocio: El precio (' || v_precio || ') es inferior al bias permitido de ' || v_bias);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM); 
END;
/

--2

--Bloque anonimo que lanza un error cuando se intenta ingresar un producto con id duplicado.
SET SERVEROUTPUT ON;

DECLARE
    -- Se define un ID que ya existe en la base de datos para forzar el error
    v_id_repetido NUMBER := 1; 
    v_nombre_prod VARCHAR2(50) := 'Teclado Mecánico';
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Inicio de Intento de Inserción ---');

    -- Intentamos insertar un registro con un ID que ya existe
    INSERT INTO Productos (ProductoID, Nombre, Precio)
    VALUES (v_id_repetido, v_nombre_prod, 25000);

    -- Esta línea NO se ejecutará si el INSERT falla
    DBMS_OUTPUT.PUT_LINE('Registro insertado con éxito.');

EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        -- El error se captura aquí y el programa no se detiene abruptamente
        DBMS_OUTPUT.PUT_LINE('Error de Integridad: El ID ' || v_id_repetido || ' ya está registrado.');
        DBMS_OUTPUT.PUT_LINE('Acción: Por favor, verifique el ID o utilice una actualización (UPDATE) en su lugar.');
    
    WHEN OTHERS THEN
        -- Manejador para cualquier otro error imprevisto
        DBMS_OUTPUT.PUT_LINE('Error inesperado: ' || SQLERRM);
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesión 5
--1

--Cursor explicito que muestra el nombre y precio de todos los productos
SET SERVEROUTPUT ON;

DECLARE
    -- 1. Definición del cursor explícito
    CURSOR c_productos IS
        SELECT Nombre, Precio 
        FROM Productos 
        ORDER BY Nombre ASC;

    -- 2. Declaración de variables individuales (en lugar de %ROWTYPE)
    -- Usamos %TYPE para que las variables hereden el tipo de dato de la tabla
    v_nombre_prod Productos.Nombre%TYPE;
    v_precio_prod Productos.Precio%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Listado de Productos (Variables Independientes) ---');
    
    -- 3. Apertura del cursor
    OPEN c_productos;
    
    LOOP
        -- 4. Captura de datos en las variables declaradas
        -- El orden de las variables debe coincidir con el orden del SELECT del cursor
        FETCH c_productos INTO v_nombre_prod, v_precio_prod;
        
        -- Condición de salida si ya no hay más filas
        EXIT WHEN c_productos%NOTFOUND; 
        
        -- 5. Mostrar la información
        DBMS_OUTPUT.PUT_LINE('Producto: ' || RPAD(v_nombre_prod, 25) || ' | Precio: $' || v_precio_prod);
    END LOOP;
    
    -- 6. Cierre del cursor
    CLOSE c_productos;
    
    DBMS_OUTPUT.PUT_LINE('--- Fin del Listado ---');

EXCEPTION
    WHEN OTHERS THEN
        IF c_productos%ISOPEN THEN
            CLOSE c_productos;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--2

--Cursor explicito con parametros que actualiza el precio de un producto en particular
DECLARE
    -- Cursor con parámetro y bloqueo de registros
    CURSOR c_actualizar_precios(p_categoria_id NUMBER) IS
        SELECT Nombre, Precio 
        FROM Productos 
        WHERE ProductoID = p_categoria_id
        FOR UPDATE; -- Bloquea las filas para evitar cambios externos

    v_precio_nuevo NUMBER;
    v_cat_id       NUMBER := 1; -- Producto a procesar
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Actualización de Precios (Categoría ' || v_cat_id || ') ---');

    FOR r_prod IN c_actualizar_precios(v_cat_id) LOOP
        -- Cálculo del aumento del 10%
        v_precio_nuevo := r_prod.Precio * 1.10;

        -- Actualización precisa usando la posición actual del cursor
        UPDATE Productos 
        SET Precio = v_precio_nuevo
        WHERE CURRENT OF c_actualizar_precios;

        -- Mostrar valores original y actualizado
        DBMS_OUTPUT.PUT_LINE('Producto: ' || r_prod.Nombre);
        DBMS_OUTPUT.PUT_LINE('  > Original: $' || r_prod.Precio || ' | Nuevo: $' || v_precio_nuevo);
    END LOOP;

    COMMIT; -- Consolida los cambios y libera los bloqueos
    DBMS_OUTPUT.PUT_LINE('--- Proceso Finalizado con Éxito ---');

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK; -- Deshace cambios en caso de error para liberar bloqueos
        DBMS_OUTPUT.PUT_LINE('Error en la actualización: ' || SQLERRM);
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Practica sesion 6
--Creacion de objeto
CREATE OR REPLACE TYPE t_producto AS OBJECT (
    nombre VARCHAR2(100),
    precio NUMBER,
    -- Función para el requerimiento 2
    MEMBER FUNCTION calcular_aumento(p_porcentaje NUMBER) RETURN NUMBER
);
/

CREATE OR REPLACE TYPE BODY t_producto AS
    MEMBER FUNCTION calcular_aumento(p_porcentaje NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN SELF.precio * (1 + (p_porcentaje / 100));
    END;
END;
/

--1

-- Cursor que instancia los objetos ordenandolos por nombre
SET SERVEROUTPUT ON;

DECLARE
    -- Cursor que instancia el objeto t_producto en la selección
    CURSOR c_obj_productos IS
        SELECT t_producto(Nombre, Precio) as obj_prod
        FROM Productos
        ORDER BY Nombre DESC; -- Ordenado por uno de los atributos

    v_item t_producto; -- Variable de tipo objeto
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Listado usando Objetos (Orden Descendente) ---');
    
    OPEN c_obj_productos;
    LOOP
        FETCH c_obj_productos INTO v_item;
        EXIT WHEN c_obj_productos%NOTFOUND;
        
        -- Accedemos a los atributos a través del objeto
        DBMS_OUTPUT.PUT_LINE('Producto: ' || RPAD(v_item.nombre, 20) || ' | Precio: ' || v_item.precio);
    END LOOP;
    CLOSE c_obj_productos;
END;
/

--2

--Cursor que instancia objetos producto y actualiza el precio usando su función interna
DECLARE
    -- Cursor con parámetro y bloqueo de registros
    CURSOR c_ajuste_precio(p_cat_id NUMBER) IS
        SELECT t_producto(Nombre, Precio) as producto_obj, 
               ROWID -- Necesario para identificar la fila físicamente
        FROM Productos
        WHERE CategoriaID = p_cat_id
        FOR UPDATE;

    v_nuevo_precio NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('--- Actualización Mediante Lógica de Objeto ---');

    FOR r IN c_ajuste_precio(1) LOOP
        -- Usamos la función interna del objeto para calcular el aumento
        v_nuevo_precio := r.producto_obj.calcular_aumento(10);

        -- Actualización basada en el bloqueo del cursor
        UPDATE Productos 
        SET Precio = v_nuevo_precio
        WHERE ROWID = r.ROWID;

        DBMS_OUTPUT.PUT_LINE('Articulo: ' || r.producto_obj.nombre);
        DBMS_OUTPUT.PUT_LINE('  Original: ' || r.producto_obj.precio || ' -> Nuevo: ' || v_nuevo_precio);
    END LOOP;

    COMMIT;[cite: 1]
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;[cite: 1]
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);[cite: 1]
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesión 7
--1

--Procedimiento almacenado que aumenta el precio de un producto usando un porcentaje
CREATE OR REPLACE PROCEDURE aumentar_precio_producto(p_producto_id IN NUMBER, p_porcentaje IN NUMBER) AS
BEGIN
	UPDATE Productos
	SET Precio = Precio * (1 + p_porcentaje / 100)
	WHERE ProductoID = p_producto_id;
	IF SQL%ROWCOUNT = 0 THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Producto con ID ' || p_producto_id || ' no encontrado.');
	END IF;
	DBMS_OUTPUT.PUT_LINE('Precio del producto ' || p_producto_id || ' aumentado en ' || p_porcentaje || '%.');
	COMMIT;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/
-- Prueba
EXEC aumentar_precio_producto(2, 10);

--2

-- Procedimiento almacenado que cuenta los pedidos del cliente y lo arroja como salida
CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_cliente_id IN NUMBER, p_cantidad OUT NUMBER) AS
BEGIN
	SELECT COUNT(*) INTO p_cantidad
	FROM Pedidos
	WHERE ClienteID = p_cliente_id;
END;
/
-- Prueba
DECLARE
	v_cantidad NUMBER;
BEGIN
	contar_pedidos_cliente(1, v_cantidad);
	DBMS_OUTPUT.PUT_LINE('Cliente 1 tiene ' || v_cantidad || ' pedidos.');
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesion 8
--1

--Liste los pedidos con total mayor a 500 y muestre el nombre del cliente asociado
DECLARE
	CURSOR pedido_cursor IS
    	SELECT p.PedidoID, p.Total, c.Nombre
    	FROM Pedidos p
    	JOIN Clientes c ON p.ClienteID = c.ClienteID
    	WHERE p.Total > 500;
	v_pedido_id NUMBER;
	v_total NUMBER;
	v_nombre VARCHAR2(50);
BEGIN
	OPEN pedido_cursor;
	LOOP
    	FETCH pedido_cursor INTO v_pedido_id, v_total, v_nombre;
    	EXIT WHEN pedido_cursor%NOTFOUND;
    	DBMS_OUTPUT.PUT_LINE('Pedido ' || v_pedido_id || ': Total ' || v_total || ', Cliente: ' || v_nombre);
	END LOOP;
	CLOSE pedido_cursor;
END;
/

--2

--Escribe un cursor explícito que aumente un 15% los precios de productos con precio inferior a 1000 y maneje una excepción si falla.
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
    	SET Precio = v_precio * 1.15
    	WHERE CURRENT OF producto_cursor;
    	DBMS_OUTPUT.PUT_LINE('Producto ' || v_productoid || ' actualizado a: ' || (v_precio * 1.15));
	END LOOP;
	CLOSE producto_cursor;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	IF producto_cursor%ISOPEN THEN
        	CLOSE producto_cursor;
    	END IF;
END;
/

-- 3

--Escribe un bloque PL/SQL con un cursor explícito que liste los clientes cuyo total de pedidos (suma de los valores de Total en la tabla Pedidos) sea mayor a 1000, mostrando el nombre del cliente y el total acumulado. 
DECLARE
	-- Declarar el cursor explícito
	CURSOR cliente_cursor IS
    	SELECT c.ClienteID, c.Nombre AS NombreCliente, SUM(p.Total) AS TotalPedidos
    	FROM Clientes c
    	JOIN Pedidos p ON c.ClienteID = p.ClienteID
    	GROUP BY c.ClienteID, c.Nombre
    	HAVING SUM(p.Total) > 1000;
    
	-- Variables para almacenar los datos del cursor
	v_cliente_id Clientes.ClienteID%TYPE;
	v_nombre_cliente Clientes.Nombre%TYPE;
	v_total_pedidos NUMBER;
	v_contador NUMBER := 0;
BEGIN
	-- Abrir el cursor
	OPEN cliente_cursor;
    
	-- Recorrer el cursor
	LOOP
    	FETCH cliente_cursor INTO v_cliente_id, v_nombre_cliente, v_total_pedidos;
    	EXIT WHEN cliente_cursor%NOTFOUND;
-- Mostrar los datos
    	DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_nombre_cliente ||
                         	', Total Pedidos: ' || v_total_pedidos);
    	v_contador := v_contador + 1;
	END LOOP;
    
	-- Cerrar el cursor
	CLOSE cliente_cursor;
    
	-- Mostrar mensaje si no se encontraron clientes
	IF v_contador = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('No se encontraron clientes con total de pedidos mayor a 1000.');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error al listar clientes: ' || SQLERRM);
    	IF cliente_cursor%ISOPEN THEN
        	CLOSE cliente_cursor;
    	END IF;
END;
/

--4

--Escribe un bloque PL/SQL con un cursor explícito que aumente en 1 la cantidad de los detalles de pedidos (DetallesPedidos) asociados a pedidos con fecha anterior al 2 de marzo de 2025 (FechaPedido en la tabla Pedidos). Usa FOR UPDATE para bloquear las filas y maneja excepciones.
DECLARE
	-- Declarar el cursor explícito con FOR UPDATE
	CURSOR detalle_cursor IS
    	SELECT dp.DetalleID, dp.PedidoID, dp.Cantidad
    	FROM DetallesPedidos dp
    	JOIN Pedidos p ON dp.PedidoID = p.PedidoID
    	WHERE p.FechaPedido < TO_DATE('2025-03-02', 'YYYY-MM-DD')
    	FOR UPDATE OF dp.Cantidad;
    
	-- Variables para almacenar los datos del cursor
	v_detalle_id DetallesPedidos.DetalleID%TYPE;
	v_pedido_id DetallesPedidos.PedidoID%TYPE;
	v_cantidad DetallesPedidos.Cantidad%TYPE;
	v_nueva_cantidad DetallesPedidos.Cantidad%TYPE;
	v_contador NUMBER := 0;
BEGIN
	-- Abrir el cursor
	OPEN detalle_cursor;
    
	-- Recorrer el cursor
	LOOP
    	FETCH detalle_cursor INTO v_detalle_id, v_pedido_id, v_cantidad;
    	EXIT WHEN detalle_cursor%NOTFOUND;
   	 
    	-- Aumentar la cantidad en 1
    	v_nueva_cantidad := v_cantidad + 1;
   	 
    	-- Actualizar la cantidad usando WHERE CURRENT OF
    	UPDATE DetallesPedidos
    	SET Cantidad = v_nueva_cantidad
    	WHERE CURRENT OF detalle_cursor;
   	 
-- Mostrar el cambio
    	DBMS_OUTPUT.PUT_LINE('DetalleID: ' || v_detalle_id ||
                         	', PedidoID: ' || v_pedido_id ||
                         	', Cantidad Anterior: ' || v_cantidad ||
                         	', Nueva Cantidad: ' || v_nueva_cantidad);
    	v_contador := v_contador + 1;
	END LOOP;
    
	-- Cerrar el cursor
	CLOSE detalle_cursor;
    
	-- Mostrar mensaje si no se actualizaron detalles
	IF v_contador = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('No se encontraron detalles de pedidos anteriores al 2 de marzo de 2025.');
	ELSE
    	DBMS_OUTPUT.PUT_LINE('Se actualizaron ' || v_contador || ' detalles de pedidos.');
	END IF;
    
	-- Confirmar los cambios
	COMMIT;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	DBMS_OUTPUT.PUT_LINE('No se encontraron datos para procesar.');
    	IF detalle_cursor%ISOPEN THEN
        	CLOSE detalle_cursor;
    	END IF;
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error al actualizar detalles: ' || SQLERRM);
    	IF detalle_cursor%ISOPEN THEN
        	CLOSE detalle_cursor;
    	END IF;
    	ROLLBACK;
END;
/

--5

--Crea un tipo de objeto cliente_obj con los atributos cliente_id, nombre, y un método get_info que devuelva una cadena con la información del cliente. Crea una tabla basada en ese tipo, transfiere los datos de la tabla Clientes a esa tabla, y escribe un bloque PL/SQL con un cursor explícito que liste la información de los clientes usando el método get_info.
CREATE OR REPLACE TYPE cliente_obj AS OBJECT (
	cliente_id NUMBER,
	nombre VARCHAR2(50),
	MEMBER FUNCTION get_info RETURN VARCHAR2
);
/

-- Crear el cuerpo del tipo con el método get_info
CREATE OR REPLACE TYPE BODY cliente_obj AS
	MEMBER FUNCTION get_info RETURN VARCHAR2 IS
	BEGIN
    	RETURN 'ID: ' || TO_CHAR(cliente_id) || ', Nombre: ' || nombre;
	END get_info;
END;
/

-- Crear la tabla basada en el tipo cliente_obj
CREATE TABLE Clientes_Obj OF cliente_obj (
	cliente_id PRIMARY KEY
);

-- Transferir datos de Clientes a Clientes_Obj
INSERT INTO Clientes_Obj (cliente_id, nombre)
SELECT ClienteID, Nombre
FROM Clientes;

-- Bloque PL/SQL para listar información de clientes usando el método get_info
DECLARE
	CURSOR cliente_cursor IS
    	SELECT VALUE(c) AS cli_obj
    	FROM Clientes_Obj c;
	v_cli_obj cliente_obj;
BEGIN
	-- Abrir el cursor
	OPEN cliente_cursor;
    
	-- Recorrer el cursor
	LOOP
    	FETCH cliente_cursor INTO v_cli_obj;
    	EXIT WHEN cliente_cursor%NOTFOUND;
   	 
    	-- Llamar al método get_info para mostrar la información
    	DBMS_OUTPUT.PUT_LINE(v_cli_obj.get_info());
	END LOOP;
    
	-- Cerrar el cursor
	CLOSE cliente_cursor;
    
	-- Manejar el caso en que no se encuentren datos
	IF SQL%NOTFOUND THEN
    	DBMS_OUTPUT.PUT_LINE('No se encontraron clientes en la tabla Clientes_Obj.');
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error al listar clientes: ' || SQLERRM);
    	IF cliente_cursor%ISOPEN THEN
        	CLOSE cliente_cursor;
    	END IF;
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesion 10
--1

--Crea un procedimiento actualizar_total_pedidos que reciba un ClienteID (parámetro IN) y un porcentaje de aumento (parámetro IN con valor por defecto 10%). Aumenta el total de todos los pedidos del cliente en el porcentaje especificado. Usa un bucle para iterar sobre los pedidos.
CREATE OR REPLACE PROCEDURE actualizar_total_pedidos(p_cliente_id IN NUMBER, p_porcentaje IN NUMBER DEFAULT 10) AS
	CURSOR pedido_cursor IS
    	SELECT PedidoID, Total
    	FROM Pedidos
    	WHERE ClienteID = p_cliente_id
    	FOR UPDATE;
BEGIN
	FOR pedido IN pedido_cursor LOOP
    	UPDATE Pedidos
    	SET Total = pedido.Total * (1 + p_porcentaje / 100)
    	WHERE CURRENT OF pedido_cursor;
    	DBMS_OUTPUT.PUT_LINE('Pedido ' || pedido.PedidoID || ': Nuevo total: ' || (pedido.Total * (1 + p_porcentaje / 100)));
	END LOOP;
	IF SQL%ROWCOUNT = 0 THEN
    	DBMS_OUTPUT.PUT_LINE('Cliente ' || p_cliente_id || ' no tiene pedidos.');
	ELSE
    	COMMIT;
	END IF;
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    	ROLLBACK;
END;
/
-- Prueba
EXEC actualizar_total_pedidos(1);

--2

--Crea un procedimiento calcular_costo_detalle que reciba un DetalleID (parámetro IN) y devuelva el costo total del detalle (parámetro IN OUT). El costo se calcula como Precio * Cantidad (usando las tablas DetallesPedidos y Productos). Maneja excepciones si el detalle no existe.
CREATE OR REPLACE PROCEDURE calcular_costo_detalle(p_detalle_id IN NUMBER, p_costo IN OUT NUMBER) AS
	v_precio NUMBER;
	v_cantidad NUMBER;
BEGIN
	SELECT p.Precio, d.Cantidad INTO v_precio, v_cantidad
	FROM DetallesPedidos d
	JOIN Productos p ON d.ProductoID = p.ProductoID
	WHERE d.DetalleID = p_detalle_id;
	p_costo := v_precio * v_cantidad;
	DBMS_OUTPUT.PUT_LINE('Costo del detalle ' || p_detalle_id || ': ' || p_costo);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20003, 'Detalle con ID ' || p_detalle_id || ' no encontrado.');
END;
/
-- Prueba
DECLARE
	v_costo NUMBER := 0;
BEGIN
	calcular_costo_detalle(1, v_costo);
	DBMS_OUTPUT.PUT_LINE('Costo calculado: ' || v_costo);
END;
/

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Práctica sesion 11
--1
--Crea una función calcular_edad_cliente que reciba un ClienteID (parámetro IN) y devuelva la edad del cliente en años (basado en FechaNacimiento). Maneja excepciones si el cliente no existe.
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
    	RAISE_APPLICATION_ERROR(-20003, 'Cliente con ID ' || p_cliente_id || ' no encontrado.');
END;
/
-- Prueba
DECLARE
	v_edad NUMBER;
BEGIN
	v_edad := calcular_edad_cliente(1);
	DBMS_OUTPUT.PUT_LINE('Edad del cliente 1: ' || v_edad);
EXCEPTION
	WHEN OTHERS THEN
    	DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

--2

--Crea una función obtener_precio_promedio que devuelva el precio promedio de todos los productos. Úsala en una consulta SQL para listar los productos cuyo precio está por encima del promedio.
CREATE OR REPLACE FUNCTION obtener_precio_promedio RETURN NUMBER AS
	v_promedio NUMBER;
BEGIN
	SELECT AVG(Precio) INTO v_promedio
	FROM Productos;
	RETURN v_promedio;
END;
/
-- Consulta SQL
SELECT Nombre, Precio
FROM Productos
WHERE Precio > obtener_precio_promedio();

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Practica sesion 12
--1

--Crea una función calcular_total_con_descuento que reciba un PedidoID (parámetro IN) y devuelva el total del pedido con un descuento del 10% si el total supera 1000. Usa la función en un procedimiento aplicar_descuento_pedido que actualice el total del pedido.
-- Función
CREATE OR REPLACE FUNCTION calcular_total_con_descuento(p_pedido_id IN NUMBER) RETURN NUMBER AS
	v_total NUMBER;
BEGIN
	SELECT Total INTO v_total
	FROM Pedidos
	WHERE PedidoID = p_pedido_id;
	IF v_total > 1000 THEN
    	v_total := v_total * 0.9; -- 10% de descuento
	END IF;
	RETURN v_total;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
    	RAISE_APPLICATION_ERROR(-20004, 'Pedido con ID ' || p_pedido_id || ' no encontrado.');
END;
/
-- Procedimiento
CREATE OR REPLACE PROCEDURE aplicar_descuento_pedido(p_pedido_id IN NUMBER) AS
	v_nuevo_total NUMBER;
BEGIN
	v_nuevo_total := calcular_total_con_descuento(p_pedido_id);
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
-- Prueba
EXEC aplicar_descuento_pedido(101);

--2

--Crea un trigger validar_cantidad_detalle que se dispare antes de insertar o actualizar en DetallesPedidos y verifique que la Cantidad sea mayor a 0. Si no, lanza un error.
CREATE OR REPLACE TRIGGER validar_cantidad_detalle
BEFORE INSERT OR UPDATE ON DetallesPedidos
FOR EACH ROW
BEGIN
	IF :NEW.Cantidad <= 0 THEN
    	RAISE_APPLICATION_ERROR(-20005, 'La cantidad debe ser mayor a 0.');
	END IF;
END;
/
-- Prueba
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 105, 2, -1);
INSERT INTO DetallesPedidos (DetalleID, PedidoID, ProductoID, Cantidad)
VALUES (3, 105, 2, 3);

/* ------------------------------------------------------------------------------------------------------------------------------*/

--Practica sesion 13
--1

--Crea un procedimiento actualizar_inventario_pedido que reciba un PedidoID (parámetro IN) y reduzca la cantidad de productos en una tabla Inventario (crea la tabla si no existe) según los detalles del pedido. Usa savepoints para manejar errores si no hay suficiente inventario.
-- Crear tabla Inventario
CREATE TABLE Inventario (
	ProductoID NUMBER PRIMARY KEY,
	Cantidad NUMBER
);
INSERT INTO Inventario VALUES (1, 10);
INSERT INTO Inventario VALUES (2, 20);

-- Procedimiento
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
    	COMMIT;
END;
/
-- Prueba
EXEC actualizar_inventario_pedido(108);

--2
--Diseña una tabla de hechos Fact_Pedidos y una dimensión Dim_Ciudad para un Data Warehouse basado en curso_topicos. Escribe una consulta analítica que muestre el total de ventas por ciudad y año.
-- Dimensión Ciudad
CREATE TABLE Dim_Ciudad (
	CiudadID NUMBER PRIMARY KEY,
	Ciudad VARCHAR2(50)
);
INSERT INTO Dim_Ciudad (CiudadID, Ciudad)
SELECT ROWNUM, Ciudad
FROM (SELECT DISTINCT Ciudad FROM Clientes);

-- Tabla de hechos (usando las dimensiones ya creadas)
CREATE TABLE Fact_Pedidos (
	PedidoID NUMBER,
	ClienteID NUMBER,
	CiudadID NUMBER,
	FechaID NUMBER,
	Total NUMBER,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Dim_Cliente(ClienteID),
	CONSTRAINT fk_pedido_ciudad FOREIGN KEY (CiudadID) REFERENCES Dim_Ciudad(CiudadID),
	CONSTRAINT fk_pedido_tiempo FOREIGN KEY (FechaID) REFERENCES Dim_Tiempo(FechaID)
);
INSERT INTO Fact_Pedidos (PedidoID, ClienteID, CiudadID, FechaID, Total)
SELECT p.PedidoID, p.ClienteID, dc.CiudadID, dt.FechaID, p.Total
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN Dim_Ciudad dc ON c.Ciudad = dc.Ciudad
JOIN Dim_Tiempo dt ON p.FechaPedido = dt.Fecha;

-- Consulta analítica
SELECT dc.Ciudad, dt.Año, SUM(fp.Total) AS TotalVentas
FROM Fact_Pedidos fp
JOIN Dim_Ciudad dc ON fp.CiudadID = dc.CiudadID
JOIN Dim_Tiempo dt ON fp.FechaID = dt.FechaID
GROUP BY dc.Ciudad, dt.Año;
