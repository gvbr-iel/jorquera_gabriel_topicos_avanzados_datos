-- Consultar todos los clientes de la ciudad de 'Santiago'
SELECT Nombre, Ciudad 
FROM Clientes 
WHERE Ciudad = 'Santiago';

-- Consultar los productos que tienen un precio mayor a 500
SELECT Nombre, Precio 
FROM Productos 
WHERE Precio > 500;

-- Obtener el total de dinero sumado de todos los pedidos realizados
SELECT SUM(Total) AS Gran_Total_Ventas 
FROM Pedidos;

-- Contar cuántos clientes hay registrados por cada ciudad
SELECT Ciudad, COUNT(*) AS Cantidad_Clientes 
FROM Clientes 
GROUP BY Ciudad;

-- Buscar clientes cuyo nombre empiece con 'A', 'B' o 'M'
SELECT Nombre 
FROM Clientes 
WHERE REGEXP_LIKE(Nombre, '^[ABM]');

-- Buscar productos cuyo nombre contenga la palabra 'top' (como Laptop) sin importar mayúsculas
SELECT Nombre 
FROM Productos 
WHERE REGEXP_LIKE(Nombre, 'top', 'i');

-- Vista 1: Resumen de pedidos con el nombre del cliente
CREATE OR REPLACE VIEW Vista_Resumen_Pedidos AS
SELECT p.PedidoID, c.Nombre AS Cliente, p.Total, p.FechaPedido
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID;

-- Vista 2: Catálogo de productos caros (más de 100)
CREATE OR REPLACE VIEW Vista_Productos_Premium AS
SELECT Nombre, Precio
FROM Productos
WHERE Precio > 100;

COMMIT;