/*
Club Database Script (SQL Server)

Order of batches:
1) Schema / Tables
2) Seed Data
3) Views & Triggers
4) Functions & Stored Procedures
5) Sample Queries (optional)

Notes:
- Target dialect: Microsoft SQL Server (tested syntax like GETDATE(), SUSER_NAME()).
- Each section is separated by GO statements for SSMS/Azure Data Studio.
- Minor fix applied: comparisons to NULL changed to IS NULL / IS NOT NULL in sample queries.
- Original file encodings detected: tables:utf-8, data:cp1252, views_triggers:cp1252, func_proc:utf-8, queries:cp1252
*/


/* ===== SCHEMA / TABLES ===== */

CREATE DATABASE CLUB;

USE CLUB;

-- SOCIO
CREATE TABLE SOCIO (
    IDSOCIO INT PRIMARY KEY,
    NOMBRE VARCHAR(100)  NOT NULL,
    APELLIDO VARCHAR(100) NOT NULL,
    DOCUMENTO VARCHAR(20) NOT NULL,
    FECHAALTA DATE NOT NULL,
    ESTADO INT NOT NULL DEFAULT 1 CHECK (ESTADO IN (0,1))
	);

-- CUOTA
CREATE TABLE CUOTA (
    IDCUOTA INT PRIMARY KEY,
    PRECIO INT NOT NULL,
    FECHAVENC DATE NOT NULL,
    IDSOCIO INT NOT NULL,
	ESTADO INT NOT NULL DEFAULT 0 CHECK (ESTADO IN (0,1))
    FOREIGN KEY (IDSOCIO) REFERENCES SOCIO(IDSOCIO)
	);

-- DEPORTE
CREATE TABLE DEPORTE (
    NOMBRE VARCHAR(100) NOT NULL PRIMARY KEY,
	);

-- EQUIPO
CREATE TABLE EQUIPO (
    IDEQUIPO INT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    ESTADO INT NOT NULL DEFAULT 1 CHECK (ESTADO IN (0,1)),
    DEPORTE VARCHAR (100) NOT NULL,
    FOREIGN KEY (DEPORTE) REFERENCES DEPORTE(NOMBRE)
	);

-- JUGADORES
CREATE TABLE JUGADOR (
    IDJUGADOR INT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    APELLIDO VARCHAR(100) NOT NULL,
    DOCUMENTO VARCHAR(20) NOT NULL,
    IDEQUIPO INT NOT NULL,
    FOREIGN KEY (IDEQUIPO) REFERENCES EQUIPO(IDEQUIPO)
	);

-- EVENTO
CREATE TABLE EVENTO (
    IDEVENTO INT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    FECHA DATE NOT NULL,
    HORA TIME NOT NULL,
    LUGAR VARCHAR(100) NOT NULL
	);

--ACTIVIDAD
CREATE TABLE ACTIVIDAD (
    IDACTIVIDAD INT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    FECHA DATE NOT NULL,
    HORA TIME NOT NULL,
    LUGAR VARCHAR(100) NOT NULL
	);

-- PARTIDO
CREATE TABLE PARTIDO (
    IDPARTIDO INT PRIMARY KEY,
	IDEQUIPO INT NOT NULL,
    EQUIPOLOCAL VARCHAR (100) NOT NULL,
    EQUIPOVISITA VARCHAR (100) NOT NULL,
    FECHA DATE NOT NULL,
    HORA TIME NOT NULL,
    LUGAR VARCHAR(100) NOT NULL,
	DEPORTE VARCHAR (100),
	FOREIGN KEY (IDEQUIPO) REFERENCES EQUIPO(IDEQUIPO),
	FOREIGN KEY (DEPORTE) REFERENCES DEPORTE(NOMBRE)
	);

-- ENTRADA

CREATE TABLE ENTRADA (
    IDENTRADA INT PRIMARY KEY,
    IDSOCIO INT NOT NULL,
    PRECIO INT NOT NULL,
	IDEVENTO INT NULL,
	IDPARTIDO INT NULL,
	IDACTIVIDAD INT NULL,
    FOREIGN KEY (IDSOCIO) REFERENCES SOCIO(IDSOCIO),
	FOREIGN KEY (IDEVENTO) REFERENCES EVENTO(IDEVENTO),
	FOREIGN KEY (IDPARTIDO) REFERENCES PARTIDO(IDPARTIDO),
	FOREIGN KEY (IDACTIVIDAD) REFERENCES ACTIVIDAD(IDACTIVIDAD)
	);

-- EMPLEADOS
CREATE TABLE EMPLEADO (
    LEGAJO INT PRIMARY KEY,
    NOMBRE VARCHAR(100) NOT NULL,
    APELLIDO VARCHAR(100) NOT NULL,
    DOCUMENTO VARCHAR(20) NOT NULL,
    IDPARTIDO INT,
	IDACTIVIDAD INT,
	IDEVENTO INT,
	FOREIGN KEY (IDEVENTO) REFERENCES EVENTO(IDEVENTO),
	FOREIGN KEY (IDPARTIDO) REFERENCES PARTIDO(IDPARTIDO),
	FOREIGN KEY (IDACTIVIDAD) REFERENCES ACTIVIDAD(IDACTIVIDAD)
	);


GO


/* ===== SEED DATA ===== */

USE CLUB

--EVENTO
INSERT INTO EVENTO VALUES 
(1, 'Concierto Rock', '2024-07-01', '20:00', 'Auditorio A'),
(2, 'Feria de Libros', '2024-07-02', '10:00', 'Salón B'),
(3, 'Taller de Cocina', '2024-07-03', '15:00', 'Cocina 1'),
(4, 'Charla Motivacional', '2024-07-04', '18:00', 'Salón C'),
(5, 'Conferencia Ciencia', '2024-07-05', '09:00', 'Auditorio B'),
(6, 'Festival de Cine', '2024-07-06', '19:00', 'Cine Club'),
(7, 'Exposición Arte', '2024-07-07', '11:00', 'Galería'),
(8, 'Show de Magia', '2024-07-08', '17:00', 'Teatro 1'),
(9, 'Fiesta de la Nieve', '2024-07-09', '21:00', 'Patio Central'),
(10, 'Danza Folklórica', '2024-07-10', '20:00', 'Salón D'),
(11, 'Noche de Tango', '2024-07-11', '22:00', 'Salón E'),
(12, 'Coro Infantil', '2024-07-12', '19:30', 'Auditorio C'),
(13, 'Maratón Solidaria', '2024-07-13', '08:00', 'Plaza'),
(14, 'Torneo Ajedrez', '2024-07-14', '14:00', 'Salón F'),
(15, 'Teatro Infantil', '2024-07-15', '16:00', 'Teatro 2');

-- ACTIVIDAD
INSERT INTO ACTIVIDAD VALUES 
(1, 'Taller de teatro', '2024-07-01', '17:00', 'Salón A'),
(2, 'Zumba', '2024-07-02', '18:00', 'Gimnasio'),
(3, 'Boxeo recreativo', '2024-07-03', '19:00', 'Ring 1'),
(4, 'Pilates', '2024-07-04', '09:00', 'Sala 2'),
(5, 'Gimnasia adultos', '2024-07-05', '08:00', 'Gimnasio'),
(6, 'Slackline', '2024-07-06', '16:00', 'Parque'),
(7, 'Escalada libre', '2024-07-07', '14:00', 'Muro'),
(8, 'Ciclismo grupal', '2024-07-08', '07:00', 'Circuito'),
(9, 'Meditación guiada', '2024-07-09', '10:00', 'Sala Zen'),
(10, 'Jazz Dance', '2024-07-10', '20:00', 'Salón B'),
(11, 'Ballet clásico', '2024-07-11', '19:00', 'Salón D'),
(12, 'Capoeira', '2024-07-12', '18:30', 'Sala C'),
(13, 'Ajedrez educativo', '2024-07-13', '15:00', 'Sala F'),
(14, 'Parkour', '2024-07-14', '11:00', 'Pista'),
(15, 'Taller de canto', '2024-07-15', '13:00', 'Salón Coral');

--DEPORTE
INSERT INTO DEPORTE VALUES 
('Fútbol'),
('Básquet'),
('Vóley'),
('Tenis'),
('Hockey'),
('Rugby'),
('Natación'),
('Atletismo'),
('Ciclismo'),
('Boxeo'),
('Handball'),
('Pádel'),
('Esgrima'),
('Gimnasia'),
('Judo');

--EQUIPO
INSERT INTO EQUIPO VALUES
(1, 'UADE Fútbol', 1, 'Fútbol'),
(2, 'UADE Básquet', 1, 'Básquet'),
(3, 'UADE Vóley', 1, 'Vóley'),
(4, 'UADE Tenis', 1, 'Tenis'),
(5, 'UADE Hockey', 1, 'Hockey'),
(6, 'UADE Rugby', 1, 'Rugby'),
(7, 'UADE Natación', 1, 'Natación'),
(8, 'UADE Atletismo', 1, 'Atletismo'),
(9, 'UADE Ciclismo', 1, 'Ciclismo'),
(10, 'UADE Boxeo', 1, 'Boxeo'),
(11, 'UADE Handball', 1, 'Handball'),
(12, 'UADE Pádel', 1, 'Pádel'),
(13, 'UADE Esgrima', 1, 'Esgrima'),
(14, 'UADE Gimnasia', 1, 'Gimnasia'),
(15, 'UADE Judo', 1, 'Judo');

--JUGADORES
INSERT INTO JUGADOR VALUES 
(1, 'Lucas', 'González', '30000001', 1),
(2, 'Matías', 'Ruiz', '30000002', 1),
(3, 'Julián', 'Pérez', '30000003', 1),
(4, 'Ezequiel', 'Sánchez', '30000004', 1),
(76, 'Federico', 'López', '30000005', 1),
(5, 'Tomás', 'Gómez', '55555555', 2),
(6, 'Alan', 'Mendoza', '66666666', 2),
(7, 'Ramiro', 'Serrano', '77777777', 2),
(8, 'Bruno', 'Herrera', '88888888', 2),
(9, 'Esteban', 'Rey', '99999999', 2),
(10, 'Gael', 'Peralta', '10101010', 3),
(11, 'Nicolás', 'Benítez', '12121212', 3),
(12, 'Damián', 'Ortiz', '13131313', 3),
(13, 'Matías', 'Vega', '14141414', 3),
(14, 'Franco', 'Ibarra', '15151515', 3),
(15, 'Leandro', 'Cáceres', '16161616', 3),
(16, 'Pablo', 'Lopez', '16161617', 4),
(17, 'Raul', 'Martinez', '16161618', 4),
(18, 'Cristian', 'Nuñez', '16161619', 4),
(19, 'Marcelo', 'Perez', '16161620', 4),
(20, 'Jorge', 'Garcia', '16161621', 4),
(21, 'Sergio', 'Diaz', '16161622', 5),
(22, 'Martin', 'Ramirez', '16161623', 5),
(23, 'Lucas', 'Fernandez', '16161624', 5),
(24, 'Eduardo', 'Morales', '16161625', 5),
(25, 'Victor', 'Castro', '16161626', 5),
(26, 'Oscar', 'Silva', '16161627', 6),
(27, 'Gonzalo', 'Acosta', '16161628', 6),
(28, 'Daniel', 'Sosa', '16161629', 6),
(29, 'Adrian', 'Herrera', '16161630', 6),
(30, 'Ricardo', 'Mendez', '16161631', 6),
(31, 'Julian', 'Paz', '16161632', 7),
(32, 'Emiliano', 'Ortega', '16161633', 7),
(33, 'Maxi', 'Alvarez', '16161634', 7),
(34, 'Ezequiel', 'Rojas', '16161635', 7),
(35, 'Kevin', 'Gimenez', '16161636', 7),
(36, 'Alejo', 'Suarez', '16161637', 8),
(37, 'Rodrigo', 'Dominguez', '16161638', 8),
(38, 'Fernando', 'Iglesias', '16161639', 8),
(39, 'Lisandro', 'Delgado', '16161640', 8),
(40, 'Agustin', 'Molina', '16161641', 8),
(41, 'Benjamin', 'Luna', '16161642', 9),
(42, 'Ivan', 'Paredes', '16161643', 9),
(43, 'Thiago', 'Rios', '16161644', 9),
(44, 'Renzo', 'Sanchez', '16161645', 9),
(45, 'Lautaro', 'Campos', '16161646', 9),
(46, 'Facundo', 'Ojeda', '16161647', 10),
(47, 'Joaquin', 'Aguirre', '16161648', 10),
(48, 'Luca', 'Bravo', '16161649', 10),
(49, 'Nahuel', 'Mansilla', '16161650', 10),
(50, 'Matias', 'Ponce', '16161651', 10),
(51, 'Diego', 'Ayala', '16161652', 11),
(52, 'Enzo', 'Toledo', '16161653', 11),
(53, 'Leonardo', 'Barrios', '16161654', 11),
(54, 'Ramón', 'Ruiz', '16161655', 11),
(55, 'Esteban', 'Campos', '16161656', 11),
(56, 'Gabriel', 'Roldan', '16161657', 12),
(57, 'Elias', 'Lara', '16161658', 12),
(58, 'Damian', 'Palacios', '16161659', 12),
(59, 'Ulises', 'Vega', '16161660', 12),
(60, 'Mauricio', 'Cabrera', '16161661', 12),
(61, 'Bruno', 'Navarro', '16161662', 13),
(62, 'Sebastian', 'Quiroga', '16161663', 13),
(63, 'Franco', 'Soria', '16161664', 13),
(64, 'Ignacio', 'Espinoza', '16161665', 13),
(65, 'Axel', 'Vera', '16161666', 13),
(66, 'Valentin', 'Medina', '16161667', 14),
(67, 'Tomas', 'Farias', '16161668', 14),
(68, 'Lorenzo', 'Ramos', '16161669', 14),
(69, 'Luciano', 'Gallo', '16161670', 14),
(70, 'Nicolas', 'Benitez', '16161671', 14),
(71, 'Ismael', 'Peralta', '16161672', 15),
(72, 'Federico', 'Bustos', '16161673', 15),
(73, 'Emanuel', 'Rios', '16161674', 15),
(74, 'Santiago', 'Vidal', '16161675', 15),
(75, 'Ignacio', 'Montes', '16161676', 15);


--PARTIDO
INSERT INTO PARTIDO VALUES 
(1, 1, 'UADE', 'UCA', '2024-07-01', '17:00', 'Estadio A', 'Fútbol'),
(2, 11, 'UBA', 'UADE', '2024-07-02', '18:00', 'Estadio B', 'Handball'),
(3, 2, 'UADE', 'UNLA', '2024-07-03', '19:00', 'Estadio C', 'Básquet'),
(4, 3, 'UTN', 'UADE', '2024-07-04', '20:00', 'Estadio A', 'Vóley'),
(5, 4, 'UADE', 'UNLP', '2024-07-05', '21:00', 'Estadio B', 'Tenis'),
(6, 5, 'KENEDY', 'UADE', '2024-07-06', '17:00', 'Estadio C', 'Hockey'),
(7, 6, 'UADE', 'DITELA', '2024-07-07', '18:00', 'Estadio A', 'Rugby'),
(8, 7, 'UNLP', 'UADE', '2024-07-08', '19:00', 'Estadio B', 'Natación'),
(9, 8, 'UADE', 'ITBA', '2024-07-09', '20:00', 'Estadio C', 'Atletismo'),
(10, 9, 'DITELA', 'UADE', '2024-07-10', '21:00', 'Estadio A', 'Ciclismo'),
(11, 10, 'UADE', 'UTN', '2024-07-11', '18:00', 'Estadio B', 'Boxeo'),
(12, 12, 'ITBA', 'UADE', '2024-07-12', '17:30', 'Estadio C', 'Pádel'),
(13, 13, 'UADE', 'UBA', '2024-07-13', '19:30', 'Estadio A', 'Esgrima'),
(14, 14, 'UNLA', 'UADE', '2024-07-14', '20:30', 'Estadio B', 'Gimnasia'),
(15, 15, 'UADE', 'UCA', '2024-07-15', '21:30', 'Estadio C', 'Judo');


--EMPLEADOS
INSERT INTO EMPLEADO VALUES 
(1, 'Roberto', 'Méndez', '88888881', 1, NULL, NULL),
(2, 'Santiago', 'López', '88888882', NULL, 1, NULL),
(3, 'Paula', 'Reyes', '88888883', NULL, NULL, 1),
(4, 'Juliana', 'Sosa', '88888884', 2, NULL, NULL),
(5, 'Gustavo', 'Ferreyra', '88888885', NULL, 2, NULL),
(6, 'Milagros', 'Navarro', '88888886', NULL, NULL, 2),
(7, 'Brenda', 'Vera', '88888887', 3, NULL, NULL),
(8, 'Facundo', 'Leiva', '88888888', NULL, 3, NULL),
(9, 'Luana', 'Arias', '88888889', NULL, NULL, 3),
(10, 'Joaquín', 'Ojeda', '88888890', 4, NULL, NULL),
(11, 'Martina', 'Gómez', '88888891', NULL, 4, NULL),
(12, 'Axel', 'Villalba', '88888892', NULL, NULL, 4),
(13, 'Natalia', 'Acosta', '88888893', 5, NULL, NULL),
(14, 'Julio', 'Moreno', '88888894', NULL, 5, NULL),
(15, 'Emilia', 'Quiroga', '88888895', NULL, NULL, 5);

--SOCIOS
INSERT INTO SOCIO VALUES 
(1, 'Juan', 'Pérez', '12345678', '2024-06-01', 1),
(2, 'Ana', 'Gómez', '23456789', '2024-06-02', 1),
(3, 'Luis', 'Martínez', '34567890', '2024-06-03', 1),
(4, 'Lucía', 'Fernández', '45678901', '2024-06-04', 1),
(5, 'Pedro', 'López', '56789012', '2024-06-05', 1),
(6, 'Carla', 'Torres', '67890123', '2024-06-06', 1),
(7, 'Sofía', 'Ramírez', '78901234', '2024-06-07', 1),
(8, 'Martín', 'Silva', '89012345', '2024-06-08', 1),
(9, 'Elena', 'Morales', '90123456', '2024-06-09', 1),
(10, 'Diego', 'Sosa', '01234567', '2024-06-10', 1),
(11, 'Valeria', 'Herrera', '11223344', '2024-06-11', 1),
(12, 'Matías', 'Giménez', '22334455', '2024-06-12', 1),
(13, 'Laura', 'Ríos', '33445566', '2024-06-13', 1),
(14, 'Nicolás', 'Castro', '44556677', '2024-06-14', 1),
(15, 'Camila', 'Vega', '55667788', '2024-06-15', 1);


--CUOTAS
INSERT INTO CUOTA VALUES
(1, 5000, '2024-06-28', 1, 1),
(2, 5000, '2024-07-28', 2, 0),
(3, 5000, '2024-05-28', 3, 1),
(4, 5000, '2024-08-28', 4, 0),
(5, 5000, '2024-04-28', 5, 1),
(6, 5000, '2024-06-28', 6, 0),
(7, 5000, '2024-09-28', 7, 1),
(8, 5000, '2024-05-28', 8, 0),
(9, 5000, '2024-07-28', 9, 1),
(10, 5000, '2024-03-28', 10, 0),
(11, 5000, '2024-10-28', 11, 1),
(12, 5000, '2024-06-28', 12, 0),
(13, 5000, '2024-08-28', 13, 0),
(14, 5000, '2024-05-28', 14, 1),
(15, 5000, '2024-07-28', 15, 0);


--ENTRADAS
INSERT INTO ENTRADA VALUES 
(1, 1, 1000, 1, NULL, NULL),
(2, 2, 1200, 2, NULL, NULL),
(3, 3, 1500, NULL, 1, NULL),
(4, 4, 1300, NULL, NULL, 1),
(5, 5, 1100, 3, NULL, NULL),
(6, 6, 1400, NULL, 2, NULL),
(7, 7, 1600, NULL, NULL, 2),
(8, 8, 1000, 4, NULL, NULL),
(9, 9, 1200, NULL, 3, NULL),
(10, 10, 1300, NULL, NULL, 3),
(11, 11, 1000, 5, NULL, NULL),
(12, 12, 1400, NULL, 4, NULL),
(13, 13, 1200, NULL, NULL, 4),
(14, 14, 1100, 6, NULL, NULL),
(15, 15, 1300, NULL, 5, NULL);

USE CLUB


GO


/* ===== VIEWS & TRIGGERS ===== */

USE CLUB
--- VISTAS ---

-- Vista 1: Jugadores por deporte
CREATE VIEW JugadoresPorDeporte AS
SELECT
    JUGADOR.IDJUGADOR,
    JUGADOR.NOMBRE AS NombreJugador,
    JUGADOR.APELLIDO AS ApellidoJugador,
    JUGADOR.DOCUMENTO AS DocumentoJugador,
    EQUIPO.NOMBRE AS NombreEquipo,
    DEPORTE.NOMBRE AS NombreDeporte
FROM
    JUGADOR
    INNER JOIN EQUIPO ON JUGADOR.IDEQUIPO = EQUIPO.IDEQUIPO
    INNER JOIN DEPORTE ON EQUIPO.DEPORTE = DEPORTE.NOMBRE;

-- Vista 2: Total de socios por alta mensual
CREATE VIEW TotalSociosPorAltaMensual AS
SELECT
    YEAR(FECHAALTA) AS Año,
    MONTH(FECHAALTA) AS Mes,
    COUNT(*) AS TotalSocios
FROM
    SOCIO
GROUP BY
    YEAR(FECHAALTA),
    MONTH(FECHAALTA);

-- Ver todos los jugadores por deporte
SELECT * FROM JugadoresPorDeporte;

-- Ver solo los jugadores de Fútbol
SELECT *
FROM JugadoresPorDeporte
WHERE NombreDeporte = 'Fútbol';


-- Ver total de socios por mes/año de alta
SELECT * FROM TotalSociosPorAltaMensual;


--TRIGGERS--

USE CLUB;


--Trigger de cambio de estado
CREATE TABLE AUDITORIA_SOCIOS (
    IDAUDITORIA INT PRIMARY KEY IDENTITY(1,1),
    IDSOCIO INT,
    ESTADO_ANTERIOR BIT,
    ESTADO_NUEVO BIT,
    FECHA_CAMBIO DATETIME DEFAULT GETDATE(),
    USUARIO_CAMBIO NVARCHAR(50) DEFAULT SUSER_NAME()
);

CREATE TRIGGER AUDITARESTADOSOCIO
ON SOCIO
AFTER UPDATE
AS
BEGIN
    INSERT INTO AUDITORIA_SOCIOS (IDSOCIO, ESTADO_ANTERIOR, ESTADO_NUEVO)
    SELECT
        D.IDSOCIO,
        D.ESTADO,
        I.ESTADO
    FROM
        DELETED D
    JOIN
        INSERTED I ON D.IDSOCIO = I.IDSOCIO
    WHERE
        D.ESTADO <> I.ESTADO;
END;

--pruebas de el trigger anterior

-- Ver estado actual del socio
SELECT IDSOCIO, NOMBRE, APELLIDO, ESTADO FROM SOCIO WHERE IDSOCIO = 1;

-- Ver tabla de auditoría
SELECT * FROM AUDITORIA_SOCIOS;

-- Cambiar estado a inactivo
UPDATE SOCIO SET ESTADO = 0 WHERE IDSOCIO = 1;

-- Verificar cambios
SELECT IDSOCIO, NOMBRE, APELLIDO, ESTADO FROM SOCIO WHERE IDSOCIO = 1;

-- Cambiar estado a activo
UPDATE SOCIO SET ESTADO = 1 WHERE IDSOCIO = 1;

-- Cambiar solo el nombre (no debe dejar registro)
UPDATE SOCIO SET NOMBRE = 'Juan Carlos' WHERE IDSOCIO = 1;


--Triggor para eliminar socios
CREATE TABLE AUDITORIA_BAJAS_SOCIOS (
    IDREGISTROBAJA INT PRIMARY KEY IDENTITY(1,1),
    IDSOCIO_ELIMINADO INT,
    NOMBRE_ELIMINADO NVARCHAR(100),
    APELLIDO_ELIMINADO NVARCHAR(100),
    DOCUMENTO_ELIMINADO NVARCHAR(50),
    FECHA_BAJA DATETIME DEFAULT GETDATE(),
    USUARIO_BAJA NVARCHAR(50) DEFAULT SUSER_NAME()
);

CREATE TRIGGER TRG_AUDITARBAJASOCIO
ON SOCIO
AFTER DELETE
AS
BEGIN
    INSERT INTO AUDITORIA_BAJAS_SOCIOS (IDSOCIO_ELIMINADO, NOMBRE_ELIMINADO, APELLIDO_ELIMINADO, DOCUMENTO_ELIMINADO)
    SELECT
        D.IDSOCIO,
        D.NOMBRE,
        D.APELLIDO,
        D.DOCUMENTO
    FROM DELETED D;
END;

--prubas del trigger anteror
-- Ver socios actuales
SELECT IDSOCIO, NOMBRE, APELLIDO FROM SOCIO;
SELECT * FROM AUDITORIA_BAJAS_SOCIOS;

-- Eliminar dependencias y luego el socio
DELETE FROM ENTRADA WHERE IDSOCIO = 2;
DELETE FROM CUOTA WHERE IDSOCIO = 2;
DELETE FROM SOCIO WHERE IDSOCIO = 2;

-- Verificar baja registrada
SELECT IDSOCIO, NOMBRE, APELLIDO FROM SOCIO;

--Intentar eliminar un socio que no existe (no genera error ni auditoría)
DELETE FROM SOCIO WHERE IDSOCIO = 999;


GO


/* ===== FUNCTIONS & STORED PROCEDURES ===== */

USE CLUB 

-- FUNCION: Cantidad de cuotas pagadas por unsocio
CREATE FUNCTION CANTIDADCUOTASPAGADAS (@IDSOCIO INT)
RETURNS INT
AS
BEGIN
    DECLARE @CANTIDAD INT;

    SELECT @CANTIDAD = COUNT(*)
    FROM CUOTA
    WHERE IDSOCIO = @IDSOCIO AND ESTADO = 1;

    RETURN @CANTIDAD;
END;

-- Ejemplo de uso	:
SELECT DBO.CANTIDADCUOTASPAGADAS(1) AS CUOTASPAGADAS;


-- PROCEDIMIENTO ALMACENADO: agregar una entrada 
CREATE PROCEDURE AGREGARENTRADAEVENTO
    @IDENTRADA INT,
    @IDSOCIO INT,
    @PRECIO INT,
    @IDEVENTO INT
AS
BEGIN
    INSERT INTO ENTRADA (IDENTRADA, IDSOCIO, PRECIO, IDEVENTO)
    VALUES (@IDENTRADA, @IDSOCIO, @PRECIO, @IDEVENTO);
END;

--Ejemplo de uso:
EXEC AGREGARENTRADAEVENTO 20, 3, 800, 2;


GO


/* ===== SAMPLE QUERIES (optional to run) ===== */

-- You can run these after the DB is created
use CLUB

--1. llamar a los socios activos, no activos y todos

SELECT * FROM SOCIO WHERE ESTADO = 1;
SELECT * FROM SOCIO WHERE ESTADO = 0;
SELECT * FROM SOCIO;

--2. mostrar socios con cuotas vencidas e impagas

SELECT *
FROM SOCIO
WHERE IDSOCIO IN (
    SELECT IDSOCIO
    FROM CUOTA
    WHERE ESTADO = 0 AND FECHAVENC < GETDATE()
);

--3. ver todas las entradas compradas por un/varios socio/s

SELECT SOCIO.NOMBRE, SOCIO.APELLIDO, SOCIO.DOCUMENTO, ENTRADA.*
FROM ENTRADA
JOIN SOCIO ON ENTRADA.IDSOCIO = SOCIO.IDSOCIO
WHERE SOCIO.IDSOCIO = 1 OR SOCIO.IDSOCIO = 4;

--4. actividades programadas para una fecha determinada

SELECT 'ACTIVIDAD' AS TIPO, NOMBRE, FECHA, HORA, LUGAR FROM ACTIVIDAD WHERE FECHA = '2024-07-05'
UNION ALL
SELECT 'PARTIDO' AS TIPO, DEPORTE, FECHA, HORA, LUGAR FROM PARTIDO WHERE FECHA = '2024-07-05'
UNION ALL
SELECT 'EVENTO' AS TIPO, NOMBRE, FECHA, HORA, LUGAR FROM EVENTO WHERE FECHA = '2024-07-05'
ORDER BY HORA;

--5. jugadores de un equipo especifico

SELECT * FROM JUGADOR WHERE IDEQUIPO = 1;

--6. empleados asignados a eventos o actividades especificas

SELECT *
FROM EMPLEADO
WHERE IDEVENTO = 2
   OR IDACTIVIDAD IS NULL
   OR IDPARTIDO IS NULL

--7. agenda completa de eventos/partidos/actividades ordenada por fecha y hora

SELECT 'EVENTO' AS TIPO, IDEVENTO AS ID, NOMBRE, FECHA, HORA, LUGAR FROM EVENTO
UNION ALL
SELECT 'PARTIDO' AS TIPO, IDPARTIDO AS ID, DEPORTE AS NOMBRE, FECHA, HORA, LUGAR FROM PARTIDO
UNION ALL 
SELECT 'ACTIVIDAD' AS TIPO, IDACTIVIDAD AS ID, NOMBRE, FECHA, HORA, LUGAR FROM ACTIVIDAD
ORDER BY FECHA, HORA;

--8. mostrar socios que nunca comprar entradas

SELECT SOCIO.* FROM SOCIO
LEFT JOIN 
ENTRADA ON SOCIO.IDSOCIO = ENTRADA.IDSOCIO WHERE ENTRADA.IDENTRADA IS NULL;

--9 mostrar la cantidad de jugadores por quipo

SELECT EQUIPO.IDEQUIPO, EQUIPO.NOMBRE, COUNT(JUGADOR.IDJUGADOR) AS CANTJUGADORES FROM EQUIPO
LEFT JOIN 
JUGADOR ON EQUIPO.IDEQUIPO = JUGADOR.IDEQUIPO
GROUP BY EQUIPO.IDEQUIPO, EQUIPO.NOMBRE
ORDER BY CANTJUGADORES DESC;

--10. mostrar todos los jugadores de un equipo específico, con sus datos y el deporte que practica ese equipo
USE CLUB

SELECT 
    JUGADOR.IDJUGADOR,
    JUGADOR.NOMBRE,
    JUGADOR.APELLIDO,
    JUGADOR.DOCUMENTO,
    EQUIPO.NOMBRE AS EQUIPO,
    DEPORTE.NOMBRE AS DEPORTE
FROM JUGADOR
JOIN EQUIPO ON JUGADOR.IDEQUIPO = EQUIPO.IDEQUIPO
JOIN DEPORTE ON EQUIPO.DEPORTE = DEPORTE.NOMBRE WHERE EQUIPO.NOMBRE = 'UADE Hockey' OR EQUIPO.NOMBRE = 'UADE Rugby';  

--11  Partido, actividad o evento que mas entradas vendio

SELECT 'Partido' AS TIPO, IDPARTIDO AS IDTIPO, COUNT(*) AS VENDIDAS FROM ENTRADA WHERE IDPARTIDO IS NOT NULL
GROUP BY IDPARTIDO
UNION ALL
SELECT 'Actividad', IDACTIVIDAD, COUNT(*) FROM ENTRADA WHERE IDACTIVIDAD IS NOT NULL
GROUP BY IDACTIVIDAD
UNION ALL
SELECT 'Evento', IDEVENTO, COUNT(*) FROM ENTRADA WHERE IDEVENTO IS NOT NULL
GROUP BY IDEVENTO;

--una vez viso cual es elque mas entradas se vendio, con estos podes ver la informacion del partido, evento o actividad
SELECT * FROM PARTIDO WHERE IDPARTIDO = 0;
SELECT * FROM ACTIVIDAD WHERE IDACTIVIDAD = 0;
SELECT * FROM EVENTO WHERE IDEVENTO = 0;


GO
