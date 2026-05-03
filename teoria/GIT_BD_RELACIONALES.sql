--Sesion 1 (GIT - Introducción a BD relacionales)
--¿Qué es git? -> Es un sistema de control de versiones distribuido que permite rastrear cambios en el código
--y colaborar en proyectos.

--Ventajas
--Seguimiento de cambios históricos
--Trabajo colaborativo
--Ramas para experimentar sin afectar el código principal

--Conceptos claves: Repositorio: Espacio donde se almacenan los archivos y su historial.
--Commit: Registro de un cambio en el repositorio.
--Push/Pull: Enviar y recibir cambios desde un repositorio remoto (Como Github)

--Creación de repositorio en Git
--cd topicos_avanzados_datos
--git init
--Creamos repositorio en github de nombre [apellido]_[nombre]_topicos_avanzados_datos
--git remote add origin https//:github.com/[tu-usuario]/[apellido]_[nombre]_topicos_avanzados_datos.git
--En nuestro direcotiro creamos README.md
--echo "# Tópicos Avanzados en Datos" > README.md
--git add README.md
--git commit -m "lab/se agrega README inicial"
--git push origin main

--Bases de datos relacionales: Una base de datos relacional organiza los datos en tablas, donde cada tabla contiene filas y comunas, y las tablas estan relacionadas
--mediante claves.
--Caracterísitcas: Datos estructurados (tablas).
--Uso de SQL para consultas y manipulaciones.
--Relaciones entre tablas mediante claves primarias y foráneas.
--Ventajas: Integridad de datos, Consultas eficientes con SQL, Escalabilidad y mantenimiento.
--Una tabla es una estructura que organiza datos en filas y columnas
--Cada columna tiene un tipo de dato (NUMBER, VARCHAR2, DATE, etc).

CREATE TABLE Clientes(
    ClienteID NUMBER PRIMARY KEY.
    Nombre VARCHAR2(50),
    Ciudad VARCHAR2(50),
    FechaNacimiento DATE
);

SELECT * FROM Clientes;

--Una llave primaria es un campo (o combinación de campos) que identifica de manera única cada fila en una tabla.
--Restricciones: No puede ser NULL y debe ser única.
--En la tabla Clientes, ClienteID es la llave primaria.
--Una llave foránea es un campo en una tabla que referencia la llave primaria de otra tabla, estableciendo una
--relación entre ellas.
--Restricciones: solo puede contener valores que existan en la llave primaria referenciada o NULL.
--Ejemplo: Relación entre Pedidos y Clientes. 

CREATE TABLE Pedidos(
    PedidoID NUMBER PRIMARY KEY,
    ClienteID NUMBER,
    Total NUMBER,
    FechaNacimiento DATE,
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

--Uno a muchos: Un cliente puede tener muchos pedidos (por ejemplo, Clientes -> Pedidos).
--Uno a Uno: Una relación donde cada registro en una tabla se asocia con una solo registro en otra
--(por ejemplo, un cliente con un perfil).
--Mucho a muchos: Requiere una tabla intermedia (por ejemplo, Pedidos y Productos a traves de una tabla DetallesPedidos).
--Ejemplo: Relación uno a muchos entre Clientes y Pedidos.
--Un cliente puede tener múltiples pedidos, pero cada pedido pertenece a un solo cliente.
--Representado por la llave foránea ClienteID en Pedidos.

