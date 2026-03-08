--
-- PostgreSQL database dump
--

\restrict gma7SrFWkSFcSZWIB1kXsohvp8OfA9MND7Ss6lDkNi5dRISoZfAOL0NX49ySo3Y

-- Dumped from database version 17.8
-- Dumped by pg_dump version 17.8

-- Started on 2026-03-08 13:26:10

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
-- TOC entry 922 (class 1247 OID 16644)
-- Name: diet_pref; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.diet_pref AS ENUM (
    'Veg',
    'Non-Veg',
    'Vegan',
    'Eggitarian'
);


ALTER TYPE public.diet_pref OWNER TO postgres;

--
-- TOC entry 934 (class 1247 OID 16688)
-- Name: meal_slot_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.meal_slot_type AS ENUM (
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack'
);


ALTER TYPE public.meal_slot_type OWNER TO postgres;

--
-- TOC entry 928 (class 1247 OID 16670)
-- Name: price_volatility; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.price_volatility AS ENUM (
    'High',
    'Medium',
    'Low',
    'Fixed'
);


ALTER TYPE public.price_volatility OWNER TO postgres;

--
-- TOC entry 925 (class 1247 OID 16654)
-- Name: staple_cat; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.staple_cat AS ENUM (
    'Vegetable',
    'Grain',
    'Protein',
    'Dairy',
    'Oil',
    'Pantry',
    'Garnish'
);


ALTER TYPE public.staple_cat OWNER TO postgres;

--
-- TOC entry 931 (class 1247 OID 16680)
-- Name: stock_state; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.stock_state AS ENUM (
    'In-Stock',
    'Running-Low',
    'Out'
);


ALTER TYPE public.stock_state OWNER TO postgres;

--
-- TOC entry 937 (class 1247 OID 16698)
-- Name: user_action; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_action AS ENUM (
    'Accepted',
    'Swapped',
    'Modified'
);


ALTER TYPE public.user_action OWNER TO postgres;

--
-- TOC entry 251 (class 1255 OID 16491)
-- Name: process_daily_price(integer, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_daily_price(p_ingredient_id integer, p_price numeric) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_high_price DECIMAL(10,2);
    v_last_price DECIMAL(10,2);
    v_alert_msg TEXT;
BEGIN
    -- 1. Get the High Alert threshold and the previous price
    SELECT high_alert_price INTO v_high_price 
    FROM ingredient_master WHERE id = p_ingredient_id;
    
    SELECT recorded_price INTO v_last_price 
    FROM price_logs WHERE ingredient_id = p_ingredient_id 
    ORDER BY recorded_at DESC LIMIT 1;

    -- 2. Insert into the permanent log
    INSERT INTO price_logs (ingredient_id, recorded_price, recorded_at)
    VALUES (p_ingredient_id, p_price, NOW());

    -- 3. The Logic Check (Wave 5 / Momentum Check)
    IF p_price >= v_high_price THEN
        v_alert_msg := 'CRITICAL: Price is at or above Peak! Use stock, do not buy.';
    ELSIF p_price > v_last_price THEN
        v_alert_msg := 'WARNING: Price is climbing.';
    ELSE
        v_alert_msg := 'STABLE: Price entry recorded successfully.';
    END IF;

    RETURN v_alert_msg;
END;
$$;


ALTER FUNCTION public.process_daily_price(p_ingredient_id integer, p_price numeric) OWNER TO postgres;

--
-- TOC entry 252 (class 1255 OID 16539)
-- Name: process_market_entry(integer, numeric, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.process_market_entry(p_ingredient_id integer, p_price numeric, p_location_name character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_loc_id INT;
BEGIN
    -- Get or Create location ID
    SELECT id INTO v_loc_id FROM market_locations WHERE location_name = p_location_name;
    IF NOT FOUND THEN
        INSERT INTO market_locations (location_name) VALUES (p_location_name) RETURNING id INTO v_loc_id;
    END IF;

    -- Insert the log with location context
    INSERT INTO price_logs (ingredient_id, recorded_price, location_id, recorded_at)
    VALUES (p_ingredient_id, p_price, v_loc_id, NOW());

    RETURN 'Price recorded for ' || p_location_name;
END;
$$;


ALTER FUNCTION public.process_market_entry(p_ingredient_id integer, p_price numeric, p_location_name character varying) OWNER TO postgres;

--
-- TOC entry 253 (class 1255 OID 16630)
-- Name: update_last_updated_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_last_updated_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.last_updated = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_last_updated_column() OWNER TO postgres;

--
-- TOC entry 254 (class 1255 OID 24591)
-- Name: update_modified_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_modified_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_modified_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 246 (class 1259 OID 16841)
-- Name: event_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event_master (
    event_id uuid DEFAULT gen_random_uuid() NOT NULL,
    house_id uuid,
    event_name character varying(100) NOT NULL,
    event_date date NOT NULL,
    event_type character varying(50),
    is_sattvic_required boolean DEFAULT false,
    recurring_annual boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    icon text,
    event_code character varying(50),
    source character varying(10),
    region_code character varying(10),
    is_active boolean DEFAULT true,
    event_year integer,
    dietary_context public.diet_pref,
    local_name character varying(100),
    CONSTRAINT event_master_event_type_check CHECK (((event_type)::text = ANY ((ARRAY['Lunar'::character varying, 'Social'::character varying, 'Ritual'::character varying, 'Personal'::character varying])::text[]))),
    CONSTRAINT event_master_source_check CHECK (((source)::text = ANY ((ARRAY['ADMIN'::character varying, 'USER'::character varying])::text[])))
);


ALTER TABLE public.event_master OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16389)
-- Name: ingredient_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient_master (
    id integer NOT NULL,
    shelf_life_days integer DEFAULT 7 NOT NULL,
    momentum_weight numeric(5,2) DEFAULT 1.0,
    peak_threshold numeric(10,2) DEFAULT 1277.00,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    high_alert_price numeric(10,2)
);


ALTER TABLE public.ingredient_master OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 16399)
-- Name: ingredient_translations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingredient_translations (
    ingredient_id integer NOT NULL,
    language_code character varying(5) NOT NULL,
    display_name text NOT NULL
);


ALTER TABLE public.ingredient_translations OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16417)
-- Name: price_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_logs (
    id integer NOT NULL,
    ingredient_id integer,
    recorded_price numeric(10,2) NOT NULL,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    location_id integer
);


ALTER TABLE public.price_logs OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 16486)
-- Name: form_helper; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.form_helper AS
 SELECT m.id,
    t.display_name,
    m.high_alert_price,
    ( SELECT price_logs.recorded_price
           FROM public.price_logs
          WHERE (price_logs.ingredient_id = m.id)
          ORDER BY price_logs.recorded_at DESC
         LIMIT 1) AS last_price
   FROM (public.ingredient_master m
     JOIN public.ingredient_translations t ON ((m.id = t.ingredient_id)))
  WHERE ((t.language_code)::text = 'ta'::text);


ALTER VIEW public.form_helper OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 16728)
-- Name: household_inventory; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.household_inventory (
    house_id uuid NOT NULL,
    staple_id character varying(10) NOT NULL,
    stock_status public.stock_state DEFAULT 'Out'::public.stock_state,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.household_inventory OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 16705)
-- Name: household_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.household_master (
    household_id uuid NOT NULL,
    house_name character varying(100) NOT NULL,
    primary_region character varying(50),
    dietary_preference public.diet_pref DEFAULT 'Veg'::public.diet_pref
);


ALTER TABLE public.household_master OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 16711)
-- Name: household_members; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.household_members (
    member_id uuid NOT NULL,
    house_id uuid,
    name character varying(50) NOT NULL,
    is_child boolean DEFAULT false
);


ALTER TABLE public.household_members OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 16388)
-- Name: ingredient_master_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingredient_master_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ingredient_master_id_seq OWNER TO postgres;

--
-- TOC entry 5053 (class 0 OID 0)
-- Dependencies: 217
-- Name: ingredient_master_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingredient_master_id_seq OWNED BY public.ingredient_master.id;


--
-- TOC entry 220 (class 1259 OID 16411)
-- Name: ingredient_summary; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.ingredient_summary AS
 SELECT m.id,
    t_en.display_name AS name_en,
    t_ta.display_name AS name_ta,
    m.shelf_life_days,
    m.momentum_weight
   FROM ((public.ingredient_master m
     LEFT JOIN public.ingredient_translations t_en ON (((m.id = t_en.ingredient_id) AND ((t_en.language_code)::text = 'en'::text))))
     LEFT JOIN public.ingredient_translations t_ta ON (((m.id = t_ta.ingredient_id) AND ((t_ta.language_code)::text = 'ta'::text))));


ALTER VIEW public.ingredient_summary OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16467)
-- Name: market_alerts; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.market_alerts AS
 WITH latestrsi AS (
         SELECT sub.ingredient_id,
            avg(
                CASE
                    WHEN (sub.diff > (0)::numeric) THEN sub.diff
                    ELSE (0)::numeric
                END) AS avg_gain,
            avg(
                CASE
                    WHEN (sub.diff < (0)::numeric) THEN abs(sub.diff)
                    ELSE (0)::numeric
                END) AS avg_loss
           FROM ( SELECT price_logs.ingredient_id,
                    (price_logs.recorded_price - lag(price_logs.recorded_price) OVER (PARTITION BY price_logs.ingredient_id ORDER BY price_logs.recorded_at)) AS diff
                   FROM public.price_logs) sub
          GROUP BY sub.ingredient_id
        ), finallogic AS (
         SELECT l.ingredient_id,
            (l.avg_gain / NULLIF(l.avg_loss, (0)::numeric)) AS rs,
            m.high_alert_price,
            ( SELECT price_logs.recorded_price
                   FROM public.price_logs
                  WHERE (price_logs.ingredient_id = l.ingredient_id)
                  ORDER BY price_logs.recorded_at DESC
                 LIMIT 1) AS current_price
           FROM (latestrsi l
             JOIN public.ingredient_master m ON ((l.ingredient_id = m.id)))
        )
 SELECT t.display_name,
    f.current_price,
        CASE
            WHEN ((((100)::numeric - ((100)::numeric / ((1)::numeric + f.rs))) > (70)::numeric) AND (f.current_price >= f.high_alert_price)) THEN 'PEAK_ALERT'::text
            WHEN (((100)::numeric - ((100)::numeric / ((1)::numeric + f.rs))) < (30)::numeric) THEN 'BUY_SIGNAL'::text
            ELSE 'STABLE'::text
        END AS status_code
   FROM (finallogic f
     JOIN public.ingredient_translations t ON ((f.ingredient_id = t.ingredient_id)))
  WHERE ((t.language_code)::text = 'ta'::text);


ALTER VIEW public.market_alerts OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 16505)
-- Name: market_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.market_locations (
    id integer NOT NULL,
    location_name character varying(50),
    currency character varying(10) DEFAULT 'INR'::character varying
);


ALTER TABLE public.market_locations OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16504)
-- Name: market_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.market_locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.market_locations_id_seq OWNER TO postgres;

--
-- TOC entry 5054 (class 0 OID 0)
-- Dependencies: 231
-- Name: market_locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.market_locations_id_seq OWNED BY public.market_locations.id;


--
-- TOC entry 229 (class 1259 OID 16492)
-- Name: system_alerts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.system_alerts (
    status_code character varying(20) NOT NULL,
    language_code character varying(5),
    display_text text
);


ALTER TABLE public.system_alerts OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 16499)
-- Name: market_signal_dashboard; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.market_signal_dashboard AS
 WITH rsi_data AS (
         SELECT s.ingredient_id,
            ((100)::numeric - ((100)::numeric / ((1)::numeric + (avg(
                CASE
                    WHEN (s.diff > (0)::numeric) THEN s.diff
                    ELSE (0)::numeric
                END) / NULLIF(avg(
                CASE
                    WHEN (s.diff < (0)::numeric) THEN abs(s.diff)
                    ELSE (0)::numeric
                END), (0)::numeric))))) AS rsi_val
           FROM ( SELECT price_logs.ingredient_id,
                    (price_logs.recorded_price - lag(price_logs.recorded_price) OVER (PARTITION BY price_logs.ingredient_id ORDER BY price_logs.recorded_at)) AS diff
                   FROM public.price_logs) s
          GROUP BY s.ingredient_id
        )
 SELECT t.display_name AS item_name,
    p.recorded_price AS current_price,
    sa.display_text AS status_label
   FROM ((((public.ingredient_master m
     JOIN public.ingredient_translations t ON ((m.id = t.ingredient_id)))
     LEFT JOIN rsi_data r ON ((m.id = r.ingredient_id)))
     LEFT JOIN LATERAL ( SELECT price_logs.recorded_price
           FROM public.price_logs
          WHERE (price_logs.ingredient_id = m.id)
          ORDER BY price_logs.recorded_at DESC
         LIMIT 1) p ON (true))
     JOIN public.system_alerts sa ON (((sa.status_code)::text =
        CASE
            WHEN (r.rsi_val >= (70)::numeric) THEN 'PEAK_ALERT'::text
            WHEN (r.rsi_val <= (30)::numeric) THEN 'BUY_SIGNAL'::text
            ELSE 'STABLE'::text
        END)))
  WHERE (((t.language_code)::text = 'ta'::text) AND ((sa.language_code)::text = 'ta'::text));


ALTER VIEW public.market_signal_dashboard OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 16805)
-- Name: meal_attendance_link; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_attendance_link (
    event_id uuid NOT NULL,
    member_id uuid NOT NULL
);


ALTER TABLE public.meal_attendance_link OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 16859)
-- Name: meal_attendance_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_attendance_log (
    attendance_id uuid DEFAULT gen_random_uuid() NOT NULL,
    session_id uuid,
    meal_date date NOT NULL,
    meal_slot character varying(20),
    absent_member_ids uuid[],
    guest_count integer DEFAULT 0,
    guest_names text,
    user_context_tag character varying(50),
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT meal_attendance_log_meal_slot_check CHECK (((meal_slot)::text = ANY ((ARRAY['Breakfast'::character varying, 'Lunch'::character varying, 'Dinner'::character varying])::text[])))
);


ALTER TABLE public.meal_attendance_log OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 16789)
-- Name: meal_event_detail; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_event_detail (
    detail_id uuid NOT NULL,
    event_id uuid,
    recipe_id uuid,
    is_remix boolean DEFAULT false,
    action_taken public.user_action,
    price_wave_context character varying(50),
    original_suggested_recipe_id uuid,
    acceptance_points integer DEFAULT 0,
    change_reason_code character varying(20)
);


ALTER TABLE public.meal_event_detail OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 16776)
-- Name: meal_event_header; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.meal_event_header (
    event_id uuid NOT NULL,
    house_id uuid,
    meal_slot public.meal_slot_type NOT NULL,
    event_date date NOT NULL,
    base_count integer DEFAULT 1,
    guest_count integer DEFAULT 0,
    total_headcount integer GENERATED ALWAYS AS ((base_count + guest_count)) STORED
);


ALTER TABLE public.meal_event_header OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 16473)
-- Name: price_input_buffer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_input_buffer (
    id integer NOT NULL,
    ingredient_id integer,
    input_price numeric(10,2),
    is_validated boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.price_input_buffer OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16472)
-- Name: price_input_buffer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_input_buffer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_input_buffer_id_seq OWNER TO postgres;

--
-- TOC entry 5055 (class 0 OID 0)
-- Dependencies: 226
-- Name: price_input_buffer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_input_buffer_id_seq OWNED BY public.price_input_buffer.id;


--
-- TOC entry 221 (class 1259 OID 16416)
-- Name: price_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_logs_id_seq OWNER TO postgres;

--
-- TOC entry 5056 (class 0 OID 0)
-- Dependencies: 221
-- Name: price_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_logs_id_seq OWNED BY public.price_logs.id;


--
-- TOC entry 224 (class 1259 OID 16430)
-- Name: price_summaries_historical; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_summaries_historical (
    id integer NOT NULL,
    ingredient_id integer,
    period_type character varying(10),
    period_label character varying(20),
    avg_price numeric(10,2),
    min_price numeric(10,2),
    max_price numeric(10,2)
);


ALTER TABLE public.price_summaries_historical OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16429)
-- Name: price_summaries_historical_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.price_summaries_historical_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.price_summaries_historical_id_seq OWNER TO postgres;

--
-- TOC entry 5057 (class 0 OID 0)
-- Dependencies: 223
-- Name: price_summaries_historical_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.price_summaries_historical_id_seq OWNED BY public.price_summaries_historical.id;


--
-- TOC entry 241 (class 1259 OID 16763)
-- Name: recipe_content_vault; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_content_vault (
    recipe_id uuid NOT NULL,
    hero_image_url character varying(255),
    carousel_thumb_url character varying(255),
    prep_steps text,
    ingredients_json jsonb
);


ALTER TABLE public.recipe_content_vault OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 16746)
-- Name: recipe_dna_master; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_dna_master (
    recipe_id uuid NOT NULL,
    dish_name character varying(100) NOT NULL,
    created_by_house_id uuid,
    diet_type public.diet_pref,
    is_sattvic boolean DEFAULT false,
    primary_staple_id character varying(10),
    remix_to_id uuid,
    is_scalable boolean DEFAULT true,
    intensity_level character varying(10) DEFAULT 'Medium'::character varying,
    CONSTRAINT recipe_dna_master_intensity_level_check CHECK (((intensity_level)::text = ANY ((ARRAY['Light'::character varying, 'Medium'::character varying, 'Heavy'::character varying])::text[])))
);


ALTER TABLE public.recipe_dna_master OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 24576)
-- Name: recipe_gap_analysis; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.recipe_gap_analysis (
    gap_id uuid DEFAULT gen_random_uuid() NOT NULL,
    suggested_menu_name character varying(255) NOT NULL,
    trigger_context text,
    regional_bias character varying(100),
    complexity_score integer,
    request_count integer DEFAULT 1,
    ai_draft_recipe jsonb,
    status character varying(50) DEFAULT 'PENDING'::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT recipe_gap_analysis_complexity_score_check CHECK (((complexity_score >= 1) AND (complexity_score <= 10)))
);


ALTER TABLE public.recipe_gap_analysis OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 16521)
-- Name: seasonal_price_benchmarks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seasonal_price_benchmarks (
    ingredient_id integer,
    season_id integer,
    expected_low numeric(10,2),
    expected_high numeric(10,2)
);


ALTER TABLE public.seasonal_price_benchmarks OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 16515)
-- Name: seasons; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.seasons (
    id integer NOT NULL,
    season_name character varying(20),
    start_month integer,
    end_month integer
);


ALTER TABLE public.seasons OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16514)
-- Name: seasons_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.seasons_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.seasons_id_seq OWNER TO postgres;

--
-- TOC entry 5058 (class 0 OID 0)
-- Dependencies: 233
-- Name: seasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.seasons_id_seq OWNED BY public.seasons.id;


--
-- TOC entry 238 (class 1259 OID 16722)
-- Name: staple_master_registry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.staple_master_registry (
    staple_id character varying(10) NOT NULL,
    item_name character varying(50) NOT NULL,
    category public.staple_cat,
    volatility public.price_volatility,
    is_sattvic boolean DEFAULT true
);


ALTER TABLE public.staple_master_registry OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 24603)
-- Name: v_combined_calendar; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_combined_calendar AS
 SELECT event_master.event_code,
    event_master.house_id,
    event_master.local_name,
    event_master.event_date,
    event_master.event_type,
    event_master.is_sattvic_required,
    event_master.icon,
    event_master.event_year,
    'ADMIN'::text AS data_source,
    false AS can_edit,
    1 AS priority
   FROM public.event_master
  WHERE ((event_master.source)::text = 'ADMIN'::text)
UNION ALL
 SELECT event_master.event_code,
    event_master.house_id,
    event_master.local_name,
    event_master.event_date,
    event_master.event_type,
    event_master.is_sattvic_required,
    event_master.icon,
    event_master.event_year,
    'USER'::text AS data_source,
    true AS can_edit,
    2 AS priority
   FROM public.event_master
  WHERE ((event_master.source)::text = 'USER'::text);


ALTER VIEW public.v_combined_calendar OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 16820)
-- Name: v_display_grid; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.v_display_grid AS
 SELECT r.recipe_id,
    r.dish_name,
    r.diet_type,
    r.created_by_house_id,
    c.hero_image_url,
    s.item_name AS core_staple,
    i.stock_status
   FROM (((public.recipe_dna_master r
     JOIN public.recipe_content_vault c ON ((r.recipe_id = c.recipe_id)))
     JOIN public.staple_master_registry s ON (((r.primary_staple_id)::text = (s.staple_id)::text)))
     LEFT JOIN public.household_inventory i ON (((s.staple_id)::text = (i.staple_id)::text)));


ALTER VIEW public.v_display_grid OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 16851)
-- Name: weekly_planning_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weekly_planning_session (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    house_id uuid NOT NULL,
    week_start_date date NOT NULL,
    session_status character varying(20) DEFAULT 'Draft'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.weekly_planning_session OWNER TO postgres;

--
-- TOC entry 4776 (class 2604 OID 16392)
-- Name: ingredient_master id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_master ALTER COLUMN id SET DEFAULT nextval('public.ingredient_master_id_seq'::regclass);


--
-- TOC entry 4787 (class 2604 OID 16508)
-- Name: market_locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.market_locations ALTER COLUMN id SET DEFAULT nextval('public.market_locations_id_seq'::regclass);


--
-- TOC entry 4784 (class 2604 OID 16476)
-- Name: price_input_buffer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_input_buffer ALTER COLUMN id SET DEFAULT nextval('public.price_input_buffer_id_seq'::regclass);


--
-- TOC entry 4781 (class 2604 OID 16420)
-- Name: price_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_logs ALTER COLUMN id SET DEFAULT nextval('public.price_logs_id_seq'::regclass);


--
-- TOC entry 4783 (class 2604 OID 16433)
-- Name: price_summaries_historical id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_summaries_historical ALTER COLUMN id SET DEFAULT nextval('public.price_summaries_historical_id_seq'::regclass);


--
-- TOC entry 4789 (class 2604 OID 16518)
-- Name: seasons id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seasons ALTER COLUMN id SET DEFAULT nextval('public.seasons_id_seq'::regclass);


--
-- TOC entry 4861 (class 2606 OID 24599)
-- Name: event_master event_master_event_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_master
    ADD CONSTRAINT event_master_event_code_key UNIQUE (event_code);


--
-- TOC entry 4863 (class 2606 OID 16850)
-- Name: event_master event_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event_master
    ADD CONSTRAINT event_master_pkey PRIMARY KEY (event_id);


--
-- TOC entry 4849 (class 2606 OID 16734)
-- Name: household_inventory household_inventory_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_inventory
    ADD CONSTRAINT household_inventory_pkey PRIMARY KEY (house_id, staple_id);


--
-- TOC entry 4843 (class 2606 OID 16710)
-- Name: household_master household_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_master
    ADD CONSTRAINT household_master_pkey PRIMARY KEY (household_id);


--
-- TOC entry 4845 (class 2606 OID 16716)
-- Name: household_members household_members_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_members
    ADD CONSTRAINT household_members_pkey PRIMARY KEY (member_id);


--
-- TOC entry 4825 (class 2606 OID 16398)
-- Name: ingredient_master ingredient_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_master
    ADD CONSTRAINT ingredient_master_pkey PRIMARY KEY (id);


--
-- TOC entry 4827 (class 2606 OID 16405)
-- Name: ingredient_translations ingredient_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_translations
    ADD CONSTRAINT ingredient_translations_pkey PRIMARY KEY (ingredient_id, language_code);


--
-- TOC entry 4837 (class 2606 OID 16513)
-- Name: market_locations market_locations_location_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.market_locations
    ADD CONSTRAINT market_locations_location_name_key UNIQUE (location_name);


--
-- TOC entry 4839 (class 2606 OID 16511)
-- Name: market_locations market_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.market_locations
    ADD CONSTRAINT market_locations_pkey PRIMARY KEY (id);


--
-- TOC entry 4859 (class 2606 OID 16809)
-- Name: meal_attendance_link meal_attendance_link_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_attendance_link
    ADD CONSTRAINT meal_attendance_link_pkey PRIMARY KEY (event_id, member_id);


--
-- TOC entry 4868 (class 2606 OID 16869)
-- Name: meal_attendance_log meal_attendance_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_attendance_log
    ADD CONSTRAINT meal_attendance_log_pkey PRIMARY KEY (attendance_id);


--
-- TOC entry 4857 (class 2606 OID 16794)
-- Name: meal_event_detail meal_event_detail_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_detail
    ADD CONSTRAINT meal_event_detail_pkey PRIMARY KEY (detail_id);


--
-- TOC entry 4855 (class 2606 OID 16783)
-- Name: meal_event_header meal_event_header_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_header
    ADD CONSTRAINT meal_event_header_pkey PRIMARY KEY (event_id);


--
-- TOC entry 4833 (class 2606 OID 16480)
-- Name: price_input_buffer price_input_buffer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_input_buffer
    ADD CONSTRAINT price_input_buffer_pkey PRIMARY KEY (id);


--
-- TOC entry 4829 (class 2606 OID 16423)
-- Name: price_logs price_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_logs
    ADD CONSTRAINT price_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4831 (class 2606 OID 16435)
-- Name: price_summaries_historical price_summaries_historical_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_summaries_historical
    ADD CONSTRAINT price_summaries_historical_pkey PRIMARY KEY (id);


--
-- TOC entry 4853 (class 2606 OID 16769)
-- Name: recipe_content_vault recipe_content_vault_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_content_vault
    ADD CONSTRAINT recipe_content_vault_pkey PRIMARY KEY (recipe_id);


--
-- TOC entry 4851 (class 2606 OID 16752)
-- Name: recipe_dna_master recipe_dna_master_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_dna_master
    ADD CONSTRAINT recipe_dna_master_pkey PRIMARY KEY (recipe_id);


--
-- TOC entry 4872 (class 2606 OID 24588)
-- Name: recipe_gap_analysis recipe_gap_analysis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_gap_analysis
    ADD CONSTRAINT recipe_gap_analysis_pkey PRIMARY KEY (gap_id);


--
-- TOC entry 4841 (class 2606 OID 16520)
-- Name: seasons seasons_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seasons
    ADD CONSTRAINT seasons_pkey PRIMARY KEY (id);


--
-- TOC entry 4847 (class 2606 OID 16727)
-- Name: staple_master_registry staple_master_registry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.staple_master_registry
    ADD CONSTRAINT staple_master_registry_pkey PRIMARY KEY (staple_id);


--
-- TOC entry 4835 (class 2606 OID 16498)
-- Name: system_alerts system_alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.system_alerts
    ADD CONSTRAINT system_alerts_pkey PRIMARY KEY (status_code);


--
-- TOC entry 4874 (class 2606 OID 24594)
-- Name: recipe_gap_analysis unique_menu_name; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_gap_analysis
    ADD CONSTRAINT unique_menu_name UNIQUE (suggested_menu_name);


--
-- TOC entry 4866 (class 2606 OID 16858)
-- Name: weekly_planning_session weekly_planning_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weekly_planning_session
    ADD CONSTRAINT weekly_planning_session_pkey PRIMARY KEY (session_id);


--
-- TOC entry 4864 (class 1259 OID 24601)
-- Name: idx_event_house_year; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_event_house_year ON public.event_master USING btree (house_id, event_year);


--
-- TOC entry 4869 (class 1259 OID 24590)
-- Name: idx_gap_region; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gap_region ON public.recipe_gap_analysis USING btree (regional_bias);


--
-- TOC entry 4870 (class 1259 OID 24589)
-- Name: idx_gap_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_gap_status ON public.recipe_gap_analysis USING btree (status);


--
-- TOC entry 4896 (class 2620 OID 24592)
-- Name: recipe_gap_analysis update_gap_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_gap_modtime BEFORE UPDATE ON public.recipe_gap_analysis FOR EACH ROW EXECUTE FUNCTION public.update_modified_column();


--
-- TOC entry 4895 (class 2620 OID 16745)
-- Name: household_inventory update_household_inventory_modtime; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_household_inventory_modtime BEFORE UPDATE ON public.household_inventory FOR EACH ROW EXECUTE FUNCTION public.update_last_updated_column();


--
-- TOC entry 4883 (class 2606 OID 16735)
-- Name: household_inventory household_inventory_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_inventory
    ADD CONSTRAINT household_inventory_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.household_master(household_id);


--
-- TOC entry 4884 (class 2606 OID 16740)
-- Name: household_inventory household_inventory_staple_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_inventory
    ADD CONSTRAINT household_inventory_staple_id_fkey FOREIGN KEY (staple_id) REFERENCES public.staple_master_registry(staple_id);


--
-- TOC entry 4882 (class 2606 OID 16717)
-- Name: household_members household_members_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.household_members
    ADD CONSTRAINT household_members_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.household_master(household_id);


--
-- TOC entry 4875 (class 2606 OID 16406)
-- Name: ingredient_translations ingredient_translations_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingredient_translations
    ADD CONSTRAINT ingredient_translations_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_master(id) ON DELETE CASCADE;


--
-- TOC entry 4892 (class 2606 OID 16810)
-- Name: meal_attendance_link meal_attendance_link_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_attendance_link
    ADD CONSTRAINT meal_attendance_link_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.meal_event_header(event_id);


--
-- TOC entry 4893 (class 2606 OID 16815)
-- Name: meal_attendance_link meal_attendance_link_member_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_attendance_link
    ADD CONSTRAINT meal_attendance_link_member_id_fkey FOREIGN KEY (member_id) REFERENCES public.household_members(member_id);


--
-- TOC entry 4894 (class 2606 OID 16870)
-- Name: meal_attendance_log meal_attendance_log_session_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_attendance_log
    ADD CONSTRAINT meal_attendance_log_session_id_fkey FOREIGN KEY (session_id) REFERENCES public.weekly_planning_session(session_id) ON DELETE CASCADE;


--
-- TOC entry 4889 (class 2606 OID 16795)
-- Name: meal_event_detail meal_event_detail_event_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_detail
    ADD CONSTRAINT meal_event_detail_event_id_fkey FOREIGN KEY (event_id) REFERENCES public.meal_event_header(event_id);


--
-- TOC entry 4890 (class 2606 OID 16826)
-- Name: meal_event_detail meal_event_detail_original_suggested_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_detail
    ADD CONSTRAINT meal_event_detail_original_suggested_recipe_id_fkey FOREIGN KEY (original_suggested_recipe_id) REFERENCES public.recipe_dna_master(recipe_id);


--
-- TOC entry 4891 (class 2606 OID 16800)
-- Name: meal_event_detail meal_event_detail_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_detail
    ADD CONSTRAINT meal_event_detail_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipe_dna_master(recipe_id);


--
-- TOC entry 4888 (class 2606 OID 16784)
-- Name: meal_event_header meal_event_header_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.meal_event_header
    ADD CONSTRAINT meal_event_header_house_id_fkey FOREIGN KEY (house_id) REFERENCES public.household_master(household_id);


--
-- TOC entry 4879 (class 2606 OID 16481)
-- Name: price_input_buffer price_input_buffer_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_input_buffer
    ADD CONSTRAINT price_input_buffer_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_master(id);


--
-- TOC entry 4876 (class 2606 OID 16424)
-- Name: price_logs price_logs_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_logs
    ADD CONSTRAINT price_logs_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_master(id);


--
-- TOC entry 4877 (class 2606 OID 16534)
-- Name: price_logs price_logs_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_logs
    ADD CONSTRAINT price_logs_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.market_locations(id);


--
-- TOC entry 4878 (class 2606 OID 16436)
-- Name: price_summaries_historical price_summaries_historical_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_summaries_historical
    ADD CONSTRAINT price_summaries_historical_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_master(id);


--
-- TOC entry 4887 (class 2606 OID 16770)
-- Name: recipe_content_vault recipe_content_vault_recipe_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_content_vault
    ADD CONSTRAINT recipe_content_vault_recipe_id_fkey FOREIGN KEY (recipe_id) REFERENCES public.recipe_dna_master(recipe_id);


--
-- TOC entry 4885 (class 2606 OID 16753)
-- Name: recipe_dna_master recipe_dna_master_created_by_house_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_dna_master
    ADD CONSTRAINT recipe_dna_master_created_by_house_id_fkey FOREIGN KEY (created_by_house_id) REFERENCES public.household_master(household_id);


--
-- TOC entry 4886 (class 2606 OID 16758)
-- Name: recipe_dna_master recipe_dna_master_primary_staple_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.recipe_dna_master
    ADD CONSTRAINT recipe_dna_master_primary_staple_id_fkey FOREIGN KEY (primary_staple_id) REFERENCES public.staple_master_registry(staple_id);


--
-- TOC entry 4880 (class 2606 OID 16524)
-- Name: seasonal_price_benchmarks seasonal_price_benchmarks_ingredient_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seasonal_price_benchmarks
    ADD CONSTRAINT seasonal_price_benchmarks_ingredient_id_fkey FOREIGN KEY (ingredient_id) REFERENCES public.ingredient_master(id);


--
-- TOC entry 4881 (class 2606 OID 16529)
-- Name: seasonal_price_benchmarks seasonal_price_benchmarks_season_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.seasonal_price_benchmarks
    ADD CONSTRAINT seasonal_price_benchmarks_season_id_fkey FOREIGN KEY (season_id) REFERENCES public.seasons(id);


-- Completed on 2026-03-08 13:26:12

--
-- PostgreSQL database dump complete
--

\unrestrict gma7SrFWkSFcSZWIB1kXsohvp8OfA9MND7Ss6lDkNi5dRISoZfAOL0NX49ySo3Y

