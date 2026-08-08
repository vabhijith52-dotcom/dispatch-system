--
-- PostgreSQL database dump
--

\restrict Nzl4LJslRgEazbujj1UJZaQ1zu49FJRwlTsFF1WaNXME7dazogla41Kj3CllpQD

-- Dumped from database version 16.14 (Debian 16.14-1.pgdg13+1)
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-1.pgdg24.04+1)

-- Started on 2026-08-08 19:53:36 IST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 222 (class 1255 OID 16432)
-- Name: notify_dispatch_change(); Type: FUNCTION; Schema: public; Owner: dispatch_user
--

CREATE FUNCTION public.notify_dispatch_change() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    payload JSON;
BEGIN
    payload := json_build_object(
        'table', TG_TABLE_NAME,
        'operation', TG_OP,
        'row', row_to_json(COALESCE(NEW, OLD))
    );
    PERFORM pg_notify('dispatch_changes', payload::text);
    RETURN COALESCE(NEW, OLD);
END;
$$;


ALTER FUNCTION public.notify_dispatch_change() OWNER TO dispatch_user;

--
-- TOC entry 221 (class 1255 OID 16435)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: dispatch_user
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO dispatch_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 220 (class 1259 OID 16417)
-- Name: count_events; Type: TABLE; Schema: public; Owner: dispatch_user
--

CREATE TABLE public.count_events (
    id integer NOT NULL,
    truck_id integer NOT NULL,
    event_type character varying DEFAULT 'carton_added'::character varying NOT NULL,
    track_id integer,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.count_events OWNER TO dispatch_user;

--
-- TOC entry 219 (class 1259 OID 16416)
-- Name: count_events_id_seq; Type: SEQUENCE; Schema: public; Owner: dispatch_user
--

CREATE SEQUENCE public.count_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.count_events_id_seq OWNER TO dispatch_user;

--
-- TOC entry 3457 (class 0 OID 0)
-- Dependencies: 219
-- Name: count_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dispatch_user
--

ALTER SEQUENCE public.count_events_id_seq OWNED BY public.count_events.id;


--
-- TOC entry 218 (class 1259 OID 16401)
-- Name: trucks; Type: TABLE; Schema: public; Owner: dispatch_user
--

CREATE TABLE public.trucks (
    id integer NOT NULL,
    truck_code character varying NOT NULL,
    plate_number character varying,
    expected_count integer DEFAULT 0 NOT NULL,
    loaded_count integer DEFAULT 0 NOT NULL,
    status character varying DEFAULT 'waiting'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    loading_started_at timestamp with time zone
);


ALTER TABLE public.trucks OWNER TO dispatch_user;

--
-- TOC entry 217 (class 1259 OID 16400)
-- Name: trucks_id_seq; Type: SEQUENCE; Schema: public; Owner: dispatch_user
--

CREATE SEQUENCE public.trucks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.trucks_id_seq OWNER TO dispatch_user;

--
-- TOC entry 3458 (class 0 OID 0)
-- Dependencies: 217
-- Name: trucks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dispatch_user
--

ALTER SEQUENCE public.trucks_id_seq OWNED BY public.trucks.id;


--
-- TOC entry 216 (class 1259 OID 16390)
-- Name: users; Type: TABLE; Schema: public; Owner: dispatch_user
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying NOT NULL,
    password_hash character varying NOT NULL
);


ALTER TABLE public.users OWNER TO dispatch_user;

--
-- TOC entry 215 (class 1259 OID 16389)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: dispatch_user
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO dispatch_user;

--
-- TOC entry 3459 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: dispatch_user
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 3286 (class 2604 OID 16420)
-- Name: count_events id; Type: DEFAULT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.count_events ALTER COLUMN id SET DEFAULT nextval('public.count_events_id_seq'::regclass);


--
-- TOC entry 3280 (class 2604 OID 16404)
-- Name: trucks id; Type: DEFAULT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.trucks ALTER COLUMN id SET DEFAULT nextval('public.trucks_id_seq'::regclass);


--
-- TOC entry 3279 (class 2604 OID 16393)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 3451 (class 0 OID 16417)
-- Dependencies: 220
-- Data for Name: count_events; Type: TABLE DATA; Schema: public; Owner: dispatch_user
--

COPY public.count_events (id, truck_id, event_type, track_id, note, created_at) FROM stdin;
1	1	carton_added	63	door line crossing detected	2026-07-29 20:12:58.263591+00
2	1	carton_added	203	door line crossing detected	2026-07-30 04:10:17.689106+00
3	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:17.745393+00
4	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:21.2057+00
5	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:23.469402+00
6	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:33.236023+00
7	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:37.901357+00
8	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:41.508499+00
9	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:43.621694+00
10	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:53.385712+00
11	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:17:58.200367+00
12	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:18:01.660089+00
13	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:13.229104+00
14	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:16.699139+00
15	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:18.961038+00
16	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:28.724328+00
17	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:33.388103+00
18	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:36.999011+00
19	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:39.108738+00
20	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:48.869821+00
21	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:53.684269+00
22	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:57.140556+00
23	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:22:59.398316+00
24	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:09.165526+00
25	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:13.976088+00
26	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:17.438772+00
27	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:19.695761+00
28	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:29.46192+00
29	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:34.128592+00
30	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:37.736235+00
31	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:39.847803+00
32	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:49.61191+00
33	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:54.429654+00
34	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:23:57.896893+00
35	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:00.15877+00
36	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:09.929153+00
37	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:14.59544+00
38	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:18.211007+00
39	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:20.323065+00
40	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:30.096789+00
41	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:34.915925+00
42	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:38.384204+00
43	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:24:40.649475+00
44	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:20.573303+00
45	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:24.053009+00
46	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:26.316323+00
47	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:36.084277+00
48	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:40.752975+00
49	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:44.375573+00
50	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:46.492047+00
51	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:44:56.256153+00
52	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:01.069427+00
53	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:04.527996+00
54	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:06.783035+00
55	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:16.545946+00
56	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:21.209032+00
59	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:36.699601+00
60	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:41.51739+00
57	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:24.82628+00
58	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:26.937892+00
61	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:44.97559+00
62	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:47.238232+00
63	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:45:57.010765+00
64	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:01.675301+00
65	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:05.283307+00
66	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:07.398224+00
67	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:17.169043+00
68	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:21.982959+00
69	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:25.445283+00
70	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:27.705193+00
71	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:37.474745+00
72	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:42.300098+00
73	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:45.760651+00
74	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:48.017288+00
75	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:46:57.779715+00
76	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:02.443319+00
77	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:06.059842+00
78	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:08.175375+00
79	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:17.94477+00
80	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:22.767243+00
81	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:26.23369+00
82	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:28.4952+00
83	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:38.117077+00
84	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:42.930824+00
85	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:46.393822+00
86	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:48.65515+00
87	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:47:58.426177+00
88	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:03.250789+00
89	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:06.717344+00
90	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:08.976416+00
91	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:18.740387+00
92	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:23.409469+00
93	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:27.017961+00
94	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:29.129542+00
95	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:38.903701+00
96	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:43.724001+00
97	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:47.190854+00
98	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:49.45779+00
99	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:48:59.079761+00
100	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:03.898565+00
101	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:07.365377+00
102	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:09.629686+00
103	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:19.396711+00
104	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:24.210069+00
105	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:27.672304+00
106	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:29.932352+00
107	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:39.552979+00
108	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:44.369336+00
109	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:47.981558+00
110	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:50.090589+00
111	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:49:59.852736+00
112	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:04.662001+00
113	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:08.123358+00
114	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:10.383471+00
117	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:28.429193+00
115	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:20.152909+00
116	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:24.818689+00
118	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:30.544379+00
119	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:47.743474+00
120	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:51.217897+00
121	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:50:53.477452+00
122	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:03.251854+00
123	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:07.915768+00
124	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:11.531611+00
125	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:13.64653+00
126	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:23.416789+00
127	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:28.230056+00
128	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:31.694806+00
129	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:33.959728+00
130	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:43.729322+00
131	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:48.391113+00
132	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:51.998759+00
133	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:51:54.110389+00
134	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:03.876514+00
135	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:08.696903+00
136	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:12.160903+00
137	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:14.419619+00
138	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:24.190633+00
139	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:28.856605+00
140	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:32.468919+00
141	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:34.581698+00
142	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:44.348559+00
143	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:49.163059+00
144	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:52.619303+00
145	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:52:54.879381+00
146	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:04.642221+00
147	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:09.460134+00
148	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:12.919301+00
149	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:15.175832+00
150	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:24.942736+00
151	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:29.612525+00
152	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:33.075939+00
153	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:35.337169+00
154	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:45.102944+00
155	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:49.918588+00
156	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:53.384211+00
157	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:53:55.648215+00
158	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:05.412593+00
159	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:10.075071+00
160	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:13.684311+00
161	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:15.791287+00
162	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:25.556012+00
163	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:30.371697+00
164	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:33.832096+00
165	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:36.087508+00
166	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:45.850275+00
167	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:50.664048+00
168	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:54.121345+00
169	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:54:56.378612+00
170	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:55:06.139977+00
171	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:55:10.803857+00
173	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:55:16.520514+00
172	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 15:55:14.415433+00
174	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:04:48.548555+00
175	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:04:52.015994+00
176	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:04:54.271766+00
177	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:04.041192+00
178	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:08.707662+00
179	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:12.318975+00
180	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:14.42779+00
181	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:24.19092+00
182	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:29.00478+00
183	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:32.472475+00
184	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:34.733607+00
185	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:44.50509+00
186	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:49.18689+00
187	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:52.679779+00
188	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:05:54.94153+00
189	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:04.739582+00
190	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:09.41695+00
191	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:13.030234+00
192	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:15.144469+00
193	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:24.959013+00
194	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:29.788089+00
195	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:33.262275+00
196	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:35.37811+00
197	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:45.183589+00
198	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:49.90191+00
199	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:53.491883+00
200	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:06:55.722157+00
201	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:12.094829+00
202	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:24.965408+00
203	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:25.285565+00
204	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:25.308455+00
205	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:25.656857+00
206	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:30.771729+00
207	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:33.992822+00
208	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:36.139237+00
209	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:45.911635+00
210	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:50.725987+00
211	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:54.190998+00
212	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:07:56.454232+00
213	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:06.224218+00
214	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:10.890728+00
215	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:14.500528+00
216	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:16.609495+00
217	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:26.380743+00
218	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:31.195356+00
219	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:34.652249+00
220	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:36.911295+00
221	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:46.716229+00
222	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:51.396441+00
223	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:54.858299+00
224	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:08:57.127107+00
225	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:06.891891+00
226	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:11.559672+00
227	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:15.172699+00
228	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:17.284871+00
231	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:35.343895+00
233	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:47.393004+00
235	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:55.69316+00
236	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:57.823811+00
237	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:07.602385+00
239	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:15.928084+00
240	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:18.056884+00
243	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:36.19529+00
244	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:38.389514+00
246	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:53.702698+00
249	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:08.270852+00
251	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:16.544864+00
256	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:38.986179+00
229	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:27.05742+00
230	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:31.87966+00
232	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:37.605105+00
234	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:09:52.072728+00
238	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:12.308867+00
241	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:27.83042+00
242	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:32.660075+00
245	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:48.2517+00
247	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:10:56.337189+00
248	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:02.340641+00
250	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:13.084273+00
252	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:18.810764+00
253	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:28.582311+00
254	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:33.254802+00
255	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:36.872592+00
257	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:48.759134+00
258	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:53.576667+00
259	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:57.043852+00
260	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:11:59.326209+00
261	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:09.107481+00
262	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:13.800938+00
263	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:17.279647+00
264	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:19.55714+00
265	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:29.213626+00
266	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:34.044474+00
267	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:37.511694+00
268	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:39.778334+00
269	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:49.461781+00
270	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:54.28879+00
271	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:12:57.754347+00
272	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:00.034651+00
273	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:09.823642+00
274	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:14.520048+00
275	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:17.990399+00
276	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:20.265493+00
277	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:29.922315+00
278	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:34.769398+00
279	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:38.246974+00
280	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:40.514389+00
281	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:50.287066+00
282	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:54.95746+00
283	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:13:58.573461+00
284	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:00.681916+00
285	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:10.451522+00
286	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:15.266041+00
287	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:18.726845+00
288	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:20.985765+00
289	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:30.756067+00
290	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:35.421372+00
291	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:39.034534+00
292	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:41.142331+00
293	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:50.905885+00
294	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:55.722897+00
295	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:14:59.189839+00
296	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:01.45401+00
297	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:11.226322+00
299	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:19.504152+00
304	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:41.914647+00
306	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:56.370948+00
309	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:11.866506+00
311	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:20.150334+00
316	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:42.575692+00
318	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:57.158308+00
321	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:12.651482+00
323	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:20.93134+00
328	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:43.353269+00
330	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:57.939921+00
333	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:13.309849+00
335	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:21.58709+00
340	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:44.021913+00
298	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:15.895944+00
301	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:31.3803+00
303	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:39.653763+00
308	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:02.098185+00
310	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:16.68537+00
313	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:32.181964+00
315	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:40.462617+00
320	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:02.885668+00
322	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:17.467824+00
325	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:32.811843+00
327	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:41.092891+00
332	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:03.528713+00
334	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:18.128393+00
337	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:33.621307+00
339	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:41.911765+00
300	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:21.613657+00
302	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:36.196439+00
305	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:51.696104+00
307	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:15:59.983874+00
312	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:22.408963+00
314	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:36.846925+00
317	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:16:52.345162+00
319	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:00.620283+00
324	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:23.044991+00
326	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:37.627598+00
329	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:17:53.124557+00
331	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:01.405719+00
336	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:23.850569+00
338	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:38.295189+00
341	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:53.794451+00
342	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:18:58.608873+00
343	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:02.072587+00
344	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:04.330265+00
345	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:14.094967+00
346	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:18.761413+00
347	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:22.372391+00
348	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:24.630154+00
349	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:34.250831+00
350	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:39.066131+00
351	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:42.52605+00
352	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:44.789709+00
353	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:54.561255+00
354	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:19:59.376536+00
355	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:02.838457+00
356	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:05.104272+00
357	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:14.720107+00
358	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:19.540487+00
359	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:23.006632+00
360	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:25.266859+00
361	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:35.037703+00
362	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:39.858084+00
363	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:43.324101+00
364	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:45.580971+00
365	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:20:55.210237+00
366	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:00.03076+00
367	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:03.494458+00
368	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:05.754244+00
369	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:15.528768+00
370	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:20.20025+00
371	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:23.812709+00
372	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:25.925229+00
373	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:35.697153+00
374	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:40.516871+00
375	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:43.979049+00
376	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:46.242805+00
377	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:21:56.011369+00
378	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:00.681594+00
379	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:04.296338+00
380	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:06.408602+00
381	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:16.174613+00
382	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:20.986262+00
385	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:36.475148+00
387	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:44.757215+00
392	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:07.190557+00
394	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:21.777657+00
397	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:37.121053+00
399	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:45.401834+00
404	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:07.981747+00
406	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:22.416529+00
409	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:37.91498+00
411	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:46.20507+00
416	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:08.634904+00
418	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:23.223642+00
421	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:38.567868+00
423	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:46.849674+00
428	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:09.437463+00
430	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:23.887734+00
433	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:39.411634+00
435	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:47.698689+00
383	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:24.444106+00
388	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:47.021019+00
390	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:01.458763+00
393	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:16.961359+00
395	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:25.240062+00
400	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:47.665759+00
402	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:02.255699+00
405	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:17.748587+00
407	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:25.880646+00
412	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:48.463326+00
414	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:02.902465+00
417	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:18.405584+00
419	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:26.693624+00
424	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:49.113193+00
426	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:03.699091+00
429	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:19.066254+00
431	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:27.351707+00
384	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:26.705538+00
386	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:41.294447+00
389	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:22:56.793263+00
391	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:04.925511+00
396	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:27.500742+00
398	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:41.936917+00
401	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:23:57.440173+00
403	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:05.717449+00
408	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:28.14212+00
410	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:42.735719+00
413	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:24:58.085602+00
415	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:06.369398+00
420	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:28.803206+00
422	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:43.392005+00
425	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:25:58.884986+00
427	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:07.165061+00
432	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:29.613798+00
434	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:44.088802+00
436	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:49.812066+00
437	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:26:59.60147+00
438	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:04.28626+00
439	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:07.909231+00
440	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:10.031154+00
441	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:19.880359+00
442	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:24.664963+00
443	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:28.145961+00
444	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:30.269437+00
445	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:40.083569+00
446	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:44.773522+00
447	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:48.394713+00
448	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:27:50.515762+00
449	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:00.328507+00
450	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:05.007211+00
451	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:08.63587+00
452	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:10.753194+00
453	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:20.589898+00
454	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:25.266742+00
455	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:28.887692+00
456	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:31.00958+00
457	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:40.810783+00
458	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:45.490251+00
459	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:49.1213+00
460	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:28:51.239243+00
461	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:01.032373+00
462	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:05.725203+00
463	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:09.34815+00
464	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:11.475262+00
465	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:21.26066+00
466	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:26.088701+00
467	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:29.55318+00
468	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:31.814483+00
469	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:41.462021+00
470	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:46.295137+00
471	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:49.793539+00
472	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:29:51.924833+00
473	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:01.760347+00
475	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:10.106441+00
480	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:32.449794+00
482	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:46.934634+00
485	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:02.466633+00
487	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:10.779082+00
492	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:33.143356+00
494	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:47.784611+00
497	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:03.195453+00
499	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:11.512898+00
504	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:33.885947+00
506	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:48.383051+00
509	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:03.937467+00
511	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:12.261611+00
516	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:34.587525+00
518	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:49.231716+00
521	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:04.666734+00
523	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:12.880206+00
528	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:35.398295+00
474	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:06.480997+00
477	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:22.022136+00
479	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:30.329059+00
484	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:52.675546+00
486	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:07.301107+00
489	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:22.708783+00
491	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:31.026747+00
496	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:53.405162+00
498	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:07.8865+00
501	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:23.44503+00
503	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:31.761365+00
508	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:54.13153+00
510	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:08.62809+00
513	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:24.104044+00
515	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:32.455244+00
520	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:54.849886+00
522	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:09.397619+00
525	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:24.803942+00
527	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:33.123077+00
476	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:12.22186+00
478	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:26.710487+00
481	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:42.251832+00
483	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:30:50.559328+00
488	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:12.903412+00
490	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:27.402663+00
493	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:42.949459+00
495	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:31:51.266476+00
500	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:13.644619+00
502	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:28.13241+00
505	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:43.695615+00
507	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:32:52.008001+00
512	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:14.383043+00
514	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:28.96446+00
517	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:44.383807+00
519	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:33:52.731773+00
524	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:15.155844+00
526	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:29.643996+00
529	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:45.049984+00
530	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:49.895243+00
531	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:53.385716+00
532	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:34:55.656836+00
533	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:05.404303+00
534	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:10.098911+00
535	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:13.602087+00
536	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:15.872453+00
537	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:25.553608+00
538	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:30.416378+00
539	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:33.914734+00
540	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:36.06493+00
541	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:45.912512+00
542	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:50.61022+00
543	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:54.102207+00
544	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:35:56.376473+00
545	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:06.040664+00
546	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:10.883358+00
547	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:14.381243+00
548	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:16.512379+00
549	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:26.318868+00
550	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:31.023107+00
551	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:34.656883+00
552	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:36.782967+00
553	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:46.61123+00
554	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:51.33828+00
555	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:54.8745+00
556	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:36:57.099416+00
557	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:06.795087+00
558	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:11.505807+00
559	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:15.157134+00
560	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:17.279323+00
561	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:27.043309+00
562	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:31.851663+00
563	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:35.392247+00
564	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:37:37.754442+00
565	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:09.432939+00
566	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:09.565074+00
568	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:09.780451+00
570	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:15.749172+00
575	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:38.268461+00
577	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:52.80106+00
580	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:08.25982+00
582	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:16.452455+00
587	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:38.942313+00
589	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:53.452386+00
592	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:08.996103+00
594	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:17.304085+00
599	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:39.733105+00
601	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:54.243598+00
604	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:09.750707+00
606	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:17.946808+00
611	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:40.366421+00
613	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:54.8768+00
616	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:10.425888+00
618	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:18.627006+00
623	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:52.199327+00
625	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:55.562115+00
628	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:43:11.130026+00
567	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:09.761758+00
569	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:12.272166+00
572	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:27.762283+00
574	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:35.980848+00
579	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:58.457753+00
581	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:12.974202+00
584	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:28.584991+00
586	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:36.807195+00
591	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:59.192045+00
593	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:13.680366+00
596	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:29.123111+00
598	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:37.449558+00
603	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:59.885553+00
605	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:14.452163+00
608	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:29.920188+00
610	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:38.23923+00
615	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:00.670767+00
617	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:15.148382+00
620	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:30.652829+00
622	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:52.15522+00
627	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:43:01.321521+00
629	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:43:15.809537+00
571	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:18.024681+00
573	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:32.494583+00
576	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:47.95823+00
578	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:38:56.328348+00
583	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:18.722046+00
585	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:33.311465+00
588	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:48.754828+00
590	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:39:56.919898+00
595	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:19.431674+00
597	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:33.970507+00
600	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:49.427716+00
602	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:40:57.750906+00
607	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:20.082779+00
609	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:34.621614+00
612	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:50.174464+00
614	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:41:58.374478+00
619	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:20.913806+00
621	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:52.115345+00
624	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:52.214451+00
626	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:42:59.190772+00
630	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:11.18325+00
631	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:14.661822+00
632	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:16.918643+00
633	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:26.695313+00
634	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:31.372189+00
635	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:34.838943+00
636	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:37.099545+00
637	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:46.866076+00
638	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:51.69041+00
639	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:55.16003+00
640	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:53:57.421111+00
641	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:07.042168+00
642	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:11.87131+00
643	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:15.334481+00
644	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:17.604339+00
645	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:27.293689+00
646	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:32.127441+00
647	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:35.612525+00
648	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:37.889447+00
649	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:47.550365+00
650	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:52.370213+00
651	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:55.835093+00
652	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:54:58.093115+00
653	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:07.878589+00
654	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:12.557359+00
655	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:16.205689+00
656	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:18.328481+00
657	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:28.094786+00
658	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:32.761891+00
659	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:36.37055+00
660	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:38.478098+00
661	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:48.242698+00
662	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:53.074105+00
663	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:56.535949+00
664	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:55:58.796407+00
665	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:08.565265+00
666	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:13.380144+00
668	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:18.954403+00
669	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:28.740755+00
670	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:33.506904+00
673	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:49.042367+00
675	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:57.325718+00
678	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:14.058835+00
684	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:39.919347+00
686	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:54.500411+00
689	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:09.999118+00
691	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:18.27713+00
696	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:40.714245+00
698	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:55.30133+00
701	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:10.643796+00
703	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:18.928499+00
706	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:35.649866+00
711	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:59.450143+00
716	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:21.860016+00
718	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:36.451348+00
721	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:51.981153+00
723	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:00.179881+00
728	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:22.59931+00
730	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:37.193147+00
733	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:52.691547+00
735	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:00.970008+00
740	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:23.369663+00
742	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:37.79545+00
745	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:53.286472+00
747	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:01.557945+00
752	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:24.035563+00
754	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:38.633394+00
667	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:16.844225+00
671	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:37.100952+00
672	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:39.261197+00
674	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:53.712848+00
676	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:56:59.438999+00
677	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:09.22637+00
679	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:17.531348+00
680	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:19.799536+00
681	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:29.466042+00
682	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:34.340645+00
683	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:37.806225+00
685	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:49.684157+00
687	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:57:57.960809+00
688	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:00.228252+00
690	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:14.818495+00
692	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:20.538873+00
693	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:30.158477+00
694	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:34.977726+00
695	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:38.447262+00
697	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:50.486753+00
699	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:58:58.761942+00
700	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:00.873014+00
702	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:15.462638+00
704	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:21.195273+00
705	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:30.974408+00
707	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:39.26561+00
708	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:41.381189+00
709	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:51.16863+00
710	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 16:59:55.987447+00
712	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:01.71055+00
713	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:11.476802+00
714	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:16.140212+00
715	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:19.748904+00
717	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:31.632753+00
719	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:39.91123+00
720	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:42.171346+00
722	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:00:56.708247+00
724	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:02.437411+00
725	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:12.205861+00
726	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:16.874867+00
727	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:20.485675+00
729	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:32.366481+00
731	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:40.658311+00
732	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:42.921936+00
734	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:01:57.35696+00
736	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:03.07993+00
737	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:12.845088+00
738	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:17.655134+00
739	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:21.11283+00
741	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:33.132986+00
743	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:41.409112+00
744	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:43.517701+00
746	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:02:58.09842+00
748	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:03.815368+00
749	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:13.624381+00
750	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:18.299631+00
753	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:33.813885+00
755	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:42.097118+00
751	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:21.919692+00
756	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:44.353932+00
757	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:54.128683+00
758	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:03:58.79435+00
759	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:02.412702+00
760	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:04.523546+00
761	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:14.299759+00
762	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:19.114181+00
763	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:22.575863+00
764	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:24.840676+00
765	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:34.61248+00
766	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:39.277042+00
767	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:42.894925+00
768	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:45.010162+00
769	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:54.777973+00
770	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:04:59.597355+00
771	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:05:03.062893+00
772	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-05 17:05:05.321506+00
773	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:09.473056+00
774	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:12.949448+00
775	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:15.209276+00
776	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:24.972588+00
777	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:29.637145+00
778	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:33.247652+00
779	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:35.356989+00
780	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:45.127927+00
781	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:49.939507+00
782	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:53.406249+00
783	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:51:55.66172+00
784	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:05.426656+00
785	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:10.088112+00
786	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:13.695806+00
787	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:15.817422+00
788	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:25.584658+00
789	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:30.407264+00
790	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:33.865412+00
791	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:36.120903+00
792	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:45.886924+00
793	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:50.70578+00
794	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:54.161952+00
795	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:52:56.417992+00
796	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:06.185115+00
797	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:10.850125+00
798	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:14.462971+00
799	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:16.577978+00
800	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:26.347452+00
801	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:31.163611+00
802	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:34.621579+00
803	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:36.882495+00
804	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:46.645048+00
805	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:51.306972+00
806	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:54.914833+00
807	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:53:57.021523+00
808	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:06.791928+00
809	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:11.612279+00
810	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:15.076972+00
812	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:27.112419+00
813	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:31.775823+00
815	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:37.50416+00
818	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:55.53929+00
820	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:07.559819+00
821	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:12.372734+00
823	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:18.087547+00
826	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:36.133108+00
828	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:48.031848+00
829	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:52.852154+00
831	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:58.575946+00
834	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:16.628025+00
836	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:28.499166+00
837	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:33.319563+00
839	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:39.053937+00
842	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:57.106133+00
844	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:08.988912+00
845	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:13.806198+00
847	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:19.54011+00
850	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:37.585761+00
852	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:49.472402+00
853	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:54.29482+00
855	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:00.019158+00
858	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:18.057397+00
860	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:29.933794+00
861	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:34.749111+00
863	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:40.473453+00
866	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:58.513223+00
869	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:15.200453+00
870	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:18.666075+00
872	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:30.706508+00
873	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:35.376413+00
875	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:41.086647+00
878	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:59.266815+00
880	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:11.143254+00
881	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:15.953946+00
883	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:21.673926+00
886	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:39.709025+00
888	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:51.590044+00
889	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:56.407846+00
891	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:02.149422+00
895	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:22.300506+00
896	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:32.069878+00
899	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:42.614648+00
902	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:00.654932+00
904	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:12.549366+00
905	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:17.359827+00
811	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:17.341638+00
814	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:35.38765+00
816	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:47.272624+00
817	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:52.08188+00
819	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:54:57.796839+00
822	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:15.830827+00
824	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:27.851091+00
825	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:32.515344+00
827	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:38.253701+00
830	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:55:56.314304+00
832	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:08.348179+00
833	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:13.013472+00
835	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:18.733211+00
838	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:36.78143+00
840	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:48.818933+00
841	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:53.490282+00
843	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:56:59.215626+00
846	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:17.266634+00
848	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:29.305996+00
849	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:33.973175+00
851	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:39.699974+00
854	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:57:57.764012+00
856	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:09.78364+00
857	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:14.446228+00
859	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:20.166984+00
862	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:38.215469+00
864	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:50.241908+00
865	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:58:54.902039+00
867	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:00.621251+00
868	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:10.390265+00
871	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:20.93675+00
874	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:38.982168+00
876	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:50.849508+00
877	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 14:59:55.660028+00
879	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:01.37724+00
882	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:19.414534+00
884	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:31.435505+00
885	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:36.101766+00
887	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:41.823524+00
890	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:00:59.875369+00
892	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:11.919767+00
893	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:16.581054+00
894	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:20.190809+00
897	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:36.895037+00
898	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:40.356636+00
900	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:52.375637+00
901	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:01:57.045533+00
903	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:02.77381+00
906	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:20.82017+00
907	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:23.076956+00
908	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:32.842586+00
909	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:37.651282+00
910	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:41.116137+00
911	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:43.372381+00
912	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:53.139572+00
913	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:02:57.818108+00
915	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:03.553106+00
918	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:21.599779+00
920	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:33.626531+00
921	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:38.295315+00
923	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:44.011166+00
926	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:02.050163+00
928	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:14.091087+00
929	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:18.771378+00
931	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:24.499316+00
934	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:42.552949+00
936	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:54.447228+00
937	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:59.263352+00
939	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:04.995912+00
942	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:23.050244+00
944	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:34.926288+00
945	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:39.746342+00
947	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:45.475048+00
950	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:03.522739+00
952	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:15.410629+00
953	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:20.230273+00
955	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:25.95369+00
958	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:44.011575+00
960	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:55.915703+00
961	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:00.733164+00
963	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:06.449983+00
966	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:24.489883+00
968	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:36.370117+00
969	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:41.182174+00
971	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:46.912913+00
974	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:04.965323+00
976	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:16.846263+00
977	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:21.666196+00
979	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:27.395917+00
982	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:45.431219+00
984	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:57.468444+00
985	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:02.153955+00
987	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:07.877947+00
990	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:25.916463+00
992	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:37.943365+00
993	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:42.603411+00
995	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:48.320541+00
998	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:06.377332+00
1000	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:18.414632+00
1001	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:23.077917+00
1003	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:28.805349+00
1006	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:46.858273+00
1008	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:58.905634+00
1009	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:11:03.574005+00
1011	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:11:09.311265+00
914	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:01.284409+00
916	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:13.319668+00
917	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:18.139698+00
919	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:23.855376+00
922	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:41.905782+00
924	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:53.773943+00
925	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:03:58.588985+00
927	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:04.310129+00
930	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:22.38785+00
932	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:34.270576+00
933	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:39.091552+00
935	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:04:44.818117+00
938	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:02.730662+00
940	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:14.767635+00
941	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:19.588313+00
943	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:25.306994+00
946	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:43.211817+00
948	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:05:55.24899+00
949	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:00.061341+00
951	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:05.784628+00
954	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:23.692639+00
956	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:35.719506+00
957	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:40.5377+00
959	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:06:46.135018+00
962	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:04.190673+00
964	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:16.216726+00
965	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:21.029875+00
967	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:26.749998+00
970	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:44.642255+00
972	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:07:56.691234+00
973	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:01.502469+00
975	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:07.225649+00
978	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:25.139366+00
980	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:37.163436+00
981	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:41.973838+00
983	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:08:47.703049+00
986	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:05.618712+00
988	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:17.642009+00
989	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:22.457919+00
991	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:28.178229+00
994	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:46.214623+00
996	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:09:58.092088+00
997	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:02.911113+00
999	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:08.640654+00
1002	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:26.694129+00
1004	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:38.574882+00
1005	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:43.39241+00
1007	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:10:49.124064+00
1010	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-06 15:11:07.048359+00
1012	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:23:43.864693+00
1013	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:23:47.344419+00
1014	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:23:49.60222+00
1015	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:23:59.369905+00
1016	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:04.038269+00
1017	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:07.652666+00
1018	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:09.762305+00
1019	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:19.543952+00
1020	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:24.357605+00
1021	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:27.817155+00
1022	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:30.087276+00
1023	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:39.84921+00
1024	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:44.517559+00
1025	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:48.124916+00
1026	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:50.232624+00
1027	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:24:59.995338+00
1028	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:04.806837+00
1029	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:08.265863+00
1030	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:10.523662+00
1031	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:20.28891+00
1032	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:24.953724+00
1033	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:28.563611+00
1034	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:30.674495+00
1035	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:40.440955+00
1036	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:45.253162+00
1037	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:48.712356+00
1038	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:25:50.985088+00
1039	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:00.751953+00
1040	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:05.563669+00
1041	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:09.022106+00
1042	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:11.279837+00
1043	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:21.043082+00
1044	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:25.711801+00
1045	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:29.339636+00
1046	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:31.512881+00
1047	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:41.189511+00
1048	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:45.916324+00
1049	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:49.567681+00
1050	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:26:51.688565+00
1051	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:01.488254+00
1052	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:06.166319+00
1053	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:09.782696+00
1054	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:11.920842+00
1055	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:21.706352+00
1056	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:26.391804+00
1057	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:30.050025+00
1058	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:32.223171+00
1059	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:41.899969+00
1060	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:46.742648+00
1061	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:50.223623+00
1062	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:27:52.494145+00
1063	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:02.166329+00
1064	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:06.987416+00
1065	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:10.449509+00
1066	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:12.708186+00
1067	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:22.476031+00
1068	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:27.139315+00
1069	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:30.749306+00
1070	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:32.860071+00
1071	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:42.627446+00
1072	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:47.447025+00
1073	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:50.916388+00
1075	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:02.963918+00
1079	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:23.169469+00
1082	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:33.588044+00
1083	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:43.418076+00
1085	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:51.714286+00
1087	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:03.619515+00
1089	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:11.905939+00
1091	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:23.794277+00
1109	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:53.079276+00
1112	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:09.773126+00
1115	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:25.25549+00
1117	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:33.527207+00
1122	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:56.086376+00
1124	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:10.514471+00
1127	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:26.030308+00
1129	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:34.324371+00
1134	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:56.745732+00
1136	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:11.322425+00
1139	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:26.808754+00
1141	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:35.079798+00
1146	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:57.485578+00
1148	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:11.910854+00
1151	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:27.392973+00
1153	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:35.673876+00
1158	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:58.226865+00
1160	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:12.659833+00
1163	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:28.140246+00
1165	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:36.41038+00
1170	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:58.965905+00
1172	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:13.394502+00
1175	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:28.881099+00
1177	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:37.149061+00
1182	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:59.562131+00
1184	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:14.139503+00
1187	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:29.622177+00
1189	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:37.903291+00
1194	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:00.315506+00
1196	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:14.891206+00
1203	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:50.532478+00
1213	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:39.379523+00
1074	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:28:53.191005+00
1076	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:07.664731+00
1077	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:11.12625+00
1078	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:13.405931+00
1080	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:27.851035+00
1081	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:31.472318+00
1084	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:48.094562+00
1086	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:29:53.843831+00
1088	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:08.445448+00
1090	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:14.173059+00
1092	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:28.624176+00
1093	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:32.116444+00
1094	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:34.416539+00
1095	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:44.074649+00
1096	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:48.805297+00
1097	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:52.425921+00
1098	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:30:54.579154+00
1099	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:04.357348+00
1100	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:09.171792+00
1101	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:12.641338+00
1102	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:14.751802+00
1103	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:24.514407+00
1104	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:29.325808+00
1105	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:32.936152+00
1106	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:35.044756+00
1107	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:44.806798+00
1108	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:49.620551+00
1110	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:31:55.335886+00
1111	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:05.110617+00
1113	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:13.386375+00
1114	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:15.492695+00
1116	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:30.069338+00
1118	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:35.783826+00
1119	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:45.553145+00
1120	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:50.366108+00
1121	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:32:53.826255+00
1123	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:05.851896+00
1125	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:14.123701+00
1126	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:16.230508+00
1128	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:30.714875+00
1130	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:36.432793+00
1131	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:46.195384+00
1132	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:51.014691+00
1133	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:33:54.476732+00
1135	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:06.5108+00
1137	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:14.78298+00
1138	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:17.043862+00
1140	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:31.471153+00
1142	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:37.188918+00
1143	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:46.956013+00
1144	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:51.77146+00
1145	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:34:55.228893+00
1147	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:07.251383+00
1149	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:15.519406+00
1150	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:17.777165+00
1152	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:32.205575+00
1155	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:47.702221+00
1157	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:55.970428+00
1162	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:18.376274+00
1164	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:32.952702+00
1167	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:48.432554+00
1169	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:56.707698+00
1174	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:19.111078+00
1176	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:33.69147+00
1179	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:49.173434+00
1181	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:57.453901+00
1186	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:19.854785+00
1188	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:34.440929+00
1191	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:49.935325+00
1193	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:58.205484+00
1198	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:20.614216+00
1199	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:30.388994+00
1201	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:38.662595+00
1206	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:01.056186+00
1209	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:19.08951+00
1211	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:31.108615+00
1212	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:35.772949+00
1214	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:41.487662+00
1154	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:37.939762+00
1156	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:35:52.513321+00
1159	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:07.995042+00
1161	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:16.269885+00
1166	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:38.668794+00
1168	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:36:53.249968+00
1171	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:08.732912+00
1173	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:17.004413+00
1178	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:39.412279+00
1180	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:37:53.845463+00
1183	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:09.326134+00
1185	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:17.596632+00
1190	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:40.168788+00
1192	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:38:54.597046+00
1195	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:10.078198+00
1197	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:18.35317+00
1200	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:35.051661+00
1202	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:40.770838+00
1204	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:55.341663+00
1205	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:39:58.801111+00
1207	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:10.81848+00
1208	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:15.632532+00
1210	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:21.346572+00
1215	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:51.252254+00
1216	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:56.064843+00
1217	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:40:59.526975+00
1218	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:01.784432+00
1219	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:11.550318+00
1220	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:16.362828+00
1221	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:19.820224+00
1222	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:22.076472+00
1223	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:31.838408+00
1224	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:36.509054+00
1225	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:40.116746+00
1226	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:42.224091+00
1227	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:51.985271+00
1228	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:41:56.805133+00
1229	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:00.266164+00
1230	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:02.522647+00
1231	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:12.29039+00
1232	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:16.956401+00
1233	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:20.563162+00
1234	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:22.66892+00
1235	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:32.430023+00
1236	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:37.247498+00
1237	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:40.854732+00
1238	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:42.961035+00
1239	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:52.744289+00
1240	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:42:57.562784+00
1241	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:01.024048+00
1242	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:03.285895+00
1243	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:13.051981+00
1244	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:17.735976+00
1245	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:21.203428+00
1246	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:23.460809+00
1247	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:33.224199+00
1249	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:41.495917+00
1248	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:38.036157+00
1250	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 14:43:43.767047+00
1251	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:10.524537+00
1252	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:14.00601+00
1253	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:16.262354+00
1254	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:26.024364+00
1255	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:30.689142+00
1256	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:34.304447+00
1257	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:36.412491+00
1258	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:46.173861+00
1259	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:50.986362+00
1260	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:54.44857+00
1261	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:04:56.727271+00
1262	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:06.495228+00
1263	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:11.167786+00
1264	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:14.7744+00
1265	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:16.882915+00
1266	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:26.644462+00
1267	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:31.458425+00
1268	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:34.924496+00
1269	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:37.18003+00
1270	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:46.941735+00
1271	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:51.754337+00
1272	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:55.210879+00
1273	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:05:57.466895+00
1274	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:07.229835+00
1275	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:11.891582+00
1276	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:15.506538+00
1277	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:17.621293+00
1278	1	carton_added	25	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:27.385764+00
1279	1	carton_added	9	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:32.19763+00
1280	1	carton_added	13	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:35.66012+00
1281	1	carton_added	14	carton centroid entered the open_door box (synced with annotated video playback)	2026-08-07 15:06:37.916676+00
\.


--
-- TOC entry 3449 (class 0 OID 16401)
-- Dependencies: 218
-- Data for Name: trucks; Type: TABLE DATA; Schema: public; Owner: dispatch_user
--

COPY public.trucks (id, truck_code, plate_number, expected_count, loaded_count, status, created_at, updated_at, loading_started_at) FROM stdin;
1	TRUCK-01	0745	100	214	completed	2026-07-29 19:53:42.134473+00	2026-08-07 15:06:37.916676+00	2026-08-06 14:59:03.996727+00
\.


--
-- TOC entry 3447 (class 0 OID 16390)
-- Dependencies: 216
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: dispatch_user
--

COPY public.users (id, username, password_hash) FROM stdin;
1	admin	$2b$12$5V.faysBi5mzzbCnI1g5xuqQE0Ie3Fq26.md02yZU5cmOR4249Toq
\.


--
-- TOC entry 3460 (class 0 OID 0)
-- Dependencies: 219
-- Name: count_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dispatch_user
--

SELECT pg_catalog.setval('public.count_events_id_seq', 1281, true);


--
-- TOC entry 3461 (class 0 OID 0)
-- Dependencies: 217
-- Name: trucks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dispatch_user
--

SELECT pg_catalog.setval('public.trucks_id_seq', 4, true);


--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 215
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: dispatch_user
--

SELECT pg_catalog.setval('public.users_id_seq', 4, true);


--
-- TOC entry 3298 (class 2606 OID 16426)
-- Name: count_events count_events_pkey; Type: CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.count_events
    ADD CONSTRAINT count_events_pkey PRIMARY KEY (id);


--
-- TOC entry 3294 (class 2606 OID 16413)
-- Name: trucks trucks_pkey; Type: CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.trucks
    ADD CONSTRAINT trucks_pkey PRIMARY KEY (id);


--
-- TOC entry 3296 (class 2606 OID 16415)
-- Name: trucks trucks_truck_code_key; Type: CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.trucks
    ADD CONSTRAINT trucks_truck_code_key UNIQUE (truck_code);


--
-- TOC entry 3290 (class 2606 OID 16397)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 3292 (class 2606 OID 16399)
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- TOC entry 3302 (class 2620 OID 24630)
-- Name: count_events trg_count_events_notify; Type: TRIGGER; Schema: public; Owner: dispatch_user
--

CREATE TRIGGER trg_count_events_notify AFTER INSERT ON public.count_events FOR EACH ROW EXECUTE FUNCTION public.notify_dispatch_change();


--
-- TOC entry 3300 (class 2620 OID 24629)
-- Name: trucks trg_trucks_notify; Type: TRIGGER; Schema: public; Owner: dispatch_user
--

CREATE TRIGGER trg_trucks_notify AFTER INSERT OR DELETE OR UPDATE ON public.trucks FOR EACH ROW EXECUTE FUNCTION public.notify_dispatch_change();


--
-- TOC entry 3301 (class 2620 OID 24631)
-- Name: trucks trg_trucks_updated_at; Type: TRIGGER; Schema: public; Owner: dispatch_user
--

CREATE TRIGGER trg_trucks_updated_at BEFORE UPDATE ON public.trucks FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 3299 (class 2606 OID 16427)
-- Name: count_events count_events_truck_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: dispatch_user
--

ALTER TABLE ONLY public.count_events
    ADD CONSTRAINT count_events_truck_id_fkey FOREIGN KEY (truck_id) REFERENCES public.trucks(id) ON DELETE CASCADE;


-- Completed on 2026-08-08 19:53:43 IST

--
-- PostgreSQL database dump complete
--

\unrestrict Nzl4LJslRgEazbujj1UJZaQ1zu49FJRwlTsFF1WaNXME7dazogla41Kj3CllpQD

