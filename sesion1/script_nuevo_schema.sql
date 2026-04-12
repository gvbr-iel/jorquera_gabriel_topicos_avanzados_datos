CREATE USER jorquera IDENTIFIED BY curso2025;
GRANT CONNECT, RESOURCE, CREATE SESSION TO jorquera;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO jorquera;
GRANT UNLIMITED TABLESPACE TO jorquera;
GRANT CREATE ANY VIEW TO jorquera;

SELECT username 
FROM dba_users
WHERE username = 'JORQUERA';

--Crear tablas SQL

CREATE TABLE Clientes(
	ClienteID NUMBER PRIMARY KEY,
	Nombre VARCHAR2(50),
	Ciudad VARCHAR2(50),
	FechaNacimiento DATE
);

INSERT INTO Clientes VALUES (1, 'Johann', 'Temuco', TO_DATE('10-03-2002', 'DD-MM-YYYY'));
INSERT INTO Clientes VALUES (2, 'Nicole', 'Coquimbo', TO_DATE('03-12-2000', 'DD-MM-YYYY'));
INSERT INTO Clientes VALUES (3, 'Pablo', 'Santiago', TO_DATE('04-10-1998', 'DD-MM-YYYY'));

CREATE TABLE Pedidos(
	PedidoID NUMBER PRIMARY KEY,
	ClienteID NUMBER,
	Total NUMBER,
	FechaPedido DATE,
	CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

INSERT INTO Pedidos VALUES (1, 2, 5000, TO_DATE('07-03-2026', 'DD-MM-YYYY'));
INSERT INTO Pedidos VALUES (2, 2, 10000, TO_DATE('08-04-2026', 'DD-MM-YYYY'));
INSERT INTO Pedidos VALUES (3, 1, 2000, TO_DATE('12-04-2026', 'DD-MM-YYYY'));

CREATE TABLE Productos(
	ProductoID NUMBER PRIMARY KEY,
	Nombre VARCHAR2(50),
	Proveedor VARCHAR2(50)
);

INSERT INTO Productos VALUES (1, 'RAM KINGSTONE 64GB', 'Falabella');
INSERT INTO Productos VALUES (2, 'TARJETA GRÁFICA NVIDIA RTX 3000', 'Microplay');
INSERT INTO Productos VALUES (3, 'MONITOR HP 4K', 'Pc Factory');

CREATE TABLE DetallesPedidos(
	PedidoID NUMBER,
	ProductoID NUMBER,
	Cantidad NUMBER,
	PRIMARY KEY (PedidoID, ProductoID),
	CONSTRAINT fk_detalle_producto FOREIGN KEY (ProductoID) REFERENCES Productos(ProductoID),
	CONSTRAINT fk_detalle_predido FOREIGN KEY(PedidoID) REFERENCES Pedidos(PedidoID)
);

INSERT INTO DetallesPedidos VALUES (1,1,4);
INSERT INTO DetallesPedidos VALUES (2,1,5);
INSERT INTO DetallesPedidos VALUES (1,2,1);
INSERT INTO DetallesPedidos VALUES (3,3,2);
