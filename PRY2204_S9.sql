
DROP TABLE jugador_idioma     CASCADE CONSTRAINTS;
DROP TABLE permanencia_club   CASCADE CONSTRAINTS;
DROP TABLE personal_planta    CASCADE CONSTRAINTS;
DROP TABLE jugador            CASCADE CONSTRAINTS;
DROP TABLE trabajador         CASCADE CONSTRAINTS;
DROP TABLE idioma             CASCADE CONSTRAINTS;
DROP TABLE escuela_futbol     CASCADE CONSTRAINTS;
DROP TABLE club_futbol        CASCADE CONSTRAINTS;
DROP TABLE asociacion         CASCADE CONSTRAINTS;
DROP TABLE genero             CASCADE CONSTRAINTS;
DROP TABLE estado_civil       CASCADE CONSTRAINTS;
DROP TABLE nacionalidad       CASCADE CONSTRAINTS;
DROP TABLE comuna             CASCADE CONSTRAINTS;
DROP TABLE region             CASCADE CONSTRAINTS;
DROP SEQUENCE seq_club_futbol;



-- FASE 1: CREACION DE TABLAS (de menor a mayor dependencia)

-- 1) REGION
CREATE TABLE region (
    id_region  NUMBER(2)    NOT NULL,
    nombre     VARCHAR2(60) NOT NULL,
    CONSTRAINT region_pk PRIMARY KEY (id_region)
);

-- 2) COMUNA
CREATE TABLE comuna (
    id_comuna         NUMBER(4)    NOT NULL,
    nombre            VARCHAR2(60) NOT NULL,
    region_id_region  NUMBER(2)    NOT NULL,
    CONSTRAINT comuna_pk        PRIMARY KEY (id_comuna),
    CONSTRAINT comuna_region_fk FOREIGN KEY (region_id_region) REFERENCES region (id_region)
);

-- 3) NACIONALIDAD 
CREATE TABLE nacionalidad (
    id_nacion    NUMBER(4) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2) NOT NULL,
    descripcion  VARCHAR2(20) NOT NULL,
    CONSTRAINT nacionalidad_pk PRIMARY KEY (id_nacion)
);

-- 4) ESTADO_CIVIL
CREATE TABLE estado_civil (
    id_estado_civil  NUMBER(2)    NOT NULL,
    descripcion      VARCHAR2(30) NOT NULL,
    CONSTRAINT estado_civil_pk PRIMARY KEY (id_estado_civil)
);

-- 5) GENERO
CREATE TABLE genero (
    id_genero    NUMBER(2)    NOT NULL,
    descripcion  VARCHAR2(30) NOT NULL,
    CONSTRAINT genero_pk PRIMARY KEY (id_genero)
);

-- 6) ASOCIACION
CREATE TABLE asociacion (
    id_asociacion      NUMBER(4)    NOT NULL,
    nombre_asociacion  VARCHAR2(80) NOT NULL,
    fecha_creacion     DATE         NOT NULL,
    tipo_asociacion    CHAR(1)      NOT NULL,
    CONSTRAINT asociacion_pk PRIMARY KEY (id_asociacion),
    CONSTRAINT asociacion_tipo_asociacion_ck CHECK (tipo_asociacion IN ('P', 'A')),
    CONSTRAINT asociacion_fecha_creacion_ck  CHECK (fecha_creacion >= DATE '1980-12-31')
);

-- 7) CLUB_FUTBOL 
CREATE SEQUENCE seq_club_futbol START WITH 703 INCREMENT BY 4 NOCACHE;

CREATE TABLE club_futbol (
    id_club          NUMBER(4)     NOT NULL,
    nombre_club      VARCHAR2(60)  NOT NULL,
    patrimonio       NUMBER(12)    DEFAULT 0 NOT NULL,
    ubicacion_calle  VARCHAR2(100) NOT NULL,
    tipo_club        VARCHAR2(12)  DEFAULT 'Profesional' NOT NULL,
    CONSTRAINT club_futbol_pk PRIMARY KEY (id_club),
    CONSTRAINT club_futbol_nombre_club_un UNIQUE (nombre_club),
    CONSTRAINT club_futbol_patrimonio_ck  CHECK (patrimonio >= 0),
    CONSTRAINT club_futbol_tipo_club_ck   CHECK (tipo_club IN ('Profesional', 'Amateur'))
);

-- 8) ESCUELA_FUTBOL
CREATE TABLE escuela_futbol (
    id_escuela       NUMBER(4)    NOT NULL,
    nombre           VARCHAR2(80) NOT NULL,
    capacidad        NUMBER(5)    NOT NULL,
    fecha_fundacion  DATE         NOT NULL,
    CONSTRAINT escuela_futbol_pk PRIMARY KEY (id_escuela),
    CONSTRAINT escuela_futbol_capacidad_ck CHECK (capacidad > 0)
);

-- 9) IDIOMA
CREATE TABLE idioma (
    id_idioma  NUMBER(8)    NOT NULL,
    nombre     VARCHAR2(40) NOT NULL,
    CONSTRAINT idioma_pk PRIMARY KEY (id_idioma),
    CONSTRAINT idioma_nombre_un UNIQUE (nombre)
);

-- 10) TRABAJADOR (supertipo)
CREATE TABLE trabajador (
    cod_inscripcion                NUMBER(8)     NOT NULL,
    rut                            NUMBER(8)     NOT NULL,
    dv                             CHAR(1)       NOT NULL,
    nombres                        VARCHAR2(60)  NOT NULL,
    apellidos                      VARCHAR2(60)  NOT NULL,
    sueldo_base                    NUMBER(10)    DEFAULT 0 NOT NULL,
    fecha_nacimiento               DATE          NOT NULL,
    telefono_movil                 VARCHAR2(15)  NOT NULL,
    direccion                      VARCHAR2(100) NOT NULL,
    comuna_id_comuna               NUMBER(4)     NOT NULL,
    estado_civil_id_estado_civil   NUMBER(2)     NOT NULL,
    nacionalidad_id_nacion         NUMBER(4)     NOT NULL,
    genero_id_genero               NUMBER(2)     NOT NULL,
    CONSTRAINT trabajador_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT trabajador_rut_un UNIQUE (rut),
    CONSTRAINT trabajador_dv_ck          CHECK (dv IN ('0','1','2','3','4','5','6','7','8','9','K')),
    CONSTRAINT trabajador_sueldo_base_ck CHECK (sueldo_base >= 0),
    CONSTRAINT trabajador_genero_fk       FOREIGN KEY (genero_id_genero)             REFERENCES genero (id_genero),
    CONSTRAINT trabajador_comuna_fk       FOREIGN KEY (comuna_id_comuna)             REFERENCES comuna (id_comuna),
    CONSTRAINT trabajador_estado_civil_fk FOREIGN KEY (estado_civil_id_estado_civil) REFERENCES estado_civil (id_estado_civil),
    CONSTRAINT trabajador_nacionalidad_fk FOREIGN KEY (nacionalidad_id_nacion)       REFERENCES nacionalidad (id_nacion)
);

-- 11) JUGADOR 
CREATE TABLE jugador (
    cod_inscripcion             NUMBER(8)    NOT NULL,
    premios_acumulados          NUMBER(12)   DEFAULT 0 NOT NULL,
    anio_deja_amateurismo       NUMBER(4),
    puesto_campo                VARCHAR2(30) NOT NULL,
    escuela_futbol_id_escuela   NUMBER(4),
    asociacion_id_asociacion    NUMBER(4)    NOT NULL,
    CONSTRAINT jugador_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT jugador_premios_acumulados_ck CHECK (premios_acumulados >= 0),
    CONSTRAINT jugador_anio_amateurismo_ck   CHECK (anio_deja_amateurismo >= 1900),
    CONSTRAINT jugador_trabajador_fk     FOREIGN KEY (cod_inscripcion)           REFERENCES trabajador (cod_inscripcion),
    CONSTRAINT jugador_escuela_futbol_fk FOREIGN KEY (escuela_futbol_id_escuela) REFERENCES escuela_futbol (id_escuela),
    CONSTRAINT jugador_asociacion_fk     FOREIGN KEY (asociacion_id_asociacion)  REFERENCES asociacion (id_asociacion)
);

-- 12) PERSONAL_PLANTA 
CREATE TABLE personal_planta (
    cod_inscripcion            NUMBER(8) NOT NULL,
    cantidad_horas_trabajadas  NUMBER(4),
    valor_horas_extras         NUMBER(4),
    club_futbol_id_club        NUMBER(4) NOT NULL,
    CONSTRAINT personal_planta_pk PRIMARY KEY (cod_inscripcion),
    CONSTRAINT personal_planta_horas_ck  CHECK (cantidad_horas_trabajadas >= 0),
    CONSTRAINT personal_planta_extras_ck CHECK (valor_horas_extras >= 0),
    CONSTRAINT personal_planta_trabajador_fk  FOREIGN KEY (cod_inscripcion)      REFERENCES trabajador (cod_inscripcion),
    CONSTRAINT personal_planta_club_futbol_fk FOREIGN KEY (club_futbol_id_club)  REFERENCES club_futbol (id_club)
);

-- 13) PERMANENCIA_CLUB 
CREATE TABLE permanencia_club (
    fecha_inicio             DATE      NOT NULL,
    fecha_fin                DATE,
    club_futbol_id_club      NUMBER(4) NOT NULL,
    jugador_cod_inscripcion  NUMBER(8) NOT NULL,
    CONSTRAINT permanencia_club_pk PRIMARY KEY (fecha_inicio, jugador_cod_inscripcion, club_futbol_id_club),
    CONSTRAINT permanencia_club_fechas_ck CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio),
    CONSTRAINT permanencia_club_jugador_fk    FOREIGN KEY (jugador_cod_inscripcion) REFERENCES jugador (cod_inscripcion),
    CONSTRAINT permanencia_club_club_futbol_fk FOREIGN KEY (club_futbol_id_club)    REFERENCES club_futbol (id_club)
);


CREATE UNIQUE INDEX permanencia_club_vigente_un
    ON permanencia_club (CASE WHEN fecha_fin IS NULL THEN jugador_cod_inscripcion END);

-- 14) JUGADOR_IDIOMA 
CREATE TABLE jugador_idioma (
    nivel_dominio            VARCHAR2(15) NOT NULL,
    idioma_id_idioma         NUMBER(8)    NOT NULL,
    jugador_cod_inscripcion  NUMBER(8)    NOT NULL,
    CONSTRAINT jugador_idioma_pk PRIMARY KEY (idioma_id_idioma, jugador_cod_inscripcion),
    CONSTRAINT jugador_idioma_nivel_dominio_ck CHECK (nivel_dominio IN ('Basico', 'Intermedio', 'Avanzado', 'Nativo')),
    CONSTRAINT jugador_idioma_jugador_fk FOREIGN KEY (jugador_cod_inscripcion) REFERENCES jugador (cod_inscripcion),
    CONSTRAINT jugador_idioma_idioma_fk  FOREIGN KEY (idioma_id_idioma)        REFERENCES idioma (id_idioma)
);


-- FASE POBLAMIENTO 
-- REGION
INSERT INTO region (id_region, nombre) VALUES (1,  'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO region (id_region, nombre) VALUES (2,  'ANTOFAGASTA');
INSERT INTO region (id_region, nombre) VALUES (3,  'ATACAMA Y COQUIMBO');
INSERT INTO region (id_region, nombre) VALUES (5,  'VALPARAISO');
INSERT INTO region (id_region, nombre) VALUES (13, 'METROPOLITANA');
INSERT INTO region (id_region, nombre) VALUES (8,  'BIOBIO');
INSERT INTO region (id_region, nombre) VALUES (16, 'ÑUBLE');

-- COMUNA
INSERT INTO comuna (id_comuna, nombre, region_id_region) VALUES (101, 'Santiago',    13);
INSERT INTO comuna (id_comuna, nombre, region_id_region) VALUES (102, 'Valparaíso',   5);
INSERT INTO comuna (id_comuna, nombre, region_id_region) VALUES (103, 'Concepción',   8);
INSERT INTO comuna (id_comuna, nombre, region_id_region) VALUES (104, 'Antofagasta',  2);
INSERT INTO comuna (id_comuna, nombre, region_id_region) VALUES (105, 'Chillán',      16);

-- ASOCIACION
INSERT INTO asociacion VALUES (25, 'Asociación de Fútbol de Santiago',       TO_DATE('15-05-2001','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (26, 'Asociación Nacional de Fútbol Amateur',  TO_DATE('10-03-1998','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (27, 'Asociación de Fútbol de Valparaíso',     TO_DATE('21-07-1987','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (28, 'Asociación de Fútbol de Concepción',     TO_DATE('30-11-1995','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (29, 'Asociación de Fútbol de Antofagasta',    TO_DATE('25-06-2003','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (30, 'Asociación de Fútbol de Temuco',         TO_DATE('12-01-2010','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (31, 'Asociación de Fútbol de Rancagua',       TO_DATE('08-09-1999','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (32, 'Asociación de Fútbol de Puerto Montt',   TO_DATE('20-04-2005','DD-MM-YYYY'), 'A');
INSERT INTO asociacion VALUES (33, 'Asociación de Fútbol de La Serena',      TO_DATE('14-08-2012','DD-MM-YYYY'), 'P');
INSERT INTO asociacion VALUES (34, 'Asociación de Fútbol de Chillán',        TO_DATE('01-12-2018','DD-MM-YYYY'), 'A');

-- NACIONALIDAD (
INSERT INTO nacionalidad (descripcion) VALUES ('Chilena');
INSERT INTO nacionalidad (descripcion) VALUES ('Argentina');
INSERT INTO nacionalidad (descripcion) VALUES ('Peruana');
INSERT INTO nacionalidad (descripcion) VALUES ('Boliviana');
INSERT INTO nacionalidad (descripcion) VALUES ('Brasileña');

-- CLUB_FUTBOL 
INSERT INTO club_futbol (id_club, nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES (seq_club_futbol.NEXTVAL, 'Colo-Colo',            500000000, 'Av. Marathon 5300',                'Profesional');
INSERT INTO club_futbol (id_club, nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES (seq_club_futbol.NEXTVAL, 'Universidad de Chile', 450000000, 'Av. El Parrón 0931',               'Profesional');
INSERT INTO club_futbol (id_club, nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES (seq_club_futbol.NEXTVAL, 'Deportes Antofagasta', 180000000, 'Avenida Angamos 01606',            'Profesional');
INSERT INTO club_futbol (id_club, nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES (seq_club_futbol.NEXTVAL, 'Huachipato',           220000000, 'Avenida Desiderio García 909',     'Profesional');
INSERT INTO club_futbol (id_club, nombre_club, patrimonio, ubicacion_calle, tipo_club)
VALUES (seq_club_futbol.NEXTVAL, 'Ñublense',             170000000, 'Avenida Pedro Aguirre Cerda 1003', 'Profesional');

COMMIT;


-- FASE 4: CONSULTAS DE RECUPERACION DE DATOS

-- Informe 1: 
SELECT 'ID:' || id_asociacion || ' * ' || nombre_asociacion AS asociacion,
       TO_CHAR(fecha_creacion, 'DD-MM-YYYY')                AS creada,
       tipo_asociacion                                      AS tipo
FROM   asociacion
WHERE  tipo_asociacion = 'P'
AND    EXTRACT(YEAR FROM fecha_creacion) > 2000
ORDER  BY fecha_creacion DESC;

-- Informe 2: 
SELECT id_club                 AS "CLUB",
       nombre_club             AS "NOMBRE CLUB",
       patrimonio              AS "PATRIMONIO EN PESOS",
       patrimonio / 955        AS "PATRIMONIO EN DOLARES"
FROM   club_futbol
WHERE  LOWER(nombre_club) LIKE '%a%'
AND    patrimonio > 200000000
AND    tipo_club = 'Profesional'
ORDER  BY id_club DESC;