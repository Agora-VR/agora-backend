--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1
-- Dumped by pg_dump version 12.1

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
-- Name: user_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_types (
    user_type_id smallint NOT NULL,
    user_type_name character varying NOT NULL,
    user_type_form_name character varying
);


--
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
-- Name: UserTypes_user_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."UserTypes_user_type_id_seq" OWNED BY public.user_types.user_type_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_type_id integer NOT NULL,
    user_name character varying NOT NULL,
    user_hash bytea NOT NULL,
    user_salt bytea NOT NULL,
    user_full_name character varying NOT NULL,
    user_response_id bigint
);


--
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
-- Name: Users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."Users_user_id_seq" OWNED BY public.users.user_id;


--
-- Name: forms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forms (
    form_name character varying NOT NULL,
    form_data json NOT NULL
);


--
-- Name: oversee_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oversee_requests (
    patient_id integer NOT NULL,
    caregiver_id integer NOT NULL
);


--
-- Name: oversees; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.oversees (
    patient_id integer NOT NULL,
    caregiver_id integer NOT NULL
);


--
-- Name: responds; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.responds (
    session_id integer NOT NULL,
    response_id integer NOT NULL
);


--
-- Name: responses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.responses (
    response_id bigint NOT NULL,
    response_form_name character varying NOT NULL,
    response_datetime timestamp without time zone NOT NULL,
    response_owner_id integer NOT NULL,
    response_data json NOT NULL
);


--
-- Name: responses_response_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.responses_response_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: responses_response_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.responses_response_id_seq OWNED BY public.responses.response_id;


--
-- Name: serve_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.serve_requests (
    patient_id integer NOT NULL,
    clinician_id integer NOT NULL
);


--
-- Name: serves; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.serves (
    patient_id integer NOT NULL,
    clinician_id integer NOT NULL
);


--
-- Name: session_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_files (
    session_id integer NOT NULL,
    type character varying NOT NULL,
    name character varying NOT NULL
);


--
-- Name: session_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session_types (
    name character varying NOT NULL,
    patient_form character varying,
    clinician_form character varying,
    caregiver_form character varying,
    speech character varying NOT NULL,
    display_name character varying NOT NULL
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sessions (
    session_owner_id integer NOT NULL,
    session_datetime timestamp without time zone,
    session_duration interval,
    session_id integer NOT NULL,
    type_name character varying NOT NULL
);


--
-- Name: sessions_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sessions_session_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sessions_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sessions_session_id_seq OWNED BY public.sessions.session_id;


--
-- Name: responses response_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses ALTER COLUMN response_id SET DEFAULT nextval('public.responses_response_id_seq'::regclass);


--
-- Name: sessions session_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions ALTER COLUMN session_id SET DEFAULT nextval('public.sessions_session_id_seq'::regclass);


--
-- Name: user_types user_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_types ALTER COLUMN user_type_id SET DEFAULT nextval('public."UserTypes_user_type_id_seq"'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public."Users_user_id_seq"'::regclass);


--
-- Name: user_types UserTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_types
    ADD CONSTRAINT "UserTypes_pkey" PRIMARY KEY (user_type_id);


--
-- Name: users Users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY (user_id);


--
-- Name: forms forms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forms
    ADD CONSTRAINT forms_pkey PRIMARY KEY (form_name);


--
-- Name: oversee_requests oversee_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversee_requests
    ADD CONSTRAINT oversee_requests_pkey PRIMARY KEY (patient_id, caregiver_id);


--
-- Name: oversees oversees_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT oversees_pkey PRIMARY KEY (patient_id, caregiver_id);


--
-- Name: responds responds_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responds
    ADD CONSTRAINT responds_pkey PRIMARY KEY (session_id, response_id);


--
-- Name: responses responses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT responses_pkey PRIMARY KEY (response_id);


--
-- Name: serve_requests serve_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serve_requests
    ADD CONSTRAINT serve_requests_pkey PRIMARY KEY (patient_id, clinician_id);


--
-- Name: serves serves_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT serves_pkey PRIMARY KEY (patient_id, clinician_id);


--
-- Name: session_files session_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_files
    ADD CONSTRAINT session_files_pkey PRIMARY KEY (session_id, type);


--
-- Name: session_types session_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_types
    ADD CONSTRAINT session_types_pkey PRIMARY KEY (name);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (session_id);


--
-- Name: users Users_user_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT "Users_user_type_id_fkey" FOREIGN KEY (user_type_id) REFERENCES public.user_types(user_type_id);


--
-- Name: oversee_requests oversee_requests_caregiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversee_requests
    ADD CONSTRAINT oversee_requests_caregiver_id_fkey FOREIGN KEY (caregiver_id) REFERENCES public.users(user_id);


--
-- Name: oversee_requests oversee_requests_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversee_requests
    ADD CONSTRAINT oversee_requests_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- Name: oversees oversees_caregiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT oversees_caregiver_id_fkey FOREIGN KEY (caregiver_id) REFERENCES public.users(user_id);


--
-- Name: oversees oversees_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.oversees
    ADD CONSTRAINT oversees_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- Name: responses responses_response_form_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT responses_response_form_name_fkey FOREIGN KEY (response_form_name) REFERENCES public.forms(form_name);


--
-- Name: responses responses_response_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.responses
    ADD CONSTRAINT responses_response_owner_id_fkey FOREIGN KEY (response_owner_id) REFERENCES public.users(user_id);


--
-- Name: serve_requests serve_requests_clinician_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serve_requests
    ADD CONSTRAINT serve_requests_clinician_id_fkey FOREIGN KEY (clinician_id) REFERENCES public.users(user_id);


--
-- Name: serve_requests serve_requests_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serve_requests
    ADD CONSTRAINT serve_requests_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- Name: serves serves_clinician_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT serves_clinician_id_fkey FOREIGN KEY (clinician_id) REFERENCES public.users(user_id);


--
-- Name: serves serves_patient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.serves
    ADD CONSTRAINT serves_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES public.users(user_id);


--
-- Name: session_files session_files_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_files
    ADD CONSTRAINT session_files_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.sessions(session_id) NOT VALID;


--
-- Name: session_types session_types_caregiver_form_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_types
    ADD CONSTRAINT session_types_caregiver_form_fkey FOREIGN KEY (caregiver_form) REFERENCES public.forms(form_name) NOT VALID;


--
-- Name: session_types session_types_clincian_form_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_types
    ADD CONSTRAINT session_types_clincian_form_fkey FOREIGN KEY (clinician_form) REFERENCES public.forms(form_name) NOT VALID;


--
-- Name: session_types session_types_patient_form_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session_types
    ADD CONSTRAINT session_types_patient_form_fkey FOREIGN KEY (patient_form) REFERENCES public.forms(form_name) NOT VALID;


--
-- Name: sessions sessions_session_owner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_session_owner_id_fkey FOREIGN KEY (session_owner_id) REFERENCES public.users(user_id) NOT VALID;


--
-- Name: sessions sessions_type_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_type_name_fkey FOREIGN KEY (type_name) REFERENCES public.session_types(name) NOT VALID;


--
-- PostgreSQL database dump complete
--

