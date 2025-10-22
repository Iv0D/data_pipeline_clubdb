-- Initialize Club Analytics Database
-- This script creates the OLTP tables and loads initial data

-- Create database and schema
CREATE DATABASE club_analytics;
\c club_analytics;

-- Create schemas
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Create OLTP tables (converted from SQL Server to PostgreSQL)
CREATE TABLE raw.socio (
    idsocio INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    fechaalta DATE NOT NULL,
    estado INT NOT NULL DEFAULT 1 CHECK (estado IN (0,1))
);

CREATE TABLE raw.cuota (
    idcuota INT PRIMARY KEY,
    precio INT NOT NULL,
    fechavenc DATE NOT NULL,
    idsocio INT NOT NULL,
    estado INT NOT NULL DEFAULT 0 CHECK (estado IN (0,1)),
    FOREIGN KEY (idsocio) REFERENCES raw.socio(idsocio)
);

CREATE TABLE raw.deporte (
    nombre VARCHAR(100) NOT NULL PRIMARY KEY
);

CREATE TABLE raw.equipo (
    idequipo INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado INT NOT NULL DEFAULT 1 CHECK (estado IN (0,1)),
    deporte VARCHAR(100) NOT NULL,
    FOREIGN KEY (deporte) REFERENCES raw.deporte(nombre)
);

CREATE TABLE raw.jugador (
    idjugador INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    idequipo INT NOT NULL,
    FOREIGN KEY (idequipo) REFERENCES raw.equipo(idequipo)
);

CREATE TABLE raw.evento (
    idevento INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    lugar VARCHAR(100) NOT NULL
);

CREATE TABLE raw.actividad (
    idactividad INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    lugar VARCHAR(100) NOT NULL
);

CREATE TABLE raw.partido (
    idpartido INT PRIMARY KEY,
    idequipo INT NOT NULL,
    equipolocal VARCHAR(100) NOT NULL,
    equipovisita VARCHAR(100) NOT NULL,
    fecha DATE NOT NULL,
    hora TIME NOT NULL,
    lugar VARCHAR(100) NOT NULL,
    deporte VARCHAR(100),
    FOREIGN KEY (idequipo) REFERENCES raw.equipo(idequipo),
    FOREIGN KEY (deporte) REFERENCES raw.deporte(nombre)
);

CREATE TABLE raw.entrada (
    identrada INT PRIMARY KEY,
    idsocio INT NOT NULL,
    precio INT NOT NULL,
    idevento INT NULL,
    idpartido INT NULL,
    idactividad INT NULL,
    FOREIGN KEY (idsocio) REFERENCES raw.socio(idsocio),
    FOREIGN KEY (idevento) REFERENCES raw.evento(idevento),
    FOREIGN KEY (idpartido) REFERENCES raw.partido(idpartido),
    FOREIGN KEY (idactividad) REFERENCES raw.actividad(idactividad)
);

CREATE TABLE raw.empleado (
    legajo INT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    documento VARCHAR(20) NOT NULL,
    idpartido INT,
    idactividad INT,
    idevento INT,
    FOREIGN KEY (idevento) REFERENCES raw.evento(idevento),
    FOREIGN KEY (idpartido) REFERENCES raw.partido(idpartido),
    FOREIGN KEY (idactividad) REFERENCES raw.actividad(idactividad)
);


