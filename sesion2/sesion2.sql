--Consultas
SELECT Nombre, Ciudad
FROM Clientes
WHERE Ciudad = 'Coquimbo'
ORDER BY Nombre;

SELECT PedidoID, Total
FROM Pedidos
WHERE Total > 500
ORDER BY Total DESC;

SELECT COUNT(*) AS TotalClientes, Ciudad
FROM Clientes
GROUP BY Ciudad HAVING COUNT(*) > 2;

--Subconsultas
SELECT Nombre
FROM Clientes
WHERE ClienteID IN (
    SELECT ClienteID
    FROM Pedidos
    WHERE Total > 
    (SELECT AVG(Total)
    FROM Pedidos)
);

--Olvidé añadir esta columna a la tabla de productos
ALTER TABLE Productos
ADD (
    Precio INT
);

UPDATE Productos
SET Precio = 1000
WHERE ProductoID IN (SELECT ProductoID FROM PRODUCTOS); 

--Otra subconsulta
SELECT Nombre
FROM Productos
WHERE Precio = (SELECT MAX(Precio) FROM Productos);

--Funciones de agregación usando COUNT, SUM, AVG, MIN, MAX
SELECT Ciudad, COUNT(*) AS TotalClientes
FROM Clientes
GROUP BY Ciudad
HAVING COUNT(*) > 0;

--JOINs + función agregada
SELECT c.Nombre, SUM(p.Total) AS TotalGastado,
AVG(p.Total) AS PromedioPorPedido
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre; 


--Alias
SELECT Nombre AS NombreCliente, Ciudad AS Ubicacion
FROM Clientes;

SELECT c.Nombre, p.Total
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE  p.Total > 500;

--Expresiones regulares (Patrones para buscar y filtrar en cadenas de texto)
SELECT Nombre
FROM Clientes
WHERE REGEXP_LIKE(Nombre, '^J'); 

SELECT Nombre, Ciudad
FROM Clientes
WHERE REGEXP_LIKE(Ciudad, 'mbo');

--Vistas (Consulta almacenada que se comporta como una tabla virtual)
CREATE VIEW PedidosCaros AS (
    SELECT c.Nombre, p.Total
    FROM Clientes c
    LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
    WHERE p.Total > 2000
);

--Práctica
--Pedidos que se realizaron despues de marzo junto con el nombre del cliente
SELECT c.Nombre AS Nombre_Cliente, p.FechaPedido as Fecha_Pedido
FROM Clientes c 
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
WHERE p.FechaPedido >= TO_DATE('2024-03-01', 'YYYY-MM-DD');

--Cliente con el pedido con mayor cantidad de cosas
SELECT c.Nombre AS Nombre_Cliente, c.Ciudad AS Ciudad, pro.Nombre AS Nombre_Producto,
dp.Cantidad AS Cantidad
FROM Clientes c 
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
INNER JOIN DetallesPedidos dp ON p.PedidoID = dp.PedidoID
INNER JOIN Productos pro ON dp.ProductoID = pro.ProductoID
WHERE dp.Cantidad = (
    SELECT MAX(Cantidad)
    FROM DetallesPedidos
);

--Cantidad de productos pertenecientes a cada proveedor
SELECT proveedor, COUNT(*) AS Total_Productos
FROM Productos
GROUP BY proveedor
ORDER BY Total_Productos ASC;

--Promedio de gasto por cliente
SELECT c.Nombre AS Nombre_Cliente, AVG(p.Total) AS Promedio_Gasto
FROM Clientes c
LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
GROUP BY c.Nombre
ORDER BY Promedio_Gasto DESC;

--Clientes que compraron específicamente un producto 'NVIDIA'
SELECT DISTINCT c.Nombre AS Nombre_Cliente
FROM Clientes c
INNER JOIN Pedidos p ON c.ClienteID = p.ClienteID
INNER JOIN DetallesPedidos dp ON p.PedidoID = dp.PedidoID
INNER JOIN Productos pro ON dp.ProductoID = pro.ProductoID
WHERE REGEXP_LIKE(pro.Nombre, 'NVIDIA');

--Clientes que viven en Coquimbo
SELECT Nombre AS Nombre_Cliente, Ciudad
FROM Clientes
WHERE REGEXP_LIKE(Ciudad, 'Coquimbo');

--Vista que me muestren los pedidos para el mes de marzo
CREATE OR REPLACE VIEW PedidosMarzo AS (
    SELECT p.PedidoID AS Numero_Pedido, c.Nombre AS Nombre_Cliente, c.Ciudad AS Ciudad,
    p.Total AS Precio_Total, SUM(dp.Cantidad) AS Total_Productos, p.FechaPedido AS Fecha_Pedido
    FROM Pedidos p
    INNER JOIN Clientes c ON p.ClienteID = c.ClienteID
    INNER JOIN DetallesPedidos dp ON p.PedidoID = dp.PedidoID
    WHERE p.FechaPedido >= TO_DATE('2026-03-01', 'YYYY-MM-DD') AND p.FechaPedido < TO_DATE('2026-04-01', 'YYYY-MM-DD')
    GROUP BY p.PedidoID, c.Nombre, c.Ciudad, p.Total, p.FechaPedido
    HAVING SUM(dp.Cantidad) > 0
);

--Vista de cantidad de productos vendidos
CREATE OR REPLACE VIEW CantidadProductosVendidos AS (
    SELECT pro.Nombre AS Nombre_Producto, SUM(dp.Cantidad) AS total_vendido
    FROM DetallesPedidos dp
    INNER JOIN Productos pro ON dp.ProductoID = pro.ProductoID
    GROUP BY pro.Nombre
);

CREATE OR REPLACE VIEW CantidadProductosVendidos AS
SELECT pro.Nombre AS Nombre_Producto, SUM(dp.Cantidad) AS total_vendido
FROM DetallesPedidos dp
INNER JOIN Productos pro ON dp.ProductoID = pro.ProductoID
GROUP BY pro.Nombre
ORDER BY total_vendido DESC;

COMMIT; --Confirma los cambios realizados en la base de datos