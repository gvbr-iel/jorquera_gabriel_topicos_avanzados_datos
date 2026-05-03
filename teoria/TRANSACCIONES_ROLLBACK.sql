-- sesion 10

--Repaso procedimientos almacenados básicos
--Ejemplo: Procedimiento para contar pedidos de un cliente

CREATE OR REPLACE PROCEDURE contar_pedidos_cliente(p_clienteid IN NUMBER, p_cantidad OUT NUMBER) AS
BEGIN
    SELECT COUNT(*) INTO p_cantidad 
    FROM Pedidos 
    WHERE ClienteID = p_clienteid;
    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_clienteid || ' tiene ' || p_cantidad || ' pedidos.');
EXCEPTION 
    WHEN NO_DATA_FOUND THEN
    p_cantidad := 0;
    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_clienteid || ' no tiene pedidos.');
END;
/

--Ejecutar 
DECLARE 
    v_cantidad NUMBER;
BEGIN 
    contar_pedidos_cliente(1, v_cantidad);
END;
/

--Procedimientos con logica condicional y bucles
--Lógica condicional: Uso de IF, ELSIF, ELSE para tomar decisiones
--Bucles: Uso de LOOP, WHILE, FOR para iterar.

--Ejemplo 1: Procedimiento que clasifica clientes segun el total de sus pedidos.

CREATE OR REPLACE PROCEDURE clasificar_cliente(p_clienteid IN NUMBER) AS 
    v_total NUMBER := 0;
    v_clasificacion VARCHAR2(20);
BEGIN 
    SELECT SUM(Total) INTO v_total 
    FROM Pedidos 
    WHERE ClienteID = p_clienteid;
    IF v_total IS NULL THEN 
    v_total := 0;
    END IF;
    IF v_total > 1000 THEN 
    v_clasificacion := 'Premium';
    ELSIF v_total > 500 THEN 
    v_clasificacion := 'Regular';
    ELSE 
    v_clasificacion := 'Básico';
    END IF;
    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_clienteid || ': ' || v_clasificacion || '(Total: ' || v_total || ')');
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
    DBMS_OUTPUT.PUT_LINE('Cliente ' || p_clienteid || ' no tiene pedidos. ');
END;
/

--Ejecutar
EXEC clasificar_cliente(1);
EXEC clasificar_cliente(2);

--Procedimientos con logica condicional y bucles
CREATE OR REPLACE PROCEDURE aplicar_descuento(p_porcentaje IN NUMBER) AS
    v_precio NUMBER; 
    CURSOR producto_cursor IS 
    SELECT ProductoID, Precio
    FROM Productos 
    FOR UPDATE;
BEGIN 
    FOR producto IN producto_cursor 
    LOOP 
    v_precio := producto.Precio * (1 - p_porcentaje/100);
    UPDATE Productos 
    SET Precio = v_precio 
    WHERE ProductoID = producto.ProductoID;
    DBMS_OUTPUT.PUT_LINE('Producto ' || producto.ProductoID || ', Nuevo Precio: ' || v_precio);
    END LOOP;
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/
--Ejecutar
EXEC aplicar_descuento(10);

--Procedimientos con parametros avanzados (IN OUT, valores por defecto)
--Parametro IN OUT: Permite que un parametro sea usado como entrada y salida.
--Valores por defecto: Permite definir valores predeterminados para parametros

--Ejemplo 1: Procedimiento almacenado con paramtro IN OUT para actualizar y devolver el total de un pedido
CREATE OR REPLACE PROCEDURE actualizar_total_pedido(p_pedidoid IN NUMBER, p_incremento IN OUT NUMBER) AS 
BEGIN 
    UPDATE Pedidos 
    SET Total = Total * p_incremtento
    WHERE PedidoID = p_pedidoid;
    IF SQL%ROWCOUNT = 0 THEN 
    RAISE_APPLICATION_ERROR(-20001, 'Pedido con ID: ' || p_pedidoid || 'no encontrado');
    END IF;
    SELECT Total INTO p_incremento
    FROM Pedidos 
    WHERE PedidoID = p_pedidoid;

    DBMS_OUTPUT.PUT_LINE('Nuevo total del pedido: ' || p_pedidoid || ': ' || p_incremento);
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

--Ejecutar
DECLARE 
    v_incremento NUMBER := 100;
BEGIN 
    actualizar_total_pedido(101, v_incremento);
    DBMS_OUTPUT.PUT_LINE('Total actualizado: ' || v_incremento);
END;
/

--Ejemplo 2: Procedimiento con valor por defecto para aplicar un aumento de precio
CREATE OR REPLACE PROCEDURE aumentar_precio_defecto(p_productoid IN NUMBER, p_porcentaje IN NUMBER DEFAULT 5) AS 
BEGIN 
    UPDATE Productos 
    SET Precio = Precio * (1-p_porcentaje/100)
    WHERE ProductoID = p_productoid;
    IF SQL%ROWCOUNT = 0 THEN 
    RAISE_APPLICATION_ERROR(-20001, 'Producto con ID: ' || p_productoid || 'no encontrado');
    END IF;
    DBMS_OUTPUT.PUT_LINE('Precio del producto: ' || p_productoid || 'aumentado a ' || p_porcentaje || '%.');
    COMMIT;
EXCEPTION 
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/

--Ejecutar
EXEC aumentar_precio_defecto(1);
EXEC aumentar_precio_defecto(1,10);

--Procedimientso con transacciones y rollback
--Tranasacciones: Conjunto de operaciones que deben completarse como una unidad (o revertirse)
--Rollback: Revierte los cambios si ocurre un error.

--Ejemplo: Procedimiento que inserta un pedido y sus detalles, con rollaback si falla

CREATE OR REPLACE PROCEDURE insertar_pedido_detalle(
    p_pedidoid IN NUMBER,
    p_clienteid IN NUMBER,
    p_total IN NUMBER,
    p_productoid IN NUMBER,
    p_cantidad IN NUMBER
) AS 
    v_detalle_id NUMBER; 
BEGIN
        --Insertar el pedido
        INSERT INTO Pedidos (PedidoID, ClienteID, Total, FechaPedido) VALUES (p_pedidoid, p_clienteid, p_total, SYSDATE);
        --Obtener el proximo detalleid
        SELECT NVL(MAX(DetalleID), 0) INTO v_detalle_id FROM DetallePedidos;
        --Insertar el detalle del pedido
        INSERT INTO DetallePedidos (DetalleID, PedidoID, ProductoID, Cantidad)
        VALUES (v_detalleid, p_clienteid, p_productoid, p_cantidadid);
        --Confirmar la transaccion
        DBMS_OUTPUT.PUT_LINE('Pedido ' || p_pedidoid || ' y detalle isnertados correctamente.');
        COMMIT;
EXCEPTION 
    WHEN OTHERS THEN 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
    RAISE;
END;
/

--Ejecutar
EXEC insertar_pedido_detalle(104,3,400,1,1);
EXEC insertar_pedido_detalle(104,3,400,2,2);