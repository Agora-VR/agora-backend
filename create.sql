--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

-- Started on 2020-02-27 10:24:42

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 2855 (class 1262 OID 16393)
-- Name: agora; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE agora WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';


\connect agora

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 203 (class 1259 OID 16407)
-- Name: user_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_types (
    user_type_id smallint NOT NULL,
    user_type_name character varying NOT NULL
);


--
-- TOC entry 202 (class 1259 OID 16405)
-- Name: UserTypes_user_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."UserTypes_user_type_id_seq"
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2856 (class 0 OID 0)
-- Dependencies: 202
-- Name: UserTypes_user_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserTypes_user_type_id_seq" OWNED BY public.user_types.user_type_id;


--
-- TOC entry 205 (class 1259 OID 16418)
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_type_id integer NOT NULL,
    user_name character varying NOT NULL,
    user_hash bytea NOT NULL,
    user_salt bytea NOT NULL
);


--
-- TOC entry 204 (class 1259 OID 16416)
-- Name: Users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."Users_user_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2857 (class 0 OID 0)
-- Dependencies: 204
-- Name: Users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Users_user_id_seq" OWNED BY public.users.user_id;


--
-- TOC entry 208 (class 1259 OID 16452)
-- Name: oversees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oversees (
    caretaker_id integer NOT NULL,
    patient_id integer NOT NULL
);


--
-- TOC entry 207 (class 1259 OID 16437)
-- Name: serves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.serves (
    clinician_id integer NOT NULL,
    patient_id integer NOT NULL
);


--
-- TOC entry 206 (class 1259 OID 16432)
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    user_id integer NOT NULL,
    session_datetime timestamp without time zone NOT NULL,
    session_type integer NOT NULL,
    session_duration interval NOT NULL
);


--
-- TOC entry 2707 (class 2604 OID 16410)
-- Name: user_types user_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_types ALTER COLUMN user_type_id SET DEFAULT nextval('public."UserTypes_user_type_id_seq"'::regclass);


--
-- TOC entry 2708 (class 2604 OID 16421)
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public."Users_user_id_seq"'::regclass);


--
-- TOC entry 2718 (class 2606 OID 16456)
-- Name: oversees Oversees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT "Oversees_pkey" PRIMARY KEY (caretaker_id, patient_id);


--
-- TOC entry 2716 (class 2606 OID 16441)
-- Name: serves Serves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT "Serves_pkey" PRIMARY KEY (clinician_id, patient_id);


--
-- TOC entry 2714 (class 2606 OID 16436)
-- Name: sessions Sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "Sessions_pkey" PRIMARY KEY (user_id, session_datetime);


--
-- TOC entry 2710 (class 2606 OID 16415)
-- Name: user_types UserTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_types
    ADD CONSTRAINT "UserTypes_pkey" PRIMARY KEY (user_type_id);


--
-- TOC entry 2712 (class 2606 OID 16426)
-- Name: users Users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY (user_id);


--
-- TOC entry 2722 (class 2606 OID 16457)
-- Name: oversees Oversees_caretaker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT "Oversees_caretaker_id_fkey" FOREIGN KEY (caretaker_id) REFERENCES public.users(user_id);


--
-- TOC entry 2723 (class 2606 OID 16462)
-- Name: oversees Oversees_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT "Oversees_patient_id_fkey" FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- TOC entry 2720 (class 2606 OID 16442)
-- Name: serves Serves_clinician_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT "Serves_clinician_id_fkey" FOREIGN KEY (clinician_id) REFERENCES public.users(user_id);


--
-- TOC entry 2721 (class 2606 OID 16447)
-- Name: serves Serves_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT "Serves_patient_id_fkey" FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- TOC entry 2719 (class 2606 OID 16427)
-- Name: users Users_user_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "Users_user_type_id_fkey" FOREIGN KEY (user_type_id) REFERENCES public.user_types(user_type_id);


-- Completed on 2020-02-27 10:24:43

--
-- PostgreSQL database dump complete
--

