-- Insert initial data into OLTP tables
\c club_analytics;

-- Insert deporte data
INSERT INTO raw.deporte VALUES 
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

-- Insert equipo data
INSERT INTO raw.equipo VALUES
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

-- Insert socio data
INSERT INTO raw.socio VALUES 
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

-- Insert evento data
INSERT INTO raw.evento VALUES 
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

-- Insert actividad data
INSERT INTO raw.actividad VALUES 
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

-- Insert partido data
INSERT INTO raw.partido VALUES 
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

-- Insert cuota data
INSERT INTO raw.cuota VALUES
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

-- Insert entrada data
INSERT INTO raw.entrada VALUES 
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


