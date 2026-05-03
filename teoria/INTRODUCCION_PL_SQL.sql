--Sesion 3: Intrducción a PL/SQL, bloques anónimos

--PL/SQL: Es un lenguaje de programación de Oracle que combina SQL con estructuras de programación procedural.
--Permite escribir código para automatizar tareas, manejar lógica de negocio y mejorar el rendimiento d las consultas.
--Ventajas: Procesamiento en el servidor: Reduce el tráfico entre el cliente y el servidor.
--Estructuras de control: Permite bucles, condicionales y manejo de excepciones. Reutilización: Se pueden crear procedimientos
--y funciones almacenados.

BEGIN
    DBMS_OUTPUT.PUT_LINE('Hola, bienvenidos a PL/SQL');
END;
/

--Para ver los mensajes OUTPUT debemos hacer SET SERVEROUTPUT ON
--Estructuras de un bloque PL/SQL

--DECLARE (opcional): Se declaran las variables, constantes y cursores.
--BEGIN (obligatorio): Contiene la lógica del programa (instrucciones).
--EXCEPTION (opcional): Maneja errores
--END (obligatorio): Cierra el bloque

DECLARE
    v_mensaje VARCHAR2(50);
BEGIN
    v_mensaje := 'Aprendiendo PL/SQL';
    DBMS_OUTPUT.PUT_LINE(v_mensaje);
END;
/

--Bloques anónimos: Declaración y uso
--Un bloque anónimo es un bloque PL/SQL que no tiene nombre y no se almacena en la base de datos (se ejecuta una sola vez)
--Ideal para pruebas rápidas o tareas puntuales.

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
        DBMS_OUTPUT.PUT_LINE('No se encontraron pedidios para el cliente: ' || v_cliente_id);
END;
/

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
        DBMS_OUTPUT.PUT_LINE('Cliente: ' || v_cliente_id || ' no encontrado');
END;
/
