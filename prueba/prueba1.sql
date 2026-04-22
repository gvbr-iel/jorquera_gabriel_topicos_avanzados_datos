--Nombre: Gabriel Jorquera

--Pregunta 1: Una relación mucho a muchos es un tipo de relación en base de datos
-- relacionales que consiste en que los registros de una tabla A están relacionados
-- mediante atributos foráneos a muchos registros de una tabla B y viceversa.
-- Los motores de bases de datos relacionales no pueden procesar esta relación por lo
-- que se emplea una tabla intermedia que use el tipo de relación uno a muchos a ambas
-- tablas para hacer posible la relación mucho a muchos en las tablas anteriores.

--Pregunta 2: Una vista se puede describir como la respuesta de una consulta
-- almacenada en la base de datos y que lleva un nombre consigo para ser identificada.
-- Para usar una vista en esta consulta le colocaría un nombre identificador
-- "HorasDedicadasPorIncidente" y usando un join conectaría las tablas de incidentes
-- y de asignaciones a través del atributo incidenteid para mostrar los detalles.

--Vista pregunta2:

CREATE OR REPLACE VIEW HorasDedicadasPorIncidente AS(
    SELECT i.IncidenteID, Descripcion, Severidad, Horas
    FROM Incidentes i
    LEFT JOIN Asignaciones a ON i.IncidenteID = a.IncidenteID
);

--Pregunta 3: Una excepcion predefinida en PL/SQL es un bloque controlado por el motor
-- de la base de datos que sirve para controlar el flujo del programa cuando un error
-- dentro del mismo surge, se maneja atrapándo al error dentro del bloque "EXCEPTION"
-- y definiendo lo que sucede cuando la excepción es atrapada.

--Ejemplo:
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Dato no encontrado ...');
END;
/

--Pregunta 4: Un cursor explícito es un puntero o selector procesa cada
-- registro que forme parte de una tabla, se usa para recorrer los registros de las
-- tablas con los loops y en PL/SQL se define en el bloque DECLARE y luego en el 
-- bloque BEGIN se activa mediante un LOOP para iniciar el recorrido, es necesario
-- cerrar el cursor una vez abierto. 
-- Atributos de cursor
-- FOR UPDATE: Indica al cursor que puede ser usado para actualizar registros
-- %NOTFOUND: Sirve para detener el procesamiento de registros del cursor cuando ya 
-- no encuentra nada que procesar.

--PARTE 2.

--EJERCICIO 1:

DECLARE
    CURSOR esp_agent AS
        SELECT especialidad, AVG(horas) as promediohoras
        FROM Agentes a
        INNER JOIN asignaciones i ON a.agenteID = i.agenteID
        HAVING SUM(horas) > 30
        GROUP BY especialidad;
    v_especialidad VARCHAR2(50);
    v_promediohora NUMBER;
BEGIN
    OPEN esp_agent;
    FETCH esp_agent INTO v_especialidad, v_promediohora;
    EXIT WHEN esp_agent%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Especialidad: ');

EXCEPTION

END;
/
