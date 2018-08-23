-----------------
-- TABLE d_car --
-----------------

DROP TABLE IF EXISTS public.d_car CASCADE;

CREATE TABLE IF NOT EXISTS public.d_car
(
    id SERIAL PRIMARY KEY,
    brand character varying(1000),
    car_model character varying(1000) ,
    color character varying(1000),
    manufacture_year integer
)
TABLESPACE pg_default;


---------------------------
-- TABLE d_accident_type --
---------------------------

DROP TABLE IF EXISTS public.d_accident_type CASCADE;

CREATE TABLE IF NOT EXISTS public.d_accident_type
(
    id SERIAL PRIMARY KEY,
    name character varying(1000) ,
    alias character varying(1000)
)
TABLESPACE pg_default;

------------------------
-- TABLE f_accident --
------------------------

DROP TABLE IF EXISTS public.f_accident CASCADE;

CREATE TABLE IF NOT EXISTS public.f_accident
(
    id SERIAL PRIMARY KEY,
    datetime timestamp with time zone,
    address character varying(1000),
    longitude double precision,
    latitude double precision,
    type_id integer,
    geo_updated boolean NOT NULL,
    created_at timestamp with time zone NOT NULL,
    CONSTRAINT dtpmapapp_mvc_type_id_4fbc8b7c_fk_dtpmapapp_mvctype_id FOREIGN KEY (type_id)
        REFERENCES public.d_accident_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
)
TABLESPACE pg_default;


---------------------------
-- TABLE d_participant --
---------------------------

DROP TABLE IF EXISTS public.d_participant CASCADE;

CREATE TABLE IF NOT EXISTS public.d_participant
(
    id SERIAL PRIMARY KEY,
    role character varying(1000),
    driving_experience integer,
    status character varying(1000) ,
    gender character varying(1000) ,
    abscond character varying(1000) ,
    car_id integer,
    mvc_id integer,
    CONSTRAINT dtpmapapp_participant_car_id_4dc6a1c8_fk_dtpmapapp_car_id FOREIGN KEY (car_id)
        REFERENCES public.d_car (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED,
    CONSTRAINT dtpmapapp_participant_mvc_id_42479ed5_fk_dtpmapapp_mvc_id FOREIGN KEY (mvc_id)
        REFERENCES public.f_accident (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
        DEFERRABLE INITIALLY DEFERRED
)
TABLESPACE pg_default;