-- DROP SCHEMA public;

CREATE SCHEMA public AUTHORIZATION postgres;

-- DROP TYPE public."attr_type";

CREATE TYPE public."attr_type" AS ENUM (
	'text',
	'date',
	'bool',
	'float');

-- DROP SEQUENCE public.attr_types_id_seq;

CREATE SEQUENCE public.attr_types_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1;
-- DROP SEQUENCE public.attr_values_id_seq;

CREATE SEQUENCE public.attr_values_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1;
-- DROP SEQUENCE public.films_id_seq;

CREATE SEQUENCE public.films_id_seq
	INCREMENT BY 1
	MINVALUE 1
	MAXVALUE 9223372036854775807
	START 1;-- public."attributes" definition

-- Drop table

-- DROP TABLE public."attributes";

CREATE TABLE public."attributes" (
	id int4 NOT NULL DEFAULT nextval('attr_types_id_seq'::regclass),
	"type" public."attr_type" NOT NULL,
	"name" varchar NOT NULL,
	CONSTRAINT attr_types_pk PRIMARY KEY (id)
);


-- public.films definition

-- Drop table

-- DROP TABLE public.films;

CREATE TABLE public.films (
	id serial4 NOT NULL,
	title varchar NOT NULL,
	CONSTRAINT films_pk PRIMARY KEY (id)
);


-- public.attr_values definition

-- Drop table

-- DROP TABLE public.attr_values;

CREATE TABLE public.attr_values (
	id serial4 NOT NULL,
	film_id int4 NOT NULL,
	attr_id int4 NOT NULL,
	date_value date NULL,
	text_value text NULL,
	bool_value bool NULL,
	float_val float4 NULL,
	CONSTRAINT attr_values_pk PRIMARY KEY (id),
	CONSTRAINT attr_values_fk FOREIGN KEY (film_id) REFERENCES public.films(id),
	CONSTRAINT attr_values_fk_1 FOREIGN KEY (attr_id) REFERENCES public."attributes"(id)
);
CREATE INDEX attr_values_attr_id_idx ON attr_values USING btree (attr_id);
CREATE INDEX attr_values_film_id_idx ON attr_values USING btree (film_id);


-- public.all_props source

CREATE OR REPLACE VIEW public.all_props
AS SELECT f.title, a.name, 
        CASE
            WHEN a.type = 'text'::attr_type THEN v.text_value
            WHEN a.type = 'date'::attr_type THEN to_char(v.date_value::timestamp with time zone, 'DD.MM.YYYY'::text)
            WHEN a.type = 'bool'::attr_type THEN v.bool_value::text
            WHEN a.type = 'float'::attr_type THEN v.float_val::text
            ELSE NULL::text
        END AS text_value
   FROM films f
   LEFT JOIN attr_values v ON v.film_id = f.id
   LEFT JOIN attributes a ON a.id = v.attr_id;


-- public.future_dates source

CREATE OR REPLACE VIEW public.future_dates
AS SELECT f.title, a.name, v.date_value
   FROM films f
   LEFT JOIN attr_values v ON v.film_id = f.id
   LEFT JOIN attributes a ON a.id = v.attr_id
  WHERE v.date_value >= now() AND v.date_value <= ('now'::text::date + '20 days'::interval);


