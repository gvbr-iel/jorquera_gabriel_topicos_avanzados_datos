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