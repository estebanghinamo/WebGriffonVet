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
IF OBJECT_ID('dbo.servicios_precios', 'U') IS NOT NULL DROP TABLE dbo.servicios_precios;

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
                              fecha_nacimiento DATE NULL,
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

CREATE TABLE dbo.servicios_precios (
                                       id_servicio_precio INT IDENTITY(1,1) PRIMARY KEY,

                                       id_servicio INT NOT NULL,
                                       tamanio NVARCHAR(20) NOT NULL, -- CHICO / MEDIANO / GRANDE

                                       precio DECIMAL(12,2) NOT NULL,
                                       duracion_minutos INT NOT NULL,

                                       activo BIT NOT NULL DEFAULT 1,

                                       CONSTRAINT FK_servicios_precios_servicios
                                           FOREIGN KEY (id_servicio) REFERENCES dbo.servicios(id_servicio),

                                       CONSTRAINT CK_servicios_precios_tamanio
                                           CHECK (tamanio IN ('CHICO', 'MEDIANO', 'GRANDE'))
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
                              id_servicio INT NOT NULL,-- Servicio solicitado
                              fecha DATE NOT NULL,-- Fecha del turno
                              hora TIME NOT NULL, -- Hora del turno
                              estado NVARCHAR(20) NOT NULL DEFAULT 'PENDIENTE', -- Estado de la reserva: PENDIENTE, CONFIRMADA, CANCELADA, ATENDIDA
                              observaciones NVARCHAR(1000) NULL, -- Comentarios extra de la reserva
                              fecha_creacion DATETIME NOT NULL DEFAULT GETDATE(),-- Fecha de creacion de la reserva

                              CONSTRAINT FK_reservas_usuarios
                                  FOREIGN KEY (id_usuario) REFERENCES dbo.usuarios(id_usuario),
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

                                        CONSTRAINT FK_consultas_clinicas_historias
                                            FOREIGN KEY (id_historia_clinica) REFERENCES dbo.historias_clinicas(id_historia_clinica),

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


/* =========================================================
   INDEXES VETERINARIA - VERSION OPTIMIZADA
   ========================================================= */

------------------------------------------------------------
-- 🔐 USUARIOS
------------------------------------------------------------

CREATE UNIQUE INDEX IX_usuarios_email
    ON dbo.usuarios(email);

CREATE INDEX IX_usuarios_apellido
    ON dbo.usuarios(apellido);

CREATE INDEX IX_usuarios_rol_activo
    ON dbo.usuarios(rol, activo);


------------------------------------------------------------
-- 🐾 MASCOTAS
------------------------------------------------------------

CREATE INDEX IX_mascotas_id_usuario
    ON dbo.mascotas(id_usuario);

CREATE INDEX IX_mascotas_usuario_activo
    ON dbo.mascotas(id_usuario, activo);

CREATE INDEX IX_mascotas_nombre
    ON dbo.mascotas(nombre);


------------------------------------------------------------
-- 🛒 PRODUCTOS
------------------------------------------------------------

CREATE INDEX IX_productos_categoria
    ON dbo.productos(categoria);

CREATE INDEX IX_productos_nombre
    ON dbo.productos(nombre);

CREATE INDEX IX_productos_activo
    ON dbo.productos(activo);


------------------------------------------------------------
-- ✂️ SERVICIOS
------------------------------------------------------------

CREATE INDEX IX_servicios_activo
    ON dbo.servicios(activo);


------------------------------------------------------------
-- 📅 RESERVAS
------------------------------------------------------------

CREATE INDEX IX_reservas_fecha_hora
    ON dbo.reservas(fecha, hora);

CREATE INDEX IX_reservas_id_usuario
    ON dbo.reservas(id_usuario);

CREATE INDEX IX_reservas_id_servicio
    ON dbo.reservas(id_servicio);

CREATE INDEX IX_reservas_estado
    ON dbo.reservas(estado);

-- PRO (agenda completa)
CREATE INDEX IX_reservas_full
    ON dbo.reservas(fecha, hora, estado);


------------------------------------------------------------
-- 🏥 HISTORIA CLINICA
------------------------------------------------------------

CREATE INDEX IX_historias_clinicas_id_mascota
    ON dbo.historias_clinicas(id_mascota);


------------------------------------------------------------
-- 🩺 CONSULTAS
------------------------------------------------------------

CREATE INDEX IX_consultas_clinicas_historia_fecha
    ON dbo.consultas_clinicas(id_historia_clinica, fecha DESC);

CREATE INDEX IX_consultas_clinicas_historia
    ON dbo.consultas_clinicas(id_historia_clinica);


------------------------------------------------------------
-- ⚖️ PESO
------------------------------------------------------------

CREATE INDEX IX_peso_mascota_id_mascota_fecha
    ON dbo.peso_mascota(id_mascota, fecha DESC);


------------------------------------------------------------
-- 🤧 ALERGIAS
------------------------------------------------------------

CREATE INDEX IX_alergias_nombre
    ON dbo.alergias(nombre);

CREATE INDEX IX_alergias_mascota_id_mascota
    ON dbo.alergias_mascota(id_mascota);

CREATE INDEX IX_alergias_mascota_full
    ON dbo.alergias_mascota(id_mascota, id_alergia);


------------------------------------------------------------
-- 💉 VACUNAS
------------------------------------------------------------

CREATE UNIQUE INDEX UX_vacunas_nombre
    ON dbo.vacunas(nombre);

CREATE INDEX IX_vacunas_mascota_id_mascota
    ON dbo.vacunas_mascota(id_mascota);

CREATE INDEX IX_vacunas_mascota_full
    ON dbo.vacunas_mascota(id_mascota, id_vacuna);


------------------------------------------------------------
-- 🦠 DESPARASITACIONES
------------------------------------------------------------

CREATE INDEX IX_desparasitaciones_nombre
    ON dbo.desparasitaciones(nombre);

CREATE INDEX IX_desparasitaciones_mascota_id_mascota
    ON dbo.desparasitaciones_mascota(id_mascota);

CREATE INDEX IX_desparasitaciones_mascota_full
    ON dbo.desparasitaciones_mascota(id_mascota, id_desparasitacion);


------------------------------------------------------------
-- 🧬 ENFERMEDADES
------------------------------------------------------------

CREATE INDEX IX_enfermedades_nombre
    ON dbo.enfermedades(nombre);

CREATE INDEX IX_enfermedades_mascota_id_mascota
    ON dbo.enfermedades_mascota(id_mascota);

CREATE INDEX IX_enfermedades_mascota_full
    ON dbo.enfermedades_mascota(id_mascota, id_enfermedad);


------------------------------------------------------------
-- 💊 MEDICAMENTOS
------------------------------------------------------------

CREATE UNIQUE INDEX UX_medicamentos_nombre
    ON dbo.medicamentos(nombre);


------------------------------------------------------------
-- 💊 TRATAMIENTOS
------------------------------------------------------------

CREATE INDEX IX_tratamientos_id_consulta
    ON dbo.tratamientos(id_consulta);

CREATE INDEX IX_tratamientos_id_medicamento
    ON dbo.tratamientos(id_medicamento);


------------------------------------------------------------
-- 🧪 ESTUDIOS
------------------------------------------------------------

CREATE INDEX IX_estudios_clinicos_id_consulta
    ON dbo.estudios_clinicos(id_consulta);


------------------------------------------------------------
-- 📎 ARCHIVOS
------------------------------------------------------------

CREATE INDEX IX_archivos_clinicos_id_consulta
    ON dbo.archivos_clinicos(id_consulta);


------------------------------------------------------------
-- ⛔ AGENDA BLOQUEOS
------------------------------------------------------------

CREATE INDEX IX_agenda_bloqueos_fecha
    ON dbo.agenda_bloqueos(fecha);


------------------------------------------------------------
-- 🕒 HORARIOS
------------------------------------------------------------

CREATE INDEX IX_horarios_dia
    ON dbo.horarios_atencion(dia_semana);

CREATE INDEX IX_servicios_precios_servicio_tamanio
    ON dbo.servicios_precios(id_servicio, tamanio);
-- =========================================================
-- DATOS INICIALES OPCIONALES
-- Algunos servicios basicos
-- =========================================================
/*INSERT INTO dbo.servicios (nombre, descripcion, duracion_minutos, precio_base, activo)
VALUES
('BAÑO', 'Servicio de baño para mascota', 60, 5000, 1),
('BAÑO Y CORTE', 'Servicio completo de baño y corte', 90, 9000, 1),
('CORTE DE UÑAS', 'Corte y mantenimiento de uñas', 20, 2500, 1),
('LIMPIEZA DE OÍDOS', 'Limpieza e higiene de oídos', 20, 2200, 1);
GO
INSERT INTO dbo.servicios_precios (id_servicio, tamanio, precio, duracion_minutos)
VALUES
-- BAÑO
(1, 'CHICO', 4000, 45),
(1, 'MEDIANO', 6000, 60),
(1, 'GRANDE', 8000, 90),

-- BAÑO Y CORTE
(2, 'CHICO', 7000, 60),
(2, 'MEDIANO', 9000, 90),
(2, 'GRANDE', 12000, 120);*/

/*
---------------INSERTS DE PRUEBAS----------------------
													
													
INSERT INTO dbo.usuarios (nombre, apellido, email, telefono, password_hash, rol)
VALUES
('juana', 'peres', 'juana@gmail.com', '3571551111', 'admin123', 'ADMIN'),
('Maria', 'Gomez', 'maria.gomez@gmail.com', '3571552222', 'hash123', 'CLIENTE'),
('Lucas', 'Fernandez', 'lucas.fernandez@gmail.com', '3571553333', 'hash123', 'CLIENTE'),
('Sofia', 'Lopez', 'sofia.lopez@gmail.com', '3571554444', 'hash123', 'CLIENTE'),
('Martin', 'Diaz', 'martin.diaz@gmail.com', '3571555555', 'hash123', 'CLIENTE');


INSERT INTO dbo.mascotas (id_usuario, nombre, especie, raza, tamanio, fecha_nacimiento, sexo, tipo_pelaje, comportamiento)
VALUES
(2, 'Rocky', 'Perro', 'Labrador', 'GRANDE', '2020-05-10', 'MACHO', 'CORTO', 'DOCIL'),
(2, 'Milo', 'Gato', 'Siames', 'CHICO', '2020-05-10',  'MACHO', 'CORTO', 'TRANQUILO'),
(2, 'Luna', 'Perro', 'Caniche', 'CHICO', '2020-05-10', 'HEMBRA', 'LARGO', 'JUGUETONA');

INSERT INTO dbo.mascotas (id_usuario, nombre, especie, raza, tamanio, fecha_nacimiento, sexo, tipo_pelaje, comportamiento)
VALUES
(2, 'Toby', 'Perro', 'Bulldog', 'MEDIANO', '2020-05-10',  'MACHO', 'CORTO', 'TRANQUILO'),
(2, 'Nina', 'Gato', 'Persa', 'CHICO', '2020-05-10',  'HEMBRA', 'LARGO', 'DOCIL');

INSERT INTO dbo.mascotas (id_usuario, nombre, especie, raza, tamanio, fecha_nacimiento, sexo, tipo_pelaje, comportamiento)
VALUES
(3, 'Thor', 'Perro', 'Ovejero Aleman', 'GRANDE', '2020-05-10', 'MACHO', 'LARGO', 'GUARDIAN'),
(3, 'Simba', 'Gato', 'Comun', 'CHICO', '2020-05-10',  'MACHO', 'CORTO', 'INQUIETO'),
(3, 'Kira', 'Perro', 'Beagle', 'MEDIANO', '2020-05-10',  'HEMBRA', 'CORTO', 'ACTIVO');

INSERT INTO dbo.mascotas (id_usuario, nombre, especie, raza, tamanio, fecha_nacimiento, sexo, tipo_pelaje, comportamiento)
VALUES
(4, 'Lola', 'Perro', 'Golden Retriever', 'GRANDE', '2020-05-10', 'HEMBRA', 'LARGO', 'DOCIL'),
(4, 'Felix', 'Gato', 'Comun', 'CHICO', '2020-05-10', 'MACHO', 'CORTO', 'TRANQUILO');


INSERT INTO dbo.mascotas (id_usuario, nombre, especie, raza, tamanio, fecha_nacimiento,  sexo, tipo_pelaje, comportamiento)
VALUES
(5, 'Bruno', 'Perro', 'Rottweiler', 'GRANDE', '2020-05-10', 'MACHO', 'CORTO', 'GUARDIAN'),
(5, 'Mia', 'Gato', 'Siames', 'CHICO', '2020-05-10', 'HEMBRA', 'CORTO', 'JUGUETONA'),
(5, 'Zeus', 'Perro', 'Pitbull', 'MEDIANO', '2020-05-10',  'MACHO', 'CORTO', 'ENERGICO');

*/








/*============================================================================0

  procedimientos de registrar y login


================================================================================*/

go--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_registrar_usuario
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(100),
        @apellido NVARCHAR(100),
        @email NVARCHAR(150),
        @telefono NVARCHAR(50),
        @password NVARCHAR(255),
        @password_hash VARBINARY(64);

    -- 🔹 Parsear JSON
SELECT
    @nombre = JSON_VALUE(@json, '$.nombre'),
    @apellido = JSON_VALUE(@json, '$.apellido'),
    @email = JSON_VALUE(@json, '$.email'),
    @telefono = JSON_VALUE(@json, '$.telefono'),
    @password = JSON_VALUE(@json, '$.password');

-- 🔐 Hashear password
SET @password_hash = HASHBYTES('SHA2_256', @password);

    -- 🔹 Validación básica
    IF @email IS NULL OR @password IS NULL
BEGIN
SELECT
    0 AS success,
    'Email y contraseña son obligatorios' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔹 Validar duplicado
    IF EXISTS (
        SELECT 1 
        FROM dbo.usuarios 
        WHERE email = @email
    )
BEGIN
SELECT
    0 AS success,
    'El email ya está registrado' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔹 Insertar usuario
INSERT INTO dbo.usuarios (
    nombre,
    apellido,
    email,
    telefono,
    password_hash,
    rol,
    activo,
    fecha_alta
)
VALUES (
           @nombre,
           @apellido,
           @email,
           @telefono,
           @password_hash,
           'CLIENTE', -- 🔥 fijo
           1,
           GETDATE()
       );

DECLARE @id_usuario INT = SCOPE_IDENTITY();

    -- ✅ Respuesta
SELECT
    1 AS success,
    'Usuario registrado correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    u.id_usuario,
                    u.nombre,
                    u.apellido,
                    (u.nombre + ' ' + u.apellido) AS nombre_completo,
                    u.email,
                    u.telefono,
                    u.rol
                FROM dbo.usuarios u
                WHERE u.id_usuario = @id_usuario
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS usuario
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO
go--endpointt
CREATE OR ALTER PROCEDURE dbo.sp_login_usuario_json
    @json         NVARCHAR(MAX),
    @login_valido INT OUTPUT,
    @rol          NVARCHAR(50) OUTPUT,
    @email_out    NVARCHAR(150) OUTPUT
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @email             NVARCHAR(150);
    DECLARE @password          NVARCHAR(255);
    DECLARE @password_hash_bin VARBINARY(64);

SELECT
    @email    = JSON_VALUE(@json, '$.email'),
    @password = JSON_VALUE(@json, '$.password');

SET @password_hash_bin = HASHBYTES('SHA2_256', @password);

SELECT @rol = rol, @email_out = email
FROM dbo.usuarios
WHERE email         = @email
  AND password_hash = @password_hash_bin
  AND activo        = 1;

IF @rol IS NOT NULL
        SET @login_valido = 1;
ELSE
BEGIN
        SET @login_valido = 0;
        SET @rol          = NULL;
        SET @email_out    = NULL;
END

END;
GO

go
CREATE OR ALTER PROCEDURE dbo.sp_insert_cliente_mascota_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE 
            -- 👤 CLIENTE
@nombre NVARCHAR(100) = JSON_VALUE(@json, '$.cliente.nombre'),
            @apellido NVARCHAR(100) = JSON_VALUE(@json, '$.cliente.apellido'),
            @email NVARCHAR(150) = JSON_VALUE(@json, '$.cliente.email'),
            @telefono NVARCHAR(50) = JSON_VALUE(@json, '$.cliente.telefono'),
            @password NVARCHAR(255) = JSON_VALUE(@json, '$.cliente.password'),
            @password_hash VARBINARY(64),

            -- 🐶 MASCOTA
            @nombre_mascota NVARCHAR(100) = JSON_VALUE(@json, '$.mascota.nombre'),
            @especie NVARCHAR(50) = JSON_VALUE(@json, '$.mascota.especie'),
            @raza NVARCHAR(100) = JSON_VALUE(@json, '$.mascota.raza'),
            @tamanio NVARCHAR(50) = JSON_VALUE(@json, '$.mascota.tamanio'),
            @fecha_nacimiento DATE = JSON_VALUE(@json, '$.mascota.fecha_nacimiento'),
            @sexo NVARCHAR(20) = JSON_VALUE(@json, '$.mascota.sexo'),
            @tipo_pelaje NVARCHAR(50) = JSON_VALUE(@json, '$.mascota.tipo_pelaje'),
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.mascota.observaciones');

        DECLARE @id_usuario INT;

        -- 🔒 Validaciones
        IF @email IS NULL OR @password IS NULL
BEGIN
SELECT 0 AS success, 'Email y contraseña son obligatorios' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
ROLLBACK;
RETURN;
END

        IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT 0 AS success, 'El nombre del cliente es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
ROLLBACK;
RETURN;
END

        -- 🔒 Email duplicado
        IF EXISTS (SELECT 1 FROM dbo.usuarios WHERE email = @email)
BEGIN
SELECT 0 AS success, 'El email ya está registrado' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
ROLLBACK;
RETURN;
END

        -- 🔐 HASH PASSWORD (igual que tu SP)
        SET @password_hash = HASHBYTES('SHA2_256', @password);

        -- 👤 INSERT CLIENTE
INSERT INTO dbo.usuarios
(
    nombre,
    apellido,
    email,
    telefono,
    password_hash,
    rol,
    activo,
    fecha_alta
)
VALUES
    (
        @nombre,
        @apellido,
        @email,
        @telefono,
        @password_hash,
        'CLIENTE',
        1,
        GETDATE()
    );

SET @id_usuario = SCOPE_IDENTITY();

        -- 🐶 INSERT MASCOTA (solo si viene info)
        IF @nombre_mascota IS NOT NULL AND @nombre_mascota <> ''
BEGIN
INSERT INTO dbo.mascotas
(
    id_usuario,
    nombre,
    especie,
    raza,
    tamanio,
    fecha_nacimiento,
    sexo,
    tipo_pelaje,
    observaciones,
    activo,
    fecha_registro
)
VALUES
    (
        @id_usuario,
        @nombre_mascota,
        @especie,
        @raza,
        @tamanio,
        @fecha_nacimiento,
        @sexo,
        @tipo_pelaje,
        @observaciones,
        1,
        GETDATE()
    );
END

COMMIT;

-- ✅ RESPUESTA
SELECT
    1 AS success,
    'Cliente y mascota creados correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    u.id_usuario,
                    u.nombre,
                    u.apellido,
                    (u.nombre + ' ' + u.apellido) AS nombre_completo,
                    u.email,
                    u.telefono,
                    u.rol,
                    (
                        SELECT
                            m.id_mascota,
                            m.nombre,
                            m.especie,
                            m.raza
                        FROM dbo.mascotas m
                        WHERE m.id_usuario = u.id_usuario
                FOR JSON PATH
        ) AS mascotas
                    FROM dbo.usuarios u
                    WHERE u.id_usuario = @id_usuario
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                )
            ) AS data
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
ROLLBACK;

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO
/*============================================================================0

  procedimientos de obtener, editar e insertar productos


================================================================================*/


GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_get_productos_json
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    p.id_producto,
    p.nombre,
    p.descripcion,
    p.precio,
    p.categoria,
    p.imagen_url,
    p.stock,
    p.activo,
    p.fecha_alta
FROM dbo.productos p
WHERE p.activo = 1
ORDER BY p.nombre
    FOR JSON PATH, ROOT('productos');
END;
GO

GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_insert_producto_json
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY

        DECLARE
@nombre NVARCHAR(200),
            @descripcion NVARCHAR(MAX),
            @precio DECIMAL(10,2),
            @categoria NVARCHAR(100),
            @imagen_url NVARCHAR(500),
            @stock INT;

        -- 🔹 Parsear JSON
SELECT
    @nombre = JSON_VALUE(@json, '$.nombre'),
    @descripcion = JSON_VALUE(@json, '$.descripcion'),
    @precio = CAST(JSON_VALUE(@json, '$.precio') AS DECIMAL(10,2)),
    @categoria = JSON_VALUE(@json, '$.categoria'),
    @imagen_url = JSON_VALUE(@json, '$.imagen_url'),
    @stock = CAST(JSON_VALUE(@json, '$.stock') AS INT);

-- 🔹 Validación
IF @nombre IS NULL OR @precio IS NULL
BEGIN
SELECT
    0 AS success,
    'Faltan datos obligatorios' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🔹 Insert
INSERT INTO dbo.productos (
    nombre,
    descripcion,
    precio,
    categoria,
    imagen_url,
    stock,
    activo,
    fecha_alta
)
VALUES (
           @nombre,
           @descripcion,
           @precio,
           @categoria,
           @imagen_url,
           @stock,
           1,
           GETDATE()
       );

DECLARE @id_producto INT = SCOPE_IDENTITY();

        -- 🔹 Respuesta
SELECT
    1 AS success,
    'Producto creado correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT *
                FROM dbo.productos
                WHERE id_producto = @id_producto
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS producto
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_delete_producto_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_producto INT = TRY_CAST(JSON_VALUE(@json, '$.id_producto') AS INT);

    -- 🔒 VALIDACIÓN
    IF @id_producto IS NULL
BEGIN
SELECT
    0 AS success,
    'id_producto es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    IF NOT EXISTS (
        SELECT 1 
        FROM dbo.productos 
        WHERE id_producto = @id_producto
    )
BEGIN
SELECT
    0 AS success,
    'El producto no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🗑️ SOFT DELETE
UPDATE dbo.productos
SET activo = 0
WHERE id_producto = @id_producto;

-- ✅ RESPUESTA
SELECT
    1 AS success,
    'Producto eliminado correctamente' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

go
GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_update_producto_json
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@id_producto INT,
        @nombre NVARCHAR(200),
        @descripcion NVARCHAR(MAX),
        @precio DECIMAL(10,2),
        @categoria NVARCHAR(100),
        @imagen_url NVARCHAR(500),
        @stock INT;

    -- 🔹 Parsear JSON
SELECT
    @id_producto = CAST(JSON_VALUE(@json, '$.id_producto') AS INT),
    @nombre = JSON_VALUE(@json, '$.nombre'),
    @descripcion = JSON_VALUE(@json, '$.descripcion'),
    @precio = CAST(JSON_VALUE(@json, '$.precio') AS DECIMAL(10,2)),
    @categoria = JSON_VALUE(@json, '$.categoria'),
    @imagen_url = JSON_VALUE(@json, '$.imagen_url'),
    @stock = CAST(JSON_VALUE(@json, '$.stock') AS INT);

-- 🔹 Validar existencia
IF NOT EXISTS (SELECT 1 FROM dbo.productos WHERE id_producto = @id_producto)
BEGIN
SELECT
    0 AS success,
    'Producto no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔹 Update
UPDATE dbo.productos
SET
    nombre = @nombre,
    descripcion = @descripcion,
    precio = @precio,
    categoria = @categoria,
    imagen_url = ISNULL(@imagen_url, imagen_url),
    stock = @stock
WHERE id_producto = @id_producto;

-- ✅ Respuesta
SELECT
    1 AS success,
    'Producto actualizado correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT *
                FROM dbo.productos
                WHERE id_producto = @id_producto
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS producto
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO
/*
DECLARE @json NVARCHAR(MAX) = '
{
  "nombre": "Collar antipulgas",
  "descripcion": "Para perros medianos",
  "precio": 1500.50,
  "categoria": "Accesorios",
  "imagen_url": "https://...",
  "stock": 10
}';

EXEC dbo.sp_insert_producto_json @json;
DECLARE @json NVARCHAR(MAX) = '
{
  "id_producto": 1,
  "nombre": "Collar premium",
  "descripcion": "Actualizado",
  "precio": 2000,
  "categoria": "Accesorios",
  "imagen_url": "https://...",
  "stock": 20
}';

EXEC dbo.sp_update_producto_json @json;*/

go


/*============================================================================0

  procedimientos para traer mascotas de clientes , insertarlas y editarlas


================================================================================*/
GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_get_mascotas_por_usuario_json
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @id_usuario INT;

    -- 🔹 Parsear JSON
SELECT
    @id_usuario = CAST(JSON_VALUE(@json, '$.id_usuario') AS INT);

-- 🔹 Validación básica
IF @id_usuario IS NULL
BEGIN
SELECT
    0 AS success,
    'id_usuario es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔹 Query principal
SELECT
    1 AS success,
    JSON_QUERY(
            (
                SELECT
                    m.id_mascota,
                    m.nombre,
                    UPPER(m.especie) AS especie,
                    m.raza,
                    m.fecha_nacimiento
                FROM dbo.mascotas m
                WHERE m.id_usuario = @id_usuario
                  AND m.activo = 1
                ORDER BY m.nombre
                FOR JSON PATH
        )
        ) AS mascotas
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO
--en el detalle llamar a este sp: dbo.sp_get_informacioncompleta_mascota
--para editar la mascota le permitimos usar el sp: dbo.sp_editar_infogeneral_mascota
go

GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_insert_mascota_json
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@id_usuario INT,
        @nombre NVARCHAR(100),
        @especie NVARCHAR(50),
        @raza NVARCHAR(100),
        @tamanio NVARCHAR(50),
        @fecha_nacimiento DATE,
        @sexo NVARCHAR(20),
        @tipo_pelaje NVARCHAR(50),
        @alergias_general NVARCHAR(MAX),
        @comportamiento NVARCHAR(MAX),
        @observaciones NVARCHAR(MAX);

    -- 🔹 Parsear JSON
SELECT
    @id_usuario = CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
    @nombre = JSON_VALUE(@json, '$.nombre'),
    @especie = JSON_VALUE(@json, '$.especie'),
    @raza = JSON_VALUE(@json, '$.raza'),
    @tamanio = JSON_VALUE(@json, '$.tamanio'),
    @fecha_nacimiento = JSON_VALUE(@json, '$.fecha_nacimiento'),
    @sexo = JSON_VALUE(@json, '$.sexo'),
    @tipo_pelaje = JSON_VALUE(@json, '$.tipo_pelaje'),
    @alergias_general = JSON_VALUE(@json, '$.alergias_general'),
    @comportamiento = JSON_VALUE(@json, '$.comportamiento'),
    @observaciones = JSON_VALUE(@json, '$.observaciones');

-- 🔹 Validaciones mínimas
IF @id_usuario IS NULL OR @nombre IS NULL OR @especie IS NULL
BEGIN
SELECT
    0 AS success,
    'id_usuario, nombre y especie son obligatorios' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔹 Insertar
INSERT INTO dbo.mascotas (
    id_usuario,
    nombre,
    especie,
    raza,
    tamanio,
    fecha_nacimiento,
    sexo,
    tipo_pelaje,
    alergias_general,
    comportamiento,
    observaciones,
    activo,
    fecha_registro
)
VALUES (
           @id_usuario,
           @nombre,
           UPPER(@especie), -- 🔥 consistente con UI
           @raza,
           @tamanio,
           @fecha_nacimiento,
           @sexo,
           @tipo_pelaje,
           @alergias_general,
           @comportamiento,
           @observaciones,
           1,
           GETDATE()
       );

DECLARE @id_mascota INT = SCOPE_IDENTITY();

    -- ✅ Respuesta
SELECT
    1 AS success,
    'Mascota registrada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    m.id_mascota,
                    m.nombre,
                    m.especie,
                    m.raza,
                    m.tamanio,
                    m.fecha_nacimiento,
                    m.sexo
                FROM dbo.mascotas m
                WHERE m.id_mascota = @id_mascota
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS mascota
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO


/*============================================================================0

  procedimientos de administrador obtencion y modificacion de historias clinicas


================================================================================*/
 
go
GO--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_get_clientes_con_mascotas_json_filtrado
    @json NVARCHAR(MAX)
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @apellido NVARCHAR(100);

    -- 🔹 Parsear JSON
SELECT
    @apellido = JSON_VALUE(@json, '$.apellido');

SELECT
    u.id_usuario,
    u.nombre,
    u.apellido,
    (u.nombre + ' ' + u.apellido) AS nombre_completo,
    u.email,
    u.telefono,
    u.activo,
    u.fecha_alta,

    JSON_QUERY(
            (
                SELECT
                    m.id_mascota,
                    m.nombre AS nombre_mascota,
                    m.especie,
                    m.raza,
                    m.tamanio,
                    m.fecha_nacimiento,
                    m.sexo,
                    m.tipo_pelaje,
                    m.alergias_general,
                    m.comportamiento,
                    m.observaciones,
                    m.activo,
                    m.fecha_registro
                FROM dbo.mascotas m
                WHERE m.id_usuario = u.id_usuario
                  AND m.activo = 1
                ORDER BY m.nombre
                FOR JSON PATH
        )
        ) AS mascotas

FROM dbo.usuarios u
WHERE u.rol = 'CLIENTE'
  AND u.activo = 1
  AND (
    @apellido IS NULL
        OR LTRIM(RTRIM(@apellido)) = ''
        OR u.apellido COLLATE Latin1_General_CI_AI LIKE '%' + @apellido + '%'
    )
ORDER BY u.apellido, u.nombre
    FOR JSON PATH, ROOT('clientes');

END;
GO


--EXEC dbo.sp_get_clientes_con_mascotas_json;
go--endpointt(vista admin)
CREATE OR ALTER PROCEDURE dbo.sp_get_clientes_con_mascotas_json
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    u.id_usuario,
    (u.nombre + ' ' + u.apellido) AS nombre_completo,
    u.email,
    u.telefono,
    u.activo,

    JSON_QUERY(
            (
                SELECT
                    m.id_mascota,
                    m.nombre AS nombre_mascota,
                    m.especie,
                    m.sexo
                FROM dbo.mascotas m
                WHERE m.id_usuario = u.id_usuario
                  AND m.activo = 1
                ORDER BY m.nombre
                FOR JSON PATH
        )
        ) AS mascotas

FROM dbo.usuarios u
WHERE u.rol = 'CLIENTE'
  AND u.activo = 1
ORDER BY u.apellido, u.nombre
    FOR JSON PATH, ROOT('clientes');
END;
GO


--DECLARE @json NVARCHAR(MAX) = '{ "id_usuario": 1,"id_mascota": 1}';
--EXEC dbo.sp_get_informacioncompleta_mascota @json;
go--endpointt
CREATE OR ALTER PROCEDURE dbo.sp_get_informacioncompleta_mascota
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@id_usuario INT = JSON_VALUE(@json, '$.id_usuario'),
        @id_mascota INT = JSON_VALUE(@json, '$.id_mascota');

    -- Validación básica
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.mascotas
        WHERE id_mascota = @id_mascota
          AND id_usuario = @id_usuario
    )
BEGIN
        RAISERROR('La mascota no pertenece al usuario', 16, 1);
        RETURN;
END

SELECT
    m.id_mascota,
    m.nombre,
    m.especie,
    m.raza,
    m.tamanio,
    m.fecha_nacimiento,
    m.sexo,
    m.tipo_pelaje,
    m.comportamiento,
    m.observaciones,

    -- 🐾 PESO HISTÓRICO
    ISNULL(JSON_QUERY((
        SELECT fecha, peso, observaciones
        FROM dbo.peso_mascota p
        WHERE p.id_mascota = m.id_mascota
        ORDER BY fecha DESC
        FOR JSON PATH
               )), '[]') AS pesos,

    -- 🤧 ALERGIAS
    ISNULL(JSON_QUERY((
        SELECT a.nombre, am.severidad, am.observaciones
        FROM dbo.alergias_mascota am
                 JOIN dbo.alergias a ON a.id_alergia = am.id_alergia
        WHERE am.id_mascota = m.id_mascota
        FOR JSON PATH
               )), '[]') AS alergias,

    -- 💉 VACUNAS
    ISNULL(JSON_QUERY((
        SELECT v.nombre, vm.fecha_aplicacion, vm.proxima_dosis
        FROM dbo.vacunas_mascota vm
                 JOIN dbo.vacunas v ON v.id_vacuna = vm.id_vacuna
        WHERE vm.id_mascota = m.id_mascota
        FOR JSON PATH
               )), '[]') AS vacunas,

    -- 🦠 DESPARASITACIONES
    ISNULL(JSON_QUERY((
        SELECT d.nombre, dm.fecha_aplicacion, dm.proxima_dosis, dm.tipo
        FROM dbo.desparasitaciones_mascota dm
                 JOIN dbo.desparasitaciones d ON d.id_desparasitacion = dm.id_desparasitacion
        WHERE dm.id_mascota = m.id_mascota
        FOR JSON PATH
               )), '[]') AS desparasitaciones,

    -- 🧬 ENFERMEDADES
    ISNULL(JSON_QUERY((
        SELECT e.nombre, em.estado, em.fecha_diagnostico
        FROM dbo.enfermedades_mascota em
                 JOIN dbo.enfermedades e ON e.id_enfermedad = em.id_enfermedad
        WHERE em.id_mascota = m.id_mascota
        FOR JSON PATH
               )), '[]') AS enfermedades,

    -- 🏥 HISTORIA CLÍNICA
    ISNULL(JSON_QUERY((
        SELECT
            hc.id_historia_clinica,

            (
                SELECT
                    c.id_consulta,
                    c.fecha,
                    c.motivo_consulta,
                    c.diagnostico,
                    c.tratamiento,

                    -- 💊 TRATAMIENTOS
                    JSON_QUERY((
                        SELECT med.nombre, t.dosis, t.frecuencia, t.duracion_dias
                        FROM dbo.tratamientos t
                                 LEFT JOIN dbo.medicamentos med ON med.id_medicamento = t.id_medicamento
                        WHERE t.id_consulta = c.id_consulta
                        FOR JSON PATH
                        )) AS tratamientos,

                    -- 🧪 ESTUDIOS
                    JSON_QUERY((
                        SELECT tipo_estudio, resultado, fecha
                        FROM dbo.estudios_clinicos e
                        WHERE e.id_consulta = c.id_consulta
                        FOR JSON PATH
                        )) AS estudios,

                    -- 📎 ARCHIVOS
                    JSON_QUERY((
                        SELECT url_archivo, tipo_archivo, descripcion
                        FROM dbo.archivos_clinicos a
                        WHERE a.id_consulta = c.id_consulta
                        FOR JSON PATH
                        )) AS archivos

                FROM dbo.consultas_clinicas c
                WHERE c.id_historia_clinica = hc.id_historia_clinica
                ORDER BY c.fecha DESC
        FOR JSON PATH
               ) AS consultas

            FROM dbo.historias_clinicas hc
            WHERE hc.id_mascota = m.id_mascota
            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )), '{}') AS historia_clinica

FROM dbo.mascotas m
WHERE m.id_mascota = @id_mascota
  AND m.id_usuario = @id_usuario
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

--DECLARE @json NVARCHAR(MAX) = '{  "id_usuario": 1,  "id_mascota": 1,  "comportamiento": "MUY ACTIVO",  "observaciones": "Mejoró después del tratamiento"}';
--EXEC dbo.sp_editar_infogeneral_mascota @json;
--procedimiento para editar informacion general del paciente
go--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_editar_infogeneral_mascota
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;
    DECLARE
@id_usuario INT,
    @id_mascota INT,
    @nombre NVARCHAR(100),
    @especie NVARCHAR(50),
    @raza NVARCHAR(100),
    @tamanio NVARCHAR(20),
    @fecha_nacimiento DATE,
    @sexo NVARCHAR(20),
    @tipo_pelaje NVARCHAR(100),
    @alergias_general NVARCHAR(500),
    @comportamiento NVARCHAR(300),
    @observaciones NVARCHAR(1000);

SELECT
    @id_usuario = TRY_CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
    @id_mascota = TRY_CAST(JSON_VALUE(@json, '$.id_mascota') AS INT),
    @nombre = JSON_VALUE(@json, '$.nombre'),
    @especie = JSON_VALUE(@json, '$.especie'),
    @raza = JSON_VALUE(@json, '$.raza'),
    @tamanio = JSON_VALUE(@json, '$.tamanio'),
    @sexo = JSON_VALUE(@json, '$.sexo'),
    @tipo_pelaje = JSON_VALUE(@json, '$.tipo_pelaje'),
    @alergias_general = JSON_VALUE(@json, '$.alergias_general'),
    @comportamiento = JSON_VALUE(@json, '$.comportamiento'),
    @observaciones = JSON_VALUE(@json, '$.observaciones');

-- 🔥 CLAVE
SET @fecha_nacimiento = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.fecha_nacimiento'));

    -- 🔒 Validación
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.mascotas
        WHERE id_mascota = @id_mascota
          AND id_usuario = @id_usuario
          AND activo = 1
    )
BEGIN
SELECT
    0 AS success,
    'Mascota no encontrada o no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🛠 UPDATE dinámico
UPDATE dbo.mascotas
SET
    nombre = ISNULL(@nombre, nombre),
    especie = ISNULL(@especie, especie),
    raza = ISNULL(@raza, raza),
    tamanio = ISNULL(@tamanio, tamanio),
    fecha_nacimiento = ISNULL(@fecha_nacimiento, fecha_nacimiento),
    sexo = ISNULL(@sexo, sexo),
    tipo_pelaje = ISNULL(@tipo_pelaje, tipo_pelaje),
    alergias_general = ISNULL(@alergias_general, alergias_general),
    comportamiento = ISNULL(@comportamiento, comportamiento),
    observaciones = ISNULL(@observaciones, observaciones)
WHERE id_mascota = @id_mascota;

-- 📦 Respuesta
SELECT *
FROM dbo.mascotas
WHERE id_mascota = @id_mascota
    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO




--obligatorio lo de la tabla consulta_clinica, las otras 3 trablas pueden o no estar con datos
go--endpoint
CREATE OR ALTER PROCEDURE dbo.sp_insert_consulta_clinica_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = JSON_VALUE(@json, '$.id_usuario'),
            @id_mascota INT = JSON_VALUE(@json, '$.id_mascota'),
            @motivo NVARCHAR(500) = JSON_VALUE(@json, '$.motivo_consulta'),
            @anamnesis NVARCHAR(MAX) = JSON_VALUE(@json, '$.anamnesis'),
            @examen NVARCHAR(MAX) = JSON_VALUE(@json, '$.examen_general'),
            @diagnostico NVARCHAR(MAX) = JSON_VALUE(@json, '$.diagnostico'),
            @tratamiento_general NVARCHAR(MAX) = JSON_VALUE(@json, '$.tratamiento'),
            @observaciones NVARCHAR(MAX) = JSON_VALUE(@json, '$.observaciones');

        DECLARE @id_historia INT;

        -- 🔒 VALIDACIÓN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La mascota no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🏥 HISTORIA CLÍNICA
SELECT @id_historia = id_historia_clinica
FROM dbo.historias_clinicas
WHERE id_mascota = @id_mascota;

IF @id_historia IS NULL
BEGIN
INSERT INTO dbo.historias_clinicas
(id_mascota, observaciones_generales)
VALUES (@id_mascota, 'Inicio de historia clínica');

SET @id_historia = SCOPE_IDENTITY();
END

        -- 🩺 CONSULTA
INSERT INTO dbo.consultas_clinicas
(
    id_historia_clinica,
    motivo_consulta,
    anamnesis,
    examen_general,
    diagnostico,
    tratamiento,
    observaciones
)
VALUES
    (
        @id_historia,
        @motivo,
        @anamnesis,
        @examen,
        @diagnostico,
        @tratamiento_general,
        @observaciones
    );

DECLARE @id_consulta INT = SCOPE_IDENTITY();

        -- 💊 TRATAMIENTOS (AHORA POR ID)
        IF EXISTS (SELECT 1 FROM OPENJSON(@json, '$.tratamientos'))
BEGIN
            DECLARE @tmp_tratamientos TABLE
            (
                id_medicamento INT,
                dosis NVARCHAR(100),
                frecuencia NVARCHAR(100),
                duracion_dias INT,
                indicaciones NVARCHAR(1000)
            );

INSERT INTO @tmp_tratamientos
SELECT
    TRY_CAST(JSON_VALUE(value, '$.id_medicamento') AS INT),
    JSON_VALUE(value, '$.dosis'),
    JSON_VALUE(value, '$.frecuencia'),
    TRY_CAST(JSON_VALUE(value, '$.duracion_dias') AS INT),
    JSON_VALUE(value, '$.indicaciones')
FROM OPENJSON(@json, '$.tratamientos');

-- 🔒 Validar existencia de medicamentos
IF EXISTS (
                SELECT 1
                FROM @tmp_tratamientos t
                LEFT JOIN dbo.medicamentos m ON m.id_medicamento = t.id_medicamento
                WHERE t.id_medicamento IS NOT NULL
                  AND m.id_medicamento IS NULL
            )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'Uno o más medicamentos no existen' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

            -- 💊 Insertar tratamientos
INSERT INTO dbo.tratamientos
(id_consulta, id_medicamento, dosis, frecuencia, duracion_dias, indicaciones)
SELECT
    @id_consulta,
    t.id_medicamento,
    t.dosis,
    t.frecuencia,
    t.duracion_dias,
    t.indicaciones
FROM @tmp_tratamientos t
WHERE t.id_medicamento IS NOT NULL;
END

        -- 🧪 ESTUDIOS
        IF EXISTS (SELECT 1 FROM OPENJSON(@json, '$.estudios'))
BEGIN
INSERT INTO dbo.estudios_clinicos
(id_consulta, tipo_estudio, resultado, observaciones)
SELECT
    @id_consulta,
    JSON_VALUE(value, '$.tipo_estudio'),
    JSON_VALUE(value, '$.resultado'),
    JSON_VALUE(value, '$.observaciones')
FROM OPENJSON(@json, '$.estudios')
WHERE JSON_VALUE(value, '$.tipo_estudio') IS NOT NULL;
END

        -- 📎 ARCHIVOS
        IF EXISTS (SELECT 1 FROM OPENJSON(@json, '$.archivos'))
BEGIN
INSERT INTO dbo.archivos_clinicos
(id_consulta, url_archivo, tipo_archivo, descripcion)
SELECT
    @id_consulta,
    JSON_VALUE(value, '$.url_archivo'),
    JSON_VALUE(value, '$.tipo_archivo'),
    JSON_VALUE(value, '$.descripcion')
FROM OPENJSON(@json, '$.archivos')
WHERE JSON_VALUE(value, '$.url_archivo') IS NOT NULL;
END

COMMIT;

SELECT
    @id_consulta AS id_consulta,
    'OK' AS status
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
END CATCH
END;
GO
/*====Ejemplo de uso

DECLARE @json NVARCHAR(MAX) = '
{
  "id_usuario": 1,
  "id_mascota": 1,
  "motivo_consulta": "Infeccion leve",
  "anamnesis": "Decaimiento y falta de apetito",
  "examen_general": "Temperatura elevada",
  "diagnostico": "Infeccion bacteriana",
  "tratamiento": "Antibiotico",
  "observaciones": "Control en 5 dias",

  "tratamientos": [
    {
      "id_medicamento": 1,
      "dosis": "1 comprimido",
      "frecuencia": "Cada 12hs",
      "duracion_dias": 7,
      "indicaciones": "Despues de comer"
    }
  ],

  "estudios": [],
  "archivos": []
}';

EXEC dbo.sp_insert_consulta_clinica_json @json;

SELECT 
    c.id_consulta,
    c.fecha,
    c.motivo_consulta,
    c.diagnostico,

    t.id_tratamiento,
    m.nombre AS medicamento,
    t.dosis,
    t.frecuencia,

    e.tipo_estudio,
    e.resultado,

    a.url_archivo,
    a.tipo_archivo

FROM dbo.consultas_clinicas c

LEFT JOIN dbo.tratamientos t 
    ON t.id_consulta = c.id_consulta

LEFT JOIN dbo.medicamentos m 
    ON m.id_medicamento = t.id_medicamento

LEFT JOIN dbo.estudios_clinicos e 
    ON e.id_consulta = c.id_consulta

LEFT JOIN dbo.archivos_clinicos a 
    ON a.id_consulta = c.id_consulta

ORDER BY c.id_consulta DESC;
*/
go

/*============================================================================0
  procedimientos de administrar medicamentos
================================================================================*/
go
--para el selector del formulario 
CREATE OR ALTER PROCEDURE dbo.sp_get_medicamentos
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    id_medicamento,
    nombre
FROM dbo.medicamentos
ORDER BY nombre
    FOR JSON PATH;
END;
GO
--para la creacion de uno nuevo
CREATE OR ALTER PROCEDURE dbo.sp_insert_medicamento
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(150),
        @nombre_normalizado NVARCHAR(150),
        @id_medicamento INT;

    -- 🔹 Parsear JSON
SELECT
    @nombre = LTRIM(RTRIM(JSON_VALUE(@json, '$.nombre')));

-- 🔹 Validación
IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT
    0 AS success,
    'El nombre del medicamento es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔥 Normalización (clave)
    SET @nombre_normalizado = UPPER(LTRIM(RTRIM(@nombre)));

    -- 🔹 Buscar si ya existe (case insensitive)
SELECT @id_medicamento = id_medicamento
FROM dbo.medicamentos
WHERE UPPER(LTRIM(RTRIM(nombre))) = @nombre_normalizado;

-- 🔥 SI EXISTE → devolverlo
IF @id_medicamento IS NOT NULL
BEGIN
SELECT
    1 AS success,
    'El medicamento ya existía' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_medicamento,
                    nombre
                FROM dbo.medicamentos
                WHERE id_medicamento = @id_medicamento
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS medicamento
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

    -- 🔹 Insertar (guardado limpio)
INSERT INTO dbo.medicamentos (nombre)
VALUES (@nombre_normalizado);

SET @id_medicamento = SCOPE_IDENTITY();

    -- 🔹 Respuesta
SELECT
    1 AS success,
    'Medicamento creado correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_medicamento,
                    nombre
                FROM dbo.medicamentos
                WHERE id_medicamento = @id_medicamento
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS medicamento
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO

/*============================================================================0
  procedimientos de administrar vacunas
================================================================================*/
--DECLARE @json NVARCHAR(MAX) = '{  "id_usuario": 1, "id_mascota": 1,  "id_vacuna": 1,  "fecha_aplicacion": "2025-03-15",  "proxima_dosis": "2026-03-15",  "observaciones": "Sin reacción post-vacunal"}';
--EXEC dbo.sp_insert_vacunacion_json @json;
CREATE OR ALTER PROCEDURE dbo.sp_insert_vacunacion_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = TRY_CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
            @id_mascota INT = TRY_CAST(JSON_VALUE(@json, '$.id_mascota') AS INT),
            @id_vacuna INT = TRY_CAST(JSON_VALUE(@json, '$.id_vacuna') AS INT),
            @fecha_aplicacion DATE,
            @proxima_dosis DATE,
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.observaciones');

        -- 🔥 Conversión segura fechas
        SET @fecha_aplicacion = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.fecha_aplicacion'));
        SET @proxima_dosis = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.proxima_dosis'));

        -- 🔒 VALIDACIÓN MASCOTA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La mascota no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🔒 VALIDACIÓN VACUNA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.vacunas
            WHERE id_vacuna = @id_vacuna
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La vacuna no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 💉 INSERTAR VACUNACIÓN
INSERT INTO dbo.vacunas_mascota
(
    id_mascota,
    id_vacuna,
    fecha_aplicacion,
    proxima_dosis,
    observaciones
)
VALUES
    (
        @id_mascota,
        @id_vacuna,
        @fecha_aplicacion,
        @proxima_dosis,
        @observaciones
    );

COMMIT;

SELECT
    1 AS success,
    'Vacunación registrada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    @id_mascota AS id_mascota,
                    @id_vacuna AS id_vacuna,
                    @fecha_aplicacion AS fecha_aplicacion,
                    @proxima_dosis AS proxima_dosis
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS vacunacion
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_vacunas
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    id_vacuna,
    nombre
FROM dbo.vacunas
ORDER BY nombre
    FOR JSON PATH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.sp_insert_vacuna_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(150),
        @nombre_normalizado NVARCHAR(150),
        @id_vacuna INT;

    -- 🔹 Parsear JSON
SELECT
    @nombre = LTRIM(RTRIM(JSON_VALUE(@json, '$.nombre')));

-- 🔹 Validación
IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT
    0 AS success,
    'El nombre de la vacuna es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔥 Normalización
    SET @nombre_normalizado = UPPER(LTRIM(RTRIM(@nombre)));

    -- 🔹 Buscar si ya existe
SELECT @id_vacuna = id_vacuna
FROM dbo.vacunas
WHERE UPPER(LTRIM(RTRIM(nombre))) = @nombre_normalizado;

-- 🔥 Si existe → devolver
IF @id_vacuna IS NOT NULL
BEGIN
SELECT
    1 AS success,
    'La vacuna ya existía' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_vacuna,
                    nombre
                FROM dbo.vacunas
                WHERE id_vacuna = @id_vacuna
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS vacuna
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

    -- 🔹 Insertar
INSERT INTO dbo.vacunas (nombre)
VALUES (@nombre_normalizado);

SET @id_vacuna = SCOPE_IDENTITY();

    -- 🔹 Respuesta
SELECT
    1 AS success,
    'Vacuna creada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_vacuna,
                    nombre
                FROM dbo.vacunas
                WHERE id_vacuna = @id_vacuna
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS vacuna
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO

/*============================================================================0
  procedimientos de administrar desparasitacion
================================================================================*/
--DECLARE @json NVARCHAR(MAX) = '{ "id_usuario": 1,  "id_mascota": 1,  "id_desparasitacion": 1,  "fecha_aplicacion": "2025-03-15",  "proxima_dosis": "2025-09-15",  "observaciones": "Dosis 2 comp."}';
--EXEC dbo.sp_insert_desparasitacion_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_insert_desparasitacion_mascota_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = TRY_CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
            @id_mascota INT = TRY_CAST(JSON_VALUE(@json, '$.id_mascota') AS INT),
            @id_desparasitacion INT = TRY_CAST(JSON_VALUE(@json, '$.id_desparasitacion') AS INT),
            @fecha_aplicacion DATE,
            @proxima_dosis DATE,
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.observaciones');

        -- 🔥 Conversión segura fechas
        SET @fecha_aplicacion = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.fecha_aplicacion'));
        SET @proxima_dosis = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.proxima_dosis'));

        -- 🔒 VALIDACIÓN MASCOTA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La mascota no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🔒 VALIDACIÓN DESPARASITACIÓN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.desparasitaciones
            WHERE id_desparasitacion = @id_desparasitacion
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'El desparasitante no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 💉 INSERTAR REGISTRO
INSERT INTO dbo.desparasitaciones_mascota
(
    id_mascota,
    id_desparasitacion,
    fecha_aplicacion,
    proxima_dosis,
    observaciones
)
VALUES
    (
        @id_mascota,
        @id_desparasitacion,
        @fecha_aplicacion,
        @proxima_dosis,
        @observaciones
    );

COMMIT;

SELECT
    1 AS success,
    'Desparasitación registrada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    @id_mascota AS id_mascota,
                    @id_desparasitacion AS id_desparasitacion,
                    @fecha_aplicacion AS fecha_aplicacion,
                    @proxima_dosis AS proxima_dosis
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS desparasitacion
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_desparasitaciones
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    id_desparasitacion,
    nombre,
    tipo
FROM dbo.desparasitaciones
ORDER BY nombre
    FOR JSON PATH;
END;
GO
CREATE OR ALTER PROCEDURE sp_insert_desparasitacion_catalogo_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(150),
        @tipo NVARCHAR(50),
        @nombre_normalizado NVARCHAR(150),
        @tipo_normalizado NVARCHAR(50),
        @id_desparasitacion INT;

    -- 🔹 Parsear JSON
SELECT
    @nombre = LTRIM(RTRIM(JSON_VALUE(@json, '$.nombre'))),
    @tipo = LTRIM(RTRIM(JSON_VALUE(@json, '$.tipo')));

-- 🔹 Validación nombre
IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT
    0 AS success,
    'El nombre es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔥 Normalización
    SET @nombre_normalizado = UPPER(@nombre);
    SET @tipo_normalizado = UPPER(@tipo);

    -- 🔒 Validación tipo (opcional pero PRO)
    IF @tipo_normalizado IS NOT NULL 
       AND @tipo_normalizado NOT IN ('INTERNO', 'EXTERNO')
BEGIN
SELECT
    0 AS success,
    'Tipo inválido (INTERNO / EXTERNO)' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔍 Buscar si ya existe
SELECT @id_desparasitacion = id_desparasitacion
FROM dbo.desparasitaciones
WHERE UPPER(LTRIM(RTRIM(nombre))) = @nombre_normalizado;

-- 🔁 Si existe → devolver
IF @id_desparasitacion IS NOT NULL
BEGIN
SELECT
    1 AS success,
    'El desparasitante ya existía' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_desparasitacion,
                    nombre,
                    tipo
                FROM dbo.desparasitaciones
                WHERE id_desparasitacion = @id_desparasitacion
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS desparasitacion
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

    -- ➕ Insertar
INSERT INTO dbo.desparasitaciones (nombre, tipo)
VALUES (@nombre_normalizado, @tipo_normalizado);

SET @id_desparasitacion = SCOPE_IDENTITY();

    -- 🔹 Respuesta
SELECT
    1 AS success,
    'Desparasitante creado correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_desparasitacion,
                    nombre,
                    tipo
                FROM dbo.desparasitaciones
                WHERE id_desparasitacion = @id_desparasitacion
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS desparasitacion
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO


--DECLARE @json NVARCHAR(MAX) = '{  "id_usuario": 1,  "id_mascota": 1,  "fecha": "2025-04-01",  "peso": 28.5,  "observaciones": "Peso estable"}';
--EXEC dbo.sp_insert_peso_json @json;
CREATE OR ALTER PROCEDURE dbo.sp_insert_peso_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = JSON_VALUE(@json, '$.id_usuario'),
            @id_mascota INT = JSON_VALUE(@json, '$.id_mascota'),
            @fecha DATE = ISNULL(JSON_VALUE(@json, '$.fecha'), GETDATE()),
            @peso DECIMAL(5,2) = TRY_CAST(JSON_VALUE(@json, '$.peso') AS DECIMAL(5,2)),
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.observaciones');

        -- 🔒 VALIDACIÓN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
            THROW 50001, 'La mascota no pertenece al usuario', 1;
END

        -- ⚠ VALIDACIÓN PESO
        IF @peso IS NULL OR @peso <= 0
BEGIN
            THROW 50002, 'Peso inválido', 1;
END

        -- 💉 INSERT
INSERT INTO dbo.peso_mascota
(
    id_mascota,
    fecha,
    peso,
    observaciones
)
VALUES
    (
        @id_mascota,
        @fecha,
        @peso,
        @observaciones
    );

COMMIT;

SELECT
    'OK' AS status
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

        THROW;
END CATCH
END;
GO

/*============================================================================0
  procedimientos de administrar enfermedad
================================================================================*/

go
--DECLARE @json NVARCHAR(MAX) = '{  "id_usuario": 1,  "id_mascota": 1,  "id_enfermedad": 1,  "estado": "CURADA",  "fecha_diagnostico": "2024-11-04",  "observaciones": "Resolución en 5 días con tratamiento"}';
--EXEC dbo.sp_insert_enfermedad_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_insert_enfermedad_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = TRY_CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
            @id_mascota INT = TRY_CAST(JSON_VALUE(@json, '$.id_mascota') AS INT),
            @id_enfermedad INT = TRY_CAST(JSON_VALUE(@json, '$.id_enfermedad') AS INT),
            @estado NVARCHAR(20) = JSON_VALUE(@json, '$.estado'),
            @fecha_diagnostico DATE,
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.observaciones');

        -- 🔥 Conversión segura fecha
        SET @fecha_diagnostico = TRY_CONVERT(DATE, JSON_VALUE(@json, '$.fecha_diagnostico'));

        -- 🔒 VALIDACIÓN MASCOTA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La mascota no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🔒 VALIDACIÓN ENFERMEDAD
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.enfermedades
            WHERE id_enfermedad = @id_enfermedad
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La enfermedad no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🧠 NORMALIZAR ESTADO
        SET @estado = UPPER(LTRIM(RTRIM(@estado)));

        IF @estado IN ('CURADO', 'CURADA')
            SET @estado = 'CURADA';

        IF @estado = 'CRÓNICA'
            SET @estado = 'CRONICA';

        -- 🔒 VALIDACIÓN ESTADO
        IF @estado NOT IN ('ACTIVA', 'CURADA', 'CRONICA')
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'Estado inválido (ACTIVA, CURADA, CRONICA)' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 💉 INSERTAR REGISTRO
INSERT INTO dbo.enfermedades_mascota
(
    id_mascota,
    id_enfermedad,
    fecha_diagnostico,
    estado,
    observaciones
)
VALUES
    (
        @id_mascota,
        @id_enfermedad,
        @fecha_diagnostico,
        @estado,
        @observaciones
    );

COMMIT;

SELECT
    1 AS success,
    'Enfermedad registrada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    @id_mascota AS id_mascota,
                    @id_enfermedad AS id_enfermedad,
                    @fecha_diagnostico AS fecha_diagnostico,
                    @estado AS estado
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS enfermedad
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

CREATE OR ALTER PROCEDURE dbo.sp_get_enfermedades
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    id_enfermedad,
    nombre
FROM dbo.enfermedades
ORDER BY nombre
    FOR JSON PATH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.sp_insert_enfermedad_catalogo_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(150),
        @nombre_normalizado NVARCHAR(150),
        @id_enfermedad INT;

    -- 🔹 Parsear JSON
SELECT
    @nombre = LTRIM(RTRIM(JSON_VALUE(@json, '$.nombre')));

-- 🔹 Validación
IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT
    0 AS success,
    'El nombre de la enfermedad es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔥 Normalización
    SET @nombre_normalizado = UPPER(@nombre);

    -- 🔍 Buscar existente (case insensitive)
SELECT @id_enfermedad = id_enfermedad
FROM dbo.enfermedades
WHERE UPPER(LTRIM(RTRIM(nombre))) = @nombre_normalizado;

-- 🔁 Si existe → devolver
IF @id_enfermedad IS NOT NULL
BEGIN
SELECT
    1 AS success,
    'La enfermedad ya existía' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_enfermedad,
                    nombre
                FROM dbo.enfermedades
                WHERE id_enfermedad = @id_enfermedad
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS enfermedad
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

    -- ➕ Insertar
INSERT INTO dbo.enfermedades (nombre)
VALUES (@nombre_normalizado);

SET @id_enfermedad = SCOPE_IDENTITY();

    -- 🔹 Respuesta
SELECT
    1 AS success,
    'Enfermedad creada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_enfermedad,
                    nombre
                FROM dbo.enfermedades
                WHERE id_enfermedad = @id_enfermedad
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS enfermedad
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO

/*============================================================================0
  procedimientos de administrar alergia
================================================================================*/

--DECLARE @json NVARCHAR(MAX) = '{  "id_usuario": 1,  "id_mascota": 1, "id_alergia": 1,  "descripcion": "Alergia estacional",  "severidad": "leve",  "observaciones": "Primavera principalmente"}';
--EXEC dbo.sp_insert_alergia_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_insert_alergia_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_usuario INT = TRY_CAST(JSON_VALUE(@json, '$.id_usuario') AS INT),
            @id_mascota INT = TRY_CAST(JSON_VALUE(@json, '$.id_mascota') AS INT),
            @id_alergia INT = TRY_CAST(JSON_VALUE(@json, '$.id_alergia') AS INT),
            @severidad NVARCHAR(20) = JSON_VALUE(@json, '$.severidad'),
            @observaciones NVARCHAR(500) = JSON_VALUE(@json, '$.observaciones');

        -- 🔒 VALIDACIÓN MASCOTA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.mascotas
            WHERE id_mascota = @id_mascota
              AND id_usuario = @id_usuario
              AND activo = 1
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La mascota no pertenece al usuario' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🔒 VALIDACIÓN ALERGIA
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.alergias
            WHERE id_alergia = @id_alergia
        )
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'La alergia no existe' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 🧠 NORMALIZAR SEVERIDAD
        SET @severidad = UPPER(LTRIM(RTRIM(@severidad)));

        IF @severidad IN ('MODERADA')
            SET @severidad = 'MEDIA';

        IF @severidad IN ('GRAVE')
            SET @severidad = 'ALTA';

        -- 🔒 VALIDACIÓN SEVERIDAD
        IF @severidad NOT IN ('LEVE', 'MEDIA', 'ALTA')
BEGIN
ROLLBACK;

SELECT
    0 AS success,
    'Severidad inválida (LEVE, MEDIA, ALTA)' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

        -- 💉 INSERTAR RELACIÓN
INSERT INTO dbo.alergias_mascota
(
    id_mascota,
    id_alergia,
    severidad,
    observaciones
)
VALUES
    (
        @id_mascota,
        @id_alergia,
        @severidad,
        @observaciones
    );

COMMIT;

SELECT
    1 AS success,
    'Alergia registrada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    @id_mascota AS id_mascota,
                    @id_alergia AS id_alergia,
                    @severidad AS severidad
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS alergia
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK;

SELECT
    0 AS success,
    ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

CREATE OR ALTER PROCEDURE  dbo.sp_get_alergias
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    id_alergia,
    nombre
FROM dbo.alergias
ORDER BY nombre
    FOR JSON PATH;
END;
GO
go
CREATE OR ALTER PROCEDURE dbo.sp_insert_alergia_catalogo_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@nombre NVARCHAR(150),
        @nombre_normalizado NVARCHAR(150),
        @id_alergia INT;

    -- 🔹 Parsear JSON
SELECT
    @nombre = LTRIM(RTRIM(JSON_VALUE(@json, '$.nombre')));

-- 🔹 Validación
IF @nombre IS NULL OR @nombre = ''
BEGIN
SELECT
    0 AS success,
    'El nombre de la alergia es obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

    -- 🔥 Normalización
    SET @nombre_normalizado = UPPER(@nombre);

    -- 🔍 Buscar existente (case insensitive)
SELECT @id_alergia = id_alergia
FROM dbo.alergias
WHERE UPPER(LTRIM(RTRIM(nombre))) = @nombre_normalizado;

-- 🔁 Si existe → devolver
IF @id_alergia IS NOT NULL
BEGIN
SELECT
    1 AS success,
    'La alergia ya existía' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_alergia,
                    nombre
                FROM dbo.alergias
                WHERE id_alergia = @id_alergia
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
            ) AS alergia
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

RETURN;
END

    -- ➕ Insertar
INSERT INTO dbo.alergias (nombre)
VALUES (@nombre_normalizado);

SET @id_alergia = SCOPE_IDENTITY();

    -- 🔹 Respuesta
SELECT
    1 AS success,
    'Alergia creada correctamente' AS mensaje,
    JSON_QUERY(
            (
                SELECT
                    id_alergia,
                    nombre
                FROM dbo.alergias
                WHERE id_alergia = @id_alergia
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
        ) AS alergia
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END;
GO

/*============================================================================0
  procedimientos de administrar servicios
================================================================================*/
go
CREATE OR ALTER PROCEDURE dbo.sp_get_servicios_json
    AS
BEGIN
    SET NOCOUNT ON;

SELECT
    s.id_servicio,
    s.nombre,
    s.descripcion,

    JSON_QUERY(
            (
                SELECT
                    sp.tamanio,
                    sp.precio,
                    sp.duracion_minutos
                FROM dbo.servicios_precios sp
                WHERE sp.id_servicio = s.id_servicio
                FOR JSON PATH
        )) AS precios

FROM dbo.servicios s
WHERE s.activo = 1
    FOR JSON PATH, ROOT('servicios');
END;
GO

--DECLARE @json NVARCHAR(MAX) = '{ "nombre": "BAÑOs",  "descripcion": "Baño completo y corte",  "precios": [    { "tamanio": "CHICO", "precio": 5000, "duracion": 45 },    { "tamanio": "MEDIANO", "precio": 7000, "duracion": 60 },    { "tamanio": "GRANDE", "precio": 9000, "duracion": 90 }  ]}';
--EXEC dbo.sp_insert_servicio_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_insert_servicio_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@nombre NVARCHAR(100) = JSON_VALUE(@json, '$.nombre'),
            @descripcion NVARCHAR(500) = JSON_VALUE(@json, '$.descripcion');

        IF @nombre IS NULL
BEGIN
SELECT 0 AS success, 'Nombre obligatorio' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
RETURN;
END

INSERT INTO dbo.servicios (nombre, descripcion, duracion_minutos, precio_base, activo)
VALUES (@nombre, @descripcion, 0, 0, 1);

DECLARE @id_servicio INT = SCOPE_IDENTITY();

INSERT INTO dbo.servicios_precios
(id_servicio, tamanio, precio, duracion_minutos)
SELECT
    @id_servicio,
    UPPER(JSON_VALUE(value, '$.tamanio')),
    TRY_CAST(JSON_VALUE(value, '$.precio') AS DECIMAL(12,2)),
    TRY_CAST(JSON_VALUE(value, '$.duracion') AS INT)
FROM OPENJSON(@json, '$.precios');

COMMIT;

SELECT 1 AS success, 'OK' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK;

SELECT 0 AS success, ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

--DECLARE @json NVARCHAR(MAX) = '{  "id_servicio": 3,  "nombre": "BAÑO PREMIUM",  "descripcion": "Baño mejorado",  "precios": [    { "tamanio": "CHICO", "precio": 5000, "duracion": 50 },    { "tamanio": "MEDIANO", "precio": 7000, "duracion": 70 },    { "tamanio": "GRANDE", "precio": 9000, "duracion": 100 }  ]}';
--EXEC dbo.sp_update_servicio_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_update_servicio_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

BEGIN TRY
BEGIN TRAN;

        DECLARE
@id_servicio INT = JSON_VALUE(@json, '$.id_servicio'),
            @nombre NVARCHAR(100) = JSON_VALUE(@json, '$.nombre'),
            @descripcion NVARCHAR(500) = JSON_VALUE(@json, '$.descripcion');

UPDATE dbo.servicios
SET nombre = ISNULL(@nombre, nombre),
    descripcion = ISNULL(@descripcion, descripcion)
WHERE id_servicio = @id_servicio;

DELETE FROM dbo.servicios_precios
WHERE id_servicio = @id_servicio;

INSERT INTO dbo.servicios_precios
(id_servicio, tamanio, precio, duracion_minutos)
SELECT
    @id_servicio,
    UPPER(JSON_VALUE(value, '$.tamanio')),
    TRY_CAST(JSON_VALUE(value, '$.precio') AS DECIMAL(12,2)),
    TRY_CAST(JSON_VALUE(value, '$.duracion') AS INT)
FROM OPENJSON(@json, '$.precios');

COMMIT;

SELECT 1 AS success, 'OK' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0 ROLLBACK;

SELECT 0 AS success, ERROR_MESSAGE() AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END CATCH
END;
GO

--DECLARE @json NVARCHAR(MAX) = '{  "id_servicio": 1}';
--EXEC dbo.sp_delete_servicio_json @json;
go
CREATE OR ALTER PROCEDURE dbo.sp_delete_servicio_json
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    DECLARE @id_servicio INT = JSON_VALUE(@json, '$.id_servicio');

UPDATE dbo.servicios
SET activo = 0
WHERE id_servicio = @id_servicio;

SELECT 1 AS success, 'OK' AS mensaje
        FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO

--DECLARE @json NVARCHAR(MAX) = '{  "id_servicio": 2,  "id_mascota": 5}';
--EXEC dbo.sp_get_servicio_por_mascota @json;
CREATE OR ALTER PROCEDURE dbo.sp_get_servicio_por_mascota
    (
    @json NVARCHAR(MAX)
    )
    AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
@id_servicio INT = JSON_VALUE(@json, '$.id_servicio'),
        @id_mascota INT = JSON_VALUE(@json, '$.id_mascota');

SELECT
    s.id_servicio,
    s.nombre,

    ISNULL(sp.precio, s.precio_base) AS precio,
    ISNULL(sp.duracion_minutos, s.duracion_minutos) AS duracion

FROM dbo.servicios s
         LEFT JOIN dbo.mascotas m ON m.id_mascota = @id_mascota
         LEFT JOIN dbo.servicios_precios sp
                   ON sp.id_servicio = s.id_servicio
                       AND sp.tamanio = m.tamanio

WHERE s.id_servicio = @id_servicio
  AND s.activo = 1

    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;
END;
GO


