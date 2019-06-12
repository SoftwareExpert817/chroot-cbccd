--
-- PostgreSQL database cluster dump
--

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

--
-- Roles
--

CREATE ROLE cbcc;
ALTER ROLE cbcc WITH NOSUPERUSER INHERIT NOCREATEROLE CREATEDB LOGIN NOREPLICATION PASSWORD 'md5815bcef6aeb6c57c330347fea1fd9a47';
CREATE ROLE epp;
ALTER ROLE epp WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION;
CREATE ROLE hotspot;
ALTER ROLE hotspot WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION;
CREATE ROLE pop3;
ALTER ROLE pop3 WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION PASSWORD 'md5a8138903fc131c65aa7d97e71fec824c';
CREATE ROLE postgres;
ALTER ROLE postgres WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION;
CREATE ROLE repmgr;
ALTER ROLE repmgr WITH SUPERUSER INHERIT CREATEROLE CREATEDB LOGIN REPLICATION;
CREATE ROLE reporting;
ALTER ROLE reporting WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION;
CREATE ROLE smtp;
ALTER ROLE smtp WITH NOSUPERUSER NOINHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION;




--
-- Tablespaces
--

CREATE TABLESPACE reporting OWNER reporting LOCATION '/var/log/reporting/pgsql';


--
-- Database creation
--

CREATE DATABASE cbcc WITH TEMPLATE = template0 OWNER = cbcc;
CREATE DATABASE epp WITH TEMPLATE = template0 OWNER = epp;
CREATE DATABASE hotspot WITH TEMPLATE = template0 OWNER = hotspot;
CREATE DATABASE pop3 WITH TEMPLATE = template0 OWNER = pop3;
CREATE DATABASE repmgr WITH TEMPLATE = template0 OWNER = repmgr;
CREATE DATABASE reporting WITH TEMPLATE = template0 OWNER = reporting TABLESPACE = reporting;
CREATE DATABASE smtp WITH TEMPLATE = template0 OWNER = smtp;
REVOKE ALL ON DATABASE template1 FROM PUBLIC;
REVOKE ALL ON DATABASE template1 FROM postgres;
GRANT ALL ON DATABASE template1 TO postgres;
GRANT CONNECT ON DATABASE template1 TO PUBLIC;


\connect cbcc

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: cbcc_get_category_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_category_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_category_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_category_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_category_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_category_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_country_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_country_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_country_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_country_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_country_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_country_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_domain_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_domain_id(character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result bigint;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_domain_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_domain_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_domain_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_domain_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_email_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_email_id(character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result bigint;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_email_addresses WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_email_addresses ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_email_addresses WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_email_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_expression_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_expression_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_expression_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_expression_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_expression_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_expression_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_extension_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_extension_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_extension_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_extension_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_extension_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_extension_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_ipaddr_id(inet); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_ipaddr_id(inet) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result bigint;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_ip_addresses WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_ip_addresses ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_ip_addresses WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_ipaddr_id(inet) OWNER TO cbcc;

--
-- Name: cbcc_get_ipsgroup_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_ipsgroup_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_ips_groups WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_ips_groups ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_ips_groups WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_ipsgroup_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_ipsmsg_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_ipsmsg_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_ips_msgs WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_ips_msgs ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_ips_msgs WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_ipsmsg_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_protocol_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_protocol_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_protocol_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_protocol_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_protocol_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_protocol_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_service_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_service_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_service_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_service_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_service_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_service_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_user_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_user_id(character varying) RETURNS bigint
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result bigint;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_user_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_user_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_user_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_user_id(character varying) OWNER TO cbcc;

--
-- Name: cbcc_get_virus_id(character varying); Type: FUNCTION; Schema: public; Owner: cbcc
--

CREATE FUNCTION cbcc_get_virus_id(character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result int;
BEGIN
    SELECT id INTO result FROM aggregated_lookup_virus_names WHERE name = $1;
    IF NOT FOUND THEN
        BEGIN
            INSERT INTO aggregated_lookup_virus_names ( name ) VALUES ( $1 ) RETURNING id INTO result;
        EXCEPTION WHEN unique_violation THEN
            SELECT id INTO result FROM aggregated_lookup_virus_names WHERE name = $1;
        END;
    END IF;
    RETURN result;
END;
$_$;


ALTER FUNCTION public.cbcc_get_virus_id(character varying) OWNER TO cbcc;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: action_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE action_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.action_info OWNER TO cbcc;

--
-- Name: agent_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE agent_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.agent_info OWNER TO cbcc;

--
-- Name: aggregated_accounting_destinations; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_accounting_destinations (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    flow_cnt bigint DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_accounting_destinations OWNER TO cbcc;

--
-- Name: aggregated_accounting_overview; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_accounting_overview (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    flow_cnt bigint DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_accounting_overview OWNER TO cbcc;

--
-- Name: aggregated_accounting_services; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_accounting_services (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    service_id integer NOT NULL,
    protocol_id integer NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    traffic_rx bigint DEFAULT 0 NOT NULL,
    traffic_tx bigint DEFAULT 0 NOT NULL,
    flow_cnt bigint DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_accounting_services OWNER TO cbcc;

--
-- Name: aggregated_accounting_sources; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_accounting_sources (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    flow_cnt bigint DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_accounting_sources OWNER TO cbcc;

--
-- Name: aggregated_emailsec_blocked_expressions; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_blocked_expressions (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_blocked_expressions OWNER TO cbcc;

--
-- Name: aggregated_emailsec_blocked_extensions; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_blocked_extensions (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_blocked_extensions OWNER TO cbcc;

--
-- Name: aggregated_emailsec_blocked_viruses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_blocked_viruses (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_blocked_viruses OWNER TO cbcc;

--
-- Name: aggregated_emailsec_email_recipients; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_email_recipients (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    email_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL,
    sender_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_email_recipients OWNER TO cbcc;

--
-- Name: aggregated_emailsec_email_senders; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_email_senders (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    email_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL,
    recipient_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_email_senders OWNER TO cbcc;

--
-- Name: aggregated_emailsec_overview; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_overview (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL,
    sender_cnt integer DEFAULT 0 NOT NULL,
    recipient_cnt integer DEFAULT 0 NOT NULL,
    spam_sender_cnt integer DEFAULT 0 NOT NULL,
    spam_country_cnt integer DEFAULT 0 NOT NULL,
    virus_cnt integer DEFAULT 0 NOT NULL,
    expression_cnt integer DEFAULT 0 NOT NULL,
    extension_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_overview OWNER TO cbcc;

--
-- Name: aggregated_emailsec_spam_countries; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_spam_countries (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL,
    sender_cnt integer DEFAULT 0 NOT NULL,
    recipient_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_spam_countries OWNER TO cbcc;

--
-- Name: aggregated_emailsec_spam_senders; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_emailsec_spam_senders (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id bigint NOT NULL,
    ipaddr_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    emails bigint DEFAULT 0 NOT NULL,
    sender_cnt integer DEFAULT 0 NOT NULL,
    recipient_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_emailsec_spam_senders OWNER TO cbcc;

--
-- Name: aggregated_lookup_category_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_category_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_category_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_category_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_category_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_category_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_category_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_category_names_id_seq OWNED BY aggregated_lookup_category_names.id;


--
-- Name: aggregated_lookup_country_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_country_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_country_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_country_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_country_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_country_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_country_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_country_names_id_seq OWNED BY aggregated_lookup_country_names.id;


--
-- Name: aggregated_lookup_domain_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_domain_names (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_domain_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_domain_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_domain_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_domain_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_domain_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_domain_names_id_seq OWNED BY aggregated_lookup_domain_names.id;


--
-- Name: aggregated_lookup_email_addresses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_email_addresses (
    id bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.aggregated_lookup_email_addresses OWNER TO cbcc;

--
-- Name: aggregated_lookup_email_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_email_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_email_addresses_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_email_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_email_addresses_id_seq OWNED BY aggregated_lookup_email_addresses.id;


--
-- Name: aggregated_lookup_expression_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_expression_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_expression_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_expression_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_expression_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_expression_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_expression_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_expression_names_id_seq OWNED BY aggregated_lookup_expression_names.id;


--
-- Name: aggregated_lookup_extension_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_extension_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_extension_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_extension_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_extension_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_extension_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_extension_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_extension_names_id_seq OWNED BY aggregated_lookup_extension_names.id;


--
-- Name: aggregated_lookup_ip_addresses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_ip_addresses (
    id bigint NOT NULL,
    name inet NOT NULL
);


ALTER TABLE public.aggregated_lookup_ip_addresses OWNER TO cbcc;

--
-- Name: aggregated_lookup_ip_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_ip_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_ip_addresses_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_ip_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_ip_addresses_id_seq OWNED BY aggregated_lookup_ip_addresses.id;


--
-- Name: aggregated_lookup_ips_groups; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_ips_groups (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_ips_groups OWNER TO cbcc;

--
-- Name: aggregated_lookup_ips_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_ips_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_ips_groups_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_ips_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_ips_groups_id_seq OWNED BY aggregated_lookup_ips_groups.id;


--
-- Name: aggregated_lookup_ips_msgs; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_ips_msgs (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_ips_msgs OWNER TO cbcc;

--
-- Name: aggregated_lookup_ips_msgs_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_ips_msgs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_ips_msgs_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_ips_msgs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_ips_msgs_id_seq OWNED BY aggregated_lookup_ips_msgs.id;


--
-- Name: aggregated_lookup_protocol_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_protocol_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_protocol_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_protocol_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_protocol_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_protocol_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_protocol_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_protocol_names_id_seq OWNED BY aggregated_lookup_protocol_names.id;


--
-- Name: aggregated_lookup_service_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_service_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_service_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_service_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_service_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_service_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_service_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_service_names_id_seq OWNED BY aggregated_lookup_service_names.id;


--
-- Name: aggregated_lookup_user_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_user_names (
    id bigint NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_user_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_user_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_user_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_user_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_user_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_user_names_id_seq OWNED BY aggregated_lookup_user_names.id;


--
-- Name: aggregated_lookup_virus_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_lookup_virus_names (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


ALTER TABLE public.aggregated_lookup_virus_names OWNER TO cbcc;

--
-- Name: aggregated_lookup_virus_names_id_seq; Type: SEQUENCE; Schema: public; Owner: cbcc
--

CREATE SEQUENCE aggregated_lookup_virus_names_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aggregated_lookup_virus_names_id_seq OWNER TO cbcc;

--
-- Name: aggregated_lookup_virus_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: cbcc
--

ALTER SEQUENCE aggregated_lookup_virus_names_id_seq OWNED BY aggregated_lookup_virus_names.id;


--
-- Name: aggregated_netsec_fw_destinations; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_fw_destinations (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    service_cnt integer DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_fw_destinations OWNER TO cbcc;

--
-- Name: aggregated_netsec_fw_services; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_fw_services (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    service_id integer NOT NULL,
    protocol_id integer NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_fw_services OWNER TO cbcc;

--
-- Name: aggregated_netsec_fw_sources; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_fw_sources (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    service_cnt integer DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_fw_sources OWNER TO cbcc;

--
-- Name: aggregated_netsec_fw_targets; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_fw_targets (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    service_id integer NOT NULL,
    protocol_id integer NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    packet_cnt bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_fw_targets OWNER TO cbcc;

--
-- Name: aggregated_netsec_ips_attacks; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_ips_attacks (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    rule_id integer NOT NULL,
    group_id integer NOT NULL,
    msg_id integer NOT NULL,
    alert_cnt bigint DEFAULT 0 NOT NULL,
    drop_cnt bigint DEFAULT 0 NOT NULL,
    src_cnt integer DEFAULT 0 NOT NULL,
    dst_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_ips_attacks OWNER TO cbcc;

--
-- Name: aggregated_netsec_ips_destinations; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_ips_destinations (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    alert_cnt bigint DEFAULT 0 NOT NULL,
    drop_cnt bigint DEFAULT 0 NOT NULL,
    src_cnt integer DEFAULT 0 NOT NULL,
    rule_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_ips_destinations OWNER TO cbcc;

--
-- Name: aggregated_netsec_ips_sources; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_ips_sources (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    country_id integer NOT NULL,
    ipaddr_id bigint NOT NULL,
    alert_cnt bigint DEFAULT 0 NOT NULL,
    drop_cnt bigint DEFAULT 0 NOT NULL,
    dst_cnt integer DEFAULT 0 NOT NULL,
    rule_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_ips_sources OWNER TO cbcc;

--
-- Name: aggregated_netsec_overview; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_netsec_overview (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    fw_events bigint DEFAULT 0 NOT NULL,
    ips_events bigint DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_netsec_overview OWNER TO cbcc;

--
-- Name: aggregated_websec_categories; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_categories (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    subtype integer DEFAULT 0 NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    domain_cnt integer DEFAULT 0 NOT NULL,
    user_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_categories OWNER TO cbcc;

--
-- Name: aggregated_websec_domains; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_domains (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    domain_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    duration integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_domains OWNER TO cbcc;

--
-- Name: aggregated_websec_extensions; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_extensions (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    user_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_extensions OWNER TO cbcc;

--
-- Name: aggregated_websec_overview; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_overview (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    complete boolean DEFAULT false NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    user_dur integer DEFAULT 0 NOT NULL,
    user_cnt integer DEFAULT 0 NOT NULL,
    domain_dur integer DEFAULT 0 NOT NULL,
    domain_cnt integer DEFAULT 0 NOT NULL,
    category_cnt integer DEFAULT 0 NOT NULL,
    extension_cnt integer DEFAULT 0 NOT NULL,
    spyware_cnt integer DEFAULT 0 NOT NULL,
    virus_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_overview OWNER TO cbcc;

--
-- Name: aggregated_websec_users; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_users (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    user_id bigint NOT NULL,
    traffic bigint DEFAULT 0 NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    duration integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_users OWNER TO cbcc;

--
-- Name: aggregated_websec_viruses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE aggregated_websec_viruses (
    guid character varying(255) NOT NULL,
    day date DEFAULT ('now'::text)::date NOT NULL,
    blocked_id integer NOT NULL,
    requests integer DEFAULT 0 NOT NULL,
    domain_cnt integer DEFAULT 0 NOT NULL,
    user_cnt integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.aggregated_websec_viruses OWNER TO cbcc;

--
-- Name: auto_backup_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE auto_backup_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.auto_backup_info OWNER TO cbcc;

--
-- Name: confd_data; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE confd_data (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.confd_data OWNER TO cbcc;

--
-- Name: config_common; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_common (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_common OWNER TO cbcc;

--
-- Name: config_device; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_device (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_device OWNER TO cbcc;

--
-- Name: config_diagnostic; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_diagnostic (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_diagnostic OWNER TO cbcc;

--
-- Name: config_object_ca_rsa; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_ca_rsa (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_ca_rsa OWNER TO cbcc;

--
-- Name: config_object_http_default_action; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_http_default_action (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_http_default_action OWNER TO cbcc;

--
-- Name: config_object_http_pac_file; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_http_pac_file (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_http_pac_file OWNER TO cbcc;

--
-- Name: config_object_ipsec_site2site; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_ipsec_site2site (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_ipsec_site2site OWNER TO cbcc;

--
-- Name: config_object_network_interface; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_network_interface (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_network_interface OWNER TO cbcc;

--
-- Name: config_object_packetfilter_rules_back; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_packetfilter_rules_back (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_packetfilter_rules_back OWNER TO cbcc;

--
-- Name: config_object_packetfilter_rules_front; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_object_packetfilter_rules_front (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_object_packetfilter_rules_front OWNER TO cbcc;

--
-- Name: config_user; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE config_user (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.config_user OWNER TO cbcc;

--
-- Name: device_backup; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_backup (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_backup OWNER TO cbcc;

--
-- Name: device_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_info OWNER TO cbcc;

--
-- Name: device_inventory; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_inventory (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_inventory OWNER TO cbcc;

--
-- Name: device_location; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_location (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_location OWNER TO cbcc;

--
-- Name: device_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_ou OWNER TO cbcc;

--
-- Name: device_product; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE device_product (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.device_product OWNER TO cbcc;

--
-- Name: event_log; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE event_log (
    event_id character varying(255) NOT NULL,
    msg character varying(255) NOT NULL,
    dev_guid character varying(255) NOT NULL,
    "timestamp" timestamp(0) without time zone NOT NULL
);


ALTER TABLE public.event_log OWNER TO cbcc;

--
-- Name: event_log_settings; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE event_log_settings (
    id character varying(255) NOT NULL,
    expired_after integer DEFAULT 30 NOT NULL
);


ALTER TABLE public.event_log_settings OWNER TO cbcc;

--
-- Name: global_epp_av_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_epp_av_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_epp_av_policy OWNER TO cbcc;

--
-- Name: global_epp_av_policy_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_epp_av_policy_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_epp_av_policy_ou OWNER TO cbcc;

--
-- Name: global_epp_dc_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_epp_dc_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_epp_dc_policy OWNER TO cbcc;

--
-- Name: global_epp_dc_policy_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_epp_dc_policy_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_epp_dc_policy_ou OWNER TO cbcc;

--
-- Name: global_http_cff_action; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_cff_action (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_cff_action OWNER TO cbcc;

--
-- Name: global_http_cff_action_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_cff_action_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_cff_action_ou OWNER TO cbcc;

--
-- Name: global_http_exception; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_exception (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_exception OWNER TO cbcc;

--
-- Name: global_http_exception_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_exception_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_exception_ou OWNER TO cbcc;

--
-- Name: global_http_pac_file; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_pac_file (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_pac_file OWNER TO cbcc;

--
-- Name: global_http_pac_file_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_pac_file_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_pac_file_ou OWNER TO cbcc;

--
-- Name: global_http_sp_category; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_sp_category (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_sp_category OWNER TO cbcc;

--
-- Name: global_http_sp_category_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_http_sp_category_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_http_sp_category_ou OWNER TO cbcc;

--
-- Name: global_importable_objects; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_importable_objects (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_importable_objects OWNER TO cbcc;

--
-- Name: global_ipsec_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_ipsec_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_ipsec_policy OWNER TO cbcc;

--
-- Name: global_ipsec_policy_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_ipsec_policy_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_ipsec_policy_ou OWNER TO cbcc;

--
-- Name: global_network_availability_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_availability_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_availability_group OWNER TO cbcc;

--
-- Name: global_network_availability_group_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_availability_group_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_availability_group_ou OWNER TO cbcc;

--
-- Name: global_network_dns_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_dns_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_dns_group OWNER TO cbcc;

--
-- Name: global_network_dns_group_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_dns_group_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_dns_group_ou OWNER TO cbcc;

--
-- Name: global_network_dns_host; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_dns_host (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_dns_host OWNER TO cbcc;

--
-- Name: global_network_dns_host_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_dns_host_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_dns_host_ou OWNER TO cbcc;

--
-- Name: global_network_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_group OWNER TO cbcc;

--
-- Name: global_network_group_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_group_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_group_ou OWNER TO cbcc;

--
-- Name: global_network_host; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_host (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_host OWNER TO cbcc;

--
-- Name: global_network_host_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_host_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_host_ou OWNER TO cbcc;

--
-- Name: global_network_multicast; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_multicast (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_multicast OWNER TO cbcc;

--
-- Name: global_network_multicast_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_multicast_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_multicast_ou OWNER TO cbcc;

--
-- Name: global_network_network; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_network (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_network OWNER TO cbcc;

--
-- Name: global_network_switch; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_switch (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_switch OWNER TO cbcc;

--
-- Name: global_network_network_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_network_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_network_ou OWNER TO cbcc;

--
-- Name: global_network_switch_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_network_switch_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_network_switch_ou OWNER TO cbcc;

--
-- Name: global_object_epp_av_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_epp_av_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_epp_av_policy OWNER TO cbcc;

--
-- Name: global_object_epp_dc_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_epp_dc_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_epp_dc_policy OWNER TO cbcc;

--
-- Name: global_object_http_cff_action; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_http_cff_action (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_http_cff_action OWNER TO cbcc;

--
-- Name: global_object_http_exception; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_http_exception (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_http_exception OWNER TO cbcc;

--
-- Name: global_object_http_pac_file; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_http_pac_file (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_http_pac_file OWNER TO cbcc;

--
-- Name: global_object_http_sp_category; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_http_sp_category (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_http_sp_category OWNER TO cbcc;

--
-- Name: global_object_ipsec_policy; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_ipsec_policy (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_ipsec_policy OWNER TO cbcc;

--
-- Name: global_object_network_availability_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_availability_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_availability_group OWNER TO cbcc;

--
-- Name: global_object_network_dns_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_dns_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_dns_group OWNER TO cbcc;

--
-- Name: global_object_network_dns_host; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_dns_host (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_dns_host OWNER TO cbcc;

--
-- Name: global_object_network_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_group OWNER TO cbcc;

--
-- Name: global_object_network_host; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_host (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_host OWNER TO cbcc;

--
-- Name: global_object_network_multicast; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_multicast (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_multicast OWNER TO cbcc;

--
-- Name: global_object_network_network; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_network_network (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_network_network OWNER TO cbcc;

--
-- Name: global_object_packetfilter_packetfilter; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_packetfilter_packetfilter (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_packetfilter_packetfilter OWNER TO cbcc;

--
-- Name: global_object_packetfilter_ruleset; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_packetfilter_ruleset (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_packetfilter_ruleset OWNER TO cbcc;

--
-- Name: global_object_service_ah; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_ah (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_ah OWNER TO cbcc;

--
-- Name: global_object_service_esp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_esp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_esp OWNER TO cbcc;

--
-- Name: global_object_service_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_group OWNER TO cbcc;

--
-- Name: global_object_service_icmp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_icmp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_icmp OWNER TO cbcc;

--
-- Name: global_object_service_ip; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_ip (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_ip OWNER TO cbcc;

--
-- Name: global_object_service_tcp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_tcp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_tcp OWNER TO cbcc;

--
-- Name: global_object_service_tcpudp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_tcpudp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_tcpudp OWNER TO cbcc;

--
-- Name: global_object_service_udp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_service_udp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_service_udp OWNER TO cbcc;

--
-- Name: global_object_time_recurring; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_time_recurring (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_time_recurring OWNER TO cbcc;

--
-- Name: global_object_time_single; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_object_time_single (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_object_time_single OWNER TO cbcc;

--
-- Name: global_packetfilter_packetfilter; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_packetfilter_packetfilter (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_packetfilter_packetfilter OWNER TO cbcc;

--
-- Name: global_packetfilter_packetfilter_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_packetfilter_packetfilter_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_packetfilter_packetfilter_ou OWNER TO cbcc;

--
-- Name: global_packetfilter_ruleset; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_packetfilter_ruleset (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_packetfilter_ruleset OWNER TO cbcc;

--
-- Name: global_packetfilter_ruleset_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_packetfilter_ruleset_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_packetfilter_ruleset_ou OWNER TO cbcc;

--
-- Name: global_service_ah; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_ah (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_ah OWNER TO cbcc;

--
-- Name: global_service_ah_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_ah_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_ah_ou OWNER TO cbcc;

--
-- Name: global_service_esp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_esp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_esp OWNER TO cbcc;

--
-- Name: global_service_esp_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_esp_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_esp_ou OWNER TO cbcc;

--
-- Name: global_service_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_group (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_group OWNER TO cbcc;

--
-- Name: global_service_group_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_group_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_group_ou OWNER TO cbcc;

--
-- Name: global_service_icmp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_icmp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_icmp OWNER TO cbcc;

--
-- Name: global_service_icmp_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_icmp_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_icmp_ou OWNER TO cbcc;

--
-- Name: global_service_ip; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_ip (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_ip OWNER TO cbcc;

--
-- Name: global_service_ip_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_ip_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_ip_ou OWNER TO cbcc;

--
-- Name: global_service_tcp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_tcp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_tcp OWNER TO cbcc;

--
-- Name: global_service_tcp_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_tcp_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_tcp_ou OWNER TO cbcc;

--
-- Name: global_service_tcpudp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_tcpudp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_tcpudp OWNER TO cbcc;

--
-- Name: global_service_tcpudp_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_tcpudp_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_tcpudp_ou OWNER TO cbcc;

--
-- Name: global_service_udp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_udp (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_udp OWNER TO cbcc;

--
-- Name: global_service_udp_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_service_udp_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_service_udp_ou OWNER TO cbcc;

--
-- Name: global_time_recurring; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_time_recurring (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_time_recurring OWNER TO cbcc;

--
-- Name: global_time_recurring_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_time_recurring_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_time_recurring_ou OWNER TO cbcc;

--
-- Name: global_time_single; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_time_single (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_time_single OWNER TO cbcc;

--
-- Name: global_time_single_ou; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE global_time_single_ou (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.global_time_single_ou OWNER TO cbcc;

--
-- Name: log_objects; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE log_objects (
    log_data text,
    guid character varying(255) NOT NULL
);


ALTER TABLE public.log_objects OWNER TO cbcc;

--
-- Name: monitoring_availability; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_availability (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_availability OWNER TO cbcc;

--
-- Name: monitoring_dashboard; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_dashboard (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_dashboard OWNER TO cbcc;

--
-- Name: monitoring_hardware; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_hardware (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_hardware OWNER TO cbcc;

--
-- Name: monitoring_license; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_license (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_license OWNER TO cbcc;

--
-- Name: monitoring_network; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_network (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_network OWNER TO cbcc;

--
-- Name: monitoring_resource; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_resource (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_resource OWNER TO cbcc;

--
-- Name: monitoring_service; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_service (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_service OWNER TO cbcc;

--
-- Name: monitoring_threat; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_threat (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_threat OWNER TO cbcc;

--
-- Name: monitoring_version; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_version (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_version OWNER TO cbcc;

--
-- Name: monitoring_vpn; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE monitoring_vpn (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.monitoring_vpn OWNER TO cbcc;

--
-- Name: msp_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE msp_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.msp_info OWNER TO cbcc;

--
-- Name: msp_log; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE msp_log (
    dev_guid character varying(255) NOT NULL,
    action character varying(255) NOT NULL,
    initiated timestamp(0) without time zone NOT NULL,
    status character varying(255) NOT NULL,
    changed timestamp(0) without time zone NOT NULL,
    message text,
    subscriptions text
);


ALTER TABLE public.msp_log OWNER TO cbcc;

--
-- Name: msp_settings; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE msp_settings (
    property character varying(255) NOT NULL,
    value character varying(255) NOT NULL
);


ALTER TABLE public.msp_settings OWNER TO cbcc;

--
-- Name: odr_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.odr_info OWNER TO cbcc;

--
-- Name: odr_ips_events; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_ips_events (
    id character varying(255),
    device character varying(255),
    packets bigint
);


ALTER TABLE public.odr_ips_events OWNER TO cbcc;

--
-- Name: odr_mailcount; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount OWNER TO cbcc;

--
-- Name: odr_mailcount_by_pop3; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_pop3 (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_pop3 OWNER TO cbcc;

--
-- Name: odr_mailcount_by_pop3_blocked; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_pop3_blocked (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_pop3_blocked OWNER TO cbcc;

--
-- Name: odr_mailcount_by_pop3_delivered; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_pop3_delivered (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_pop3_delivered OWNER TO cbcc;

--
-- Name: odr_mailcount_by_smtp; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_smtp (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_smtp OWNER TO cbcc;

--
-- Name: odr_mailcount_by_smtp_blocked; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_smtp_blocked (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_smtp_blocked OWNER TO cbcc;

--
-- Name: odr_mailcount_by_smtp_delivered; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_smtp_delivered (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_smtp_delivered OWNER TO cbcc;

--
-- Name: odr_mailcount_by_spam; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_spam (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_spam OWNER TO cbcc;

--
-- Name: odr_mailcount_by_virus; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailcount_by_virus (
    id character varying(255),
    device character varying(255),
    count bigint
);


ALTER TABLE public.odr_mailcount_by_virus OWNER TO cbcc;

--
-- Name: odr_mailsec_top_domains; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_mailsec_top_domains (
    id character varying(255),
    device character varying(255),
    domain text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_mailsec_top_domains OWNER TO cbcc;

--
-- Name: odr_packetfilter_events; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_packetfilter_events (
    id character varying(255),
    device character varying(255),
    packets bigint
);


ALTER TABLE public.odr_packetfilter_events OWNER TO cbcc;

--
-- Name: odr_top_addresses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_addresses (
    id character varying(255),
    device character varying(255),
    address text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_addresses OWNER TO cbcc;

--
-- Name: odr_top_applications; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_applications (
    id character varying(255),
    device character varying(255),
    application text,
    appgroup text,
    afc_proto text,
    traffic_in bigint,
    traffic_out bigint,
    traffic_total bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_applications OWNER TO cbcc;

--
-- Name: odr_top_applications_by_client; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_applications_by_client (
    id character varying(255),
    device character varying(255),
    application text,
    appgroup text,
    afc_proto text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_applications_by_client OWNER TO cbcc;

--
-- Name: odr_top_applications_by_server; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_applications_by_server (
    id character varying(255),
    device character varying(255),
    application text,
    appgroup text,
    afc_proto text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_applications_by_server OWNER TO cbcc;

--
-- Name: odr_top_blocked_addresses; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_addresses (
    id character varying(255),
    device character varying(255),
    address text,
    srcdomain text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_addresses OWNER TO cbcc;

--
-- Name: odr_top_blocked_addresses_by_domain; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_addresses_by_domain (
    id character varying(255),
    device character varying(255),
    address text,
    srcdomain text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_addresses_by_domain OWNER TO cbcc;

--
-- Name: odr_top_blocked_domains; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_domains (
    id character varying(255),
    device character varying(255),
    domain text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_domains OWNER TO cbcc;

--
-- Name: odr_top_blocked_expressions; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_expressions (
    id character varying(255),
    device character varying(255),
    expression text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_expressions OWNER TO cbcc;

--
-- Name: odr_top_blocked_extensions; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_extensions (
    id character varying(255),
    device character varying(255),
    extension text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_extensions OWNER TO cbcc;

--
-- Name: odr_top_blocked_malware; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_malware (
    id character varying(255),
    device character varying(255),
    malware text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_malware OWNER TO cbcc;

--
-- Name: odr_top_blocked_mime_types; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_mime_types (
    id character varying(255),
    device character varying(255),
    mimetype text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_mime_types OWNER TO cbcc;

--
-- Name: odr_top_blocked_spam; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_spam (
    id character varying(255),
    device character varying(255),
    reason text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_spam OWNER TO cbcc;

--
-- Name: odr_top_blocked_spam_countries; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_spam_countries (
    id character varying(255),
    device character varying(255),
    country text,
    country_name text,
    count bigint,
    size bigint,
    cnt_sender bigint,
    cnt_destinations bigint
);


ALTER TABLE public.odr_top_blocked_spam_countries OWNER TO cbcc;

--
-- Name: odr_top_blocked_unscannable; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_blocked_unscannable (
    id character varying(255),
    device character varying(255),
    unscannable text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_blocked_unscannable OWNER TO cbcc;

--
-- Name: odr_top_clients; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_clients (
    id character varying(255),
    device character varying(255),
    srccountry text,
    srcip text,
    srchost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_clients OWNER TO cbcc;

--
-- Name: odr_top_clients_by_application; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_clients_by_application (
    id character varying(255),
    device character varying(255),
    srccountry text,
    srcip text,
    srchost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_clients_by_application OWNER TO cbcc;

--
-- Name: odr_top_clients_by_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_clients_by_group (
    id character varying(255),
    device character varying(255),
    srccountry text,
    srcip text,
    srchost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_clients_by_group OWNER TO cbcc;

--
-- Name: odr_top_clients_by_service; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_clients_by_service (
    id character varying(255),
    device character varying(255),
    srccountry text,
    srcip text,
    srchost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_clients_by_service OWNER TO cbcc;

--
-- Name: odr_top_domains; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_domains (
    id character varying(255),
    device character varying(255),
    domain text,
    requests bigint,
    duration interval,
    traffic bigint
);


ALTER TABLE public.odr_top_domains OWNER TO cbcc;

--
-- Name: odr_top_domains_by_user; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_domains_by_user (
    id character varying(255),
    device character varying(255),
    serverdomain text,
    requests bigint,
    duration interval,
    traffic bigint
);


ALTER TABLE public.odr_top_domains_by_user OWNER TO cbcc;

--
-- Name: odr_top_groups; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_groups (
    id character varying(255),
    device character varying(255),
    appgroup text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_groups OWNER TO cbcc;

--
-- Name: odr_top_groups_by_client; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_groups_by_client (
    id character varying(255),
    device character varying(255),
    appgroup text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_groups_by_client OWNER TO cbcc;

--
-- Name: odr_top_groups_by_server; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_groups_by_server (
    id character varying(255),
    device character varying(255),
    appgroup text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_groups_by_server OWNER TO cbcc;

--
-- Name: odr_top_im_events_by_protocol; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_im_events_by_protocol (
    id character varying(255),
    device character varying(255),
    protocol text,
    packets bigint,
    cnt_dstip bigint,
    cnt_srcip bigint,
    cnt_protocols bigint
);


ALTER TABLE public.odr_top_im_events_by_protocol OWNER TO cbcc;

--
-- Name: odr_top_im_events_dst_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_im_events_dst_by_src (
    id character varying(255),
    device character varying(255),
    dstip text,
    dstcountry text,
    packets bigint,
    cnt_protocols bigint,
    cnt_dstip bigint
);


ALTER TABLE public.odr_top_im_events_dst_by_src OWNER TO cbcc;

--
-- Name: odr_top_im_events_protocol_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_im_events_protocol_by_src (
    id character varying(255),
    device character varying(255),
    protocol text,
    packets bigint,
    cnt_dstip bigint,
    cnt_srcip bigint,
    cnt_protocols bigint
);


ALTER TABLE public.odr_top_im_events_protocol_by_src OWNER TO cbcc;

--
-- Name: odr_top_ips_events; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events (
    id character varying(255),
    device character varying(255),
    srcip text,
    srccountry text,
    dstip text,
    dstcountry text,
    ruleid text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint
);


ALTER TABLE public.odr_top_ips_events OWNER TO cbcc;

--
-- Name: odr_top_ips_events_by_destination; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_by_destination (
    id character varying(255),
    device character varying(255),
    dstip text,
    dstcountry text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_srcip bigint,
    cnt_rules bigint
);


ALTER TABLE public.odr_top_ips_events_by_destination OWNER TO cbcc;

--
-- Name: odr_top_ips_events_by_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_by_group (
    id character varying(255),
    device character varying(255),
    groupid text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_srcip bigint,
    cnt_dstip bigint
);


ALTER TABLE public.odr_top_ips_events_by_group OWNER TO cbcc;

--
-- Name: odr_top_ips_events_by_source; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_by_source (
    id character varying(255),
    device character varying(255),
    srcip text,
    srccountry text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_dstip bigint,
    cnt_rules bigint
);


ALTER TABLE public.odr_top_ips_events_by_source OWNER TO cbcc;

--
-- Name: odr_top_ips_events_dst_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_dst_by_src (
    id character varying(255),
    device character varying(255),
    dstip text,
    dstcountry text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_srcip bigint,
    cnt_rules bigint
);


ALTER TABLE public.odr_top_ips_events_dst_by_src OWNER TO cbcc;

--
-- Name: odr_top_ips_events_rules_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_rules_by_src (
    id character varying(255),
    device character varying(255),
    ruleid text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_srcip bigint,
    cnt_dstip bigint
);


ALTER TABLE public.odr_top_ips_events_rules_by_src OWNER TO cbcc;

--
-- Name: odr_top_ips_events_src_by_dst; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_ips_events_src_by_dst (
    id character varying(255),
    device character varying(255),
    srcip text,
    srccountry text,
    alertpackets bigint,
    droppackets bigint,
    packets bigint,
    cnt_dstip bigint,
    cnt_rules bigint
);


ALTER TABLE public.odr_top_ips_events_src_by_dst OWNER TO cbcc;

--
-- Name: odr_top_p2p_events_by_destination; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_p2p_events_by_destination (
    id character varying(255),
    device character varying(255),
    dstip text,
    dstcountry text,
    packets bigint,
    cnt_protocols bigint,
    cnt_dstip bigint
);


ALTER TABLE public.odr_top_p2p_events_by_destination OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events (
    id character varying(255),
    device character varying(255),
    srcip text,
    srchost text,
    srccountry text,
    dstip text,
    dsthost text,
    dstcountry text,
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_by_destination; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_by_destination (
    id character varying(255),
    device character varying(255),
    dstip text,
    dsthost text,
    dstcountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_by_destination OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_by_service; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_by_service (
    id character varying(255),
    device character varying(255),
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events_by_service OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_by_service_by_destination; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_by_service_by_destination (
    id character varying(255),
    device character varying(255),
    service text,
    packets bigint,
    dstip text,
    dsthost text,
    dstcountry text,
    cnt_dstip bigint
);


ALTER TABLE public.odr_top_packetfilter_events_by_service_by_destination OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_by_source; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_by_source (
    id character varying(255),
    device character varying(255),
    srcip text,
    srchost text,
    srccountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_by_source OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_dst_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_dst_by_src (
    id character varying(255),
    device character varying(255),
    dstip text,
    dsthost text,
    dstcountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_dst_by_src OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_dst_by_svc; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_dst_by_svc (
    id character varying(255),
    device character varying(255),
    dstip text,
    dsthost text,
    dstcountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_dst_by_svc OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_src_by_dst; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_src_by_dst (
    id character varying(255),
    device character varying(255),
    srcip text,
    srchost text,
    srccountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_src_by_dst OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_src_by_svc; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_src_by_svc (
    id character varying(255),
    device character varying(255),
    srcip text,
    srchost text,
    srccountry text,
    packets bigint,
    cnt_services bigint
);


ALTER TABLE public.odr_top_packetfilter_events_src_by_svc OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_svc_by_dst; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_svc_by_dst (
    id character varying(255),
    device character varying(255),
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events_svc_by_dst OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_svc_by_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_svc_by_src (
    id character varying(255),
    device character varying(255),
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events_svc_by_src OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_svc_dst; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_svc_dst (
    id character varying(255),
    device character varying(255),
    dstip text,
    dsthost text,
    dstcountry text,
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events_svc_dst OWNER TO cbcc;

--
-- Name: odr_top_packetfilter_events_svc_src; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_packetfilter_events_svc_src (
    id character varying(255),
    device character varying(255),
    srcip text,
    srchost text,
    srccountry text,
    service text,
    packets bigint
);


ALTER TABLE public.odr_top_packetfilter_events_svc_src OWNER TO cbcc;

--
-- Name: odr_top_recipients; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_recipients (
    id character varying(255),
    device character varying(255),
    recipient text,
    count bigint,
    size bigint,
    cnt_sender bigint
);


ALTER TABLE public.odr_top_recipients OWNER TO cbcc;

--
-- Name: odr_top_senders; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_senders (
    id character varying(255),
    device character varying(255),
    sender text,
    count bigint,
    size bigint,
    cnt_recipient bigint
);


ALTER TABLE public.odr_top_senders OWNER TO cbcc;

--
-- Name: odr_top_servers; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_servers (
    id character varying(255),
    device character varying(255),
    dstcountry text,
    dstip text,
    dsthost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_servers OWNER TO cbcc;

--
-- Name: odr_top_servers_by_application; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_servers_by_application (
    id character varying(255),
    device character varying(255),
    dstcountry text,
    dstip text,
    dsthost text,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_servers_by_application OWNER TO cbcc;

--
-- Name: odr_top_servers_by_group; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_servers_by_group (
    id character varying(255),
    device character varying(255),
    dstcountry text,
    dstip text,
    dsthost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_servers_by_group OWNER TO cbcc;

--
-- Name: odr_top_servers_by_service; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_servers_by_service (
    id character varying(255),
    device character varying(255),
    dstcountry text,
    dstip text,
    dsthost text,
    flows bigint,
    traffic bigint,
    pktcount bigint
);


ALTER TABLE public.odr_top_servers_by_service OWNER TO cbcc;

--
-- Name: odr_top_services; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_services (
    id character varying(255),
    device character varying(255),
    service text,
    protocol text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint,
    port text
);


ALTER TABLE public.odr_top_services OWNER TO cbcc;

--
-- Name: odr_top_services_by_client; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_services_by_client (
    id character varying(255),
    device character varying(255),
    service text,
    protocol text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint,
    port text
);


ALTER TABLE public.odr_top_services_by_client OWNER TO cbcc;

--
-- Name: odr_top_services_by_server; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_services_by_server (
    id character varying(255),
    device character varying(255),
    service text,
    protocol text,
    traffic_in bigint,
    traffic_out bigint,
    traffic bigint,
    flows bigint,
    pktcount bigint,
    port text
);


ALTER TABLE public.odr_top_services_by_server OWNER TO cbcc;

--
-- Name: odr_top_spam_countries; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_spam_countries (
    id character varying(255),
    device character varying(255),
    country text,
    country_name text,
    count bigint,
    size bigint,
    cnt_sender bigint,
    cnt_destinations bigint,
    cnt_country bigint
);


ALTER TABLE public.odr_top_spam_countries OWNER TO cbcc;

--
-- Name: odr_top_spam_senders; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_spam_senders (
    id character varying(255),
    device character varying(255),
    srcip text,
    country text,
    country_name text,
    count bigint,
    size bigint,
    cnt_sender bigint,
    cnt_destinations bigint,
    cnt_srcip bigint
);


ALTER TABLE public.odr_top_spam_senders OWNER TO cbcc;

--
-- Name: odr_top_users; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_users (
    id character varying(255),
    device character varying(255),
    username text,
    requests bigint,
    duration interval,
    traffic bigint
);


ALTER TABLE public.odr_top_users OWNER TO cbcc;

--
-- Name: odr_top_users_by_domain; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_users_by_domain (
    id character varying(255),
    device character varying(255),
    username text,
    requests bigint,
    duration interval,
    traffic bigint
);


ALTER TABLE public.odr_top_users_by_domain OWNER TO cbcc;

--
-- Name: odr_top_virus_names; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE odr_top_virus_names (
    id character varying(255),
    device character varying(255),
    virus text,
    count bigint,
    size bigint
);


ALTER TABLE public.odr_top_virus_names OWNER TO cbcc;

--
-- Name: ou_default; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE ou_default (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.ou_default OWNER TO cbcc;

--
-- Name: ou_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE ou_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.ou_info OWNER TO cbcc;

--
-- Name: reporting_hardware; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE reporting_hardware (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.reporting_hardware OWNER TO cbcc;

--
-- Name: reporting_network; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE reporting_network (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.reporting_network OWNER TO cbcc;

--
-- Name: reporting_security; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE reporting_security (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.reporting_security OWNER TO cbcc;

--
-- Name: script_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE script_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.script_info OWNER TO cbcc;

--
-- Name: user_acl; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE user_acl (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.user_acl OWNER TO cbcc;

--
-- Name: user_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE user_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.user_info OWNER TO cbcc;

--
-- Name: version; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE version (
    version integer
);


ALTER TABLE public.version OWNER TO cbcc;

--
-- Name: vpn_info; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE vpn_info (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.vpn_info OWNER TO cbcc;

--
-- Name: vpn_monitoring; Type: TABLE; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE TABLE vpn_monitoring (
    guid character varying(255) DEFAULT ''::character varying NOT NULL,
    data text
);


ALTER TABLE public.vpn_monitoring OWNER TO cbcc;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_category_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_category_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_country_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_country_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_domain_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_domain_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_email_addresses ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_email_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_expression_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_expression_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_extension_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_extension_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_ip_addresses ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_ip_addresses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_ips_groups ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_ips_groups_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_ips_msgs ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_ips_msgs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_protocol_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_protocol_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_service_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_service_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_user_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_user_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_lookup_virus_names ALTER COLUMN id SET DEFAULT nextval('aggregated_lookup_virus_names_id_seq'::regclass);


--
-- Data for Name: action_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY action_info (guid, data) FROM stdin;
\.


--
-- Data for Name: agent_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY agent_info (guid, data) FROM stdin;
\.


--
-- Data for Name: aggregated_accounting_destinations; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_accounting_destinations (guid, day, country_id, ipaddr_id, traffic, flow_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_accounting_overview; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_accounting_overview (guid, day, complete, traffic, flow_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_accounting_services; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_accounting_services (guid, day, service_id, protocol_id, port, traffic_rx, traffic_tx, flow_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_accounting_sources; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_accounting_sources (guid, day, country_id, ipaddr_id, traffic, flow_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_blocked_expressions; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_blocked_expressions (guid, day, blocked_id, traffic, emails) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_blocked_extensions; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_blocked_extensions (guid, day, blocked_id, traffic, emails) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_blocked_viruses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_blocked_viruses (guid, day, blocked_id, traffic, emails) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_email_recipients; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_email_recipients (guid, day, email_id, traffic, emails, sender_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_email_senders; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_email_senders (guid, day, email_id, traffic, emails, recipient_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_overview; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_overview (guid, day, complete, traffic, emails, sender_cnt, recipient_cnt, spam_sender_cnt, spam_country_cnt, virus_cnt, expression_cnt, extension_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_spam_countries; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_spam_countries (guid, day, country_id, traffic, emails, sender_cnt, recipient_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_emailsec_spam_senders; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_emailsec_spam_senders (guid, day, country_id, ipaddr_id, traffic, emails, sender_cnt, recipient_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_lookup_category_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_category_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_category_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_category_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_country_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_country_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_country_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_country_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_domain_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_domain_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_domain_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_domain_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_email_addresses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_email_addresses (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_email_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_email_addresses_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_expression_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_expression_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_expression_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_expression_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_extension_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_extension_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_extension_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_extension_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_ip_addresses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_ip_addresses (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_ip_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_ip_addresses_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_ips_groups; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_ips_groups (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_ips_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_ips_groups_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_ips_msgs; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_ips_msgs (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_ips_msgs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_ips_msgs_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_protocol_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_protocol_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_protocol_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_protocol_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_service_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_service_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_service_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_service_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_user_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_user_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_user_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_user_names_id_seq', 1, false);


--
-- Data for Name: aggregated_lookup_virus_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_lookup_virus_names (id, name) FROM stdin;
\.


--
-- Name: aggregated_lookup_virus_names_id_seq; Type: SEQUENCE SET; Schema: public; Owner: cbcc
--

SELECT pg_catalog.setval('aggregated_lookup_virus_names_id_seq', 1, false);


--
-- Data for Name: aggregated_netsec_fw_destinations; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_fw_destinations (guid, day, country_id, ipaddr_id, service_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_fw_services; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_fw_services (guid, day, service_id, protocol_id, port, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_fw_sources; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_fw_sources (guid, day, country_id, ipaddr_id, service_cnt, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_fw_targets; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_fw_targets (guid, day, country_id, ipaddr_id, service_id, protocol_id, port, packet_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_ips_attacks; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_ips_attacks (guid, day, rule_id, group_id, msg_id, alert_cnt, drop_cnt, src_cnt, dst_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_ips_destinations; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_ips_destinations (guid, day, country_id, ipaddr_id, alert_cnt, drop_cnt, src_cnt, rule_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_ips_sources; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_ips_sources (guid, day, country_id, ipaddr_id, alert_cnt, drop_cnt, dst_cnt, rule_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_netsec_overview; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_netsec_overview (guid, day, complete, fw_events, ips_events) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_categories; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_categories (guid, day, blocked_id, subtype, requests, domain_cnt, user_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_domains; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_domains (guid, day, domain_id, traffic, requests, duration) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_extensions; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_extensions (guid, day, blocked_id, requests, user_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_overview; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_overview (guid, day, complete, traffic, requests, user_dur, user_cnt, domain_dur, domain_cnt, category_cnt, extension_cnt, spyware_cnt, virus_cnt) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_users; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_users (guid, day, user_id, traffic, requests, duration) FROM stdin;
\.


--
-- Data for Name: aggregated_websec_viruses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY aggregated_websec_viruses (guid, day, blocked_id, requests, domain_cnt, user_cnt) FROM stdin;
\.


--
-- Data for Name: auto_backup_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY auto_backup_info (guid, data) FROM stdin;
1	{"ba_interval":"monthly","ba_max":5,"enqueued_starttime":1471370400,"next_starttime":1474048800,"status":0}
\.


--
-- Data for Name: confd_data; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY confd_data (guid, data) FROM stdin;
1	{"cbccd":{"access":{"allowed_admins":["REF_DefaultSuperAdmin"],"allowed_networks":["REF_NetworkAny"],"allowed_users":[],"cert":"REF_CaHosAccDaemoCerti","port":4411},"devices":{"allowed_networks":["REF_NetworkAny"],"auth":{"auto":1,"secret":"","status":0},"cert":"REF_CaHosAccDaemoCerti","port":4433},"general":{"allowed_networks":["REF_NetworkAny"],"cert":"REF_CaHosWebadCertiFor","language":"english","port":4422,"timeout":600}},"internal":{"facility":"","host":"127.0.0.1","password":"","port":"4472","username":"system","version":-1},"objs":{},"settings":{"admin_email":"admin@infosec.com","basic_setup":1,"cc_mode":0,"city":"PyongYang","country":"kp","hostname":"MyACC","icsa_mode":0,"organization":"Infosec","password_complexity":{"min_digits":1,"min_length":8,"min_lower_chars":1,"min_special_chars":1,"min_upper_chars":1,"status":0},"popularity":"","ras_update":"default","system_id":"f017b0cb-7adf-3bbb-8636-1545d8da6aa5","timezone":"Asia/Pyongyang"},"u2dcache":{"allowed_networks":[],"port":8080,"status":0}}
\.


--
-- Data for Name: config_common; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_common (guid, data) FROM stdin;
\.


--
-- Data for Name: config_device; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_device (guid, data) FROM stdin;
1	{"aggregated":{"history":180,"interval":10800,"top":50},"connection":{"socket":"0.0.0.0:4433","ssl":{"cert":"/etc/cm/ssl/device_cert.pem","key":"/etc/cm/ssl/device_key.pem"}},"keepalive":{"interval":30,"probes":3},"reporting":{"intervals":{"daily":900,"monthly":43200,"weekly":14400,"yearly":86400},"scatter":{"max":900,"min":0}}}
\.


--
-- Data for Name: config_diagnostic; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_diagnostic (guid, data) FROM stdin;
1	{"dump_type":"perlhash|json|log","interval_dump":30,"output_prefix":"/var/diag/cbccd","run_action":true}
\.


--
-- Data for Name: config_object_ca_rsa; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_ca_rsa (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_http_default_action; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_http_default_action (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_http_pac_file; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_http_pac_file (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_ipsec_site2site; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_ipsec_site2site (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_network_interface; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_network_interface (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_packetfilter_rules_back; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_packetfilter_rules_back (guid, data) FROM stdin;
\.


--
-- Data for Name: config_object_packetfilter_rules_front; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_object_packetfilter_rules_front (guid, data) FROM stdin;
\.


--
-- Data for Name: config_user; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY config_user (guid, data) FROM stdin;
1	{"connection":{"cert":"/etc/cm/ssl/user_cert.pem","key":"/etc/cm/ssl/user_key.pem","socket":"0.0.0.0:4411"}}
\.


--
-- Data for Name: device_backup; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_backup (guid, data) FROM stdin;
\.


--
-- Data for Name: device_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_info (guid, data) FROM stdin;
\.


--
-- Data for Name: device_inventory; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_inventory (guid, data) FROM stdin;
\.


--
-- Data for Name: device_location; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_location (guid, data) FROM stdin;
\.


--
-- Data for Name: device_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: device_product; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY device_product (guid, data) FROM stdin;
\.


--
-- Data for Name: event_log; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY event_log (event_id, msg, dev_guid, "timestamp") FROM stdin;
\.


--
-- Data for Name: event_log_settings; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY event_log_settings (id, expired_after) FROM stdin;
1	30
\.


--
-- Data for Name: global_epp_av_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_epp_av_policy (guid, data) FROM stdin;
\.


--
-- Data for Name: global_epp_av_policy_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_epp_av_policy_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_epp_dc_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_epp_dc_policy (guid, data) FROM stdin;
\.


--
-- Data for Name: global_epp_dc_policy_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_epp_dc_policy_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_http_cff_action; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_cff_action (guid, data) FROM stdin;
REF_ACC_GBL_810bd1b172134e3a82ce25daef6c01ed01ed	{"av":true,"av_engines":"double","comment":"test-webfilter1","contenttype_blacklist":["application/zip"],"embedded_removal":false,"extensions":["com"],"log_access":true,"log_blocked":true,"max_filesize":50,"mode":"allow","name":"test-webfilter1","script_removal":false,"sp_categories":[],"sp_minreputation":"off","spyware":false,"uncategorized":false,"url_list":["www.google.com"],"url_list_override":["www.amazon.com"]}
\.


--
-- Data for Name: global_http_cff_action_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_cff_action_ou (guid, data) FROM stdin;
REF_ACC_GBL_810bd1b172134e3a82ce25daef6c01ed01ed	{"ou":"RootOrganizationalUnit"}
\.


--
-- Data for Name: global_http_exception; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_exception (guid, data) FROM stdin;
REF_ACC_GBL_3d5e132098a2481084eb5e5584b59dfe9dfe	{"aaa":[],"comment":"test-exception1","domains":[],"mode":"add","name":"test-exception1","networks":["REF_ACC_GBL_ae399484f6974c969112e95b4157ceb0ceb0"],"operator":"OR","skiplist":["extensions","contenttype_blacklist","url_filter","ssl_scanning","log_blocked"],"sp_categories":[],"status":false}
\.


--
-- Data for Name: global_http_exception_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_exception_ou (guid, data) FROM stdin;
REF_ACC_GBL_3d5e132098a2481084eb5e5584b59dfe9dfe	{"ou":"RootOrganizationalUnit"}
\.


--
-- Data for Name: global_http_pac_file; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_pac_file (guid, data) FROM stdin;
\.


--
-- Data for Name: global_http_pac_file_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_pac_file_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_http_sp_category; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_sp_category (guid, data) FROM stdin;
\.


--
-- Data for Name: global_http_sp_category_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_http_sp_category_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_importable_objects; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_importable_objects (guid, data) FROM stdin;
\.


--
-- Data for Name: global_ipsec_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_ipsec_policy (guid, data) FROM stdin;
REF_ACC_GBL_IPSecPolicy3DES	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"3des","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"3des","ipsec_pfs_group":"null","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"TripleDES (ACC)"}
REF_ACC_GBL_IPSecPolicy3DESPFS	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"3des","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"3des","ipsec_pfs_group":"modp1536","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"TripleDES PFS (ACC)"}
REF_ACC_GBL_IPSecPolicyAES128	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"aes256","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"aes128","ipsec_pfs_group":"null","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"AES-128 (ACC)"}
REF_ACC_GBL_IPSecPolicyAES128PFS	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"aes256","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"aes128","ipsec_pfs_group":"modp1536","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"AES-128 PFS (ACC)"}
REF_ACC_GBL_IPSecPolicyAES256	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"aes256","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"aes256","ipsec_pfs_group":"null","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"AES-256 (ACC)"}
REF_ACC_GBL_IPSecPolicyAES256PFS	{"comment":"(auto-generated by ACC)","ike_auth_alg":"md5","ike_dh_group":"modp1536","ike_enc_alg":"aes256","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"aes256","ipsec_pfs_group":"modp1536","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"AES-256 PFS (ACC)"}
REF_ACC_GBL_IPSecPolicyBorderManager	{"comment":"(auto-generated by ACC)","ike_auth_alg":"sha","ike_dh_group":"modp1024","ike_enc_alg":"3des","ike_sa_lifetime":14400,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"3des","ipsec_pfs_group":"modp1024","ipsec_sa_lifetime":3600,"ipsec_strict_policy":true,"name":"Novell BorderManager (ACC)"}
REF_ACC_GBL_IPSecPolicyWindows	{"comment":"(auto-generated by ACC)","ike_auth_alg":"sha","ike_dh_group":"modp2048","ike_enc_alg":"3des","ike_sa_lifetime":28800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"3des","ipsec_pfs_group":"null","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"Microsoft Windows (ACC)"}
REF_ACC_GBL_077984a4a2494f6d850fbbbfcd8bc30dc30d	{"comment":"test-ipsec1","ike_auth_alg":"md5","ike_dh_group":"modp768","ike_enc_alg":"aes128","ike_sa_lifetime":7800,"ipsec_auth_alg":"md5","ipsec_compression":false,"ipsec_enc_alg":"aes128","ipsec_pfs_group":"modp768","ipsec_sa_lifetime":3600,"ipsec_strict_policy":false,"name":"test-ipsec1","ou":"RootOrganizationalUnit"}
\.


--
-- Data for Name: global_ipsec_policy_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_ipsec_policy_ou (guid, data) FROM stdin;
REF_ACC_GBL_IPSecPolicy3DES	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicy3DESPFS	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyAES128	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyAES128PFS	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyAES256	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyAES256PFS	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyBorderManager	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_IPSecPolicyWindows	{"ou":"RootOrganizationalUnit"}
REF_ACC_GBL_077984a4a2494f6d850fbbbfcd8bc30dc30d	{"ou":"RootOrganizationalUnit"}
\.


--
-- Data for Name: global_network_availability_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_availability_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_availability_group_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_availability_group_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_dns_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_dns_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_dns_group_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_dns_group_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_dns_host; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_dns_host (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_dns_host_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_dns_host_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_group_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_group_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_host; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_host (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_host_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_host_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_multicast; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_multicast (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_multicast_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_multicast_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_network; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_network (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_switch; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_switch (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_network_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_network_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_network_switch_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_network_switch_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_epp_av_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_epp_av_policy (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_epp_dc_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_epp_dc_policy (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_http_cff_action; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_http_cff_action (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_http_exception; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_http_exception (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_http_pac_file; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_http_pac_file (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_http_sp_category; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_http_sp_category (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_ipsec_policy; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_ipsec_policy (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_availability_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_availability_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_dns_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_dns_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_dns_host; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_dns_host (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_host; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_host (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_multicast; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_multicast (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_network_network; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_network_network (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_packetfilter_packetfilter; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_packetfilter_packetfilter (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_packetfilter_ruleset; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_packetfilter_ruleset (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_ah; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_ah (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_esp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_esp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_icmp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_icmp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_ip; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_ip (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_tcp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_tcp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_tcpudp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_tcpudp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_service_udp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_service_udp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_time_recurring; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_time_recurring (guid, data) FROM stdin;
\.


--
-- Data for Name: global_object_time_single; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_object_time_single (guid, data) FROM stdin;
\.


--
-- Data for Name: global_packetfilter_packetfilter; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_packetfilter_packetfilter (guid, data) FROM stdin;
\.


--
-- Data for Name: global_packetfilter_packetfilter_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_packetfilter_packetfilter_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_packetfilter_ruleset; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_packetfilter_ruleset (guid, data) FROM stdin;
\.


--
-- Data for Name: global_packetfilter_ruleset_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_packetfilter_ruleset_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_ah; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_ah (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_ah_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_ah_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_esp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_esp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_esp_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_esp_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_group (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_group_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_group_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_icmp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_icmp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_icmp_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_icmp_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_ip; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_ip (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_ip_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_ip_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_tcp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_tcp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_tcp_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_tcp_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_tcpudp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_tcpudp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_tcpudp_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_tcpudp_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_udp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_udp (guid, data) FROM stdin;
\.


--
-- Data for Name: global_service_udp_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_service_udp_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_time_recurring; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_time_recurring (guid, data) FROM stdin;
\.


--
-- Data for Name: global_time_recurring_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_time_recurring_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: global_time_single; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_time_single (guid, data) FROM stdin;
\.


--
-- Data for Name: global_time_single_ou; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY global_time_single_ou (guid, data) FROM stdin;
\.


--
-- Data for Name: log_objects; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY log_objects (log_data, guid) FROM stdin;
\.


--
-- Data for Name: monitoring_availability; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_availability (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_dashboard; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_dashboard (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_hardware; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_hardware (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_license; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_license (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_network; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_network (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_resource; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_resource (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_service; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_service (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_threat; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_threat (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_version; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_version (guid, data) FROM stdin;
\.


--
-- Data for Name: monitoring_vpn; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY monitoring_vpn (guid, data) FROM stdin;
\.


--
-- Data for Name: msp_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY msp_info (guid, data) FROM stdin;
\.


--
-- Data for Name: msp_log; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY msp_log (dev_guid, action, initiated, status, changed, message, subscriptions) FROM stdin;
\.


--
-- Data for Name: msp_settings; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY msp_settings (property, value) FROM stdin;
enabled	false
csr_file	/etc/cm/ssl/myAstaro.csr
scheduler_next_start	
last_heartbeat	
ca_host	ws-csr.sophos.com
ca_port	443
ca_uri	/CertificateService.svc/GetCertificateUsingJson
host	ws-utm-msp.sophos.com
methods_without_ca	create_certificate
myastaro_cert_file	/etc/cm/ssl/myAstaro.crt
myastaro_csr_file	/etc/cm/ssl/myAstaro.csr
myastaro_key_file	/etc/cm/ssl/myAstaro.key
plaintext_authentication	true
port	443
sum_id_file	/etc/cm/ssl/system_id
timeout	60
uri	/MSPLicensingService.svc/ProcessMessage
use_ca	true
\.


--
-- Data for Name: odr_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_info (guid, data) FROM stdin;
\.


--
-- Data for Name: odr_ips_events; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_ips_events (id, device, packets) FROM stdin;
\.


--
-- Data for Name: odr_mailcount; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_pop3; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_pop3 (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_pop3_blocked; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_pop3_blocked (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_pop3_delivered; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_pop3_delivered (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_smtp; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_smtp (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_smtp_blocked; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_smtp_blocked (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_smtp_delivered; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_smtp_delivered (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_spam; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_spam (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailcount_by_virus; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailcount_by_virus (id, device, count) FROM stdin;
\.


--
-- Data for Name: odr_mailsec_top_domains; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_mailsec_top_domains (id, device, domain, count, size) FROM stdin;
\.


--
-- Data for Name: odr_packetfilter_events; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_packetfilter_events (id, device, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_addresses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_addresses (id, device, address, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_applications; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_applications (id, device, application, appgroup, afc_proto, traffic_in, traffic_out, traffic_total, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_applications_by_client; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_applications_by_client (id, device, application, appgroup, afc_proto, traffic_in, traffic_out, traffic, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_applications_by_server; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_applications_by_server (id, device, application, appgroup, afc_proto, traffic_in, traffic_out, traffic, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_addresses; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_addresses (id, device, address, srcdomain, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_addresses_by_domain; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_addresses_by_domain (id, device, address, srcdomain, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_domains; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_domains (id, device, domain, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_expressions; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_expressions (id, device, expression, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_extensions; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_extensions (id, device, extension, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_malware; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_malware (id, device, malware, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_mime_types; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_mime_types (id, device, mimetype, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_spam; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_spam (id, device, reason, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_spam_countries; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_spam_countries (id, device, country, country_name, count, size, cnt_sender, cnt_destinations) FROM stdin;
\.


--
-- Data for Name: odr_top_blocked_unscannable; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_blocked_unscannable (id, device, unscannable, count, size) FROM stdin;
\.


--
-- Data for Name: odr_top_clients; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_clients (id, device, srccountry, srcip, srchost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_clients_by_application; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_clients_by_application (id, device, srccountry, srcip, srchost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_clients_by_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_clients_by_group (id, device, srccountry, srcip, srchost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_clients_by_service; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_clients_by_service (id, device, srccountry, srcip, srchost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_domains; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_domains (id, device, domain, requests, duration, traffic) FROM stdin;
\.


--
-- Data for Name: odr_top_domains_by_user; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_domains_by_user (id, device, serverdomain, requests, duration, traffic) FROM stdin;
\.


--
-- Data for Name: odr_top_groups; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_groups (id, device, appgroup, traffic_in, traffic_out, traffic, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_groups_by_client; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_groups_by_client (id, device, appgroup, traffic_in, traffic_out, traffic, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_groups_by_server; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_groups_by_server (id, device, appgroup, traffic_in, traffic_out, traffic, flows, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_im_events_by_protocol; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_im_events_by_protocol (id, device, protocol, packets, cnt_dstip, cnt_srcip, cnt_protocols) FROM stdin;
\.


--
-- Data for Name: odr_top_im_events_dst_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_im_events_dst_by_src (id, device, dstip, dstcountry, packets, cnt_protocols, cnt_dstip) FROM stdin;
\.


--
-- Data for Name: odr_top_im_events_protocol_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_im_events_protocol_by_src (id, device, protocol, packets, cnt_dstip, cnt_srcip, cnt_protocols) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events (id, device, srcip, srccountry, dstip, dstcountry, ruleid, alertpackets, droppackets, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_by_destination; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_by_destination (id, device, dstip, dstcountry, alertpackets, droppackets, packets, cnt_srcip, cnt_rules) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_by_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_by_group (id, device, groupid, alertpackets, droppackets, packets, cnt_srcip, cnt_dstip) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_by_source; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_by_source (id, device, srcip, srccountry, alertpackets, droppackets, packets, cnt_dstip, cnt_rules) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_dst_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_dst_by_src (id, device, dstip, dstcountry, alertpackets, droppackets, packets, cnt_srcip, cnt_rules) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_rules_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_rules_by_src (id, device, ruleid, alertpackets, droppackets, packets, cnt_srcip, cnt_dstip) FROM stdin;
\.


--
-- Data for Name: odr_top_ips_events_src_by_dst; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_ips_events_src_by_dst (id, device, srcip, srccountry, alertpackets, droppackets, packets, cnt_dstip, cnt_rules) FROM stdin;
\.


--
-- Data for Name: odr_top_p2p_events_by_destination; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_p2p_events_by_destination (id, device, dstip, dstcountry, packets, cnt_protocols, cnt_dstip) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events (id, device, srcip, srchost, srccountry, dstip, dsthost, dstcountry, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_by_destination; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_by_destination (id, device, dstip, dsthost, dstcountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_by_service; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_by_service (id, device, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_by_service_by_destination; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_by_service_by_destination (id, device, service, packets, dstip, dsthost, dstcountry, cnt_dstip) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_by_source; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_by_source (id, device, srcip, srchost, srccountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_dst_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_dst_by_src (id, device, dstip, dsthost, dstcountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_dst_by_svc; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_dst_by_svc (id, device, dstip, dsthost, dstcountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_src_by_dst; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_src_by_dst (id, device, srcip, srchost, srccountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_src_by_svc; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_src_by_svc (id, device, srcip, srchost, srccountry, packets, cnt_services) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_svc_by_dst; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_svc_by_dst (id, device, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_svc_by_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_svc_by_src (id, device, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_svc_dst; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_svc_dst (id, device, dstip, dsthost, dstcountry, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_packetfilter_events_svc_src; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_packetfilter_events_svc_src (id, device, srcip, srchost, srccountry, service, packets) FROM stdin;
\.


--
-- Data for Name: odr_top_recipients; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_recipients (id, device, recipient, count, size, cnt_sender) FROM stdin;
\.


--
-- Data for Name: odr_top_senders; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_senders (id, device, sender, count, size, cnt_recipient) FROM stdin;
\.


--
-- Data for Name: odr_top_servers; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_servers (id, device, dstcountry, dstip, dsthost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_servers_by_application; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_servers_by_application (id, device, dstcountry, dstip, dsthost, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_servers_by_group; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_servers_by_group (id, device, dstcountry, dstip, dsthost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_servers_by_service; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_servers_by_service (id, device, dstcountry, dstip, dsthost, flows, traffic, pktcount) FROM stdin;
\.


--
-- Data for Name: odr_top_services; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_services (id, device, service, protocol, traffic_in, traffic_out, traffic, flows, pktcount, port) FROM stdin;
\.


--
-- Data for Name: odr_top_services_by_client; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_services_by_client (id, device, service, protocol, traffic_in, traffic_out, traffic, flows, pktcount, port) FROM stdin;
\.


--
-- Data for Name: odr_top_services_by_server; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_services_by_server (id, device, service, protocol, traffic_in, traffic_out, traffic, flows, pktcount, port) FROM stdin;
\.


--
-- Data for Name: odr_top_spam_countries; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_spam_countries (id, device, country, country_name, count, size, cnt_sender, cnt_destinations, cnt_country) FROM stdin;
\.


--
-- Data for Name: odr_top_spam_senders; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_spam_senders (id, device, srcip, country, country_name, count, size, cnt_sender, cnt_destinations, cnt_srcip) FROM stdin;
\.


--
-- Data for Name: odr_top_users; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_users (id, device, username, requests, duration, traffic) FROM stdin;
\.


--
-- Data for Name: odr_top_users_by_domain; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_users_by_domain (id, device, username, requests, duration, traffic) FROM stdin;
\.


--
-- Data for Name: odr_top_virus_names; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY odr_top_virus_names (id, device, virus, count, size) FROM stdin;
\.


--
-- Data for Name: ou_default; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY ou_default (guid, data) FROM stdin;
1	{"default":"RootOrganizationalUnit"}
\.


--
-- Data for Name: ou_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY ou_info (guid, data) FROM stdin;
RootOrganizationalUnit	{"autodeploy":false,"comment":"Shared OU","disabled_notifications":[],"info":"","name":"Global","notification_interval":30,"parent":"","recipients":[],"send_notifications":true}
\.


--
-- Data for Name: reporting_hardware; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY reporting_hardware (guid, data) FROM stdin;
\.


--
-- Data for Name: reporting_network; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY reporting_network (guid, data) FROM stdin;
\.


--
-- Data for Name: reporting_security; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY reporting_security (guid, data) FROM stdin;
\.


--
-- Data for Name: script_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY script_info (guid, data) FROM stdin;
\.


--
-- Data for Name: user_acl; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY user_acl (guid, data) FROM stdin;
REF_DefaultSuperAdmin	{"admin":true,"ou.roles":{"device.admin":{"ous":[]},"device.config":{"ous":[]},"device.manage":{"ous":[]},"device.monitor":{"ous":[]},"device.report":{"ous":[]},"user.admin":{"ous":[]}},"roles":{"device.admin":{"devices":[]},"device.config":{"devices":[]},"device.monitor":{"devices":[]},"user.admin":{"devices":[]}},"users":[]}
\.


--
-- Data for Name: user_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY user_info (guid, data) FROM stdin;
REF_DefaultSuperAdmin	{"name":"admin","type":"user"}
\.


--
-- Data for Name: version; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY version (version) FROM stdin;
13
\.


--
-- Data for Name: vpn_info; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY vpn_info (guid, data) FROM stdin;
\.


--
-- Data for Name: vpn_monitoring; Type: TABLE DATA; Schema: public; Owner: cbcc
--

COPY vpn_monitoring (guid, data) FROM stdin;
\.


--
-- Name: action_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY action_info
    ADD CONSTRAINT action_info_pkey PRIMARY KEY (guid);


--
-- Name: agent_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY agent_info
    ADD CONSTRAINT agent_info_pkey PRIMARY KEY (guid);


--
-- Name: aggregated_accounting_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_accounting_destinations
    ADD CONSTRAINT aggregated_accounting_destinations_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_accounting_overview_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_accounting_overview
    ADD CONSTRAINT aggregated_accounting_overview_pkey PRIMARY KEY (day, guid);


--
-- Name: aggregated_accounting_services_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_accounting_services
    ADD CONSTRAINT aggregated_accounting_services_pkey PRIMARY KEY (day, guid, service_id, protocol_id, port);


--
-- Name: aggregated_accounting_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_accounting_sources
    ADD CONSTRAINT aggregated_accounting_sources_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_emailsec_blocked_expressions_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_blocked_expressions
    ADD CONSTRAINT aggregated_emailsec_blocked_expressions_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: aggregated_emailsec_blocked_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_blocked_extensions
    ADD CONSTRAINT aggregated_emailsec_blocked_extensions_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: aggregated_emailsec_blocked_viruses_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_blocked_viruses
    ADD CONSTRAINT aggregated_emailsec_blocked_viruses_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: aggregated_emailsec_email_recipients_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_email_recipients
    ADD CONSTRAINT aggregated_emailsec_email_recipients_pkey PRIMARY KEY (day, guid, email_id);


--
-- Name: aggregated_emailsec_email_senders_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_email_senders
    ADD CONSTRAINT aggregated_emailsec_email_senders_pkey PRIMARY KEY (day, guid, email_id);


--
-- Name: aggregated_emailsec_overview_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_overview
    ADD CONSTRAINT aggregated_emailsec_overview_pkey PRIMARY KEY (day, guid);


--
-- Name: aggregated_emailsec_spam_countries_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_spam_countries
    ADD CONSTRAINT aggregated_emailsec_spam_countries_pkey PRIMARY KEY (day, guid, country_id);


--
-- Name: aggregated_emailsec_spam_senders_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_emailsec_spam_senders
    ADD CONSTRAINT aggregated_emailsec_spam_senders_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_lookup_category_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_category_names
    ADD CONSTRAINT aggregated_lookup_category_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_category_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_category_names
    ADD CONSTRAINT aggregated_lookup_category_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_country_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_country_names
    ADD CONSTRAINT aggregated_lookup_country_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_country_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_country_names
    ADD CONSTRAINT aggregated_lookup_country_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_domain_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_domain_names
    ADD CONSTRAINT aggregated_lookup_domain_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_domain_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_domain_names
    ADD CONSTRAINT aggregated_lookup_domain_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_email_addresses_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_email_addresses
    ADD CONSTRAINT aggregated_lookup_email_addresses_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_email_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_email_addresses
    ADD CONSTRAINT aggregated_lookup_email_addresses_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_expression_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_expression_names
    ADD CONSTRAINT aggregated_lookup_expression_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_expression_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_expression_names
    ADD CONSTRAINT aggregated_lookup_expression_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_extension_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_extension_names
    ADD CONSTRAINT aggregated_lookup_extension_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_extension_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_extension_names
    ADD CONSTRAINT aggregated_lookup_extension_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_ip_addresses_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ip_addresses
    ADD CONSTRAINT aggregated_lookup_ip_addresses_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_ip_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ip_addresses
    ADD CONSTRAINT aggregated_lookup_ip_addresses_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_ips_groups_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ips_groups
    ADD CONSTRAINT aggregated_lookup_ips_groups_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_ips_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ips_groups
    ADD CONSTRAINT aggregated_lookup_ips_groups_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_ips_msgs_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ips_msgs
    ADD CONSTRAINT aggregated_lookup_ips_msgs_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_ips_msgs_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_ips_msgs
    ADD CONSTRAINT aggregated_lookup_ips_msgs_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_protocol_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_protocol_names
    ADD CONSTRAINT aggregated_lookup_protocol_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_protocol_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_protocol_names
    ADD CONSTRAINT aggregated_lookup_protocol_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_service_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_service_names
    ADD CONSTRAINT aggregated_lookup_service_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_service_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_service_names
    ADD CONSTRAINT aggregated_lookup_service_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_user_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_user_names
    ADD CONSTRAINT aggregated_lookup_user_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_user_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_user_names
    ADD CONSTRAINT aggregated_lookup_user_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_lookup_virus_names_name_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_virus_names
    ADD CONSTRAINT aggregated_lookup_virus_names_name_key UNIQUE (name);


--
-- Name: aggregated_lookup_virus_names_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_lookup_virus_names
    ADD CONSTRAINT aggregated_lookup_virus_names_pkey PRIMARY KEY (id);


--
-- Name: aggregated_netsec_fw_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_fw_destinations
    ADD CONSTRAINT aggregated_netsec_fw_destinations_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_netsec_fw_services_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_fw_services
    ADD CONSTRAINT aggregated_netsec_fw_services_pkey PRIMARY KEY (day, guid, service_id, protocol_id, port);


--
-- Name: aggregated_netsec_fw_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_fw_sources
    ADD CONSTRAINT aggregated_netsec_fw_sources_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_netsec_fw_targets_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_fw_targets
    ADD CONSTRAINT aggregated_netsec_fw_targets_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id, service_id, protocol_id);


--
-- Name: aggregated_netsec_ips_attacks_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_ips_attacks
    ADD CONSTRAINT aggregated_netsec_ips_attacks_pkey PRIMARY KEY (day, guid, rule_id);


--
-- Name: aggregated_netsec_ips_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_ips_destinations
    ADD CONSTRAINT aggregated_netsec_ips_destinations_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_netsec_ips_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_ips_sources
    ADD CONSTRAINT aggregated_netsec_ips_sources_pkey PRIMARY KEY (day, guid, country_id, ipaddr_id);


--
-- Name: aggregated_netsec_overview_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_netsec_overview
    ADD CONSTRAINT aggregated_netsec_overview_pkey PRIMARY KEY (day, guid);


--
-- Name: aggregated_websec_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_categories
    ADD CONSTRAINT aggregated_websec_categories_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: aggregated_websec_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_domains
    ADD CONSTRAINT aggregated_websec_domains_pkey PRIMARY KEY (day, guid, domain_id);


--
-- Name: aggregated_websec_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_extensions
    ADD CONSTRAINT aggregated_websec_extensions_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: aggregated_websec_overview_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_overview
    ADD CONSTRAINT aggregated_websec_overview_pkey PRIMARY KEY (day, guid);


--
-- Name: aggregated_websec_users_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_users
    ADD CONSTRAINT aggregated_websec_users_pkey PRIMARY KEY (day, guid, user_id);


--
-- Name: aggregated_websec_viruses_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY aggregated_websec_viruses
    ADD CONSTRAINT aggregated_websec_viruses_pkey PRIMARY KEY (day, guid, blocked_id);


--
-- Name: auto_backup_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY auto_backup_info
    ADD CONSTRAINT auto_backup_info_pkey PRIMARY KEY (guid);


--
-- Name: confd_data_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY confd_data
    ADD CONSTRAINT confd_data_pkey PRIMARY KEY (guid);


--
-- Name: config_common_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_common
    ADD CONSTRAINT config_common_pkey PRIMARY KEY (guid);


--
-- Name: config_device_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_device
    ADD CONSTRAINT config_device_pkey PRIMARY KEY (guid);


--
-- Name: config_diagnostic_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_diagnostic
    ADD CONSTRAINT config_diagnostic_pkey PRIMARY KEY (guid);


--
-- Name: config_object_ca_rsa_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_ca_rsa
    ADD CONSTRAINT config_object_ca_rsa_pkey PRIMARY KEY (guid);


--
-- Name: config_object_http_default_action_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_http_default_action
    ADD CONSTRAINT config_object_http_default_action_pkey PRIMARY KEY (guid);


--
-- Name: config_object_http_pac_file_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_http_pac_file
    ADD CONSTRAINT config_object_http_pac_file_pkey PRIMARY KEY (guid);


--
-- Name: config_object_ipsec_site2site_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_ipsec_site2site
    ADD CONSTRAINT config_object_ipsec_site2site_pkey PRIMARY KEY (guid);


--
-- Name: config_object_network_interface_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_network_interface
    ADD CONSTRAINT config_object_network_interface_pkey PRIMARY KEY (guid);


--
-- Name: config_object_packetfilter_rules_back_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_packetfilter_rules_back
    ADD CONSTRAINT config_object_packetfilter_rules_back_pkey PRIMARY KEY (guid);


--
-- Name: config_object_packetfilter_rules_front_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_object_packetfilter_rules_front
    ADD CONSTRAINT config_object_packetfilter_rules_front_pkey PRIMARY KEY (guid);


--
-- Name: config_user_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY config_user
    ADD CONSTRAINT config_user_pkey PRIMARY KEY (guid);


--
-- Name: device_backup_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_backup
    ADD CONSTRAINT device_backup_pkey PRIMARY KEY (guid);


--
-- Name: device_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_info
    ADD CONSTRAINT device_info_pkey PRIMARY KEY (guid);


--
-- Name: device_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_inventory
    ADD CONSTRAINT device_inventory_pkey PRIMARY KEY (guid);


--
-- Name: device_location_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_location
    ADD CONSTRAINT device_location_pkey PRIMARY KEY (guid);


--
-- Name: device_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_ou
    ADD CONSTRAINT device_ou_pkey PRIMARY KEY (guid);


--
-- Name: device_product_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY device_product
    ADD CONSTRAINT device_product_pkey PRIMARY KEY (guid);


--
-- Name: event_log_settings_id_key; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY event_log_settings
    ADD CONSTRAINT event_log_settings_id_key UNIQUE (id);


--
-- Name: global_epp_av_policy_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_epp_av_policy_ou
    ADD CONSTRAINT global_epp_av_policy_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_epp_av_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_epp_av_policy
    ADD CONSTRAINT global_epp_av_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_epp_dc_policy_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_epp_dc_policy_ou
    ADD CONSTRAINT global_epp_dc_policy_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_epp_dc_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_epp_dc_policy
    ADD CONSTRAINT global_epp_dc_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_http_cff_action_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_cff_action_ou
    ADD CONSTRAINT global_http_cff_action_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_http_cff_action_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_cff_action
    ADD CONSTRAINT global_http_cff_action_pkey PRIMARY KEY (guid);


--
-- Name: global_http_exception_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_exception_ou
    ADD CONSTRAINT global_http_exception_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_http_exception_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_exception
    ADD CONSTRAINT global_http_exception_pkey PRIMARY KEY (guid);


--
-- Name: global_http_pac_file_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_pac_file_ou
    ADD CONSTRAINT global_http_pac_file_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_http_pac_file_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_pac_file
    ADD CONSTRAINT global_http_pac_file_pkey PRIMARY KEY (guid);


--
-- Name: global_http_sp_category_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_sp_category_ou
    ADD CONSTRAINT global_http_sp_category_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_http_sp_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_http_sp_category
    ADD CONSTRAINT global_http_sp_category_pkey PRIMARY KEY (guid);


--
-- Name: global_importable_objects_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_importable_objects
    ADD CONSTRAINT global_importable_objects_pkey PRIMARY KEY (guid);


--
-- Name: global_ipsec_policy_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_ipsec_policy_ou
    ADD CONSTRAINT global_ipsec_policy_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_ipsec_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_ipsec_policy
    ADD CONSTRAINT global_ipsec_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_network_availability_group_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_availability_group_ou
    ADD CONSTRAINT global_network_availability_group_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_availability_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_availability_group
    ADD CONSTRAINT global_network_availability_group_pkey PRIMARY KEY (guid);


--
-- Name: global_network_dns_group_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_dns_group_ou
    ADD CONSTRAINT global_network_dns_group_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_dns_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_dns_group
    ADD CONSTRAINT global_network_dns_group_pkey PRIMARY KEY (guid);


--
-- Name: global_network_dns_host_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_dns_host_ou
    ADD CONSTRAINT global_network_dns_host_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_dns_host_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_dns_host
    ADD CONSTRAINT global_network_dns_host_pkey PRIMARY KEY (guid);


--
-- Name: global_network_group_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_group_ou
    ADD CONSTRAINT global_network_group_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_group
    ADD CONSTRAINT global_network_group_pkey PRIMARY KEY (guid);


--
-- Name: global_network_host_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_host_ou
    ADD CONSTRAINT global_network_host_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_host_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_host
    ADD CONSTRAINT global_network_host_pkey PRIMARY KEY (guid);


--
-- Name: global_network_multicast_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_multicast_ou
    ADD CONSTRAINT global_network_multicast_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_multicast_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_multicast
    ADD CONSTRAINT global_network_multicast_pkey PRIMARY KEY (guid);


--
-- Name: global_network_network_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_network_ou
    ADD CONSTRAINT global_network_network_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_switch_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_switch_ou
    ADD CONSTRAINT global_network_switch_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_network_network_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_network
    ADD CONSTRAINT global_network_network_pkey PRIMARY KEY (guid);


--
-- Name: global_network_switch_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_network_switch
    ADD CONSTRAINT global_network_switch_pkey PRIMARY KEY (guid);


--
-- Name: global_object_epp_av_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_epp_av_policy
    ADD CONSTRAINT global_object_epp_av_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_object_epp_dc_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_epp_dc_policy
    ADD CONSTRAINT global_object_epp_dc_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_object_http_cff_action_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_http_cff_action
    ADD CONSTRAINT global_object_http_cff_action_pkey PRIMARY KEY (guid);


--
-- Name: global_object_http_exception_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_http_exception
    ADD CONSTRAINT global_object_http_exception_pkey PRIMARY KEY (guid);


--
-- Name: global_object_http_pac_file_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_http_pac_file
    ADD CONSTRAINT global_object_http_pac_file_pkey PRIMARY KEY (guid);


--
-- Name: global_object_http_sp_category_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_http_sp_category
    ADD CONSTRAINT global_object_http_sp_category_pkey PRIMARY KEY (guid);


--
-- Name: global_object_ipsec_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_ipsec_policy
    ADD CONSTRAINT global_object_ipsec_policy_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_availability_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_availability_group
    ADD CONSTRAINT global_object_network_availability_group_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_dns_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_dns_group
    ADD CONSTRAINT global_object_network_dns_group_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_dns_host_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_dns_host
    ADD CONSTRAINT global_object_network_dns_host_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_group
    ADD CONSTRAINT global_object_network_group_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_host_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_host
    ADD CONSTRAINT global_object_network_host_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_multicast_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_multicast
    ADD CONSTRAINT global_object_network_multicast_pkey PRIMARY KEY (guid);


--
-- Name: global_object_network_network_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_network_network
    ADD CONSTRAINT global_object_network_network_pkey PRIMARY KEY (guid);


--
-- Name: global_object_packetfilter_packetfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_packetfilter_packetfilter
    ADD CONSTRAINT global_object_packetfilter_packetfilter_pkey PRIMARY KEY (guid);


--
-- Name: global_object_packetfilter_ruleset_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_packetfilter_ruleset
    ADD CONSTRAINT global_object_packetfilter_ruleset_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_ah_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_ah
    ADD CONSTRAINT global_object_service_ah_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_esp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_esp
    ADD CONSTRAINT global_object_service_esp_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_group
    ADD CONSTRAINT global_object_service_group_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_icmp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_icmp
    ADD CONSTRAINT global_object_service_icmp_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_ip
    ADD CONSTRAINT global_object_service_ip_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_tcp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_tcp
    ADD CONSTRAINT global_object_service_tcp_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_tcpudp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_tcpudp
    ADD CONSTRAINT global_object_service_tcpudp_pkey PRIMARY KEY (guid);


--
-- Name: global_object_service_udp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_service_udp
    ADD CONSTRAINT global_object_service_udp_pkey PRIMARY KEY (guid);


--
-- Name: global_object_time_recurring_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_time_recurring
    ADD CONSTRAINT global_object_time_recurring_pkey PRIMARY KEY (guid);


--
-- Name: global_object_time_single_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_object_time_single
    ADD CONSTRAINT global_object_time_single_pkey PRIMARY KEY (guid);


--
-- Name: global_packetfilter_packetfilter_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_packetfilter_packetfilter_ou
    ADD CONSTRAINT global_packetfilter_packetfilter_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_packetfilter_packetfilter_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_packetfilter_packetfilter
    ADD CONSTRAINT global_packetfilter_packetfilter_pkey PRIMARY KEY (guid);


--
-- Name: global_packetfilter_ruleset_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_packetfilter_ruleset_ou
    ADD CONSTRAINT global_packetfilter_ruleset_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_packetfilter_ruleset_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_packetfilter_ruleset
    ADD CONSTRAINT global_packetfilter_ruleset_pkey PRIMARY KEY (guid);


--
-- Name: global_service_ah_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_ah_ou
    ADD CONSTRAINT global_service_ah_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_ah_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_ah
    ADD CONSTRAINT global_service_ah_pkey PRIMARY KEY (guid);


--
-- Name: global_service_esp_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_esp_ou
    ADD CONSTRAINT global_service_esp_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_esp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_esp
    ADD CONSTRAINT global_service_esp_pkey PRIMARY KEY (guid);


--
-- Name: global_service_group_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_group_ou
    ADD CONSTRAINT global_service_group_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_group_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_group
    ADD CONSTRAINT global_service_group_pkey PRIMARY KEY (guid);


--
-- Name: global_service_icmp_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_icmp_ou
    ADD CONSTRAINT global_service_icmp_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_icmp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_icmp
    ADD CONSTRAINT global_service_icmp_pkey PRIMARY KEY (guid);


--
-- Name: global_service_ip_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_ip_ou
    ADD CONSTRAINT global_service_ip_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_ip
    ADD CONSTRAINT global_service_ip_pkey PRIMARY KEY (guid);


--
-- Name: global_service_tcp_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_tcp_ou
    ADD CONSTRAINT global_service_tcp_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_tcp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_tcp
    ADD CONSTRAINT global_service_tcp_pkey PRIMARY KEY (guid);


--
-- Name: global_service_tcpudp_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_tcpudp_ou
    ADD CONSTRAINT global_service_tcpudp_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_tcpudp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_tcpudp
    ADD CONSTRAINT global_service_tcpudp_pkey PRIMARY KEY (guid);


--
-- Name: global_service_udp_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_udp_ou
    ADD CONSTRAINT global_service_udp_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_service_udp_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_service_udp
    ADD CONSTRAINT global_service_udp_pkey PRIMARY KEY (guid);


--
-- Name: global_time_recurring_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_time_recurring_ou
    ADD CONSTRAINT global_time_recurring_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_time_recurring_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_time_recurring
    ADD CONSTRAINT global_time_recurring_pkey PRIMARY KEY (guid);


--
-- Name: global_time_single_ou_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_time_single_ou
    ADD CONSTRAINT global_time_single_ou_pkey PRIMARY KEY (guid);


--
-- Name: global_time_single_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY global_time_single
    ADD CONSTRAINT global_time_single_pkey PRIMARY KEY (guid);


--
-- Name: guid; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY log_objects
    ADD CONSTRAINT guid PRIMARY KEY (guid);


--
-- Name: monitoring_availability_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_availability
    ADD CONSTRAINT monitoring_availability_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_dashboard_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_dashboard
    ADD CONSTRAINT monitoring_dashboard_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_hardware_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_hardware
    ADD CONSTRAINT monitoring_hardware_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_license_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_license
    ADD CONSTRAINT monitoring_license_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_network_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_network
    ADD CONSTRAINT monitoring_network_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_resource_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_resource
    ADD CONSTRAINT monitoring_resource_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_service_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_service
    ADD CONSTRAINT monitoring_service_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_threat_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_threat
    ADD CONSTRAINT monitoring_threat_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_version_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_version
    ADD CONSTRAINT monitoring_version_pkey PRIMARY KEY (guid);


--
-- Name: monitoring_vpn_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY monitoring_vpn
    ADD CONSTRAINT monitoring_vpn_pkey PRIMARY KEY (guid);


--
-- Name: msp_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY msp_info
    ADD CONSTRAINT msp_info_pkey PRIMARY KEY (guid);


--
-- Name: odr_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY odr_info
    ADD CONSTRAINT odr_info_pkey PRIMARY KEY (guid);


--
-- Name: ou_default_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY ou_default
    ADD CONSTRAINT ou_default_pkey PRIMARY KEY (guid);


--
-- Name: ou_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY ou_info
    ADD CONSTRAINT ou_info_pkey PRIMARY KEY (guid);


--
-- Name: reporting_hardware_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY reporting_hardware
    ADD CONSTRAINT reporting_hardware_pkey PRIMARY KEY (guid);


--
-- Name: reporting_network_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY reporting_network
    ADD CONSTRAINT reporting_network_pkey PRIMARY KEY (guid);


--
-- Name: reporting_security_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY reporting_security
    ADD CONSTRAINT reporting_security_pkey PRIMARY KEY (guid);


--
-- Name: script_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY script_info
    ADD CONSTRAINT script_info_pkey PRIMARY KEY (guid);


--
-- Name: user_acl_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY user_acl
    ADD CONSTRAINT user_acl_pkey PRIMARY KEY (guid);


--
-- Name: user_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY user_info
    ADD CONSTRAINT user_info_pkey PRIMARY KEY (guid);


--
-- Name: vpn_info_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY vpn_info
    ADD CONSTRAINT vpn_info_pkey PRIMARY KEY (guid);


--
-- Name: vpn_monitoring_pkey; Type: CONSTRAINT; Schema: public; Owner: cbcc; Tablespace: 
--

ALTER TABLE ONLY vpn_monitoring
    ADD CONSTRAINT vpn_monitoring_pkey PRIMARY KEY (guid);


--
-- Name: aggregated_accounting_destinations_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_accounting_destinations_guid_key ON aggregated_accounting_destinations USING btree (guid);


--
-- Name: aggregated_accounting_overview_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_accounting_overview_guid_key ON aggregated_accounting_overview USING btree (guid);


--
-- Name: aggregated_accounting_services_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_accounting_services_guid_key ON aggregated_accounting_services USING btree (guid);


--
-- Name: aggregated_accounting_sources_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_accounting_sources_guid_key ON aggregated_accounting_sources USING btree (guid);


--
-- Name: aggregated_emailsec_blocked_expressions_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_blocked_expressions_guid_key ON aggregated_emailsec_blocked_expressions USING btree (guid);


--
-- Name: aggregated_emailsec_blocked_extensions_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_blocked_extensions_guid_key ON aggregated_emailsec_blocked_extensions USING btree (guid);


--
-- Name: aggregated_emailsec_blocked_viruses_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_blocked_viruses_guid_key ON aggregated_emailsec_blocked_viruses USING btree (guid);


--
-- Name: aggregated_emailsec_email_recipients_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_email_recipients_guid_key ON aggregated_emailsec_email_recipients USING btree (guid);


--
-- Name: aggregated_emailsec_email_senders_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_email_senders_guid_key ON aggregated_emailsec_email_senders USING btree (guid);


--
-- Name: aggregated_emailsec_overview_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_overview_guid_key ON aggregated_emailsec_overview USING btree (guid);


--
-- Name: aggregated_emailsec_spam_countries_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_spam_countries_guid_key ON aggregated_emailsec_spam_countries USING btree (guid);


--
-- Name: aggregated_emailsec_spam_senders_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_emailsec_spam_senders_guid_key ON aggregated_emailsec_spam_senders USING btree (guid);


--
-- Name: aggregated_netsec_fw_destinations_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_fw_destinations_guid_key ON aggregated_netsec_fw_destinations USING btree (guid);


--
-- Name: aggregated_netsec_fw_services_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_fw_services_guid_key ON aggregated_netsec_fw_services USING btree (guid);


--
-- Name: aggregated_netsec_fw_sources_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_fw_sources_guid_key ON aggregated_netsec_fw_sources USING btree (guid);


--
-- Name: aggregated_netsec_fw_targets_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_fw_targets_guid_key ON aggregated_netsec_fw_targets USING btree (guid);


--
-- Name: aggregated_netsec_ips_attacks_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_ips_attacks_guid_key ON aggregated_netsec_ips_attacks USING btree (guid);


--
-- Name: aggregated_netsec_ips_destinations_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_ips_destinations_guid_key ON aggregated_netsec_ips_destinations USING btree (guid);


--
-- Name: aggregated_netsec_ips_sources_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_ips_sources_guid_key ON aggregated_netsec_ips_sources USING btree (guid);


--
-- Name: aggregated_netsec_overview_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_netsec_overview_guid_key ON aggregated_netsec_overview USING btree (guid);


--
-- Name: aggregated_websec_categories_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_categories_guid_key ON aggregated_websec_categories USING btree (guid);


--
-- Name: aggregated_websec_domains_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_domains_guid_key ON aggregated_websec_domains USING btree (guid);


--
-- Name: aggregated_websec_extensions_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_extensions_guid_key ON aggregated_websec_extensions USING btree (guid);


--
-- Name: aggregated_websec_overview_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_overview_guid_key ON aggregated_websec_overview USING btree (guid);


--
-- Name: aggregated_websec_users_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_users_guid_key ON aggregated_websec_users USING btree (guid);


--
-- Name: aggregated_websec_viruses_guid_key; Type: INDEX; Schema: public; Owner: cbcc; Tablespace: 
--

CREATE INDEX aggregated_websec_viruses_guid_key ON aggregated_websec_viruses USING btree (guid);


--
-- Name: aggregated_accounting_destinations_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_destinations
    ADD CONSTRAINT aggregated_accounting_destinations_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_accounting_destinations_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_destinations
    ADD CONSTRAINT aggregated_accounting_destinations_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_accounting_services_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_services
    ADD CONSTRAINT aggregated_accounting_services_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES aggregated_lookup_protocol_names(id);


--
-- Name: aggregated_accounting_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_services
    ADD CONSTRAINT aggregated_accounting_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES aggregated_lookup_service_names(id);


--
-- Name: aggregated_accounting_sources_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_sources
    ADD CONSTRAINT aggregated_accounting_sources_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_accounting_sources_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_accounting_sources
    ADD CONSTRAINT aggregated_accounting_sources_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_emailsec_blocked_expressions_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_blocked_expressions
    ADD CONSTRAINT aggregated_emailsec_blocked_expressions_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_expression_names(id);


--
-- Name: aggregated_emailsec_blocked_extensions_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_blocked_extensions
    ADD CONSTRAINT aggregated_emailsec_blocked_extensions_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_extension_names(id);


--
-- Name: aggregated_emailsec_blocked_viruses_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_blocked_viruses
    ADD CONSTRAINT aggregated_emailsec_blocked_viruses_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_virus_names(id);


--
-- Name: aggregated_emailsec_email_recipients_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_email_recipients
    ADD CONSTRAINT aggregated_emailsec_email_recipients_email_id_fkey FOREIGN KEY (email_id) REFERENCES aggregated_lookup_email_addresses(id);


--
-- Name: aggregated_emailsec_email_senders_email_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_email_senders
    ADD CONSTRAINT aggregated_emailsec_email_senders_email_id_fkey FOREIGN KEY (email_id) REFERENCES aggregated_lookup_email_addresses(id);


--
-- Name: aggregated_emailsec_spam_countries_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_spam_countries
    ADD CONSTRAINT aggregated_emailsec_spam_countries_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_emailsec_spam_senders_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_spam_senders
    ADD CONSTRAINT aggregated_emailsec_spam_senders_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_emailsec_spam_senders_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_emailsec_spam_senders
    ADD CONSTRAINT aggregated_emailsec_spam_senders_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_netsec_fw_destinations_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_destinations
    ADD CONSTRAINT aggregated_netsec_fw_destinations_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_netsec_fw_destinations_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_destinations
    ADD CONSTRAINT aggregated_netsec_fw_destinations_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_netsec_fw_services_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_services
    ADD CONSTRAINT aggregated_netsec_fw_services_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES aggregated_lookup_protocol_names(id);


--
-- Name: aggregated_netsec_fw_services_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_services
    ADD CONSTRAINT aggregated_netsec_fw_services_service_id_fkey FOREIGN KEY (service_id) REFERENCES aggregated_lookup_service_names(id);


--
-- Name: aggregated_netsec_fw_sources_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_sources
    ADD CONSTRAINT aggregated_netsec_fw_sources_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_netsec_fw_sources_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_sources
    ADD CONSTRAINT aggregated_netsec_fw_sources_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_netsec_fw_targets_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_targets
    ADD CONSTRAINT aggregated_netsec_fw_targets_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_netsec_fw_targets_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_targets
    ADD CONSTRAINT aggregated_netsec_fw_targets_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_netsec_fw_targets_protocol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_targets
    ADD CONSTRAINT aggregated_netsec_fw_targets_protocol_id_fkey FOREIGN KEY (protocol_id) REFERENCES aggregated_lookup_protocol_names(id);


--
-- Name: aggregated_netsec_fw_targets_service_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_fw_targets
    ADD CONSTRAINT aggregated_netsec_fw_targets_service_id_fkey FOREIGN KEY (service_id) REFERENCES aggregated_lookup_service_names(id);


--
-- Name: aggregated_netsec_ips_attacks_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_attacks
    ADD CONSTRAINT aggregated_netsec_ips_attacks_group_id_fkey FOREIGN KEY (group_id) REFERENCES aggregated_lookup_ips_groups(id);


--
-- Name: aggregated_netsec_ips_attacks_msg_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_attacks
    ADD CONSTRAINT aggregated_netsec_ips_attacks_msg_id_fkey FOREIGN KEY (msg_id) REFERENCES aggregated_lookup_ips_msgs(id);


--
-- Name: aggregated_netsec_ips_destinations_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_destinations
    ADD CONSTRAINT aggregated_netsec_ips_destinations_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_netsec_ips_destinations_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_destinations
    ADD CONSTRAINT aggregated_netsec_ips_destinations_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_netsec_ips_sources_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_sources
    ADD CONSTRAINT aggregated_netsec_ips_sources_country_id_fkey FOREIGN KEY (country_id) REFERENCES aggregated_lookup_country_names(id);


--
-- Name: aggregated_netsec_ips_sources_ipaddr_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_netsec_ips_sources
    ADD CONSTRAINT aggregated_netsec_ips_sources_ipaddr_id_fkey FOREIGN KEY (ipaddr_id) REFERENCES aggregated_lookup_ip_addresses(id);


--
-- Name: aggregated_websec_categories_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_websec_categories
    ADD CONSTRAINT aggregated_websec_categories_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_category_names(id);


--
-- Name: aggregated_websec_domains_domain_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_websec_domains
    ADD CONSTRAINT aggregated_websec_domains_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES aggregated_lookup_domain_names(id);


--
-- Name: aggregated_websec_extensions_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_websec_extensions
    ADD CONSTRAINT aggregated_websec_extensions_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_extension_names(id);


--
-- Name: aggregated_websec_users_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_websec_users
    ADD CONSTRAINT aggregated_websec_users_user_id_fkey FOREIGN KEY (user_id) REFERENCES aggregated_lookup_user_names(id);


--
-- Name: aggregated_websec_viruses_blocked_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: cbcc
--

ALTER TABLE ONLY aggregated_websec_viruses
    ADD CONSTRAINT aggregated_websec_viruses_blocked_id_fkey FOREIGN KEY (blocked_id) REFERENCES aggregated_lookup_virus_names(id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect epp

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: device_type_; Type: TYPE; Schema: public; Owner: epp
--

CREATE TYPE device_type_ AS ENUM (
    'floppy_drive',
    'optical_drive',
    'removable_storage',
    'encrypted_storage',
    'modem',
    'wireless',
    'bluetooth',
    'infrared'
);


ALTER TYPE public.device_type_ OWNER TO epp;

--
-- Name: endpoint_type_; Type: TYPE; Schema: public; Owner: epp
--

CREATE TYPE endpoint_type_ AS ENUM (
    'desktop',
    'laptop',
    'server'
);


ALTER TYPE public.endpoint_type_ OWNER TO epp;

--
-- Name: status_type_; Type: TYPE; Schema: public; Owner: epp
--

CREATE TYPE status_type_ AS ENUM (
    'ready',
    'pending',
    'sent',
    'done'
);


ALTER TYPE public.status_type_ OWNER TO epp;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: actions; Type: TABLE; Schema: public; Owner: epp; Tablespace: 
--

CREATE TABLE actions (
    action_id integer NOT NULL,
    mcs_id text NOT NULL,
    subtype text NOT NULL,
    cause text NOT NULL,
    alert text,
    action integer NOT NULL,
    priority integer NOT NULL,
    status status_type_ DEFAULT 'ready'::status_type_,
    date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.actions OWNER TO epp;

--
-- Name: actions_action_id_seq; Type: SEQUENCE; Schema: public; Owner: epp
--

CREATE SEQUENCE actions_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.actions_action_id_seq OWNER TO epp;

--
-- Name: actions_action_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epp
--

ALTER SEQUENCE actions_action_id_seq OWNED BY actions.action_id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: epp; Tablespace: 
--

CREATE TABLE devices (
    id integer NOT NULL,
    device_type device_type_ DEFAULT 'removable_storage'::device_type_,
    name text,
    device_id text NOT NULL,
    instance_id text,
    creation_time timestamp without time zone DEFAULT now(),
    mcs_id text,
    last_connected timestamp without time zone DEFAULT now(),
    reference text
);


ALTER TABLE public.devices OWNER TO epp;

--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: epp
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.devices_id_seq OWNER TO epp;

--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epp
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: endpoints; Type: TABLE; Schema: public; Owner: epp; Tablespace: 
--

CREATE TABLE endpoints (
    endpoint_id integer NOT NULL,
    mcs_id text NOT NULL,
    endpoint_type endpoint_type_ DEFAULT 'desktop'::endpoint_type_,
    computer_name text,
    domain text,
    operating_system text,
    service_pack text,
    internal_ip text,
    geo_ip text,
    geo_country text,
    geo_city text,
    last_logged_on_user text,
    last_ping timestamp without time zone DEFAULT now(),
    reference text
);


ALTER TABLE public.endpoints OWNER TO epp;

--
-- Name: endpoints_endpoint_id_seq; Type: SEQUENCE; Schema: public; Owner: epp
--

CREATE SEQUENCE endpoints_endpoint_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.endpoints_endpoint_id_seq OWNER TO epp;

--
-- Name: endpoints_endpoint_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epp
--

ALTER SEQUENCE endpoints_endpoint_id_seq OWNED BY endpoints.endpoint_id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: epp; Tablespace: 
--

CREATE TABLE events (
    event_id integer NOT NULL,
    mcs_id text NOT NULL,
    event_type text NOT NULL,
    cause text NOT NULL,
    effect text NOT NULL,
    type text,
    scantype text,
    subtype text,
    action text,
    status text,
    acknowledged boolean DEFAULT false,
    date timestamp without time zone DEFAULT now()
);


ALTER TABLE public.events OWNER TO epp;

--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: public; Owner: epp
--

CREATE SEQUENCE events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_event_id_seq OWNER TO epp;

--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: epp
--

ALTER SEQUENCE events_event_id_seq OWNED BY events.event_id;


--
-- Name: groups_exceptions; Type: TABLE; Schema: public; Owner: epp; Tablespace: 
--

CREATE TABLE groups_exceptions (
    group_ref text NOT NULL,
    exception_ref text NOT NULL
);


ALTER TABLE public.groups_exceptions OWNER TO epp;

--
-- Name: action_id; Type: DEFAULT; Schema: public; Owner: epp
--

ALTER TABLE ONLY actions ALTER COLUMN action_id SET DEFAULT nextval('actions_action_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: epp
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: endpoint_id; Type: DEFAULT; Schema: public; Owner: epp
--

ALTER TABLE ONLY endpoints ALTER COLUMN endpoint_id SET DEFAULT nextval('endpoints_endpoint_id_seq'::regclass);


--
-- Name: event_id; Type: DEFAULT; Schema: public; Owner: epp
--

ALTER TABLE ONLY events ALTER COLUMN event_id SET DEFAULT nextval('events_event_id_seq'::regclass);


--
-- Data for Name: actions; Type: TABLE DATA; Schema: public; Owner: epp
--

COPY actions (action_id, mcs_id, subtype, cause, alert, action, priority, status, date) FROM stdin;
\.


--
-- Name: actions_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epp
--

SELECT pg_catalog.setval('actions_action_id_seq', 1, false);


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: epp
--

COPY devices (id, device_type, name, device_id, instance_id, creation_time, mcs_id, last_connected, reference) FROM stdin;
\.


--
-- Name: devices_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epp
--

SELECT pg_catalog.setval('devices_id_seq', 1, false);


--
-- Data for Name: endpoints; Type: TABLE DATA; Schema: public; Owner: epp
--

COPY endpoints (endpoint_id, mcs_id, endpoint_type, computer_name, domain, operating_system, service_pack, internal_ip, geo_ip, geo_country, geo_city, last_logged_on_user, last_ping, reference) FROM stdin;
\.


--
-- Name: endpoints_endpoint_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epp
--

SELECT pg_catalog.setval('endpoints_endpoint_id_seq', 1, false);


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: epp
--

COPY events (event_id, mcs_id, event_type, cause, effect, type, scantype, subtype, action, status, acknowledged, date) FROM stdin;
\.


--
-- Name: events_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: epp
--

SELECT pg_catalog.setval('events_event_id_seq', 1, false);


--
-- Data for Name: groups_exceptions; Type: TABLE DATA; Schema: public; Owner: epp
--

COPY groups_exceptions (group_ref, exception_ref) FROM stdin;
\.


--
-- Name: actions_pkey; Type: CONSTRAINT; Schema: public; Owner: epp; Tablespace: 
--

ALTER TABLE ONLY actions
    ADD CONSTRAINT actions_pkey PRIMARY KEY (action_id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: epp; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: endpoints_pkey; Type: CONSTRAINT; Schema: public; Owner: epp; Tablespace: 
--

ALTER TABLE ONLY endpoints
    ADD CONSTRAINT endpoints_pkey PRIMARY KEY (endpoint_id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: public; Owner: epp; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: groups_exceptions_pkey; Type: CONSTRAINT; Schema: public; Owner: epp; Tablespace: 
--

ALTER TABLE ONLY groups_exceptions
    ADD CONSTRAINT groups_exceptions_pkey PRIMARY KEY (group_ref, exception_ref);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect hotspot

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: hotspot; Tablespace: 
--

CREATE TABLE interfaces (
    portal_id integer NOT NULL,
    interface character varying NOT NULL,
    ip inet,
    ip6 inet
);


ALTER TABLE public.interfaces OWNER TO hotspot;

--
-- Name: macs; Type: TABLE; Schema: public; Owner: hotspot; Tablespace: 
--

CREATE TABLE macs (
    id integer NOT NULL,
    user_id integer NOT NULL,
    mac macaddr NOT NULL,
    created boolean DEFAULT false NOT NULL,
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.macs OWNER TO hotspot;

--
-- Name: macs_id_seq; Type: SEQUENCE; Schema: public; Owner: hotspot
--

CREATE SEQUENCE macs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.macs_id_seq OWNER TO hotspot;

--
-- Name: macs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hotspot
--

ALTER SEQUENCE macs_id_seq OWNED BY macs.id;


--
-- Name: portals; Type: TABLE; Schema: public; Owner: hotspot; Tablespace: 
--

CREATE TABLE portals (
    id integer NOT NULL,
    ref character varying,
    name character varying,
    title character varying,
    terms character varying,
    description character varying,
    authtype integer NOT NULL,
    password character varying,
    expiry integer,
    maclimit integer,
    deleted boolean DEFAULT false NOT NULL,
    created boolean DEFAULT false NOT NULL,
    redirect_url character varying
);


ALTER TABLE public.portals OWNER TO hotspot;

--
-- Name: portals_id_seq; Type: SEQUENCE; Schema: public; Owner: hotspot
--

CREATE SEQUENCE portals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.portals_id_seq OWNER TO hotspot;

--
-- Name: portals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hotspot
--

ALTER SEQUENCE portals_id_seq OWNED BY portals.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: hotspot; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    portal_id integer NOT NULL,
    name character varying,
    comment character varying,
    caption character varying,
    firstlogin timestamp with time zone,
    expiry integer,
    timequota integer,
    trafficlimit bigint,
    usedtime integer DEFAULT 0 NOT NULL,
    usedtraffic bigint DEFAULT 0 NOT NULL,
    lastseen timestamp with time zone,
    expired timestamp with time zone,
    deleted boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO hotspot;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: hotspot
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO hotspot;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hotspot
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: view_users; Type: VIEW; Schema: public; Owner: hotspot
--

CREATE VIEW view_users AS
    SELECT users.id, users.portal_id, users.name, users.comment, users.firstlogin, users.expiry, users.timequota, users.trafficlimit, users.usedtime, users.usedtraffic, users.lastseen, users.expired, users.deleted, ((now() > (users.firstlogin + ((users.expiry)::double precision * '00:01:00'::interval))) IS TRUE) AS validity_expired, ((users.usedtraffic >= users.trafficlimit) IS TRUE) AS trafficlimit_exceeded, ((users.usedtime >= users.timequota) IS TRUE) AS timequota_exceeded FROM users;


ALTER TABLE public.view_users OWNER TO hotspot;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY macs ALTER COLUMN id SET DEFAULT nextval('macs_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY portals ALTER COLUMN id SET DEFAULT nextval('portals_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: hotspot
--

COPY interfaces (portal_id, interface, ip, ip6) FROM stdin;
\.


--
-- Data for Name: macs; Type: TABLE DATA; Schema: public; Owner: hotspot
--

COPY macs (id, user_id, mac, created, deleted) FROM stdin;
\.


--
-- Name: macs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hotspot
--

SELECT pg_catalog.setval('macs_id_seq', 1, false);


--
-- Data for Name: portals; Type: TABLE DATA; Schema: public; Owner: hotspot
--

COPY portals (id, ref, name, title, terms, description, authtype, password, expiry, maclimit, deleted, created, redirect_url) FROM stdin;
\.


--
-- Name: portals_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hotspot
--

SELECT pg_catalog.setval('portals_id_seq', 1, false);


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: hotspot
--

COPY users (id, portal_id, name, comment, caption, firstlogin, expiry, timequota, trafficlimit, usedtime, usedtraffic, lastseen, expired, deleted) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: hotspot
--

SELECT pg_catalog.setval('users_id_seq', 1, false);


--
-- Name: interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (interface);


--
-- Name: macs_mac_key; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY macs
    ADD CONSTRAINT macs_mac_key UNIQUE (mac, user_id);


--
-- Name: macs_pkey; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY macs
    ADD CONSTRAINT macs_pkey PRIMARY KEY (id);


--
-- Name: portals_pkey; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY portals
    ADD CONSTRAINT portals_pkey PRIMARY KEY (id);


--
-- Name: portals_ref_key; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY portals
    ADD CONSTRAINT portals_ref_key UNIQUE (ref);


--
-- Name: users_name_key; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_name_key UNIQUE (name, portal_id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: hotspot; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: interfaces_portal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY interfaces
    ADD CONSTRAINT interfaces_portal_id_fkey FOREIGN KEY (portal_id) REFERENCES portals(id) ON DELETE CASCADE;


--
-- Name: macs_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY macs
    ADD CONSTRAINT macs_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: users_portal_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hotspot
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_portal_id_fkey FOREIGN KEY (portal_id) REFERENCES portals(id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect pop3

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE accounts (
    account_id integer NOT NULL,
    server_id integer NOT NULL,
    username character varying NOT NULL,
    passwd character varying,
    lock_client character varying,
    lock_prefetch character varying,
    last_proxy_login timestamp with time zone,
    last_fetch_try timestamp with time zone,
    fetch_tries smallint DEFAULT 0 NOT NULL,
    last_digest timestamp with time zone,
    last_ssl_status integer DEFAULT 0
);


ALTER TABLE public.accounts OWNER TO pop3;

--
-- Name: confd_accounts; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE confd_accounts (
    account_ref character varying NOT NULL,
    user_ref character varying NOT NULL,
    server_ref character varying NOT NULL,
    username character varying NOT NULL,
    passwd character varying NOT NULL,
    comment character varying
);


ALTER TABLE public.confd_accounts OWNER TO pop3;

--
-- Name: servers; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE servers (
    server_id integer NOT NULL,
    server_ref character varying,
    name character varying
);


ALTER TABLE public.servers OWNER TO pop3;

--
-- Name: account_map; Type: VIEW; Schema: public; Owner: pop3
--

CREATE VIEW account_map AS
    SELECT a.account_id, ca.account_ref, a.username, ca.comment, ca.user_ref, s.name AS srv_name FROM accounts a, confd_accounts ca, servers s WHERE ((((lower((a.username)::text) = lower((ca.username)::text)) AND ((a.passwd)::text = (ca.passwd)::text)) AND (a.server_id = s.server_id)) AND ((ca.server_ref)::text = (s.server_ref)::text));


ALTER TABLE public.account_map OWNER TO pop3;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE; Schema: public; Owner: pop3
--

CREATE SEQUENCE accounts_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accounts_account_id_seq OWNER TO pop3;

--
-- Name: accounts_account_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pop3
--

ALTER SEQUENCE accounts_account_id_seq OWNED BY accounts.account_id;


--
-- Name: confd_blacklist; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE confd_blacklist (
    user_ref character varying NOT NULL,
    expr character varying NOT NULL
);


ALTER TABLE public.confd_blacklist OWNER TO pop3;

--
-- Name: confd_users; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE confd_users (
    user_ref character varying NOT NULL,
    name character varying
);


ALTER TABLE public.confd_users OWNER TO pop3;

--
-- Name: confd_whitelist; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE confd_whitelist (
    user_ref character varying NOT NULL,
    expr character varying NOT NULL
);


ALTER TABLE public.confd_whitelist OWNER TO pop3;

--
-- Name: messages; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE messages (
    message_id integer NOT NULL,
    cluster_id smallint NOT NULL,
    account_id integer,
    uid character varying,
    size integer NOT NULL,
    ident character varying NOT NULL,
    receive_time timestamp with time zone DEFAULT now() NOT NULL,
    status smallint NOT NULL,
    on_server boolean DEFAULT true NOT NULL,
    on_proxy integer DEFAULT 0
);


ALTER TABLE public.messages OWNER TO pop3;

--
-- Name: messages_message_id_seq; Type: SEQUENCE; Schema: public; Owner: pop3
--

CREATE SEQUENCE messages_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.messages_message_id_seq OWNER TO pop3;

--
-- Name: messages_message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pop3
--

ALTER SEQUENCE messages_message_id_seq OWNED BY messages.message_id;


--
-- Name: modified_headers; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE modified_headers (
    message_id integer NOT NULL,
    name character varying NOT NULL,
    value character varying NOT NULL
);


ALTER TABLE public.modified_headers OWNER TO pop3;

--
-- Name: quarantine; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE quarantine (
    message_id integer NOT NULL,
    recipient character varying,
    sender character varying,
    subject character varying,
    reason smallint NOT NULL,
    reason_extra character varying,
    need_report boolean NOT NULL
);


ALTER TABLE public.quarantine OWNER TO pop3;

--
-- Name: serveraddress; Type: TABLE; Schema: public; Owner: pop3; Tablespace: 
--

CREATE TABLE serveraddress (
    server_id integer NOT NULL,
    ip_addr inet NOT NULL
);


ALTER TABLE public.serveraddress OWNER TO pop3;

--
-- Name: servers_server_id_seq; Type: SEQUENCE; Schema: public; Owner: pop3
--

CREATE SEQUENCE servers_server_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.servers_server_id_seq OWNER TO pop3;

--
-- Name: servers_server_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pop3
--

ALTER SEQUENCE servers_server_id_seq OWNED BY servers.server_id;


--
-- Name: account_id; Type: DEFAULT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY accounts ALTER COLUMN account_id SET DEFAULT nextval('accounts_account_id_seq'::regclass);


--
-- Name: message_id; Type: DEFAULT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY messages ALTER COLUMN message_id SET DEFAULT nextval('messages_message_id_seq'::regclass);


--
-- Name: server_id; Type: DEFAULT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY servers ALTER COLUMN server_id SET DEFAULT nextval('servers_server_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY accounts (account_id, server_id, username, passwd, lock_client, lock_prefetch, last_proxy_login, last_fetch_try, fetch_tries, last_digest, last_ssl_status) FROM stdin;
\.


--
-- Name: accounts_account_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pop3
--

SELECT pg_catalog.setval('accounts_account_id_seq', 1, false);


--
-- Data for Name: confd_accounts; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY confd_accounts (account_ref, user_ref, server_ref, username, passwd, comment) FROM stdin;
\.


--
-- Data for Name: confd_blacklist; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY confd_blacklist (user_ref, expr) FROM stdin;
\.


--
-- Data for Name: confd_users; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY confd_users (user_ref, name) FROM stdin;
\.


--
-- Data for Name: confd_whitelist; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY confd_whitelist (user_ref, expr) FROM stdin;
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY messages (message_id, cluster_id, account_id, uid, size, ident, receive_time, status, on_server, on_proxy) FROM stdin;
\.


--
-- Name: messages_message_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pop3
--

SELECT pg_catalog.setval('messages_message_id_seq', 1, false);


--
-- Data for Name: modified_headers; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY modified_headers (message_id, name, value) FROM stdin;
\.


--
-- Data for Name: quarantine; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY quarantine (message_id, recipient, sender, subject, reason, reason_extra, need_report) FROM stdin;
\.


--
-- Data for Name: serveraddress; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY serveraddress (server_id, ip_addr) FROM stdin;
\.


--
-- Data for Name: servers; Type: TABLE DATA; Schema: public; Owner: pop3
--

COPY servers (server_id, server_ref, name) FROM stdin;
\.


--
-- Name: servers_server_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pop3
--

SELECT pg_catalog.setval('servers_server_id_seq', 1, false);


--
-- Name: accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (account_id);


--
-- Name: confd_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY confd_accounts
    ADD CONSTRAINT confd_accounts_pkey PRIMARY KEY (account_ref);


--
-- Name: confd_blacklist_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY confd_blacklist
    ADD CONSTRAINT confd_blacklist_pkey PRIMARY KEY (expr, user_ref);


--
-- Name: confd_whitelist_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY confd_whitelist
    ADD CONSTRAINT confd_whitelist_pkey PRIMARY KEY (expr, user_ref);


--
-- Name: messages_ident_key; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_ident_key UNIQUE (ident, cluster_id);


--
-- Name: messages_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (message_id);


--
-- Name: messages_uid_key; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_uid_key UNIQUE (uid, account_id);


--
-- Name: modified_headers_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY modified_headers
    ADD CONSTRAINT modified_headers_pkey PRIMARY KEY (message_id, name);


--
-- Name: quarantine_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY quarantine
    ADD CONSTRAINT quarantine_pkey PRIMARY KEY (message_id);


--
-- Name: serveraddress_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY serveraddress
    ADD CONSTRAINT serveraddress_pkey PRIMARY KEY (ip_addr);


--
-- Name: servers_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY servers
    ADD CONSTRAINT servers_pkey PRIMARY KEY (server_id);


--
-- Name: servers_server_ref_key; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY servers
    ADD CONSTRAINT servers_server_ref_key UNIQUE (server_ref);


--
-- Name: users_lock_client_key; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT users_lock_client_key UNIQUE (lock_client);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: pop3; Tablespace: 
--

ALTER TABLE ONLY confd_users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_ref);


--
-- Name: a_username; Type: INDEX; Schema: public; Owner: pop3; Tablespace: 
--

CREATE INDEX a_username ON accounts USING btree (lower((username)::text));


--
-- Name: m_account_id; Type: INDEX; Schema: public; Owner: pop3; Tablespace: 
--

CREATE INDEX m_account_id ON messages USING btree (account_id);


--
-- Name: m_receive_time; Type: INDEX; Schema: public; Owner: pop3; Tablespace: 
--

CREATE INDEX m_receive_time ON messages USING btree (receive_time);


--
-- Name: m_status; Type: INDEX; Schema: public; Owner: pop3; Tablespace: 
--

CREATE INDEX m_status ON messages USING btree (status);


--
-- Name: q_reason; Type: INDEX; Schema: public; Owner: pop3; Tablespace: 
--

CREATE INDEX q_reason ON quarantine USING btree (reason);


--
-- Name: release_hold_message; Type: RULE; Schema: public; Owner: pop3
--

CREATE RULE release_hold_message AS ON UPDATE TO messages WHERE ((old.status = 4) AND (new.status = 2)) DO INSTEAD DELETE FROM messages WHERE (messages.message_id = old.message_id);


--
-- Name: accounts_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY accounts
    ADD CONSTRAINT accounts_server_id_fkey FOREIGN KEY (server_id) REFERENCES servers(server_id) ON DELETE CASCADE;


--
-- Name: confd_accounts_server_ref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY confd_accounts
    ADD CONSTRAINT confd_accounts_server_ref_fkey FOREIGN KEY (server_ref) REFERENCES servers(server_ref) ON DELETE CASCADE;


--
-- Name: confd_accounts_user_ref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY confd_accounts
    ADD CONSTRAINT confd_accounts_user_ref_fkey FOREIGN KEY (user_ref) REFERENCES confd_users(user_ref) ON DELETE CASCADE;


--
-- Name: confd_blacklist_user_ref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY confd_blacklist
    ADD CONSTRAINT confd_blacklist_user_ref_fkey FOREIGN KEY (user_ref) REFERENCES confd_users(user_ref) ON DELETE CASCADE;


--
-- Name: confd_whitelist_user_ref_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY confd_whitelist
    ADD CONSTRAINT confd_whitelist_user_ref_fkey FOREIGN KEY (user_ref) REFERENCES confd_users(user_ref) ON DELETE CASCADE;


--
-- Name: messages_account_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY messages
    ADD CONSTRAINT messages_account_id_fkey FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE SET NULL;


--
-- Name: modified_headers_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY modified_headers
    ADD CONSTRAINT modified_headers_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(message_id) ON DELETE CASCADE;


--
-- Name: quarantine_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY quarantine
    ADD CONSTRAINT quarantine_message_id_fkey FOREIGN KEY (message_id) REFERENCES messages(message_id) ON DELETE CASCADE;


--
-- Name: serveraddress_server_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: pop3
--

ALTER TABLE ONLY serveraddress
    ADD CONSTRAINT serveraddress_server_id_fkey FOREIGN KEY (server_id) REFERENCES servers(server_id) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect postgres

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: postgres; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect repmgr

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect reporting

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: websec_function; Type: TYPE; Schema: public; Owner: reporting
--

CREATE TYPE websec_function AS ENUM (
    'requests',
    'visits',
    'sessions',
    'searches'
);


ALTER TYPE public.websec_function OWNER TO reporting;

--
-- Name: disconnect_current_vpn_connections(); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION disconnect_current_vpn_connections() RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	update vpn set 
		status = 1,
		logouttime = logintime
	where
		status = 0;
end;
$$;


ALTER FUNCTION public.disconnect_current_vpn_connections() OWNER TO reporting;

--
-- Name: get_departmentid(text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION get_departmentid(dpt text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
declare
	tmp		bigint;
begin
	if dpt is null then
		return null;
	else
		with ins (dno) as (
			insert into dpt_lookup (name)
				select dpt where not exists (
					select * from dpt_lookup where name = dpt
				) returning _rowno
		) select ins.dno from ins
		union
		select _rowno into tmp from dpt_lookup where name = dpt;
	end if;

	return tmp;
end;
$$;


ALTER FUNCTION public.get_departmentid(dpt text) OWNER TO reporting;

--
-- Name: get_mailaddrid(text, text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION get_mailaddrid(u text, d text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
declare
	tmp		bigint;
	did		bigint;
begin
	did := get_maildomainid(d);
	with ins (uno) as (
		insert into mailanon_addrs (lpart, domain)
			select u, did where not exists (
				select * from mailanon_addrs where lpart = u and domain = did
			) returning _rowno
	) select ins.uno from ins
	union
	select _rowno into tmp from mailanon_addrs where lpart = u and domain = did;

	return tmp;
end;
$$;


ALTER FUNCTION public.get_mailaddrid(u text, d text) OWNER TO reporting;

--
-- Name: get_maildomainid(text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION get_maildomainid(domainname text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
declare
	tmp		bigint;
begin
	with ins (dno) as (
		insert into mailanon_domains (domain)
			select domainname where not exists (
				select * from mailanon_domains where domain = domainname
			) returning _rowno
	) select ins.dno from ins
	union
	select _rowno into tmp from mailanon_domains where domain = domainname;

	return tmp;
end;
$$;


ALTER FUNCTION public.get_maildomainid(domainname text) OWNER TO reporting;

--
-- Name: get_webuserid(text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION get_webuserid(username text) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
declare
	tmp		bigint;
begin
	with ins (uno) as (
		insert into webanon_users (userid)
			select username where not exists (
				select * from webanon_users where userid = username
			) returning _rowno
	) select ins.uno from ins
	union
	select _rowno into tmp from webanon_users where userid = username;

	return tmp;
end;
$$;


ALTER FUNCTION public.get_webuserid(username text) OWNER TO reporting;

--
-- Name: ins_accounting(inet, inet, integer, integer, integer, bigint, bigint, bigint, bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_accounting(saddr inet, daddr inet, proto integer, port integer, afc integer, in_len bigint, in_cnt bigint, out_len bigint, out_cnt bigint, flow_start integer, duration integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	src_id		integer;
	dst_id		integer;
	appid		integer;
	day			date;
begin
	src_id = 0;
	dst_id = 0;
	day = (timestamp with time zone 'epoch' + flow_start * interval '1 second')::date;

	SELECT INTO src_id id FROM endpoint_lookup WHERE ip = saddr;
	SELECT INTO dst_id id FROM endpoint_lookup WHERE ip = daddr;

	if afc = 4096 then
		appid := 0;
	else
		appid := afc;
	end if;

	with upsert (flowcount) as (
		update accounting set
			raw_in_pktlen = raw_in_pktlen + in_len,
			raw_in_pktcount = raw_in_pktcount + in_cnt,
			raw_out_pktlen = raw_out_pktlen + out_len,
			raw_out_pktcount = raw_out_pktcount + out_cnt,
			flow_count = flow_count + 1
		where
			logday = day and
			srcip = saddr and dstip = daddr and
			l4_dport = port and ip_protocol = proto and
			(srcid = src_id or (srcid IS NULL and src_id IS NULL)) and
			(dstid = dst_id or (dstid IS NULL and dst_id IS NULL)) and
			afc_proto = appid
		returning
			flow_count
	) insert into accounting (
		srcip, srcid, dstip, dstid, ip_protocol, l4_dport, afc_proto,
		raw_in_pktlen, raw_in_pktcount, raw_out_pktlen, raw_out_pktcount,
		logday, flow_duration, flow_count
	) select
		saddr, src_id, daddr, dst_id, proto, port, appid,
		in_len, in_cnt, out_len, out_cnt,
		day, duration, 1
	where not exists (select 1 from upsert);

	-- We try to update the entry with this ip which is currently established.
	-- We therefore assume that a virtual IP is only used by one connection.
	-- If this update does not work for whatever reason, we do nothing
	perform enable_accounting from vpn_options where enable_accounting = true;
	if found then
		update vpn set
			pktlen_in  = pktlen_in + out_len,
			pktlen_out = pktlen_out + in_len
		where
			(virt_ip = saddr or src_ip = saddr) and
			status  = 0; -- connected
		update vpn set
			pktlen_in  = pktlen_in + in_len,
			pktlen_out = pktlen_out + out_len
		where
			(virt_ip = daddr or src_ip = daddr) and
			status  = 0; -- connected
	end if;
end;
$$;


ALTER FUNCTION public.ins_accounting(saddr inet, daddr inet, proto integer, port integer, afc integer, in_len bigint, in_cnt bigint, out_len bigint, out_cnt bigint, flow_start integer, duration integer) OWNER TO reporting;

--
-- Name: ins_appctrl(date, inet, inet, integer, text, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_appctrl(day date, saddr inet, daddr inet, appno integer, act text, cnt bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	src_id	integer;
	dst_id	integer;
begin
	src_id = 0;
	dst_id = 0;

	select into src_id id from endpoint_lookup where ip = saddr;
	select into dst_id id from endpoint_lookup where ip = daddr;

	with upsert (pktcount) as (
		update appcontrol set
			count = count + cnt
		where
			logday = day and
			srcip = saddr and
			(srcid = src_id or (srcid is null and src_id is null)) and
			dstip = daddr and
			(dstid = dst_id or (dstid is null and dst_id is null)) and
			appid = appno and
			action = act
		returning count
	) insert into appcontrol (
		logday, srcip, srcid, dstip, dstid, appid, action, count
	) select
		day, saddr, src_id, daddr, dst_id, appno, act, cnt
	where not exists (select * from upsert);
end;
$$;


ALTER FUNCTION public.ins_appctrl(day date, saddr inet, daddr inet, appno integer, act text, cnt bigint) OWNER TO reporting;

--
-- Name: ins_auth(timestamp without time zone, text, text, text, inet); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_auth(ts timestamp without time zone, auth_user text, auth_facility text, auth_result text, ip inet) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	day		date;
begin
	day = date_trunc('day', ts);

	insert into auth (
		logtime, logday, srcip, username, facility, authresult
	) values (
		date_trunc('seconds', ts), day, ip,
		auth_user, auth_facility, auth_result
	);
end;
$$;


ALTER FUNCTION public.ins_auth(ts timestamp without time zone, auth_user text, auth_facility text, auth_result text, ip inet) OWNER TO reporting;

--
-- Name: ins_ips(date, integer, integer, inet, inet, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_ips(day date, ipsrule integer, ipsgroup integer, src inet, dst inet, alerts bigint, drops bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	with upsert (cnt) as (
		update ipscount set
			count = count + drops + alerts
		where
			groupid = ipsgroup and ruleid = ipsrule
		returning count
	) insert into ipscount (
		groupid, ruleid, count
	) select
		ipsgroup, ipsrule, alerts + drops
	where not exists (select 1 from upsert);

	with upsert (drops) as (
		update ips set
			alert_packets = alert_packets + alerts,
			drop_packets = drop_packets + drops
		where
			logday = day and
			srcip = src and dstip = dst and
			groupid = ipsgroup and ruleid = ipsrule
		returning drop_packets
	) insert into ips (
		logday, srcip, dstip, groupid, ruleid, alert_packets, drop_packets
	) select
		day, src, dst, ipsgroup, ipsrule, alerts, drops
	where not exists (select 1 from upsert);
end;
$$;


ALTER FUNCTION public.ins_ips(day date, ipsrule integer, ipsgroup integer, src inet, dst inet, alerts bigint, drops bigint) OWNER TO reporting;

--
-- Name: ins_mailsec(date, inet, text, text, inet, text, text, text, integer, text, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_mailsec(day date, src inet, srcuser text, srcdomain text, dst inet, dstuser text, dstdomain text, mproto text, mtype integer, mreason text, count bigint, size bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	suid	bigint;
	sdid	bigint;
	duid	bigint;
	ddid	bigint;
begin
	suid = get_mailaddrid(srcuser, srcdomain);
	sdid = get_maildomainid(srcdomain);
	duid = get_mailaddrid(dstuser, dstdomain);
	ddid = get_maildomainid(dstdomain);

	with upsert (mailcnt) as (
		update mailsec set
			mailcount = mailcount + count,
			mailsize = mailsize + size
		where
			logday = day and
			srcip = src and srcaddrid = suid and srcdomainid = sdid and
			dstip = dst and dstaddrid = duid and dstdomainid = ddid and
			proto = mproto and type = mtype and reason = mreason
		returning mailcount
	) insert into mailsec (
		logday,
		srcip, srcaddrid, srcdomainid, dstip, dstaddrid, dstdomainid,
		proto, type, reason, mailcount, mailsize
	) select
		day, src, suid, sdid, dst, duid, ddid,
		mproto, mtype, mreason, count, size
	where not exists (select 1 from upsert);
end;
$$;


ALTER FUNCTION public.ins_mailsec(day date, src inet, srcuser text, srcdomain text, dst inet, dstuser text, dstdomain text, mproto text, mtype integer, mreason text, count bigint, size bigint) OWNER TO reporting;

--
-- Name: ins_pfilter(date, inet, inet, text, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_pfilter(day date, src inet, dst inet, service text, count bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	src_id		integer;
	dst_id		integer;
begin
	src_id = 0;
	dst_id = 0;

	SELECT INTO src_id id FROM endpoint_lookup WHERE ip = src;
	SELECT INTO dst_id id FROM endpoint_lookup WHERE ip = dst;

	with upsert (pktcount) as (
		update pfilter set
			packets = packets + count
		where
			logday = day and
			srcip = src and
			(srcid = src_id or (srcid IS NULL and src_id IS NULL)) and
			dstip = dst and
			(dstid = dst_id or (dstid IS NULL and dst_id IS NULL)) and
			svc = service
		returning count
	) insert into pfilter (
		logday, srcip, srcid, dstip, dstid, svc, packets
	) select
		day, src, src_id, dst, dst_id, service, count
	where not exists (select 1 from upsert);
end;
$$;


ALTER FUNCTION public.ins_pfilter(day date, src inet, dst inet, service text, count bigint) OWNER TO reporting;

--
-- Name: ins_vpn(integer, timestamp without time zone, timestamp without time zone, timestamp without time zone, text, text, inet, inet); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_vpn(stat integer, ts timestamp without time zone, lin timestamp without time zone, lout timestamp without time zone, name text, srv text, sip inet, vip inet) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare 
	day 		date;
begin
	day = date_trunc('day', ts);

	-- if status is 'complete', check, if we have a pending entry and update it
	-- if there is no such entry, or if we have another status, simply insert
	if stat = 1 then -- complete
		update vpn set 
			logouttime = lout,
			status = stat
		where
			logintime = lin and
			username = name and
			status = 0 and 
			service = srv;
	end if;

	if not found or stat != 1 then 
		insert into vpn ( status, logintime, logouttime, logday, username, service, src_ip, virt_ip, pktlen_in, pktlen_out )
			values      ( stat,   lin,       lout,       day,    name,     srv,     sip,    vip,     0,         0    );
	end if;
end;
$$;


ALTER FUNCTION public.ins_vpn(stat integer, ts timestamp without time zone, lin timestamp without time zone, lout timestamp without time zone, name text, srv text, sip inet, vip inet) OWNER TO reporting;

--
-- Name: ins_waf(date, inet, inet, integer, text, integer, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_waf(day date, cip inet, sip inet, sport integer, host text, rcode integer, req bigint, byteout bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	with upsert (traf) as (
		update waf set
			requests = requests + req,
			transfer = transfer + byteout
		where
			logday = day and
			client = cip and server = sip and port = sport and
			vhost = host and status = rcode
		returning transfer
	) insert into waf (
		logday, client, server, port, vhost, status, requests, transfer
	) select
		day, cip, sip, sport, host, rcode, req, byteout
	where not exists (select * from upsert);
end;
$$;


ALTER FUNCTION public.ins_waf(day date, cip inet, sip inet, sport integer, host text, rcode integer, req bigint, byteout bigint) OWNER TO reporting;

--
-- Name: ins_waf_event(timestamp without time zone, text, inet, inet, integer, text, text, integer, integer, text, text, text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_waf_event(ts timestamp without time zone, req text, cip inet, sip inet, sport integer, host text, reqpath text, rcode integer, rule integer, grp text, log text, lsev text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	day		date;
begin
	day = date_trunc('day', ts);

	insert into waf_events (
		logday, reqtime, request, client, server, port, vhost, path,
		status, ruleid, rulegroup, msg, severity
	) values (
		day, ts, req, cip, sip, sport, host, reqpath,
		rcode, rule, grp, log, lsev
	);
end;
$$;


ALTER FUNCTION public.ins_waf_event(ts timestamp without time zone, req text, cip inet, sip inet, sport integer, host text, reqpath text, rcode integer, rule integer, grp text, log text, lsev text) OWNER TO reporting;

--
-- Name: ins_websecsearches(date, text, inet, text, text, text, text, text, text[], bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_websecsearches(day date, requser text, reqclient inet, reqproto text, reqhost text, reqengine text, reqterm text, reqaction text, departments text[], reqs bigint, bytes bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	uid		bigint;
	req		bigint;
begin
	uid := get_webuserid(requser);

	with upsert (reqno) as (
		update websec_searches set
			requests = requests + reqs,
			transfer = transfer + bytes
		where
			logday = day and userid = uid and
			protocol = reqproto and host = reqhost and engine = reqengine and
			term = reqterm and action = reqaction
		returning _rowno
	), insweb (reqno) as (
		insert into websec_searches (
			logday, userid, protocol, host, engine, term, action,
			requests, transfer
		) select
			day, uid, reqproto, reqhost, reqengine, reqterm, reqaction,
			reqs, bytes
		where not exists (select * from upsert)
		returning _rowno
	) insert into websec_reqdpt (
		func, request, dptid
	) select
		'searches', insweb.reqno, get_departmentid(unnest(departments))
	from
		insweb;
end;
$$;


ALTER FUNCTION public.ins_websecsearches(day date, requser text, reqclient inet, reqproto text, reqhost text, reqengine text, reqterm text, reqaction text, departments text[], reqs bigint, bytes bigint) OWNER TO reporting;

--
-- Name: ins_websecsessions(date, text, inet, text[], bigint, bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_websecsessions(day date, requser text, reqclient inet, departments text[], seconds bigint, reqs bigint, reqpages bigint, bytes bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	uid		bigint;
	req		bigint;
	dur		interval;
begin
	uid := get_webuserid(requser);
	dur := seconds * interval '1 second';

	with upsert (reqno) as (
		update websec_sessions set
			requests = requests + reqs,
			pages = pages + reqpages,
			transfer = transfer + bytes,
			duration = duration + dur
		where
			logday = day and userid = uid
		returning _rowno
	), insweb (reqno) as (
		insert into websec_sessions (
			logday, userid, duration, requests, pages, transfer
		) select
			day, uid, dur, reqs, reqpages, bytes
		where not exists (select * from upsert)
		returning _rowno
	) insert into websec_reqdpt (
		func, request, dptid
	) select
		'sessions', insweb.reqno, get_departmentid(unnest(departments))
	from
		insweb;
end;
$$;


ALTER FUNCTION public.ins_websecsessions(day date, requser text, reqclient inet, departments text[], seconds bigint, reqs bigint, reqpages bigint, bytes bigint) OWNER TO reporting;

--
-- Name: ins_websecurity(date, text, inet, text, text, text, text, text, text, text, integer[], text[], bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_websecurity(day date, requser text, reqclient inet, reqproto text, reqdomain text, reqsite text, reqpath text, reqaction text, reqreason text, reqinfo text, categories integer[], departments text[], reqs bigint, reqpages bigint, bytes bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	uid		bigint;
	cat		integer;
	req		bigint;
begin
	uid := get_webuserid(requser);

	with upsert (reqno) as (
		update websecurity set
			requests = requests + reqs,
			pages = pages + reqpages,
			transfer = transfer + bytes
		where
			logday = day and userid = uid and
			protocol = reqproto and domain = reqdomain and site = reqsite and
			path = reqpath and action = reqaction and reason = reqreason and
			info = reqinfo
		returning _rowno
	), insweb (reqno) as (
		insert into websecurity (
			logday, userid, protocol, domain, site, path,
			action, reason, info, requests, pages, transfer
		) select
			day, uid, reqproto, reqdomain, reqsite, reqpath,
			reqaction, reqreason, reqinfo, reqs, reqpages, bytes
		where not exists (select 1 from upsert)
		returning _rowno
	), inscat (reqno) as (
		insert into websec_reqcat (
			request, category
		) select
			insweb.reqno, unnest(categories)
		from
			insweb
		returning request
	) insert into websec_reqdpt (
		func, request, dptid
	) select
		'requests', insweb.reqno, get_departmentid(unnest(departments))
	from
		insweb;
end;
$$;


ALTER FUNCTION public.ins_websecurity(day date, requser text, reqclient inet, reqproto text, reqdomain text, reqsite text, reqpath text, reqaction text, reqreason text, reqinfo text, categories integer[], departments text[], reqs bigint, reqpages bigint, bytes bigint) OWNER TO reporting;

--
-- Name: ins_websecvisits(date, text, inet, text, text, text, text[], bigint, bigint, bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION ins_websecvisits(day date, requser text, reqclient inet, reqproto text, reqdomain text, reqsite text, departments text[], seconds bigint, reqs bigint, reqpages bigint, bytes bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
	uid		bigint;
	req		bigint;
	dur		interval;
begin
	uid := get_webuserid(requser);
	dur := seconds * interval '1 second';

	with upsert (reqno) as (
		update websec_visits set
			requests = requests + reqs,
			pages = pages + reqpages,
			transfer = transfer + bytes,
			duration = duration + dur
		where
			logday = day and userid = uid and
			protocol = reqproto and domain = reqdomain and site = reqsite
		returning _rowno
	), insweb (reqno) as (
		insert into websec_visits (
			logday, userid, protocol, domain, site,
			requests, pages, transfer, duration
		) select
			day, uid, reqproto, reqdomain, reqsite, reqs, reqpages, bytes, dur
		where not exists (select * from upsert)
		returning _rowno
	) insert into websec_reqdpt (
		func, request, dptid
	) select
		'visits', insweb.reqno, get_departmentid(unnest(departments))
	from
		insweb;
end;
$$;


ALTER FUNCTION public.ins_websecvisits(day date, requser text, reqclient inet, reqproto text, reqdomain text, reqsite text, departments text[], seconds bigint, reqs bigint, reqpages bigint, bytes bigint) OWNER TO reporting;

--
-- Name: ip2country(inet); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION ip2country(inet) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_ip2country';


ALTER FUNCTION public.ip2country(inet) OWNER TO postgres;

--
-- Name: pct(bigint, bigint); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION pct(value bigint, base bigint) RETURNS double precision
    LANGUAGE plpgsql
    AS $$
begin
	return case when base <> 0 then 100.0 * value / base else 100 end;
end;
$$;


ALTER FUNCTION public.pct(value bigint, base bigint) OWNER TO reporting;

--
-- Name: resolve_app(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION resolve_app(integer) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_resolve_app';


ALTER FUNCTION public.resolve_app(integer) OWNER TO postgres;

--
-- Name: resolve_group(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION resolve_group(integer) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_resolve_group';


ALTER FUNCTION public.resolve_group(integer) OWNER TO postgres;

--
-- Name: resolve_protocol(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION resolve_protocol(integer) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_resolve_protocol';


ALTER FUNCTION public.resolve_protocol(integer) OWNER TO postgres;

--
-- Name: resolve_service(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION resolve_service(text) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_resolve_service';


ALTER FUNCTION public.resolve_service(text) OWNER TO postgres;

--
-- Name: seconds_to_hms(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION seconds_to_hms(bigint) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_seconds_to_hms';


ALTER FUNCTION public.seconds_to_hms(bigint) OWNER TO postgres;

--
-- Name: set_vpn_accounting(boolean); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION set_vpn_accounting(enable boolean) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	if enable then
		insert into vpn_options values (TRUE);
	else
		delete from vpn_options;
	end if;
end;
$$;


ALTER FUNCTION public.set_vpn_accounting(enable boolean) OWNER TO reporting;

--
-- Name: transform_common(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transform_common(bigint) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_transform_common';


ALTER FUNCTION public.transform_common(bigint) OWNER TO postgres;

--
-- Name: transform_iec(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transform_iec(bigint, integer) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_transform_iec';


ALTER FUNCTION public.transform_iec(bigint, integer) OWNER TO postgres;

--
-- Name: transform_si(bigint, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION transform_si(bigint, integer) RETURNS text
    LANGUAGE c
    AS '$libdir/astaro_functions', 'astaro_transform_si';


ALTER FUNCTION public.transform_si(bigint, integer) OWNER TO postgres;

--
-- Name: upd_webseccat(integer, text); Type: FUNCTION; Schema: public; Owner: reporting
--

CREATE FUNCTION upd_webseccat(catno integer, catname text) RETURNS void
    LANGUAGE plpgsql
    AS $$
begin
	with upsert (num) as (
		update websec_categories set
			name = catname
		where
			category = catno
		returning category
	) insert into websec_categories (
		category, name
	) select
		catno, catname
	where not exists (select 1 from upsert);
end
$$;


ALTER FUNCTION public.upd_webseccat(catno integer, catname text) OWNER TO reporting;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: mailsec; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE mailsec (
    logday date,
    srcip inet,
    srcaddrid bigint,
    srcdomainid bigint,
    dstip inet,
    dstaddrid bigint,
    dstdomainid bigint,
    proto text,
    type integer,
    reason text,
    mailcount bigint,
    mailsize bigint
);


ALTER TABLE public.mailsec OWNER TO reporting;

--
-- Name: _mailsec_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW _mailsec_anon AS
    SELECT mailsec.logday, mailsec.srcip, mailsec.srcaddrid AS srcuser, mailsec.srcdomainid AS srcdomain, mailsec.dstip, mailsec.dstaddrid AS dstuser, mailsec.dstdomainid AS dstdomain, mailsec.proto, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec;


ALTER TABLE public._mailsec_anon OWNER TO reporting;

--
-- Name: accounting; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE accounting (
    srcip inet,
    srcid integer,
    dstip inet,
    dstid integer,
    ip_protocol integer,
    l4_dport integer,
    afc_proto integer,
    raw_in_pktlen bigint,
    raw_in_pktcount bigint,
    raw_out_pktlen bigint,
    raw_out_pktcount bigint,
    logday date,
    flow_duration integer,
    flow_count bigint DEFAULT 1
);


ALTER TABLE public.accounting OWNER TO reporting;

--
-- Name: endpoint_users; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE endpoint_users (
    id integer NOT NULL,
    name text
);


ALTER TABLE public.endpoint_users OWNER TO reporting;

--
-- Name: accounting_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW accounting_data AS
    SELECT accounting.logday, accounting.srcip, accounting.srcid, accounting.dstip, accounting.dstid, accounting.ip_protocol, accounting.l4_dport, accounting.afc_proto, resolve_app(accounting.afc_proto) AS application, resolve_group(accounting.afc_proto) AS appgroup, accounting.raw_in_pktlen, accounting.raw_in_pktcount, accounting.raw_out_pktlen, accounting.raw_out_pktcount, accounting.flow_duration, accounting.flow_count, endpoint_src.name AS srchost, endpoint_dst.name AS dsthost FROM ((accounting LEFT JOIN endpoint_users endpoint_src ON ((accounting.srcid = endpoint_src.id))) LEFT JOIN endpoint_users endpoint_dst ON ((accounting.dstid = endpoint_dst.id)));


ALTER TABLE public.accounting_data OWNER TO reporting;

--
-- Name: appcontrol; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE appcontrol (
    logday date,
    srcip inet,
    srcid integer,
    dstip inet,
    dstid integer,
    appid integer,
    action text,
    count bigint
);


ALTER TABLE public.appcontrol OWNER TO reporting;

--
-- Name: appcontrol_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW appcontrol_data AS
    SELECT appcontrol.logday, appcontrol.srcip, appcontrol.srcid, appcontrol.dstip, appcontrol.dstid, appcontrol.appid, resolve_app(appcontrol.appid) AS application, resolve_group(appcontrol.appid) AS appgroup, appcontrol.action, appcontrol.count, endpoint_src.name AS srchost, endpoint_dst.name AS dsthost FROM ((appcontrol LEFT JOIN endpoint_users endpoint_src ON ((appcontrol.srcid = endpoint_src.id))) LEFT JOIN endpoint_users endpoint_dst ON ((appcontrol.dstid = endpoint_dst.id)));


ALTER TABLE public.appcontrol_data OWNER TO reporting;

--
-- Name: auth; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE auth (
    logtime timestamp without time zone,
    logday date,
    srcip inet,
    username text,
    facility text,
    authresult text
);


ALTER TABLE public.auth OWNER TO reporting;

--
-- Name: confd_nodes; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE confd_nodes (
    sid text,
    "time" timestamp without time zone,
    node text,
    value text,
    oldvalue text
);


ALTER TABLE public.confd_nodes OWNER TO reporting;

--
-- Name: confd_objects; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE confd_objects (
    sid text,
    "time" timestamp without time zone,
    class text,
    type text,
    ref text,
    objname text,
    action text,
    attrs text[]
);


ALTER TABLE public.confd_objects OWNER TO reporting;

--
-- Name: confd_sessions; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE confd_sessions (
    sid text,
    facility text,
    srcip inet,
    username text,
    "time" timestamp without time zone,
    endtime timestamp without time zone,
    state text
);


ALTER TABLE public.confd_sessions OWNER TO reporting;

--
-- Name: dpt_lookup; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE dpt_lookup (
    name text,
    _rowno bigint NOT NULL
);


ALTER TABLE public.dpt_lookup OWNER TO reporting;

--
-- Name: dpt_lookup__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE dpt_lookup__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dpt_lookup__rowno_seq OWNER TO reporting;

--
-- Name: dpt_lookup__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE dpt_lookup__rowno_seq OWNED BY dpt_lookup._rowno;


--
-- Name: endpoint_lookup; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE endpoint_lookup (
    ip inet NOT NULL,
    id integer
);


ALTER TABLE public.endpoint_lookup OWNER TO reporting;

--
-- Name: endpoint_users_id_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE endpoint_users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.endpoint_users_id_seq OWNER TO reporting;

--
-- Name: endpoint_users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE endpoint_users_id_seq OWNED BY endpoint_users.id;


--
-- Name: ips; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE ips (
    logday date,
    srcip inet,
    dstip inet,
    groupid integer,
    ruleid integer,
    alert_packets bigint,
    drop_packets bigint
);


ALTER TABLE public.ips OWNER TO reporting;

--
-- Name: ipscount; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE ipscount (
    groupid integer NOT NULL,
    ruleid integer NOT NULL,
    count integer
);


ALTER TABLE public.ipscount OWNER TO reporting;

--
-- Name: mailanon_addrs; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE mailanon_addrs (
    lpart text,
    domain bigint,
    _rowno bigint NOT NULL
);


ALTER TABLE public.mailanon_addrs OWNER TO reporting;

--
-- Name: mailanon_addrs__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE mailanon_addrs__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mailanon_addrs__rowno_seq OWNER TO reporting;

--
-- Name: mailanon_addrs__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE mailanon_addrs__rowno_seq OWNED BY mailanon_addrs._rowno;


--
-- Name: mailanon_domains; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE mailanon_domains (
    domain text,
    _rowno bigint NOT NULL
);


ALTER TABLE public.mailanon_domains OWNER TO reporting;

--
-- Name: mailanon_domains__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE mailanon_domains__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mailanon_domains__rowno_seq OWNER TO reporting;

--
-- Name: mailanon_domains__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE mailanon_domains__rowno_seq OWNED BY mailanon_domains._rowno;


--
-- Name: mailsec_addresses; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_addresses AS
    SELECT a.logday, b.lpart AS localpart, c.domain, a.type, a.reason, a.mailcount, a.mailsize FROM mailsec a, mailanon_addrs b, mailanon_domains c WHERE ((a.dstaddrid = b._rowno) AND (a.dstdomainid = c._rowno)) UNION ALL SELECT a.logday, b.lpart AS localpart, c.domain, a.type, a.reason, a.mailcount, a.mailsize FROM mailsec a, mailanon_addrs b, mailanon_domains c WHERE ((a.srcaddrid = b._rowno) AND (a.srcdomainid = c._rowno));


ALTER TABLE public.mailsec_addresses OWNER TO reporting;

--
-- Name: mailsec_addrids; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_addrids AS
    SELECT mailsec.logday, ('User_'::text || mailsec.dstaddrid) AS localpart, ('Domain_'::text || mailsec.dstdomainid) AS domain, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec UNION ALL SELECT mailsec.logday, ('User_'::text || mailsec.srcaddrid) AS localpart, ('Domain_'::text || mailsec.srcdomainid) AS domain, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec;


ALTER TABLE public.mailsec_addrids OWNER TO reporting;

--
-- Name: mailsec_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_anon AS
    SELECT mailsec.logday, mailsec.srcip, ('User_'::text || mailsec.srcaddrid) AS srcuser, ('Domain_'::text || mailsec.srcdomainid) AS srcdomain, mailsec.dstip, ('User_'::text || mailsec.dstaddrid) AS dstuser, ('Domain_'::text || mailsec.dstdomainid) AS dstdomain, mailsec.proto, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec;


ALTER TABLE public.mailsec_anon OWNER TO reporting;

--
-- Name: mailsec_contactids; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_contactids AS
    SELECT mailsec.logday, ('User_'::text || mailsec.dstaddrid) AS localpart, ('Domain_'::text || mailsec.dstdomainid) AS domain, ('User_'::text || mailsec.srcaddrid) AS peerlocal, ('Domain_'::text || mailsec.srcdomainid) AS peerdomain, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec UNION ALL SELECT mailsec.logday, ('User_'::text || mailsec.srcaddrid) AS localpart, ('Domain_'::text || mailsec.srcdomainid) AS domain, ('User_'::text || mailsec.dstaddrid) AS peerlocal, ('Domain_'::text || mailsec.dstdomainid) AS peerdomain, mailsec.type, mailsec.reason, mailsec.mailcount, mailsec.mailsize FROM mailsec;


ALTER TABLE public.mailsec_contactids OWNER TO reporting;

--
-- Name: mailsec_contacts; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_contacts AS
    SELECT a.logday, b.lpart AS localpart, c.domain, d.lpart AS peerlocal, e.domain AS peerdomain, a.type, a.reason, a.mailcount, a.mailsize FROM mailsec a, mailanon_addrs b, mailanon_domains c, mailanon_addrs d, mailanon_domains e WHERE ((((a.srcaddrid = b._rowno) AND (a.srcdomainid = c._rowno)) AND (a.dstaddrid = d._rowno)) AND (a.dstdomainid = e._rowno)) UNION ALL SELECT a.logday, b.lpart AS localpart, c.domain, d.lpart AS peerlocal, e.domain AS peerdomain, a.type, a.reason, a.mailcount, a.mailsize FROM mailsec a, mailanon_addrs b, mailanon_domains c, mailanon_addrs d, mailanon_domains e WHERE ((((a.dstaddrid = b._rowno) AND (a.dstdomainid = c._rowno)) AND (a.srcaddrid = d._rowno)) AND (a.srcdomainid = e._rowno));


ALTER TABLE public.mailsec_contacts OWNER TO reporting;

--
-- Name: mailsec_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW mailsec_data AS
    SELECT a.logday, a.srcip, b.lpart AS srcuser, c.domain AS srcdomain, a.dstip, d.lpart AS dstuser, e.domain AS dstdomain, a.proto, a.type, a.reason, a.mailcount, a.mailsize FROM mailsec a, mailanon_addrs b, mailanon_domains c, mailanon_addrs d, mailanon_domains e WHERE ((((a.srcaddrid = b._rowno) AND (a.srcdomainid = c._rowno)) AND (a.dstaddrid = d._rowno)) AND (a.dstdomainid = e._rowno));


ALTER TABLE public.mailsec_data OWNER TO reporting;

--
-- Name: pfilter; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE pfilter (
    logday date,
    srcip inet,
    srcid integer,
    dstip inet,
    dstid integer,
    svc text,
    packets bigint
);


ALTER TABLE public.pfilter OWNER TO reporting;

--
-- Name: pfilter_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW pfilter_data AS
    SELECT pfilter.logday, pfilter.srcip, pfilter.srcid AS srscid, pfilter.dstip, pfilter.dstid, pfilter.svc, pfilter.packets, endpoint_src.name AS srchost, endpoint_dst.name AS dsthost FROM ((pfilter LEFT JOIN endpoint_users endpoint_src ON ((pfilter.srcid = endpoint_src.id))) LEFT JOIN endpoint_users endpoint_dst ON ((pfilter.dstid = endpoint_dst.id)));


ALTER TABLE public.pfilter_data OWNER TO reporting;

--
-- Name: vpn; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE vpn (
    status integer,
    logintime timestamp without time zone,
    logouttime timestamp without time zone,
    logday date,
    username text,
    service text,
    src_ip inet,
    virt_ip inet,
    pktlen_in bigint,
    pktlen_out bigint
);


ALTER TABLE public.vpn OWNER TO reporting;

--
-- Name: vpn_options; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE vpn_options (
    enable_accounting boolean
);


ALTER TABLE public.vpn_options OWNER TO reporting;

--
-- Name: waf; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE waf (
    logday date,
    client inet,
    server inet,
    port integer,
    vhost text,
    status integer,
    requests bigint,
    transfer bigint
);


ALTER TABLE public.waf OWNER TO reporting;

--
-- Name: waf_events; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE waf_events (
    logday date,
    reqtime timestamp without time zone,
    request text,
    client inet,
    server inet,
    port integer,
    vhost text,
    path text,
    status integer,
    ruleid integer,
    rulegroup text,
    msg text,
    severity text
);


ALTER TABLE public.waf_events OWNER TO reporting;

--
-- Name: webanon_users; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE webanon_users (
    userid text,
    _rowno bigint NOT NULL
);


ALTER TABLE public.webanon_users OWNER TO reporting;

--
-- Name: webanon_users__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE webanon_users__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.webanon_users__rowno_seq OWNER TO reporting;

--
-- Name: webanon_users__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE webanon_users__rowno_seq OWNED BY webanon_users._rowno;


--
-- Name: websec_categories; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_categories (
    category integer NOT NULL,
    name text
);


ALTER TABLE public.websec_categories OWNER TO reporting;

--
-- Name: websec_reqcat; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_reqcat (
    request bigint NOT NULL,
    category integer NOT NULL
);


ALTER TABLE public.websec_reqcat OWNER TO reporting;

--
-- Name: websec_reqcatnames; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websec_reqcatnames AS
    SELECT websec_reqcat.request, websec_reqcat.category AS catno, websec_categories.name AS category FROM (websec_reqcat JOIN websec_categories ON ((websec_reqcat.category = websec_categories.category)));


ALTER TABLE public.websec_reqcatnames OWNER TO reporting;

--
-- Name: websec_reqdpt; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_reqdpt (
    request bigint NOT NULL,
    func websec_function NOT NULL,
    dptid integer NOT NULL
);


ALTER TABLE public.websec_reqdpt OWNER TO reporting;

--
-- Name: websec_searches; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_searches (
    logday date,
    userid bigint,
    protocol text,
    host text,
    engine text,
    term text,
    action text,
    requests bigint,
    transfer bigint,
    _rowno bigint NOT NULL
);


ALTER TABLE public.websec_searches OWNER TO reporting;

--
-- Name: websec_searches__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE websec_searches__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.websec_searches__rowno_seq OWNER TO reporting;

--
-- Name: websec_searches__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE websec_searches__rowno_seq OWNED BY websec_searches._rowno;


--
-- Name: websec_sessions; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_sessions (
    logday date,
    userid bigint,
    duration interval,
    requests bigint,
    pages bigint,
    transfer bigint,
    _rowno bigint NOT NULL
);


ALTER TABLE public.websec_sessions OWNER TO reporting;

--
-- Name: websec_sessions__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE websec_sessions__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.websec_sessions__rowno_seq OWNER TO reporting;

--
-- Name: websec_sessions__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE websec_sessions__rowno_seq OWNED BY websec_sessions._rowno;


--
-- Name: websec_visits; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websec_visits (
    logday date,
    userid bigint,
    protocol text,
    domain text,
    site text,
    duration interval,
    requests bigint,
    pages bigint,
    transfer bigint,
    _rowno bigint NOT NULL
);


ALTER TABLE public.websec_visits OWNER TO reporting;

--
-- Name: websec_visits__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE websec_visits__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.websec_visits__rowno_seq OWNER TO reporting;

--
-- Name: websec_visits__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE websec_visits__rowno_seq OWNED BY websec_visits._rowno;


--
-- Name: websecsearches_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecsearches_anon AS
    SELECT websec_searches.logday, ('User_'::text || websec_searches.userid) AS clientusername, dptlookup.departments, ((websec_searches.protocol || '://'::text) || websec_searches.host) AS url, websec_searches.protocol, websec_searches.host, websec_searches.engine, websec_searches.term, websec_searches.requests, websec_searches.transfer FROM (websec_searches LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'searches'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_searches._rowno = dptlookup.request)));


ALTER TABLE public.websecsearches_anon OWNER TO reporting;

--
-- Name: websecsearches_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecsearches_data AS
    SELECT websec_searches.logday, webanon_users.userid AS clientusername, dptlookup.departments, ((websec_searches.protocol || '://'::text) || websec_searches.host) AS url, websec_searches.protocol, websec_searches.host, websec_searches.engine, websec_searches.term, websec_searches.requests, websec_searches.transfer FROM ((websec_searches JOIN webanon_users ON ((webanon_users._rowno = websec_searches.userid))) LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'searches'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_searches._rowno = dptlookup.request)));


ALTER TABLE public.websecsearches_data OWNER TO reporting;

--
-- Name: websecsessions_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecsessions_anon AS
    SELECT websec_sessions.logday, ('User_'::text || websec_sessions.userid) AS clientusername, dptlookup.departments, websec_sessions.duration, websec_sessions.requests, websec_sessions.pages, websec_sessions.transfer FROM (websec_sessions LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'sessions'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_sessions._rowno = dptlookup.request)));


ALTER TABLE public.websecsessions_anon OWNER TO reporting;

--
-- Name: websecsessions_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecsessions_data AS
    SELECT websec_sessions.logday, webanon_users.userid AS clientusername, dptlookup.departments, websec_sessions.duration, websec_sessions.requests, websec_sessions.pages, websec_sessions.transfer FROM ((websec_sessions JOIN webanon_users ON ((webanon_users._rowno = websec_sessions.userid))) LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'sessions'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_sessions._rowno = dptlookup.request)));


ALTER TABLE public.websecsessions_data OWNER TO reporting;

--
-- Name: websecurity; Type: TABLE; Schema: public; Owner: reporting; Tablespace: 
--

CREATE TABLE websecurity (
    logday date,
    userid bigint,
    protocol text,
    domain text,
    site text,
    path text,
    action text,
    reason text,
    info text,
    requests bigint,
    pages bigint,
    transfer bigint,
    _rowno bigint NOT NULL
);


ALTER TABLE public.websecurity OWNER TO reporting;

--
-- Name: websecurity__rowno_seq; Type: SEQUENCE; Schema: public; Owner: reporting
--

CREATE SEQUENCE websecurity__rowno_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.websecurity__rowno_seq OWNER TO reporting;

--
-- Name: websecurity__rowno_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: reporting
--

ALTER SEQUENCE websecurity__rowno_seq OWNED BY websecurity._rowno;


--
-- Name: websecurity_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecurity_anon AS
    SELECT websecurity.logday, ('User_'::text || websecurity.userid) AS clientusername, dptlookup.departments, websecurity.protocol, websecurity.domain, websecurity.site, websecurity.path, (((websecurity.protocol || '://'::text) || websecurity.domain) || websecurity.path) AS url, categorization.cats AS categories, websecurity.action, websecurity.reason, websecurity.info, websecurity.requests, websecurity.pages, websecurity.transfer FROM ((websecurity LEFT JOIN (SELECT websec_reqcat.request, array_agg(websec_categories.name) AS cats FROM (websec_reqcat JOIN websec_categories ON ((websec_reqcat.category = websec_categories.category))) GROUP BY websec_reqcat.request) categorization ON ((websecurity._rowno = categorization.request))) LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'requests'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websecurity._rowno = dptlookup.request)));


ALTER TABLE public.websecurity_anon OWNER TO reporting;

--
-- Name: websecurity_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecurity_data AS
    SELECT websecurity.logday, webanon_users.userid AS clientusername, dptlookup.departments, websecurity.protocol, websecurity.domain, websecurity.site, websecurity.path, (((websecurity.protocol || '://'::text) || websecurity.domain) || websecurity.path) AS url, categorization.cats AS categories, websecurity.action, websecurity.reason, websecurity.info, websecurity.requests, websecurity.pages, websecurity.transfer FROM (((websecurity LEFT JOIN (SELECT websec_reqcat.request, array_agg(websec_categories.name) AS cats FROM (websec_reqcat JOIN websec_categories ON ((websec_reqcat.category = websec_categories.category))) GROUP BY websec_reqcat.request) categorization ON ((websecurity._rowno = categorization.request))) LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'requests'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websecurity._rowno = dptlookup.request))) JOIN webanon_users ON ((webanon_users._rowno = websecurity.userid)));


ALTER TABLE public.websecurity_data OWNER TO reporting;

--
-- Name: websecvisits_anon; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecvisits_anon AS
    SELECT websec_visits.logday, ('User_'::text || websec_visits.userid) AS clientusername, dptlookup.departments, websec_visits.protocol, websec_visits.domain, websec_visits.site, ((websec_visits.protocol || '://'::text) || websec_visits.domain) AS url, websec_visits.duration, websec_visits.requests, websec_visits.pages, websec_visits.transfer FROM (websec_visits LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'visits'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_visits._rowno = dptlookup.request)));


ALTER TABLE public.websecvisits_anon OWNER TO reporting;

--
-- Name: websecvisits_data; Type: VIEW; Schema: public; Owner: reporting
--

CREATE VIEW websecvisits_data AS
    SELECT websec_visits.logday, webanon_users.userid AS clientusername, dptlookup.departments, websec_visits.protocol, websec_visits.domain, websec_visits.site, ((websec_visits.protocol || '://'::text) || websec_visits.domain) AS url, websec_visits.duration, websec_visits.requests, websec_visits.pages, websec_visits.transfer FROM ((websec_visits JOIN webanon_users ON ((webanon_users._rowno = websec_visits.userid))) LEFT JOIN (SELECT websec_reqdpt.request, array_agg(dpt_lookup.name) AS departments FROM (websec_reqdpt JOIN dpt_lookup ON ((dpt_lookup._rowno = websec_reqdpt.dptid))) WHERE (websec_reqdpt.func = 'visits'::websec_function) GROUP BY websec_reqdpt.request) dptlookup ON ((websec_visits._rowno = dptlookup.request)));


ALTER TABLE public.websecvisits_data OWNER TO reporting;

--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY dpt_lookup ALTER COLUMN _rowno SET DEFAULT nextval('dpt_lookup__rowno_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY endpoint_users ALTER COLUMN id SET DEFAULT nextval('endpoint_users_id_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY mailanon_addrs ALTER COLUMN _rowno SET DEFAULT nextval('mailanon_addrs__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY mailanon_domains ALTER COLUMN _rowno SET DEFAULT nextval('mailanon_domains__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY webanon_users ALTER COLUMN _rowno SET DEFAULT nextval('webanon_users__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY websec_searches ALTER COLUMN _rowno SET DEFAULT nextval('websec_searches__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY websec_sessions ALTER COLUMN _rowno SET DEFAULT nextval('websec_sessions__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY websec_visits ALTER COLUMN _rowno SET DEFAULT nextval('websec_visits__rowno_seq'::regclass);


--
-- Name: _rowno; Type: DEFAULT; Schema: public; Owner: reporting
--

ALTER TABLE ONLY websecurity ALTER COLUMN _rowno SET DEFAULT nextval('websecurity__rowno_seq'::regclass);


--
-- Data for Name: accounting; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY accounting (srcip, srcid, dstip, dstid, ip_protocol, l4_dport, afc_proto, raw_in_pktlen, raw_in_pktcount, raw_out_pktlen, raw_out_pktcount, logday, flow_duration, flow_count) FROM stdin;
192.168.1.2	\N	192.168.1.102	\N	6	4444	0	3175601	2703	637436	3144	2016-08-16	61	224
192.168.1.52	\N	192.168.1.102	\N	6	4433	0	17834	239	251207	311	2016-08-16	100	4
192.168.1.2	\N	192.168.1.102	\N	6	4422	0	2920723	4610	1364431	5374	2016-08-16	25	568
\.


--
-- Data for Name: appcontrol; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY appcontrol (logday, srcip, srcid, dstip, dstid, appid, action, count) FROM stdin;
\.


--
-- Data for Name: auth; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY auth (logtime, logday, srcip, username, facility, authresult) FROM stdin;
2016-08-16 11:34:52	2016-08-16	192.168.1.2	admin	webadmin	ok
2016-08-16 16:48:03	2016-08-16	192.168.1.2	admin	webadmin	ok
2016-08-16 16:49:38	2016-08-16	192.168.1.2	admin	acc	ok
\.


--
-- Data for Name: confd_nodes; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY confd_nodes (sid, "time", node, value, oldvalue) FROM stdin;
qMGXFRCzipvoSQCFEPHU	2016-08-16 11:32:30	customization->epp->last_updated	1471314723	0
MEbapKAhgugizHuBTcyF	2016-08-16 11:32:39	notifications->reboot_reason	{'0' => ''}	{}
spmJemIsQbpiALqYrhel	2016-08-16 11:33:23	customization->epp->last_updated	1471314796	1471314723
\.


--
-- Data for Name: confd_objects; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY confd_objects (sid, "time", class, type, ref, objname, action, attrs) FROM stdin;
qMGXFRCzipvoSQCFEPHU	2016-08-16 11:32:30	network	interface_network	REF_DefaultInternalNetwork	Internal (Network)	changed	{resolved,1,0,address6,::,"",netmask6,64,0}
qMGXFRCzipvoSQCFEPHU	2016-08-16 11:32:30	itfparams	primary	REF_ItfParamsDefaultInternal	Internal	changed	{resolved,1,0,address6,::,""}
qMGXFRCzipvoSQCFEPHU	2016-08-16 11:32:30	network	interface_broadcast	REF_DefaultInternalBroadcast	Internal (Broadcast)	changed	{resolved,1,0}
qMGXFRCzipvoSQCFEPHU	2016-08-16 11:32:30	network	interface_address	REF_DefaultInternalAddress	Internal (Address)	changed	{resolved,1,0,address6,::,""}
IkIotWUygqXIwxhCtyHF	2016-08-16 11:34:54	aaa	user	REF_DefaultSuperAdmin	admin	changed	{user_preferences,REF_UseWeb1,""}
IkIotWUygqXIwxhCtyHF	2016-08-16 11:34:54	user_preferences	webadmin	REF_UseWeb1	REF_UseWeb1	created	{}
\.


--
-- Data for Name: confd_sessions; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY confd_sessions (sid, facility, srcip, username, "time", endtime, state) FROM stdin;
qMGXFRCzipvoSQCFEPHU	system	127.0.0.1	mdw.plx	2016-08-16 11:32:30	2016-08-16 11:32:30	ended
MEbapKAhgugizHuBTcyF	system	127.0.0.1	notifier.plx	2016-08-16 11:32:39	2016-08-16 11:32:39	ended
spmJemIsQbpiALqYrhel	system	127.0.0.1	mdw.plx	2016-08-16 11:33:23	2016-08-16 11:33:23	ended
IkIotWUygqXIwxhCtyHF	webadmin	192.168.1.2	admin	2016-08-16 11:34:53	2016-08-16 11:39:56	ended
alztRqhWHVGCusoyrNtr	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
bGszzNvqDrbGdWiXxsvJ	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
GdQPXGmqfizWBiTSreCs	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
jBAKcHaaTNFQUrVzlUUq	system	127.0.0.1	unknown	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
joYjMBGpbSzUbNxMZaQB	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
JxYDAwgQWmIZNeVIljGc	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
LQwgPqmaRluEMHrVGwfX	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
MrJfIROvexdinkvonvdk	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
NWEONNEDxhANDKXXvyTa	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
QpCFkptRxtybiFZTSvhA	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
uUhkMyFZYkBEgDjBzWxj	system	127.0.0.1	websecreporter	2016-08-16 11:51:09	2016-08-16 11:51:09	timeout
BMSUvHqNYBsSwqnpViho	system	127.0.0.1	dns-resolver.plx	2016-08-16 16:25:13	2016-08-16 16:25:13	timeout
esvhLEkOkrgazNDArxXO	webadmin	192.168.1.2	admin	2016-08-16 16:48:04	2016-08-16 16:54:05	ended
\.


--
-- Data for Name: dpt_lookup; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY dpt_lookup (name, _rowno) FROM stdin;
\.


--
-- Name: dpt_lookup__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('dpt_lookup__rowno_seq', 1, false);


--
-- Data for Name: endpoint_lookup; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY endpoint_lookup (ip, id) FROM stdin;
\.


--
-- Data for Name: endpoint_users; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY endpoint_users (id, name) FROM stdin;
\.


--
-- Name: endpoint_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('endpoint_users_id_seq', 1, false);


--
-- Data for Name: ips; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY ips (logday, srcip, dstip, groupid, ruleid, alert_packets, drop_packets) FROM stdin;
\.


--
-- Data for Name: ipscount; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY ipscount (groupid, ruleid, count) FROM stdin;
\.


--
-- Data for Name: mailanon_addrs; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY mailanon_addrs (lpart, domain, _rowno) FROM stdin;
\.


--
-- Name: mailanon_addrs__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('mailanon_addrs__rowno_seq', 1, false);


--
-- Data for Name: mailanon_domains; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY mailanon_domains (domain, _rowno) FROM stdin;
\.


--
-- Name: mailanon_domains__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('mailanon_domains__rowno_seq', 1, false);


--
-- Data for Name: mailsec; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY mailsec (logday, srcip, srcaddrid, srcdomainid, dstip, dstaddrid, dstdomainid, proto, type, reason, mailcount, mailsize) FROM stdin;
\.


--
-- Data for Name: pfilter; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY pfilter (logday, srcip, srcid, dstip, dstid, svc, packets) FROM stdin;
2016-08-16	192.168.1.2	\N	192.168.1.102	\N	tcp/4444	6
\.


--
-- Data for Name: vpn; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY vpn (status, logintime, logouttime, logday, username, service, src_ip, virt_ip, pktlen_in, pktlen_out) FROM stdin;
\.


--
-- Data for Name: vpn_options; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY vpn_options (enable_accounting) FROM stdin;
\.


--
-- Data for Name: waf; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY waf (logday, client, server, port, vhost, status, requests, transfer) FROM stdin;
\.


--
-- Data for Name: waf_events; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY waf_events (logday, reqtime, request, client, server, port, vhost, path, status, ruleid, rulegroup, msg, severity) FROM stdin;
\.


--
-- Data for Name: webanon_users; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY webanon_users (userid, _rowno) FROM stdin;
\.


--
-- Name: webanon_users__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('webanon_users__rowno_seq', 1, false);


--
-- Data for Name: websec_categories; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_categories (category, name) FROM stdin;
101	Alcohol
147	Streaming Media
175	Software/Hardware
167	Messaging
190	Historical Revisionism
176	Illegal Software
159	Forum/Bulletin Boards
177	Content Server
125	Job Search
136	Online Shopping
106	Chat
141	Portal Sites
121	Hate/Discrimination
9999	Categorization Failed
164	Visual Search Engine
174	Fashion/Beauty
148	Shareware/Freeware
134	General News
115	Gambling
112	Entertainment
100	Art/Culture/Heritage
107	Computing / Internet
600	For Kids
145	Search Engines
183	Parked Domain
137	Provocative Attire
139	Politics/Opinion
158	Auctions/Classifieds
204	Malicious Downloads
191	Technical Information
120	Humor/Comics
192	Dating/Personals
603	Text/Spoken Only
102	Anonymizers
202	Illegal UK
199	Residential IP Addresses
602	Moderated
166	Gambling Related
193	Motor Vehicles
104	Anonymizing Utilities
153	Violence
601	History
144	Resource Sharing
185	Restaurants
122	Instant Messaging
157	Web Phone
178	Internet Services
162	Sexual Materials
184	Pharmacy
108	Public Information
203	Major Global Religions
163	Gruesome Content
114	Finance/Banking
172	Interactive Web Applications
160	Profanity
173	Information Security New
165	Technical/Business Forums
149	Pornography
152	Travel
111	Education/Reference
155	Weapons
181	Marketing/Merchandising
154	Web Ads
123	Stock Trading
201	Consumer Protection
119	Health
161	School Cheating Information
128	Mobile Phone
130	Malicious Sites
126	Information Security
109	Criminal Activities
179	Media Sharing
110	Drugs
156	Web Mail
200	Browser Exploits
127	Dating/Social Networking
132	Nudity
133	Non-Profit/Advocacy/NGO
171	Spam URLs
194	Professional Networking
188	Blogs/Wiki
170	Personal Network Storage
189	Digital Postcards
116	Games
198	Controversal Opinions
180	Incidental Nudity
105	Business
197	Web Meetings
186	Real Estate
138	P2P/File Sharing
117	Government/Military
195	Social Networking
187	Recreation/Hobbies
0	Uncategorized
143	Religion/Ideology
140	Personal Pages
150	Spyware/Adware
151	Tobacco
131	Usenet News
168	Game/Cartoon Violence
146	Sports
196	Text Translators
169	Phishing
205	Potiental Unwanted Programs
118	Hacking/Computer Crime
129	Media Downloads
124	Internet Radio/TV
113	Extreme
142	Remote Access
\.


--
-- Data for Name: websec_reqcat; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_reqcat (request, category) FROM stdin;
\.


--
-- Data for Name: websec_reqdpt; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_reqdpt (request, func, dptid) FROM stdin;
\.


--
-- Data for Name: websec_searches; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_searches (logday, userid, protocol, host, engine, term, action, requests, transfer, _rowno) FROM stdin;
\.


--
-- Name: websec_searches__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('websec_searches__rowno_seq', 1, false);


--
-- Data for Name: websec_sessions; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_sessions (logday, userid, duration, requests, pages, transfer, _rowno) FROM stdin;
\.


--
-- Name: websec_sessions__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('websec_sessions__rowno_seq', 1, false);


--
-- Data for Name: websec_visits; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websec_visits (logday, userid, protocol, domain, site, duration, requests, pages, transfer, _rowno) FROM stdin;
\.


--
-- Name: websec_visits__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('websec_visits__rowno_seq', 1, false);


--
-- Data for Name: websecurity; Type: TABLE DATA; Schema: public; Owner: reporting
--

COPY websecurity (logday, userid, protocol, domain, site, path, action, reason, info, requests, pages, transfer, _rowno) FROM stdin;
\.


--
-- Name: websecurity__rowno_seq; Type: SEQUENCE SET; Schema: public; Owner: reporting
--

SELECT pg_catalog.setval('websecurity__rowno_seq', 1, false);


--
-- Name: dpt_lookup_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY dpt_lookup
    ADD CONSTRAINT dpt_lookup_pkey PRIMARY KEY (_rowno);


--
-- Name: endpoint_lookup_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY endpoint_lookup
    ADD CONSTRAINT endpoint_lookup_pkey PRIMARY KEY (ip);


--
-- Name: endpoint_users_name_key; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY endpoint_users
    ADD CONSTRAINT endpoint_users_name_key UNIQUE (name);


--
-- Name: endpoint_users_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY endpoint_users
    ADD CONSTRAINT endpoint_users_pkey PRIMARY KEY (id);


--
-- Name: ipscount_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY ipscount
    ADD CONSTRAINT ipscount_pkey PRIMARY KEY (ruleid, groupid);


--
-- Name: mailanon_addrs_lpart_domain_key; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY mailanon_addrs
    ADD CONSTRAINT mailanon_addrs_lpart_domain_key UNIQUE (lpart, domain);


--
-- Name: mailanon_addrs_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY mailanon_addrs
    ADD CONSTRAINT mailanon_addrs_pkey PRIMARY KEY (_rowno);


--
-- Name: mailanon_domains_domain_key; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY mailanon_domains
    ADD CONSTRAINT mailanon_domains_domain_key UNIQUE (domain);


--
-- Name: mailanon_domains_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY mailanon_domains
    ADD CONSTRAINT mailanon_domains_pkey PRIMARY KEY (_rowno);


--
-- Name: webanon_users_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY webanon_users
    ADD CONSTRAINT webanon_users_pkey PRIMARY KEY (_rowno);


--
-- Name: webanon_users_userid_key; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY webanon_users
    ADD CONSTRAINT webanon_users_userid_key UNIQUE (userid);


--
-- Name: websec_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_categories
    ADD CONSTRAINT websec_categories_pkey PRIMARY KEY (category);


--
-- Name: websec_reqcat_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_reqcat
    ADD CONSTRAINT websec_reqcat_pkey PRIMARY KEY (request, category);


--
-- Name: websec_reqdpt_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_reqdpt
    ADD CONSTRAINT websec_reqdpt_pkey PRIMARY KEY (request, func, dptid);


--
-- Name: websec_searches_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_searches
    ADD CONSTRAINT websec_searches_pkey PRIMARY KEY (_rowno);


--
-- Name: websec_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_sessions
    ADD CONSTRAINT websec_sessions_pkey PRIMARY KEY (_rowno);


--
-- Name: websec_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websec_visits
    ADD CONSTRAINT websec_visits_pkey PRIMARY KEY (_rowno);


--
-- Name: websecurity_pkey; Type: CONSTRAINT; Schema: public; Owner: reporting; Tablespace: 
--

ALTER TABLE ONLY websecurity
    ADD CONSTRAINT websecurity_pkey PRIMARY KEY (_rowno);


--
-- Name: accounting_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX accounting_idx ON accounting USING btree (logday, srcip, dstip, l4_dport, afc_proto);


--
-- Name: appctrl_dayappidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX appctrl_dayappidx ON appcontrol USING btree (logday, appid);


--
-- Name: appctrl_ipidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX appctrl_ipidx ON appcontrol USING btree (srcip, dstip);


--
-- Name: auth_dayfacindex; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX auth_dayfacindex ON auth USING btree (logday, facility);


--
-- Name: confd_nodes_sid_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX confd_nodes_sid_idx ON confd_nodes USING btree (sid, "time");


--
-- Name: confd_objects_sid_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX confd_objects_sid_idx ON confd_objects USING btree (sid, "time");


--
-- Name: confd_sessions_sid_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX confd_sessions_sid_idx ON confd_sessions USING btree (sid, "time");


--
-- Name: ips_daysrcidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX ips_daysrcidx ON ips USING btree (logday, srcip);


--
-- Name: mailsec_dayaddridx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX mailsec_dayaddridx ON mailsec USING btree (logday, srcaddrid, dstaddrid);


--
-- Name: mailsec_typeidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX mailsec_typeidx ON mailsec USING btree (type, reason);


--
-- Name: pfilter_dayidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX pfilter_dayidx ON pfilter USING btree (logday);


--
-- Name: pfilter_ipidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX pfilter_ipidx ON pfilter USING btree (srcip, dstip);


--
-- Name: vpn_dayidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX vpn_dayidx ON vpn USING btree (logday);


--
-- Name: vpn_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX vpn_idx ON vpn USING btree (src_ip, logintime, logouttime);


--
-- Name: waf_dayclientidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX waf_dayclientidx ON waf USING btree (logday, client);


--
-- Name: waf_events_dayclientidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX waf_events_dayclientidx ON waf_events USING btree (logday, client);


--
-- Name: waf_events_rulegrpidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX waf_events_rulegrpidx ON waf_events USING btree (ruleid, rulegroup);


--
-- Name: websecreqcat_catidx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecreqcat_catidx ON websec_reqcat USING btree (category);


--
-- Name: websecsearches_day_user_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecsearches_day_user_idx ON websec_searches USING btree (logday, userid);


--
-- Name: websecsearches_term_engine_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecsearches_term_engine_idx ON websec_searches USING btree (term, engine);


--
-- Name: websecsessions_day_user_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecsessions_day_user_idx ON websec_sessions USING btree (logday, userid);


--
-- Name: websecurity_action_info_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecurity_action_info_idx ON websecurity USING btree (action, info) WHERE (action <> 'passed'::text);


--
-- Name: websecurity_day_user_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecurity_day_user_idx ON websecurity USING btree (logday, userid);


--
-- Name: websecvisits_day_user_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecvisits_day_user_idx ON websec_visits USING btree (logday, userid);


--
-- Name: websecvisits_site_idx; Type: INDEX; Schema: public; Owner: reporting; Tablespace: 
--

CREATE INDEX websecvisits_site_idx ON websec_visits USING btree (site);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect smtp

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


SET search_path = public, pg_catalog;

--
-- Name: action_m_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE action_m_enum AS ENUM (
    'none',
    'delete',
    'cancel',
    'retry'
);


ALTER TYPE public.action_m_enum OWNER TO smtp;

--
-- Name: action_q_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE action_q_enum AS ENUM (
    'none',
    'delete',
    'release'
);


ALTER TYPE public.action_q_enum OWNER TO smtp;

--
-- Name: location_m_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE location_m_enum AS ENUM (
    'input',
    'work',
    'output',
    'error'
);


ALTER TYPE public.location_m_enum OWNER TO smtp;

--
-- Name: reason_import_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE reason_import_enum AS ENUM (
    'av',
    'as',
    'ext',
    'exp',
    'other'
);


ALTER TYPE public.reason_import_enum OWNER TO smtp;

--
-- Name: reason_l_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE reason_l_enum AS ENUM (
    'av',
    'as',
    'exp',
    'ext',
    'mime',
    'unscannable',
    'other',
    'host_blacklist',
    'sender_blacklist',
    'rdns_helo',
    'rbl',
    'batv',
    'address_verification',
    'spf'
);


ALTER TYPE public.reason_l_enum OWNER TO smtp;

--
-- Name: reason_q_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE reason_q_enum AS ENUM (
    'av',
    'as',
    'ext',
    'exp',
    'mime',
    'unscannable',
    'other'
);


ALTER TYPE public.reason_q_enum OWNER TO smtp;

--
-- Name: result_l_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE result_l_enum AS ENUM (
    'rejected',
    'delivered',
    'quarantined',
    'blackholed',
    'cancelled',
    'bounced',
    'deleted',
    'unknown'
);


ALTER TYPE public.result_l_enum OWNER TO smtp;

--
-- Name: status_import_enum; Type: TYPE; Schema: public; Owner: smtp
--

CREATE TYPE status_import_enum AS ENUM (
    'quarantine',
    'not_scanned'
);


ALTER TYPE public.status_import_enum OWNER TO smtp;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: greylist_msg_hashes; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE greylist_msg_hashes (
    host cidr NOT NULL,
    stamp integer DEFAULT 0 NOT NULL,
    md5 character varying NOT NULL
);


ALTER TABLE public.greylist_msg_hashes OWNER TO smtp;

--
-- Name: greylist_retry_hosts; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE greylist_retry_hosts (
    host cidr NOT NULL,
    stamp integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.greylist_retry_hosts OWNER TO smtp;

--
-- Name: import; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE import (
    cluster_id smallint NOT NULL,
    file character varying NOT NULL,
    recipient character varying NOT NULL,
    sender character varying,
    status status_import_enum DEFAULT 'not_scanned'::status_import_enum NOT NULL,
    reason reason_import_enum DEFAULT 'other'::reason_import_enum NOT NULL,
    reason_extra character varying,
    received bigint NOT NULL,
    subject character varying,
    size bigint NOT NULL,
    src cidr NOT NULL
);


ALTER TABLE public.import OWNER TO smtp;

--
-- Name: l; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE l (
    cluster_id smallint NOT NULL,
    message_id character varying NOT NULL,
    recipient character varying NOT NULL,
    sender character varying,
    result result_l_enum DEFAULT 'delivered'::result_l_enum NOT NULL,
    result_time bigint NOT NULL,
    reason reason_l_enum DEFAULT 'other'::reason_l_enum NOT NULL,
    reason_extra character varying,
    msglog text,
    received bigint NOT NULL,
    subject character varying,
    size bigint NOT NULL,
    src cidr NOT NULL,
    attachment smallint DEFAULT 0 NOT NULL,
    saved timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.l OWNER TO smtp;

--
-- Name: m; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE m (
    cluster_id smallint NOT NULL,
    message_id character varying NOT NULL,
    recipient character varying NOT NULL,
    sender character varying,
    location location_m_enum DEFAULT 'input'::location_m_enum NOT NULL,
    action action_m_enum DEFAULT 'none'::action_m_enum NOT NULL,
    msglog text,
    received bigint NOT NULL,
    subject character varying,
    size bigint NOT NULL,
    src cidr NOT NULL,
    attachment smallint DEFAULT 0 NOT NULL,
    saved timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.m OWNER TO smtp;

--
-- Name: q; Type: TABLE; Schema: public; Owner: smtp; Tablespace: 
--

CREATE TABLE q (
    cluster_id smallint NOT NULL,
    message_id character varying NOT NULL,
    recipient character varying NOT NULL,
    sender character varying,
    action action_q_enum DEFAULT 'none'::action_q_enum NOT NULL,
    action_extra character varying,
    reason reason_q_enum DEFAULT 'other'::reason_q_enum NOT NULL,
    reason_extra character varying,
    received bigint NOT NULL,
    subject character varying,
    size bigint NOT NULL,
    src cidr NOT NULL,
    attachment smallint DEFAULT 0 NOT NULL,
    reported smallint DEFAULT 0 NOT NULL,
    saved timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.q OWNER TO smtp;

--
-- Data for Name: greylist_msg_hashes; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY greylist_msg_hashes (host, stamp, md5) FROM stdin;
\.


--
-- Data for Name: greylist_retry_hosts; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY greylist_retry_hosts (host, stamp) FROM stdin;
\.


--
-- Data for Name: import; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY import (cluster_id, file, recipient, sender, status, reason, reason_extra, received, subject, size, src) FROM stdin;
\.


--
-- Data for Name: l; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY l (cluster_id, message_id, recipient, sender, result, result_time, reason, reason_extra, msglog, received, subject, size, src, attachment, saved) FROM stdin;
\.


--
-- Data for Name: m; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY m (cluster_id, message_id, recipient, sender, location, action, msglog, received, subject, size, src, attachment, saved) FROM stdin;
0	1bZUEc-0001nK-6Q	admin@infosec.com	do-not-reply@fw-notify.net	output	none	2016-08-16 11:36:10 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:39:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:41:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:43:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:45:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:47:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:49:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:51:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:53:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:55:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:57:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 11:59:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:01:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:03:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:05:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:07:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:09:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:11:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:13:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:15:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:17:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:19:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:21:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:23:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:25:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:27:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:29:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:31:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:33:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:35:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:37:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:39:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:41:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:43:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:45:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:47:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:49:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:51:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:53:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:55:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:57:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 12:59:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:01:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:03:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:05:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:07:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:09:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:11:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:13:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:15:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:17:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:19:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:21:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:23:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 13:25:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n2016-08-16 16:26:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n	1471314967	[MyACC][CRIT-310] Up2Date prefetch failed	242	127.0.0.1/32	0	2016-08-16 02:36:09.416259
0	1bZZQl-00048w-Jr	admin@infosec.com	do-not-reply@fw-notify.net	output	none	2016-08-16 17:09:04 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n	1471334933	[MyACC][WARN-007] Failed console login	266	127.0.0.1/32	0	2016-08-16 08:08:56.232419
0	1bZZRg-00049n-5T	admin@infosec.com	do-not-reply@fw-notify.net	output	none	2016-08-16 17:10:00 admin@infosec.com R=dnslookup defer (-1): host lookup did not complete\n	1471334997	[MyACC][WARN-007] Failed console login	266	127.0.0.1/32	0	2016-08-16 08:09:58.505454
\.


--
-- Data for Name: q; Type: TABLE DATA; Schema: public; Owner: smtp
--

COPY q (cluster_id, message_id, recipient, sender, action, action_extra, reason, reason_extra, received, subject, size, src, attachment, reported, saved) FROM stdin;
\.


--
-- Name: greylist_msg_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY greylist_msg_hashes
    ADD CONSTRAINT greylist_msg_hashes_pkey PRIMARY KEY (md5);


--
-- Name: greylist_retry_hosts_pkey; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY greylist_retry_hosts
    ADD CONSTRAINT greylist_retry_hosts_pkey PRIMARY KEY (host);


--
-- Name: primary_import; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY import
    ADD CONSTRAINT primary_import PRIMARY KEY (file);


--
-- Name: primary_l; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY l
    ADD CONSTRAINT primary_l PRIMARY KEY (cluster_id, message_id);


--
-- Name: primary_m; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY m
    ADD CONSTRAINT primary_m PRIMARY KEY (cluster_id, message_id, recipient);


--
-- Name: primary_q; Type: CONSTRAINT; Schema: public; Owner: smtp; Tablespace: 
--

ALTER TABLE ONLY q
    ADD CONSTRAINT primary_q PRIMARY KEY (cluster_id, message_id);


--
-- Name: action_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX action_m ON m USING btree (action);


--
-- Name: action_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX action_q ON q USING btree (action);


--
-- Name: cluster_id_import; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX cluster_id_import ON import USING btree (cluster_id);


--
-- Name: cluster_id_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX cluster_id_l ON l USING btree (cluster_id);


--
-- Name: cluster_id_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX cluster_id_m ON m USING btree (cluster_id);


--
-- Name: cluster_id_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX cluster_id_q ON q USING btree (cluster_id);


--
-- Name: file_import; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX file_import ON import USING btree (file);


--
-- Name: greylist_msg_hashes_host; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX greylist_msg_hashes_host ON greylist_msg_hashes USING btree (host);


--
-- Name: greylist_msg_hashes_stamp; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX greylist_msg_hashes_stamp ON greylist_msg_hashes USING btree (stamp);


--
-- Name: greylist_retry_hosts_stamp; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX greylist_retry_hosts_stamp ON greylist_retry_hosts USING btree (stamp);


--
-- Name: location_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX location_m ON m USING btree (location);


--
-- Name: message_id_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX message_id_l ON l USING btree (message_id);


--
-- Name: message_id_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX message_id_m ON m USING btree (message_id);


--
-- Name: message_id_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX message_id_q ON q USING btree (message_id);


--
-- Name: reason_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX reason_l ON l USING btree (reason);


--
-- Name: reason_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX reason_q ON q USING btree (reason);


--
-- Name: received_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX received_l ON l USING btree (received);


--
-- Name: received_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX received_m ON m USING btree (received);


--
-- Name: received_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX received_q ON q USING btree (received);


--
-- Name: recipient_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX recipient_l ON l USING btree (recipient);


--
-- Name: recipient_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX recipient_m ON m USING btree (recipient);


--
-- Name: recipient_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX recipient_q ON q USING btree (recipient);


--
-- Name: reported_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX reported_q ON q USING btree (reported);


--
-- Name: result_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX result_l ON l USING btree (result);


--
-- Name: result_time_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX result_time_l ON l USING btree (result_time);


--
-- Name: sender_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX sender_l ON l USING btree (sender);


--
-- Name: sender_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX sender_m ON m USING btree (sender);


--
-- Name: sender_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX sender_q ON q USING btree (sender);


--
-- Name: size_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX size_l ON l USING btree (size);


--
-- Name: size_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX size_m ON m USING btree (size);


--
-- Name: size_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX size_q ON q USING btree (size);


--
-- Name: src_l; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX src_l ON l USING btree (src);


--
-- Name: src_m; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX src_m ON m USING btree (src);


--
-- Name: src_q; Type: INDEX; Schema: public; Owner: smtp; Tablespace: 
--

CREATE INDEX src_q ON q USING btree (src);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

\connect template1

--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: template1; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON DATABASE template1 IS 'default template for new databases';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

--
-- PostgreSQL database cluster dump complete
--

