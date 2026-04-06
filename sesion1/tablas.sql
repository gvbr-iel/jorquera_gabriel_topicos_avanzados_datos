WHENEVER SQLERROR EXIT SQL.SQLCODE;

ALTER SESSION SET CONTAINER = XEPDB1;
CREATE USER gabriel IDENTIFIED BY curso2026;

GRANT CONNECT, RESOURCE, CREATE SESSION TO gabriel;
GRANT CREATE TABLE, CREATE TYPE, CREATE PROCEDURE TO gabriel;
GRANT UNLIMITED TABLESPACE TO gabriel;
GRANT CREATE ANY VIEW TO gabriel;

SELECT username FROM dba_users WHERE username = 'GABRIEL';
ALTER SESSION SET CURRENT_SCHEMA = gabriel;

SET SERVEROUTPUT ON;

BEGIN
	DMBS_OUTPUT.PUT_LINE('Creando tabla Clientes...');
	EXECUTE IMMEDIATE 'CREATE TABLE Clientes (
		ClienteID NUMBER PRIMARY KEY,
		Nombre VARCHAR2(50),
		Ciudad VARCHAR2(50),
		FechaNacimiento DATE
	)';
	DBMS_OUTPUT.PUT_LINE('Tabla Clientes creada.');
END;
/

BEGIN
	DBMS_OUTPUT.PUT_LINE("Creando tabla Pedidos...");
	EXECUTE IMMEDIATE 'CREATE TABLE Pedidos (
		PedidoID NUMBER PRIMARY KEY,
		ClienteID NUMBER,
		Total NUMBER,
		FechaPedido DATE,
		CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
	)';
	DBMS_OUTPUT.PUT_LINE('Tabla Pedidos creada...');
END;
/

BEGIN
	DBMS_OUTPUT.PUT_LINE('Creando tabla Productos...');
	EXECUTE IMMEDIATE 'CREATE TABLE Productos(
		ProductoID NUMBER PRIMARY KEY,
		Nombre VARCHAR2(50),
		Precio NUMBER
	)';
	DBMS_OUTPUT.PUT_LINE('Tabla Productos creada.');
END;
/

BEGIN
	DBMS_OUTPUT.PUT_LINE('Insertando datos en Clientes...');
	INSERT INTO Clientes VALUES (1, 'Juan Perez', 'Santiago', TO_DATE('1990-05-15','YYYY-MM-DD'));
	INSERT INTO Clientes VALUES (2, 'María Gomez', 'Valparaiso', TO_DATE('1985-10-20', 'YYYY-MM-DD'));
	INSERT INTO Clientes VALUES (3, 'Ana Lopez', 'Santiago', TO_DATE('1995-03-10', 'YYYY-MM-DD'));
END;
/

-- Insertar datos en Pedidos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Pedidos...');
    INSERT INTO Pedidos VALUES (101, 1, 600, TO_DATE('2025-03-01', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (102, 1, 300, TO_DATE('2025-03-02', 'YYYY-MM-DD'));
    INSERT INTO Pedidos VALUES (103, 2, 800, TO_DATE('2025-03-03', 'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Pedidos.');
END;
/

-- Insertar datos en Productos
BEGIN
    DBMS_OUTPUT.PUT_LINE('Insertando datos en Productos...');
    INSERT INTO Productos VALUES (1, 'Laptop', 1200);
    INSERT INTO Productos VALUES (2, 'Mouse', 25);
    DBMS_OUTPUT.PUT_LINE('Datos insertados en Productos.');
END;
/

COMMIT; 

BEGIN
	DBMS_OUTPUT.PUT_LINE('Tablas creadas y datos insertados correctamente.');
END;
/

SELECT * FROM Clientes;
SELECT * FROM Pedidos;
SELECT * FROM Productos;

BEGIN
	DBMS_OUTPUT.PUT_LINE('Creando tabla DetallesPedidos...');
	EXECUTE IMMEDIATE 'CREATE TABLE DetallesPedidos(
		DetalleID NUMBER PRIMARY KEY,
		PedidoID NUMBER,
		ProductoID NUMBER,
		Cantidad NUMBER,
		CONSTRAINT fk_detalle_pedido FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
		CONSTRAINT fk_detalle_producto FOREGIN KEY (ProductoID) REFERENCES Productor(ProductoID)
	)';
	DBMS_OUTPUT.PUT_LINE('Tabla DetallesPedidos creada.');
END;
/

BEGIN
	DBMS_OUTPUT.PUT_LINE('Insertando datos en DetallesPedidos...')
	INSERT INTO DetallesPedidos VALUES (2,101,1,2);
	INSERT INTO DetallesPedidos VALUES (2, 101, 2, 5); -- Pedido 101: 5 Mouse
    	DBMS_OUTPUT.PUT_LINE('Datos insertados en DetallesPedidos.');
END;
/

SELECT * FROM DetallesPedidos;
COMMIT;
