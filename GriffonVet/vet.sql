/* =========================================================
   BASE DE DATOS: VETERINARIA / PELUQUERIA CANINA
   MOTOR: SQL SERVER
   OBJETIVO:
   - Gestion de clientes y administradores
   - Gestion de mascotas
   - Reserva de turnos de peluqueria
   - Catalogo de productos
   - Historia clinica completa por mascota
   ========================================================= */


/* =========================================================
   DROP TABLES EN ORDEN CORRECTO
   Se eliminan primero las tablas hijas y al final las padres
   ========================================================= */

IF OBJECT_ID('dbo.archivos_clinicos', 'U') IS NOT NULL DROP TABLE dbo.archivos_clinicos;
IF OBJECT_ID('dbo.estudios_clinicos', 'U') IS NOT NULL DROP TABLE dbo.estudios_clinicos;
IF OBJECT_ID('dbo.tratamientos', 'U') IS NOT NULL DROP TABLE dbo.tratamientos;

IF OBJECT_ID('dbo.enfermedades_mascota', 'U') IS NOT NULL DROP TABLE dbo.enfermedades_mascota;
IF OBJECT_ID('dbo.vacunas_mascota', 'U') IS NOT NULL DROP TABLE dbo.vacunas_mascota;
IF OBJECT_ID('dbo.desparasitaciones_mascota', 'U') IS NOT NULL DROP TABLE dbo.desparasitaciones_mascota;
IF OBJECT_ID('dbo.alergias_mascota', 'U') IS NOT NULL DROP TABLE dbo.alergias_mascota;
IF OBJECT_ID('dbo.peso_mascota', 'U') IS NOT NULL DROP TABLE dbo.peso_mascota;

IF OBJECT_ID('dbo.consultas_clinicas', 'U') IS NOT NULL DROP TABLE dbo.consultas_clinicas;
IF OBJECT_ID('dbo.historias_clinicas', 'U') IS NOT NULL DROP TABLE dbo.historias_clinicas;

IF OBJECT_ID('dbo.reservas', 'U') IS NOT NULL DROP TABLE dbo.reservas;

IF OBJECT_ID('dbo.medicamentos', 'U') IS NOT NULL DROP TABLE dbo.medicamentos;
IF OBJECT_ID('dbo.enfermedades', 'U') IS NOT NULL DROP TABLE dbo.enfermedades;
IF OBJECT_ID('dbo.vacunas', 'U') IS NOT NULL DROP TABLE dbo.vacunas;
IF OBJECT_ID('dbo.desparasitaciones', 'U') IS NOT NULL DROP TABLE dbo.desparasitaciones;
IF OBJECT_ID('dbo.alergias', 'U') IS NOT NULL DROP TABLE dbo.alergias;

IF OBJECT_ID('dbo.agenda_bloqueos', 'U') IS NOT NULL DROP TABLE dbo.agenda_bloqueos;
IF OBJECT_ID('dbo.horarios_atencion', 'U') IS NOT NULL DROP TABLE dbo.horarios_atencion;
IF OBJECT_ID('dbo.productos', 'U') IS NOT NULL DROP TABLE dbo.productos;
IF OBJECT_ID('dbo.servicios', 'U') IS NOT NULL DROP TABLE dbo.servicios;

IF OBJECT_ID('dbo.mascotas', 'U') IS NOT NULL DROP TABLE dbo.mascotas;
IF OBJECT_ID('dbo.usuarios', 'U') IS NOT NULL DROP TABLE dbo.usuarios;
GO

-- =========================================================
-- TABLA: usuarios
-- Guarda clientes y administradores del sistema
-- =========================================================
CREATE TABLE dbo.usuarios (
    id_usuario INT IDENTITY(1,1) PRIMARY KEY,-- Identificador unico del usuario
    nombre NVARCHAR(100) NOT NULL,-- Nombre del usuario
    apellido NVARCHAR(100) NOT NULL,-- Apellido del usuario
    email NVARCHAR(150) NOT NULL UNIQUE,-- Correo electronico, se usa para login y contacto
    telefono NVARCHAR(30) NULL,-- Telefono del usuario
    password_hash NVARCHAR(255) NOT NULL,-- Contraseña en formato hash, nunca guardar contraseña plana
    rol NVARCHAR(20) NOT NULL,-- Rol del usuario: CLIENTE o ADMIN
    activo BIT NOT NULL DEFAULT 1,-- Indica si el usuario esta habilitado en el sistema
    fecha_alta DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha de alta del usuario

    CONSTRAINT CK_usuarios_rol
        CHECK (rol IN ('CLIENTE', 'ADMIN'))
);
GO

-- =========================================================
-- TABLA: mascotas
-- Guarda las mascotas registradas por cada cliente
-- =========================================================
CREATE TABLE dbo.mascotas (
    id_mascota INT IDENTITY(1,1) PRIMARY KEY,-- Identificador unico de la mascota
    id_usuario INT NOT NULL, -- Dueño de la mascota (cliente)
    nombre NVARCHAR(100) NOT NULL,-- Nombre de la mascota
    especie NVARCHAR(50) NOT NULL,-- Ejemplo: Perro, Gato
    raza NVARCHAR(100) NULL,-- Raza de la mascota
    tamanio NVARCHAR(20) NULL,-- Tamaño: Chico, Mediano, Grande
    edad INT NULL,-- Edad de la mascota
    peso DECIMAL(10,2) NULL,-- Peso actual aproximado
    sexo NVARCHAR(20) NULL,-- Macho / Hembra
    tipo_pelaje NVARCHAR(100) NULL,-- Largo, corto, rizado, etc.
    alergias_general NVARCHAR(500) NULL,-- Campo resumen rapido de alergias
    comportamiento NVARCHAR(300) NULL,-- Ejemplo: nervioso, docil, agresivo, etc.
    observaciones NVARCHAR(1000) NULL,-- Observaciones generales cargadas por el cliente o admin
    activo BIT NOT NULL DEFAULT 1,-- Baja logica de la mascota
    fecha_registro DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha en la que se registro la mascota

    CONSTRAINT FK_mascotas_usuarios
        FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario),
    CONSTRAINT CK_mascotas_tamanio
        CHECK (tamanio IN ('CHICO', 'MEDIANO', 'GRANDE') OR tamanio IS NULL),
    CONSTRAINT CK_mascotas_sexo
        CHECK (sexo IN ('MACHO', 'HEMBRA') OR sexo IS NULL)
);
GO

-- =========================================================
-- TABLA: servicios
-- Define los servicios disponibles de peluqueria/veterinaria
-- =========================================================
CREATE TABLE dbo.servicios (
    id_servicio INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del servicio
    nombre NVARCHAR(100) NOT NULL,-- Nombre del servicio: baño, corte, etc.
    descripcion NVARCHAR(500) NULL,-- Descripcion del servicio
    duracion_minutos INT NOT NULL,-- Duracion estimada del servicio
    precio_base DECIMAL(12,2) NOT NULL,-- Precio base del servicio
    activo BIT NOT NULL DEFAULT 1-- Indica si el servicio esta disponible
);
GO

-- =========================================================
-- TABLA: productos
-- Catalogo de productos visibles en la pagina
-- No incluye carrito, solo exhibicion y gestion
-- =========================================================
CREATE TABLE dbo.productos (
    id_producto INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del producto
    nombre NVARCHAR(150) NOT NULL,-- Nombre comercial del producto
    descripcion NVARCHAR(1000) NULL,-- Descripcion del producto
    precio DECIMAL(12,2) NOT NULL, -- Precio del producto
    categoria NVARCHAR(100) NOT NULL,-- Categoria: alimento, shampoo, juguete, etc.
    imagen_url NVARCHAR(500) NULL, -- URL o ruta de imagen del producto
    stock INT NULL,-- Stock opcional, por si queres mostrar disponibilidad
    activo BIT NOT NULL DEFAULT 1,-- Indica si el producto esta visible
    fecha_alta DATETIME NOT NULL DEFAULT GETDATE()-- Fecha de alta del producto
);
GO

-- =========================================================
-- TABLA: horarios_atencion
-- Define los horarios regulares del negocio por dia de semana
-- =========================================================
CREATE TABLE dbo.horarios_atencion (
    id_horario INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro de horario
    dia_semana INT NOT NULL,-- Dia de la semana: 1=Lunes ... 7=Domingo
    hora_apertura TIME NOT NULL,-- Hora de inicio de atencion
    hora_cierre TIME NOT NULL,-- Hora de finalizacion de atencion
    duracion_turno_minutos INT NOT NULL,-- Duracion base de cada turno
    activo BIT NOT NULL DEFAULT 1,-- Permite habilitar/deshabilitar un horario

    CONSTRAINT CK_horarios_atencion_dia_semana
        CHECK (dia_semana BETWEEN 1 AND 7),
    CONSTRAINT CK_horarios_atencion_horas
        CHECK (hora_apertura < hora_cierre)
);
GO

-- =========================================================
-- TABLA: agenda_bloqueos
-- Sirve para bloquear fechas o franjas horarias
-- Ej: feriados, cierre por mantenimiento, etc.
-- =========================================================
CREATE TABLE dbo.agenda_bloqueos (
    id_bloqueo INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del bloqueo
    fecha DATE NOT NULL,-- Fecha del bloqueo
    hora_desde TIME NULL,-- Hora de inicio del bloqueo; NULL puede significar todo el dia
    hora_hasta TIME NULL, -- Hora de fin del bloqueo
    motivo NVARCHAR(300) NULL, -- Motivo del bloqueo
    activo BIT NOT NULL DEFAULT 1, -- Si el bloqueo esta vigente

    CONSTRAINT CK_agenda_bloqueos_horas
        CHECK (
            (hora_desde IS NULL AND hora_hasta IS NULL)
            OR
            (hora_desde IS NOT NULL AND hora_hasta IS NOT NULL AND hora_desde < hora_hasta)
        )
);
GO

-- =========================================================
-- TABLA: reservas
-- Guarda los turnos reservados por los clientes
-- =========================================================
CREATE TABLE dbo.reservas (
    id_reserva INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de la reserva
    id_usuario INT NOT NULL,-- Cliente que realiza la reserva
    id_mascota INT NOT NULL,-- Mascota para la cual se reserva el turno
    id_servicio INT NOT NULL,-- Servicio solicitado
    fecha DATE NOT NULL,-- Fecha del turno
    hora TIME NOT NULL, -- Hora del turno
    estado NVARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- Estado de la reserva: PENDIENTE, CONFIRMADA, CANCELADA, ATENDIDA
    observaciones NVARCHAR(1000) NULL, -- Comentarios extra de la reserva
    google_calendar_event_id NVARCHAR(255) NULL,-- Id del evento creado en Google Calendar
    fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha de creacion de la reserva

    CONSTRAINT FK_reservas_usuarios
        FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario),
    CONSTRAINT FK_reservas_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota),
    CONSTRAINT FK_reservas_servicios
        FOREIGN KEY (id_servicio) REFERENCES dbo.servicios(id_servicio),
    CONSTRAINT CK_reservas_estado
        CHECK (estado IN ('PENDIENTE', 'CONFIRMADA', 'CANCELADA', 'ATENDIDA'))
);
GO

-- =========================================================
-- TABLA: historias_clinicas
-- Cabecera de la historia clinica de una mascota
-- Una mascota tiene una historia clinica principal
-- =========================================================
CREATE TABLE dbo.historias_clinicas (
    id_historia_clinica INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de la historia clinica
    id_mascota INT NOT NULL UNIQUE,-- Relacion 1 a 1 con la mascota
    fecha_apertura DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha de apertura de la historia clinica
    observaciones_generales NVARCHAR(2000) NULL,-- Observaciones generales permanentes del paciente
    activo BIT NOT NULL DEFAULT 1,-- Indica si la historia clinica esta activa

    CONSTRAINT FK_historias_clinicas_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota)
);
GO

-- =========================================================
-- TABLA: consultas_clinicas
-- Cada fila representa una consulta/control/atencion
-- registrada por un administrador para una mascota
-- =========================================================
CREATE TABLE dbo.consultas_clinicas (
    id_consulta INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de la consulta clinica
    id_historia_clinica INT NOT NULL,-- Historia clinica a la que pertenece la consulta
    fecha DATETIME NOT NULL DEFAULT GETDATE(), -- Fecha y hora de la consulta
    motivo_consulta NVARCHAR(500) NULL, -- Motivo por el cual se atendio al paciente
    anamnesis NVARCHAR(MAX) NULL,-- Informacion recopilada del dueño/paciente
    examen_general NVARCHAR(MAX) NULL,-- Hallazgos del examen fisico general
    diagnostico NVARCHAR(MAX) NULL,-- Diagnostico o impresion clinica
    tratamiento NVARCHAR(MAX) NULL,-- Tratamiento general indicado
    observaciones NVARCHAR(MAX) NULL,-- Observaciones complementarias
    id_admin INT NOT NULL,-- Administrador/veterinario que registró la consulta

    CONSTRAINT FK_consultas_clinicas_historias
        FOREIGN KEY (id_historia_clinica) REFERENCES dbo.historias_clinicas(id_historia_clinica),
    CONSTRAINT FK_consultas_clinicas_admin
        FOREIGN KEY (id_admin) REFERENCES dbo.usuarios(id_usuario)
);
GO

-- =========================================================
-- TABLA: peso_mascota
-- Lleva el historial de peso del paciente a lo largo del tiempo
-- =========================================================
CREATE TABLE dbo.peso_mascota (
    id_peso INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro de peso
    id_mascota INT NOT NULL,-- Mascota asociada
    fecha DATETIME NOT NULL DEFAULT GETDATE(), -- Fecha de la medicion
    peso DECIMAL(10,2) NOT NULL, -- Peso registrado
    observaciones NVARCHAR(500) NULL, -- Comentarios sobre la medicion

    CONSTRAINT FK_peso_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota)
);
GO

-- =========================================================
-- TABLA: alergias
-- Catalogo maestro de alergias posibles
-- =========================================================
CREATE TABLE dbo.alergias (
    id_alergia INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de la alergia
    nombre NVARCHAR(150) NOT NULL UNIQUE,-- Nombre de la alergia
    descripcion NVARCHAR(500) NULL-- Descripcion de la alergia
);
GO

-- =========================================================
-- TABLA: alergias_mascota
-- Relacion entre mascota y alergias registradas
-- =========================================================
CREATE TABLE dbo.alergias_mascota (
    id_alergia_mascota INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro
    id_mascota INT NOT NULL,-- Mascota afectada
    id_alergia INT NOT NULL,-- Alergia registrada
    severidad NVARCHAR(20) NULL,-- LEVE, MODERADA, GRAVE
    observaciones NVARCHAR(500) NULL,-- Comentarios sobre la alergia

    CONSTRAINT FK_alergias_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota),
    CONSTRAINT FK_alergias_mascota_alergias
        FOREIGN KEY (id_alergia) REFERENCES dbo.alergias(id_alergia),
    CONSTRAINT CK_alergias_mascota_severidad
        CHECK (severidad IN ('LEVE', 'MODERADA', 'GRAVE') OR severidad IS NULL)
);
GO

-- =========================================================
-- TABLA: vacunas
-- Catalogo maestro de vacunas
-- =========================================================
CREATE TABLE dbo.vacunas (
    id_vacuna INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de vacuna
    nombre NVARCHAR(150) NOT NULL UNIQUE,-- Nombre de la vacuna
    descripcion NVARCHAR(500) NULL-- Descripcion general
);
GO

-- =========================================================
-- TABLA: vacunas_mascota
-- Historial de vacunacion de cada mascota
-- =========================================================
CREATE TABLE dbo.vacunas_mascota (
    id_vacuna_mascota INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro de vacunacion
    id_mascota INT NOT NULL,-- Mascota vacunada
    id_vacuna INT NOT NULL,-- Vacuna aplicada
    fecha_aplicacion DATE NOT NULL,-- Fecha en la que se aplico la vacuna
    proxima_dosis DATE NULL,-- Proxima fecha sugerida
    observaciones NVARCHAR(500) NULL,-- Notas extras

    CONSTRAINT FK_vacunas_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota),
    CONSTRAINT FK_vacunas_mascota_vacunas
        FOREIGN KEY (id_vacuna) REFERENCES dbo.vacunas(id_vacuna)
);
GO

-- =========================================================
-- TABLA: desparasitaciones
-- Catalogo maestro de desparasitantes (productos o tipos)
-- Ej: antiparasitario interno, externo, marca X, etc.
-- =========================================================
CREATE TABLE dbo.desparasitaciones (
    id_desparasitacion INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del desparasitante
    nombre NVARCHAR(150) NOT NULL UNIQUE,-- Nombre del producto o tipo (ej: Ivermectina, Pipeta Frontline, etc.)
    tipo NVARCHAR(50) NULL,-- Tipo: INTERNO / EXTERNO
    descripcion NVARCHAR(500) NULL-- Descripcion general
);
GO
-- =========================================================
-- TABLA: desparasitaciones_mascota
-- Historial de desparasitaciones realizadas a cada mascota
-- Similar a vacunas_mascota
-- =========================================================
CREATE TABLE dbo.desparasitaciones_mascota (
    id_desparasitacion_mascota INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro
    id_mascota INT NOT NULL,-- Mascota desparasitada
    id_desparasitacion INT NOT NULL,-- Tipo/producto utilizado
    fecha_aplicacion DATE NOT NULL,-- Fecha en la que se realizo la desparasitacion
    proxima_dosis DATE NULL,-- Fecha recomendada para la siguiente desparasitacion
    tipo NVARCHAR(50) NULL,-- INTERNO / EXTERNO (redundante pero útil para consulta rápida)
    observaciones NVARCHAR(500) NULL,-- Comentarios adicionales (ej: reaccion, dosis especial, etc.)

    CONSTRAINT FK_desparasitaciones_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota),
    CONSTRAINT FK_desparasitaciones_mascota_desparasitaciones
        FOREIGN KEY (id_desparasitacion) REFERENCES dbo.desparasitaciones(id_desparasitacion),
    CONSTRAINT CK_desparasitaciones_tipo
        CHECK (tipo IN ('INTERNO', 'EXTERNO') OR tipo IS NULL)
);
GO
-- =========================================================
-- TABLA: enfermedades
-- Catalogo maestro de enfermedades
-- =========================================================
CREATE TABLE dbo.enfermedades (
    id_enfermedad INT IDENTITY(1,1) PRIMARY KEY,-- Identificador de enfermedad
    nombre NVARCHAR(150) NOT NULL UNIQUE,-- Nombre de la enfermedad
    descripcion NVARCHAR(500) NULL-- Descripcion general
);
GO

-- =========================================================
-- TABLA: enfermedades_mascota
-- Historial de enfermedades/diagnosticos de una mascota
-- =========================================================
CREATE TABLE dbo.enfermedades_mascota (
    id_enfermedad_mascota INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del registro
    id_mascota INT NOT NULL,-- Mascota asociada
    id_enfermedad INT NOT NULL,-- Enfermedad registrada
    fecha_diagnostico DATE NULL,-- Fecha del diagnostico
    estado NVARCHAR(20) NULL, -- ACTIVA, CURADA, CRONICA
    observaciones NVARCHAR(500) NULL,-- Comentarios adicionales

    CONSTRAINT FK_enfermedades_mascota_mascotas
        FOREIGN KEY (id_mascota) REFERENCES dbo.mascotas(id_mascota),
    CONSTRAINT FK_enfermedades_mascota_enfermedades
        FOREIGN KEY (id_enfermedad) REFERENCES dbo.enfermedades(id_enfermedad),
    CONSTRAINT CK_enfermedades_mascota_estado
        CHECK (estado IN ('ACTIVA', 'CURADA', 'CRONICA') OR estado IS NULL)
);
GO

-- =========================================================
-- TABLA: medicamentos
-- Catalogo maestro de medicamentos
-- =========================================================
CREATE TABLE dbo.medicamentos (
    id_medicamento INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del medicamento
    nombre NVARCHAR(150) NOT NULL UNIQUE,-- Nombre del medicamento
    descripcion NVARCHAR(500) NULL-- Descripcion del medicamento
);
GO

-- =========================================================
-- TABLA: tratamientos
-- Tratamientos/medicacion indicados dentro de una consulta
-- =========================================================
CREATE TABLE dbo.tratamientos (
    id_tratamiento INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del tratamiento
    id_consulta INT NOT NULL,-- Consulta clinica asociada
    id_medicamento INT NULL,-- Medicamento asociado si corresponde
    dosis NVARCHAR(100) NULL,-- Dosis indicada
    frecuencia NVARCHAR(100) NULL,-- Frecuencia de administracion
    duracion_dias INT NULL,-- Cuantos dias dura el tratamiento
    indicaciones NVARCHAR(1000) NULL,-- Instrucciones de uso o comentarios

    CONSTRAINT FK_tratamientos_consultas
        FOREIGN KEY (id_consulta) REFERENCES dbo.consultas_clinicas(id_consulta),
    CONSTRAINT FK_tratamientos_medicamentos
        FOREIGN KEY (id_medicamento) REFERENCES dbo.medicamentos(id_medicamento)
);
GO

-- =========================================================
-- TABLA: estudios_clinicos
-- Guarda estudios complementarios de una consulta
-- Ej: analisis, ecografia, radiografia, etc.
-- =========================================================
CREATE TABLE dbo.estudios_clinicos (
    id_estudio INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del estudio
    id_consulta INT NOT NULL,-- Consulta a la que pertenece
    tipo_estudio NVARCHAR(150) NOT NULL,-- Tipo de estudio realizado
    resultado NVARCHAR(MAX) NULL, -- Resultado o resumen del estudio
    fecha DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha del estudio
    observaciones NVARCHAR(1000) NULL, -- Observaciones adicionales

    CONSTRAINT FK_estudios_clinicos_consultas
        FOREIGN KEY (id_consulta) REFERENCES dbo.consultas_clinicas(id_consulta)
);
GO

-- =========================================================
-- TABLA: archivos_clinicos
-- Permite guardar adjuntos relacionados a una consulta
-- Ej: fotos, PDFs, radiografias, recetas escaneadas
-- =========================================================
CREATE TABLE dbo.archivos_clinicos (
    id_archivo INT IDENTITY(1,1) PRIMARY KEY,-- Identificador del archivo
    id_consulta INT NOT NULL,-- Consulta a la que pertenece el archivo
    url_archivo NVARCHAR(500) NOT NULL,-- Ruta o URL donde esta guardado el archivo
    tipo_archivo NVARCHAR(50) NOT NULL, -- Tipo: IMAGEN, PDF, RADIOGRAFIA, etc.
    descripcion NVARCHAR(500) NULL,-- Descripcion del archivo
    fecha DATETIME NOT NULL DEFAULT GETDATE(),  -- Fecha de carga

    CONSTRAINT FK_archivos_clinicos_consultas
        FOREIGN KEY (id_consulta) REFERENCES dbo.consultas_clinicas(id_consulta)
);
GO

-- =========================================================
-- INDICES RECOMENDADOS
-- Mejoran consultas frecuentes
-- =========================================================

CREATE INDEX IX_mascotas_id_usuario
ON dbo.mascotas(id_usuario);
GO

CREATE INDEX IX_reservas_fecha_hora
ON dbo.reservas(fecha, hora);
GO

CREATE INDEX IX_reservas_id_usuario
ON dbo.reservas(id_usuario);
GO

CREATE INDEX IX_reservas_id_mascota
ON dbo.reservas(id_mascota);
GO

CREATE INDEX IX_consultas_clinicas_historia_fecha
ON dbo.consultas_clinicas(id_historia_clinica, fecha DESC);
GO

CREATE INDEX IX_peso_mascota_id_mascota_fecha
ON dbo.peso_mascota(id_mascota, fecha DESC);
GO

CREATE INDEX IX_vacunas_mascota_id_mascota
ON dbo.vacunas_mascota(id_mascota);
GO

CREATE INDEX IX_desparasitaciones_mascota_id_mascota
ON dbo.desparasitaciones_mascota(id_mascota);
GO

CREATE INDEX IX_enfermedades_mascota_id_mascota
ON dbo.enfermedades_mascota(id_mascota);
GO

CREATE INDEX IX_alergias_mascota_id_mascota
ON dbo.alergias_mascota(id_mascota);
GO

-- =========================================================
-- DATOS INICIALES OPCIONALES
-- Algunos servicios basicos
-- =========================================================
INSERT INTO dbo.servicios (nombre, descripcion, duracion_minutos, precio_base, activo)
VALUES
('BAÑO', 'Servicio de baño para mascota', 60, 5000, 1),
('CORTE', 'Servicio de corte de pelo', 60, 6000, 1),
('BAÑO Y CORTE', 'Servicio completo de baño y corte', 90, 9000, 1),
('CORTE DE UÑAS', 'Corte y mantenimiento de uñas', 20, 2500, 1),
('LIMPIEZA DE OÍDOS', 'Limpieza e higiene de oídos', 20, 2200, 1);
GO