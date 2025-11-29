--
-- PostgreSQL database dump
--

\restrict RrSZ3IYaaj0uJ5xRqLXSOlLXo3orcv6v2DKdcPCsS51Ss1mcII8DACH1t7z4VGD

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.0

-- Started on 2025-11-29 03:36:17

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 222 (class 1259 OID 16405)
-- Name: api_test_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_test_results (
    test_id integer NOT NULL,
    carrier_id integer,
    test_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    test_case_id character varying(20),
    request_body text,
    response_body text,
    response_time numeric(5,2),
    status_code integer,
    test_status character varying(10),
    error_details text,
    tested_by character varying(100)
);


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE api_test_results; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.api_test_results IS 'Detailed logs of API testing activities';


--
-- TOC entry 221 (class 1259 OID 16404)
-- Name: api_test_results_test_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_test_results_test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 221
-- Name: api_test_results_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_test_results_test_id_seq OWNED BY public.api_test_results.test_id;


--
-- TOC entry 220 (class 1259 OID 16390)
-- Name: carriers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.carriers (
    carrier_id integer NOT NULL,
    carrier_name character varying(100) NOT NULL,
    api_endpoint character varying(500) NOT NULL,
    soap_action character varying(255),
    status character varying(20) DEFAULT 'Active'::character varying,
    avg_response_time numeric(5,2),
    success_rate numeric(5,2),
    date_added timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    notes text
);


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 220
-- Name: TABLE carriers; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.carriers IS 'Insurance carrier API endpoints and performance metrics';


--
-- TOC entry 223 (class 1259 OID 16420)
-- Name: carrier_performance_summary; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.carrier_performance_summary AS
 SELECT c.carrier_name,
    c.api_endpoint,
    c.status,
    count(t.test_id) AS total_tests,
    count(
        CASE
            WHEN ((t.test_status)::text = 'PASS'::text) THEN 1
            ELSE NULL::integer
        END) AS passed_tests,
    count(
        CASE
            WHEN ((t.test_status)::text = 'FAIL'::text) THEN 1
            ELSE NULL::integer
        END) AS failed_tests,
    round(avg(t.response_time), 2) AS avg_response_time,
    round((((count(
        CASE
            WHEN ((t.test_status)::text = 'PASS'::text) THEN 1
            ELSE NULL::integer
        END))::numeric / (count(t.test_id))::numeric) * (100)::numeric), 2) AS success_rate_percent
   FROM (public.carriers c
     LEFT JOIN public.api_test_results t ON ((c.carrier_id = t.carrier_id)))
  GROUP BY c.carrier_id, c.carrier_name, c.api_endpoint, c.status
  ORDER BY (round(avg(t.response_time), 2));


--
-- TOC entry 219 (class 1259 OID 16389)
-- Name: carriers_carrier_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.carriers_carrier_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5035 (class 0 OID 0)
-- Dependencies: 219
-- Name: carriers_carrier_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.carriers_carrier_id_seq OWNED BY public.carriers.carrier_id;


--
-- TOC entry 4868 (class 2604 OID 16408)
-- Name: api_test_results test_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_test_results ALTER COLUMN test_id SET DEFAULT nextval('public.api_test_results_test_id_seq'::regclass);


--
-- TOC entry 4865 (class 2604 OID 16393)
-- Name: carriers carrier_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carriers ALTER COLUMN carrier_id SET DEFAULT nextval('public.carriers_carrier_id_seq'::regclass);


--
-- TOC entry 5026 (class 0 OID 16405)
-- Dependencies: 222
-- Data for Name: api_test_results; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.api_test_results VALUES (1, 1, '2025-11-23 21:16:17.188546', 'TC-001', NULL, NULL, 1.20, 200, 'PASS', NULL, 'Kenny Clayton');
INSERT INTO public.api_test_results VALUES (2, 2, '2025-11-23 21:16:17.188546', 'TC-002', NULL, NULL, 0.80, 200, 'PASS', NULL, 'Kenny Clayton');
INSERT INTO public.api_test_results VALUES (3, 3, '2025-11-23 21:16:17.188546', 'TC-004', NULL, NULL, 1.50, 200, 'PASS', NULL, 'Kenny Clayton');
INSERT INTO public.api_test_results VALUES (4, 3, '2025-11-23 21:16:17.188546', 'TC-003', NULL, NULL, NULL, NULL, 'FAIL', 'ECONNRESET - NumberConversion endpoint unavailable. Documented in Jira KAN-1.', 'Kenny Clayton');


--
-- TOC entry 5024 (class 0 OID 16390)
-- Dependencies: 220
-- Data for Name: carriers; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.carriers VALUES (1, 'Carrier A - CountryInfo', 'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso', '', 'Active', 1.20, 100.00, '2025-11-23 21:14:45.174204', 'Returns country information. Used for location-based quote validation.');
INSERT INTO public.carriers VALUES (2, 'Carrier B - Calculator', 'http://www.dneonline.com/calculator.asmx', 'http://tempuri.org/Add', 'Active', 0.80, 100.00, '2025-11-23 21:14:45.174204', 'Premium calculation service. Fastest response time of all carriers.');
INSERT INTO public.carriers VALUES (3, 'Carrier C - Currency', 'http://webservices.oorsprong.org/websamples.countryinfo/CountryInfoService.wso', '', 'Active', 1.50, 100.00, '2025-11-23 21:14:45.174204', 'Alternative endpoint after NumberConversion service failed. See Jira KAN-1.');


--
-- TOC entry 5036 (class 0 OID 0)
-- Dependencies: 221
-- Name: api_test_results_test_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.api_test_results_test_id_seq', 4, true);


--
-- TOC entry 5037 (class 0 OID 0)
-- Dependencies: 219
-- Name: carriers_carrier_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.carriers_carrier_id_seq', 3, true);


--
-- TOC entry 4873 (class 2606 OID 16414)
-- Name: api_test_results api_test_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_test_results
    ADD CONSTRAINT api_test_results_pkey PRIMARY KEY (test_id);


--
-- TOC entry 4871 (class 2606 OID 16402)
-- Name: carriers carriers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.carriers
    ADD CONSTRAINT carriers_pkey PRIMARY KEY (carrier_id);


--
-- TOC entry 4874 (class 2606 OID 16415)
-- Name: api_test_results api_test_results_carrier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_test_results
    ADD CONSTRAINT api_test_results_carrier_id_fkey FOREIGN KEY (carrier_id) REFERENCES public.carriers(carrier_id);


-- Completed on 2025-11-29 03:36:17

--
-- PostgreSQL database dump complete
--

\unrestrict RrSZ3IYaaj0uJ5xRqLXSOlLXo3orcv6v2DKdcPCsS51Ss1mcII8DACH1t7z4VGD

