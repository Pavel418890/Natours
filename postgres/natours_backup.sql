--
-- PostgreSQL database dump
--

-- Dumped from database version 15.0 (Debian 15.0-1.pgdg110+1)
-- Dumped by pg_dump version 15.0 (Debian 15.0-1.pgdg110+1)

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
-- Name: bookings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.bookings (
    id bigint NOT NULL,
    price numeric(7,2) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    is_paid boolean NOT NULL,
    tour_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.bookings OWNER TO postgres;

--
-- Name: bookings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.bookings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookings_id_seq OWNER TO postgres;

--
-- Name: bookings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.bookings_id_seq OWNED BY public.bookings.id;


--
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id bigint NOT NULL,
    latitude numeric(10,6),
    longitude numeric(10,6),
    name character varying(500),
    day integer NOT NULL,
    tour_id bigint NOT NULL
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.locations_id_seq OWNER TO postgres;

--
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id bigint NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    photo character varying(100),
    user_id bigint NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.profiles_id_seq OWNER TO postgres;

--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.profiles_id_seq OWNED BY public.profiles.id;


--
-- Name: start_dates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.start_dates (
    id bigint NOT NULL,
    start_date timestamp with time zone NOT NULL,
    tour_id bigint NOT NULL
);


ALTER TABLE public.start_dates OWNER TO postgres;

--
-- Name: tours; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tours (
    id bigint NOT NULL,
    slug character varying(50),
    name character varying(200) NOT NULL,
    image_cover character varying(100) NOT NULL,
    duration integer NOT NULL,
    max_group_size integer NOT NULL,
    difficulty character varying(10) NOT NULL,
    price numeric(7,2) NOT NULL,
    discount_price numeric(7,2),
    summary character varying(255),
    description text,
    secret_tour boolean NOT NULL,
    CONSTRAINT natours_tour_discount_price_lte_general_price CHECK ((price > discount_price))
);


ALTER TABLE public.tours OWNER TO postgres;

--
-- Name: report_2021; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.report_2021 AS
 WITH tours_to_months(name, month) AS (
         SELECT tours.name,
            to_char(sd.start_date, 'Month'::text) AS to_char
           FROM (public.tours
             JOIN public.start_dates sd ON ((tours.id = sd.tour_id)))
          WHERE ((sd.start_date >= '2021-01-01 00:00:00+00'::timestamp with time zone) AND (sd.start_date <= '2021-12-31 00:00:00+00'::timestamp with time zone))
        )
 SELECT tours_to_months.month,
    count(tours_to_months.month) AS num_tours_starts,
    array_agg(tours_to_months.name) AS tours
   FROM tours_to_months
  GROUP BY tours_to_months.month
  ORDER BY (count(tours_to_months.month)) DESC
 LIMIT 12
  WITH NO DATA;


ALTER TABLE public.report_2021 OWNER TO postgres;

--
-- Name: report_2022; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.report_2022 AS
 WITH tours_to_months(name, month) AS (
         SELECT tours.name,
            to_char(sd.start_date, 'Month'::text) AS to_char
           FROM (public.tours
             JOIN public.start_dates sd ON ((tours.id = sd.tour_id)))
          WHERE ((sd.start_date >= '2022-01-01 00:00:00+00'::timestamp with time zone) AND (sd.start_date <= '2022-12-31 00:00:00+00'::timestamp with time zone))
        )
 SELECT tours_to_months.month,
    count(tours_to_months.month) AS num_tours_starts,
    array_agg(tours_to_months.name) AS tours
   FROM tours_to_months
  GROUP BY tours_to_months.month
  ORDER BY (count(tours_to_months.month)) DESC
 LIMIT 12
  WITH NO DATA;


ALTER TABLE public.report_2022 OWNER TO postgres;

--
-- Name: start_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.start_locations (
    id bigint NOT NULL,
    latitude numeric(10,6),
    longitude numeric(10,6),
    name character varying(500),
    address character varying(255) NOT NULL,
    tour_id bigint NOT NULL
);


ALTER TABLE public.start_locations OWNER TO postgres;

--
-- Name: tour_reviews; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tour_reviews (
    id bigint NOT NULL,
    review text NOT NULL,
    rating integer NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    tour_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.tour_reviews OWNER TO postgres;

--
-- Name: top_5_cheap_tours; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.top_5_cheap_tours AS
 SELECT tours.id,
    tours.name,
    tours.price,
    tours.summary,
    tours.difficulty,
    round(avg(tr.rating), 2) AS avg_rating
   FROM (public.tours
     JOIN public.tour_reviews tr ON ((tours.id = tr.tour_id)))
  GROUP BY tours.id, tours.name, tours.price, tours.summary, tours.difficulty
  ORDER BY (round(avg(tr.rating), 2)) DESC, tours.price DESC
 LIMIT 5;


ALTER TABLE public.top_5_cheap_tours OWNER TO postgres;

--
-- Name: tour_images; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tour_images (
    id bigint NOT NULL,
    image character varying(100) NOT NULL,
    tour_id bigint
);


ALTER TABLE public.tour_images OWNER TO postgres;

--
-- Name: tour_images_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tour_images_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tour_images_id_seq OWNER TO postgres;

--
-- Name: tour_images_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tour_images_id_seq OWNED BY public.tour_images.id;


--
-- Name: tour_reviews_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tour_reviews_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tour_reviews_id_seq OWNER TO postgres;

--
-- Name: tour_reviews_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tour_reviews_id_seq OWNED BY public.tour_reviews.id;


--
-- Name: tour_start_dates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tour_start_dates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tour_start_dates_id_seq OWNER TO postgres;

--
-- Name: tour_start_dates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tour_start_dates_id_seq OWNED BY public.start_dates.id;


--
-- Name: tour_start_location_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tour_start_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tour_start_location_id_seq OWNER TO postgres;

--
-- Name: tour_start_location_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tour_start_location_id_seq OWNED BY public.start_locations.id;


--
-- Name: tours_guides; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tours_guides (
    id integer NOT NULL,
    tour_id bigint NOT NULL,
    user_id bigint NOT NULL
);


ALTER TABLE public.tours_guides OWNER TO postgres;

--
-- Name: tours_guides_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tours_guides_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tours_guides_id_seq OWNER TO postgres;

--
-- Name: tours_guides_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tours_guides_id_seq OWNED BY public.tours_guides.id;


--
-- Name: tours_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tours_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tours_id_seq OWNER TO postgres;

--
-- Name: tours_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tours_id_seq OWNED BY public.tours.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    email character varying(255) NOT NULL,
    role character varying(15) NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    is_active boolean NOT NULL,
    is_email_confirmed boolean NOT NULL,
    password_reset_token character varying(255),
    password_changed_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: bookings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings ALTER COLUMN id SET DEFAULT nextval('public.bookings_id_seq'::regclass);


--
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- Name: profiles id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles ALTER COLUMN id SET DEFAULT nextval('public.profiles_id_seq'::regclass);


--
-- Name: start_dates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_dates ALTER COLUMN id SET DEFAULT nextval('public.tour_start_dates_id_seq'::regclass);


--
-- Name: start_locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_locations ALTER COLUMN id SET DEFAULT nextval('public.tour_start_location_id_seq'::regclass);


--
-- Name: tour_images id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_images ALTER COLUMN id SET DEFAULT nextval('public.tour_images_id_seq'::regclass);


--
-- Name: tour_reviews id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_reviews ALTER COLUMN id SET DEFAULT nextval('public.tour_reviews_id_seq'::regclass);


--
-- Name: tours id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours ALTER COLUMN id SET DEFAULT nextval('public.tours_id_seq'::regclass);


--
-- Name: tours_guides id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours_guides ALTER COLUMN id SET DEFAULT nextval('public.tours_guides_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: bookings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.bookings (id, price, created_at, is_paid, tour_id, user_id) FROM stdin;
\.


--
-- Data for Name: locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.locations (id, latitude, longitude, name, day, tour_id) FROM stdin;
19	33.022843	-116.830104	San Diego Skydive	6	6
9	39.604990	-106.516623	Beaver Creek	2	3
5	51.417611	-116.214531	Banff National Park	1	2
11	36.864380	-111.376161	Antelope Canyon	4	4
1	25.781842	-80.128473	Lummus Park Beach	1	1
26	38.510312	-122.479887	Beringer Vineyards	1	9
8	39.182677	-106.855385	Aspen Highlands	1	3
28	38.482181	-122.434697	Raymond Vineyard and Cellar	5	9
24	36.501435	-117.073990	Death Valley National Park	6	7
23	36.883269	-111.509540	Horseshoe Bend	3	7
10	37.198125	-112.987418	Zion Canyon National Park	1	4
3	24.707496	-81.078400	Sombrero Beach	3	1
4	24.552242	-81.768719	West Key	5	1
14	40.781821	-73.967696	New York	1	5
20	35.710359	-118.454700	Kern River Rafting	7	6
22	37.629017	-109.999530	Natural Bridges National Monument	1	7
7	51.261937	-117.490309	Glacier National Park of Canada	5	2
6	52.875223	-118.076152	Jasper National Park	3	2
2	24.909047	-80.647885	Islamorada	2	1
15	34.097984	-118.324396	Los Angeles	3	5
25	62.439943	-114.406097	Yellowknife	1	8
27	38.585707	-122.582948	Clos Pegase Winery & Tasting Room	3	9
17	34.003098	-118.809361	Point Dume Beach	1	6
21	37.742371	-119.600492	Yosemite National Park	1	6
18	33.987367	-118.475490	Venice Skate Park	4	6
13	34.011646	-116.107963	Joshua Tree National Park	9	4
12	36.058973	-112.115763	Grand Canyon National Park	5	4
16	37.787825	-122.408865	San Francisco	5	5
\.


--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.profiles (id, first_name, last_name, photo, user_id) FROM stdin;
1	Pavel	Lots	user-1.jpg	1
2	Lourdes	Browning	user-2.jpg	2
3	Sophie	Louise Hart	user-3.jpg	3
4	Ayla	Cornell	user-4.jpg	4
5	Leo	Gillespie	user-5.jpg	5
6	Jennifer	Hardy	user-6.jpg	6
7	Kate	Morrison	user-7.jpg	7
8	Eliana	Stout	user-8.jpg	8
9	Cristian	Vega	user-9.jpg	9
10	Steve	T. Scaife	user-10.jpg	10
11	Aarav	Lynn	user-11.jpg	11
12	Miyah	Myles	user-12.jpg	12
13	Ben	Hadley	user-13.jpg	13
14	Laura	Wilson	user-14.jpg	14
15	Max	Smith	user-15.jpg	15
16	Isabel	Kirkland	user-16.jpg	16
17	Alexander	Jones	user-17.jpg	17
18	Eduardo	Hernandez	user-18.jpg	18
19	John	Riley	user-19.jpg	19
20	Lisa	Brown	user-20.jpg	20
\.


--
-- Data for Name: start_dates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.start_dates (id, start_date, tour_id) FROM stdin;
6	2021-04-25 09:00:00+00	1
7	2021-07-20 09:00:00+00	1
8	2021-10-05 09:00:00+00	1
9	2021-06-19 09:00:00+00	2
10	2021-07-20 09:00:00+00	2
11	2021-08-18 09:00:00+00	2
12	2022-01-05 10:00:00+00	3
13	2022-02-12 10:00:00+00	3
14	2023-01-06 10:00:00+00	3
15	2021-03-11 10:00:00+00	4
16	2021-05-02 09:00:00+00	4
17	2021-06-09 09:00:00+00	4
18	2021-08-05 09:00:00+00	5
19	2022-03-20 10:00:00+00	5
20	2022-08-12 09:00:00+00	5
21	2021-07-19 09:00:00+00	6
22	2021-09-06 09:00:00+00	6
23	2022-03-18 10:00:00+00	6
24	2021-02-12 10:00:00+00	7
25	2021-04-14 09:00:00+00	7
26	2021-09-01 09:00:00+00	7
27	2021-03-23 10:00:00+00	8
28	2021-10-25 09:00:00+00	8
29	2022-01-30 10:00:00+00	8
30	2021-12-16 10:00:00+00	9
31	2022-01-16 10:00:00+00	9
32	2022-12-12 10:00:00+00	9
\.


--
-- Data for Name: start_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.start_locations (id, latitude, longitude, name, address, tour_id) FROM stdin;
16	39.190872	-106.822318	Aspen, USA	419 S Mill St, Aspen, CO 81611, USA	3
13	51.178456	-115.570154	Banff, CAN	224 Banff Ave, Banff, AB, Canada	1
17	34.006072	-118.803461	California, USA	29130 Cliffside Dr, Malibu, CA 90265, USA	6
19	37.283469	-109.550990	Utah, USA	Bluff, UT 84512, USA	8
15	40.758940	-73.985141	NYC, USA	Manhattan, NY 10036, USA	4
18	38.294065	-122.292860	California, USA	560 Jefferson St, Napa, CA 94559, USA	7
14	36.110904	-115.172652	Las Vegas, USA	3663 S Las Vegas Blvd, Las Vegas, NV 89109, USA	5
12	25.774772	-80.185942	Miami, USA	301 Biscayne Blvd, Miami, FL 33132, USA	2
20	62.439943	-114.406097	Yellowknife, CAN	Yellowknife, NT X1A 2L2, Canada	9
\.


--
-- Data for Name: tour_images; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tour_images (id, image, tour_id) FROM stdin;
1	tour-1-1.jpg	1
2	tour-1-2.jpg	1
3	tour-1-3.jpg	1
4	tour-2-1.jpg	2
5	tour-2-2.jpg	2
6	tour-2-3.jpg	2
7	tour-3-1.jpg	3
8	tour-3-2.jpg	3
9	tour-3-3.jpg	3
10	tour-4-1.jpg	4
11	tour-4-2.jpg	4
12	tour-4-3.jpg	4
13	tour-5-1.jpg	5
14	tour-5-2.jpg	5
15	tour-5-3.jpg	5
16	tour-6-1.jpg	6
17	tour-6-2.jpg	6
18	tour-6-3.jpg	6
19	tour-7-1.jpg	7
20	tour-7-2.jpg	7
21	tour-7-3.jpg	7
22	tour-8-1.jpg	8
23	tour-8-2.jpg	8
24	tour-8-3.jpg	8
25	tour-9-1.jpg	9
26	tour-9-2.jpg	9
27	tour-9-3.jpg	9
\.


--
-- Data for Name: tour_reviews; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tour_reviews (id, review, rating, created_at, updated_at, tour_id, user_id) FROM stdin;
1	Cras mollis nisi parturient mi nec aliquet suspendisse sagittis eros condimentum scelerisque taciti mattis praesent feugiat eu nascetur a tincidunt	5	2022-01-09 14:59:29.163+00	2022-01-09 14:59:29.163+00	2	2
2	Laoreet justo volutpat per etiam donec at augue penatibus eu facilisis lorem phasellus ipsum tristique urna quam platea.	5	2022-01-09 14:59:29.163001+00	2022-01-09 14:59:29.163001+00	4	3
3	Habitasse scelerisque class quam primis convallis integer eros congue nulla proin nam faucibus parturient.	4	2022-01-09 14:59:29.163002+00	2022-01-09 14:59:29.163002+00	3	2
4	Convallis turpis porttitor sapien ad urna efficitur dui vivamus in praesent nulla hac non potenti!	5	2022-01-09 14:59:29.163003+00	2022-01-09 14:59:29.163003+00	5	2
5	Auctor euismod interdum augue tristique senectus nascetur cras justo eleifend mattis libero id adipiscing amet placerat	5	2022-01-09 14:59:29.163004+00	2022-01-09 14:59:29.163004+00	6	17
6	Senectus lectus eleifend ex lobortis cras nam cursus accumsan tellus lacus faucibus himenaeos posuere!	5	2022-01-09 14:59:29.163005+00	2022-01-09 14:59:29.163005+00	7	3
7	Tempus curabitur faucibus auctor bibendum duis gravida tincidunt litora himenaeos facilisis vivamus vehicula potenti semper fusce suspendisse sagittis!	4	2022-01-09 14:59:29.163006+00	2022-01-09 14:59:29.163006+00	8	2
8	Cras consequat fames faucibus ac aliquam dolor a euismod porttitor rhoncus venenatis himenaeos montes tristique pretium libero nisi!	5	2022-01-09 14:59:29.163007+00	2022-01-09 14:59:29.163007+00	3	3
9	A facilisi justo ornare magnis velit diam dictumst parturient arcu nullam rhoncus nec!	4	2022-01-09 14:59:29.163008+00	2022-01-09 14:59:29.163008+00	9	17
10	Pretium vel inceptos fringilla sit dui fusce varius gravida platea morbi semper erat elit porttitor potenti!	5	2022-01-09 14:59:29.163009+00	2022-01-09 14:59:29.163009+00	1	17
11	Neque amet vel integer placerat ex pretium elementum vitae quis ullamcorper nullam nunc habitant cursus justo!!!	5	2022-01-09 14:59:29.16301+00	2022-01-09 14:59:29.16301+00	6	4
12	Pulvinar taciti etiam aenean lacinia natoque interdum fringilla suspendisse nam sapien urna!	4	2022-01-09 14:59:29.163011+00	2022-01-09 14:59:29.163011+00	2	3
13	Ex a bibendum quis volutpat consequat euismod vulputate parturient laoreet diam sagittis amet at blandit.	4	2022-01-09 14:59:29.163012+00	2022-01-09 14:59:29.163012+00	8	17
14	Sollicitudin sagittis ex ut fringilla enim condimentum et netus tristique.	5	2022-01-09 14:59:29.163013+00	2022-01-09 14:59:29.163013+00	5	4
15	Elementum massa porttitor enim vitae eu ligula vivamus amet imperdiet urna tristique donec mattis mus erat.	5	2022-01-09 14:59:29.163014+00	2022-01-09 14:59:29.163014+00	9	9
16	Porttitor ullamcorper rutrum semper proin mus felis varius convallis conubia nisl erat lectus eget.	5	2022-01-09 14:59:29.163015+00	2022-01-09 14:59:29.163015+00	1	4
17	Porttitor ullamcorper rutrum semper proin mus felis varius convallis conubia nisl erat lectus eget.	5	2022-01-09 14:59:29.163016+00	2022-01-09 14:59:29.163016+00	4	17
18	Semper blandit felis nostra facilisi sodales pulvinar habitasse diam sapien lobortis urna nunc ipsum orci.	5	2022-01-09 14:59:29.163017+00	2022-01-09 14:59:29.163017+00	8	4
19	Fusce ullamcorper gravida libero nullam lacus litora class orci habitant sollicitudin...	5	2022-01-09 14:59:29.163018+00	2022-01-09 14:59:29.163018+00	5	9
20	Arcu adipiscing lobortis sem finibus consequat ac justo nisi pharetra ultricies facilisi!	5	2022-01-09 14:59:29.163019+00	2022-01-09 14:59:29.163019+00	3	9
21	Tortor dolor sed vehicula neque ultrices varius orci feugiat dignissim auctor consequat.	4	2022-01-09 14:59:29.16302+00	2022-01-09 14:59:29.16302+00	5	8
22	Rutrum viverra turpis nunc ultricies dolor ornare metus habitant ex quis sociosqu nascetur pellentesque quam!	5	2022-01-09 14:59:29.163021+00	2022-01-09 14:59:29.163021+00	7	9
23	Felis mauris aenean eu lectus fringilla habitasse nullam eros senectus ante etiam!	5	2022-01-09 14:59:29.163022+00	2022-01-09 14:59:29.163022+00	7	8
24	Semper tempus curae at platea lobortis ullamcorper curabitur luctus maecenas nisl laoreet!	5	2022-01-09 14:59:29.163023+00	2022-01-09 14:59:29.163023+00	3	4
25	Sem feugiat sed lorem vel dignissim platea habitasse dolor suscipit ultricies dapibus	5	2022-01-09 14:59:29.163024+00	2022-01-09 14:59:29.163024+00	2	9
26	Netus eleifend adipiscing ligula placerat fusce orci sollicitudin vivamus conubia.	5	2022-01-09 14:59:29.163025+00	2022-01-09 14:59:29.163025+00	8	14
27	Sem feugiat sed lorem vel dignissim platea habitasse dolor suscipit ultricies dapibus	5	2022-01-09 14:59:29.163026+00	2022-01-09 14:59:29.163026+00	1	8
28	Eleifend suspendisse ultricies platea primis ut ornare purus vel taciti faucibus justo nunc	4	2022-01-09 14:59:29.163027+00	2022-01-09 14:59:29.163027+00	6	14
29	Varius potenti proin hendrerit felis sit convallis nunc non id facilisis aliquam platea elementum	5	2022-01-09 14:59:29.163028+00	2022-01-09 14:59:29.163028+00	1	9
30	Blandit varius nascetur est felis praesent lorem himenaeos pretium dapibus tellus bibendum consequat ac duis	5	2022-01-09 14:59:29.163029+00	2022-01-09 14:59:29.163029+00	2	14
31	Sociosqu eleifend tincidunt aenean condimentum gravida lorem arcu pellentesque felis dui feugiat nec.	5	2022-01-09 14:59:29.16303+00	2022-01-09 14:59:29.16303+00	4	15
32	Iaculis mauris eget sed nec lobortis rhoncus montes etiam dapibus suspendisse hendrerit quam pellentesque potenti sapien!	5	2022-01-09 14:59:29.163031+00	2022-01-09 14:59:29.163031+00	1	14
33	Ridiculus facilisis sem id aenean amet penatibus gravida phasellus a mus dui lacinia accumsan!!	1	2022-01-09 14:59:29.163032+00	2022-01-09 14:59:29.163032+00	9	15
34	Blandit varius nascetur est felis praesent lorem himenaeos pretium dapibus tellus bibendum consequat ac duis	3	2022-01-09 14:59:29.163033+00	2022-01-09 14:59:29.163033+00	4	8
35	Curabitur maximus montes vestibulum nulla vel dictum cubilia himenaeos nunc hendrerit amet urna.	5	2022-01-09 14:59:29.163034+00	2022-01-09 14:59:29.163034+00	7	14
36	Conubia semper efficitur rhoncus suspendisse taciti lectus ex sapien dolor molestie fusce class.	5	2022-01-09 14:59:29.163035+00	2022-01-09 14:59:29.163035+00	6	16
37	Curabitur maximus montes vestibulum nulla vel dictum cubilia himenaeos nunc hendrerit amet urna.	5	2022-01-09 14:59:29.163036+00	2022-01-09 14:59:29.163036+00	3	15
38	Conubia pharetra pulvinar libero hac class congue curabitur mi porttitor!!	5	2022-01-09 14:59:29.163037+00	2022-01-09 14:59:29.163037+00	9	16
39	Malesuada consequat congue vel gravida eros conubia in sapien praesent diam!	4	2022-01-09 14:59:29.163038+00	2022-01-09 14:59:29.163038+00	9	14
40	Tempor pellentesque eu placerat auctor enim nam suscipit tincidunt natoque ipsum est.	5	2022-01-09 14:59:29.163039+00	2022-01-09 14:59:29.163039+00	2	15
41	Blandit varius finibus imperdiet tortor hendrerit erat rhoncus dictumst inceptos massa in.	5	2022-01-09 14:59:29.16304+00	2022-01-09 14:59:29.16304+00	6	18
42	Tempor pellentesque eu placerat auctor enim nam suscipit tincidunt natoque ipsum est.	5	2022-01-09 14:59:29.163041+00	2022-01-09 14:59:29.163041+00	8	16
43	Tristique semper proin pellentesque ipsum urna habitasse venenatis tincidunt morbi nisi at	4	2022-01-09 14:59:29.163042+00	2022-01-09 14:59:29.163042+00	5	18
44	Venenatis molestie luctus cubilia taciti tempor faucibus nostra nisi curae integer.	5	2022-01-09 14:59:29.163043+00	2022-01-09 14:59:29.163043+00	1	15
45	Euismod suscipit ipsum efficitur rutrum dis mus dictumst laoreet lectus.	5	2022-01-09 14:59:29.163044+00	2022-01-09 14:59:29.163044+00	1	18
46	Magna magnis tellus dui vivamus donec placerat vehicula erat turpis	5	2022-01-09 14:59:29.163045+00	2022-01-09 14:59:29.163045+00	2	19
47	Ligula lorem taciti fringilla himenaeos ex aliquam litora nam ad maecenas sit phasellus lectus!!	5	2022-01-09 14:59:29.163046+00	2022-01-09 14:59:29.163046+00	1	19
48	Massa orci lacus suspendisse maximus ad integer donec arcu parturient facilisis accumsan consectetur non	4	2022-01-09 14:59:29.163047+00	2022-01-09 14:59:29.163047+00	8	18
49	Nullam felis dictumst eros nulla torquent arcu inceptos mi faucibus ridiculus pellentesque gravida mauris.	5	2022-01-09 14:59:29.163048+00	2022-01-09 14:59:29.163048+00	4	16
50	Molestie non montes at fermentum cubilia quis dis placerat maecenas vulputate sapien facilisis	5	2022-01-09 14:59:29.163049+00	2022-01-09 14:59:29.163049+00	7	18
51	Ultrices nam dui ex posuere velit varius himenaeos bibendum fermentum sollicitudin purus	5	2022-01-09 14:59:29.16305+00	2022-01-09 14:59:29.16305+00	4	20
52	Velit vulputate faucibus in nascetur praesent potenti primis pulvinar tempor	5	2022-01-09 14:59:29.163051+00	2022-01-09 14:59:29.163051+00	3	18
53	Potenti etiam placerat mi metus ipsum curae eget nisl torquent pretium	4	2022-01-09 14:59:29.163052+00	2022-01-09 14:59:29.163052+00	9	18
54	Vitae vulputate id quam metus orci cras mollis vivamus vehicula sapien et	2	2022-01-09 14:59:29.163053+00	2022-01-09 14:59:29.163053+00	3	20
55	Ullamcorper ac nec id habitant a commodo eget libero cras congue!	4	2022-01-09 14:59:29.163054+00	2022-01-09 14:59:29.163054+00	7	19
56	Nam ultrices quis leo viverra tristique curae facilisi luctus sapien eleifend fames orci lacinia pulvinar.	4	2022-01-09 14:59:29.163055+00	2022-01-09 14:59:29.163055+00	6	19
57	Feugiat egestas ac pulvinar quis dui ligula tempor ad platea quisque scelerisque!	5	2022-01-09 14:59:29.163056+00	2022-01-09 14:59:29.163056+00	1	20
58	Sem risus tempor auctor mattis netus montes tincidunt mollis lacinia natoque adipiscing	5	2022-01-09 14:59:29.163057+00	2022-01-09 14:59:29.163057+00	6	20
59	Ultrices nam dui ex posuere velit varius himenaeos bibendum fermentum sollicitudin purus	5	2022-01-09 14:59:29.163058+00	2022-01-09 14:59:29.163058+00	4	19
60	Quisque egestas faucibus primis ridiculus mi felis tristique curabitur habitasse vehicula	4	2022-01-09 14:59:29.163059+00	2022-01-09 14:59:29.163059+00	9	20
\.


--
-- Data for Name: tours; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tours (id, slug, name, image_cover, duration, max_group_size, difficulty, price, discount_price, summary, description, secret_tour) FROM stdin;
2	the-sea-explorer	The Sea Explorer	tour-2-cover.jpg	7	15	MEDIUM	497.00	\N	Exploring the jaw-dropping US east coast by foot and by boat	Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\\nIrure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.	f
3	the-snow-adventurer	The Snow Adventurer	tour-3-cover.jpg	4	10	DIFFICULT	997.00	\N	Exciting adventure in the snow with snowboarding and skiing	Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua, ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!\\nDolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur, exercitation ullamco laboris nisi ut aliquip. Lorem ipsum dolor sit amet, consectetur adipisicing elit!	f
4	the-city-wanderer	The City Wanderer	tour-4-cover.jpg	9	20	EASY	1197.00	\N	Living the life of Wanderlust in the US' most beatiful cities	Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat lorem ipsum dolor sit amet.\\nConsectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur, nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat!	f
5	the-park-camper	The Park Camper	tour-5-cover.jpg	10	15	MEDIUM	1497.00	\N	Breathing in Nature in America's most spectacular National Parks	Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!	f
6	the-sports-lover	The Sports Lover	tour-6-cover.jpg	14	8	DIFFICULT	2997.00	\N	Surfing, skating, parajumping, rock climbing and more, all in one tour	Nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\\nVoluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur!	f
7	the-wine-taster	The Wine Taster	tour-7-cover.jpg	5	8	EASY	1997.00	\N	Exquisite wines, scenic views, exclusive barrel tastings,  and much more	Consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\\nIrure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.	f
8	the-star-gazer	The Star Gazer	tour-8-cover.jpg	9	8	MEDIUM	2997.00	\N	The most remote and stunningly beautiful places for seeing the night sky	Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.	f
9	the-northern-lights	The Northern Lights	tour-9-cover.jpg	3	12	EASY	1497.00	\N	Enjoy the Northern Lights in one of the best places in the world	Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua, ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum!\\nDolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur, exercitation ullamco laboris nisi ut aliquip. Lorem ipsum dolor sit amet, consectetur adipisicing elit!	f
1	the-forest-hiker	The Forest Hiker	tour-1-cover.jpg	5	25	EASY	497.00	\N	Breathtaking hike through the Canadian Banff National Park	Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.\\nLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.	f
\.


--
-- Data for Name: tours_guides; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tours_guides (id, tour_id, user_id) FROM stdin;
1	1	10
2	1	7
3	1	5
4	2	12
5	2	6
6	3	10
7	3	13
8	3	6
9	4	11
10	4	13
11	4	7
12	5	12
13	5	7
14	6	11
15	6	5
16	6	6
17	7	12
18	7	13
19	8	10
20	8	5
21	9	11
22	9	7
23	9	13
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, password, last_login, email, role, created_at, updated_at, is_active, is_email_confirmed, password_reset_token, password_changed_at) FROM stdin;
2	pbkdf2_sha256$320000$xeru3EFyGHC00avLPQp1iu$lVRkrueRq7N1cKMuysjJn1gvlrh11kO8NbxPUxT2aR8=	\N	loulou@example.com	user	2022-02-10 01:01:30.315841+00	2022-02-10 01:01:30.315848+00	t	t	\N	\N
3	pbkdf2_sha256$320000$2qqFIExeBjLbyoDOOvixMb$aIkMEuA553PcJZ29xyo1GwUPFmmA/Mv9xUG/wa4DWBc=	\N	sophie@example.com	user	2022-02-10 01:01:30.315877+00	2022-02-10 01:01:30.315883+00	t	t	\N	\N
4	pbkdf2_sha256$320000$Eulryhp5yJRIYh8dQUhEoe$n7u4ZbjUD2+q4R8s56psIeJaFJOl2cllwuaq5ikFlFU=	\N	ayls@example.com	user	2022-02-10 01:01:30.315912+00	2022-02-10 01:01:30.315917+00	t	t	\N	\N
5	pbkdf2_sha256$320000$1D9HAqExcY11OS6Za29CRL$yYB6hNf25ff2oLXaI/H370Q/Gr7cw+kViC6OWdKz2Ho=	\N	leo@example.com	guide	2022-02-10 01:01:30.315946+00	2022-02-10 01:01:30.315951+00	t	t	\N	\N
6	pbkdf2_sha256$320000$x9xN9S0MDBHmaIZJDh2SKy$hMCug+HxAZKSvdIL90VlPfZ8olEh2kZxTtc1PUov8S8=	\N	jennifer@example.com	guide	2022-02-10 01:01:30.31598+00	2022-02-10 01:01:30.315986+00	t	t	\N	\N
7	pbkdf2_sha256$320000$eOwgeGJg2NXUKF5BwQucmB$B+TKl2Tfi6uQrG8yqyofZ4MEZntn4t2R/CmoPZgCnQQ=	\N	kate@example.com	guide	2022-02-10 01:01:30.316016+00	2022-02-10 01:01:30.316021+00	t	t	\N	\N
8	pbkdf2_sha256$320000$v1u2yHmUtgGodpA4baEhEe$PFHujEbjFP+vV25mHUdhejPH9oTwUuZPWDQt7zB4AHE=	\N	eliana@example.com	user	2022-02-10 01:01:30.31605+00	2022-02-10 01:01:30.316055+00	t	t	\N	\N
9	pbkdf2_sha256$320000$BYw1aSlj9zeokQ6yqhGpIT$juM7iOsEhPIlR1Rr5ADoT7TM/33kl2jY1tTqZMZmL88=	\N	chris@example.com	user	2022-02-10 01:01:30.316084+00	2022-02-10 01:01:30.316089+00	t	t	\N	\N
10	pbkdf2_sha256$320000$om20ROliMIx8mNQ6IwdeP5$v8R1JbCt8VAhXGFP9qa/zHYtfmMYm0oJvgdGKFQagoM=	\N	steve@example.com	lead-guide	2022-02-10 01:01:30.316118+00	2022-02-10 01:01:30.316123+00	t	t	\N	\N
11	pbkdf2_sha256$320000$lzW8qVaiwOwzINSuAYI22l$P0r99Pk25rsI8eNP2X5Szi/zKq3G1AUjyJDzdD9eXBQ=	\N	aarav@example.com	lead-guide	2022-02-10 01:01:30.316152+00	2022-02-10 01:01:30.316158+00	t	t	\N	\N
12	pbkdf2_sha256$320000$YZObaOWIaxmz7gJOGswRlZ$DZSq2Xs6afyxRB5jASo7NndkRU1KaZMrIlMyzCUEPE4=	\N	miyah@example.com	lead-guide	2022-02-10 01:01:30.316186+00	2022-02-10 01:01:30.316191+00	t	t	\N	\N
13	pbkdf2_sha256$320000$4JprMMqpXYUy7M8NXO1AaJ$3h8SGR3mEo2X/9Z59DwUMfPKPXpCPxVIIlO8QT3G23A=	\N	ben@example.com	guide	2022-02-10 01:01:30.316221+00	2022-02-10 01:01:30.316226+00	t	t	\N	\N
14	pbkdf2_sha256$320000$9nUg7n6gRoluRRvnGG0Dkv$jNZuaBvHv4S/SVmSx7VR3mDjl0VJokLis39NNhWPT9s=	\N	laura@example.com	user	2022-02-10 01:01:30.316256+00	2022-02-10 01:01:30.316262+00	t	t	\N	\N
15	pbkdf2_sha256$320000$PIhObBVGcrFPyhlFQaJhmt$hbY/bnqmzT3r6Rx5BJDcau+lACx1qMqI/rCXDVPP4fs=	\N	max@example.com	user	2022-02-10 01:01:30.316301+00	2022-02-10 01:01:30.316307+00	t	t	\N	\N
16	pbkdf2_sha256$320000$h4Lnn6dDQaQ6zHP3Bb5YYg$HWf2JlL4z2yZeL0OxVhnAEk0/iBxKa1bgtD+J5IDhnE=	\N	isabel@example.com	user	2022-02-10 01:01:30.316337+00	2022-02-10 01:01:30.316343+00	t	t	\N	\N
17	pbkdf2_sha256$320000$x56IKHLY3Vgy8zo8QHF4Ns$gPpSwhAUZrOv0G4ZlsJA58zjfnor5QsvNezCs5/PTZk=	\N	alex@example.com	user	2022-02-10 01:01:30.316371+00	2022-02-10 01:01:30.316377+00	t	t	\N	\N
18	pbkdf2_sha256$320000$8KfHampvvHpPBQCQibboRH$Nl1/b3nLfKTgWIRxvXaCgkQZSu2fp7wcDNAY1VUGTkI=	\N	edu@example.com	user	2022-02-10 01:01:30.316407+00	2022-02-10 01:01:30.316413+00	t	t	\N	\N
19	pbkdf2_sha256$320000$a10VuwNA2C2YlxovCubtca$R4XdaBIhFoqnYjWvv/9wREey04d4XxD1oKRGQPhuE8Y=	\N	john@example.com	user	2022-02-10 01:01:30.316441+00	2022-02-10 01:01:30.316446+00	t	t	\N	\N
1	pbkdf2_sha256$320000$c9Nddh91zptIBSDDqO3sDV$gXyrVvR458ArIeDIDcwu6d/3tj8UpZJv6XGMnJQgP/s=	2022-11-01 22:52:16.016247+00	admin@natours.io	admin	2022-02-10 01:01:30.315785+00	2022-11-01 22:52:16.016564+00	t	t	\N	\N
20	pbkdf2_sha256$390000$JPvnCvBa0A6zCIMLEulGEz$qE/W+5lt8pBoq5gZMetm/GTm+hfCj1811ukcrmKZgGI=	2022-11-03 22:39:28.494124+00	lisa@example.com	user	2022-02-10 01:01:30.316475+00	2022-11-03 22:39:28.494429+00	t	t	\N	\N
\.


--
-- Name: bookings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.bookings_id_seq', 8, true);


--
-- Name: locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.locations_id_seq', 1, false);


--
-- Name: profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.profiles_id_seq', 72, true);


--
-- Name: tour_images_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tour_images_id_seq', 1, false);


--
-- Name: tour_reviews_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tour_reviews_id_seq', 1, false);


--
-- Name: tour_start_dates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tour_start_dates_id_seq', 1, false);


--
-- Name: tour_start_location_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tour_start_location_id_seq', 1, false);


--
-- Name: tours_guides_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tours_guides_id_seq', 1, false);


--
-- Name: tours_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tours_id_seq', 15, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 83, true);


--
-- Name: bookings bookings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_pkey PRIMARY KEY (id);


--
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: profiles profiles_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_key UNIQUE (user_id);


--
-- Name: tour_images tour_images_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_images
    ADD CONSTRAINT tour_images_pkey PRIMARY KEY (id);


--
-- Name: tour_reviews tour_reviews_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT tour_reviews_pkey PRIMARY KEY (id);


--
-- Name: start_dates tour_start_dates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_dates
    ADD CONSTRAINT tour_start_dates_pkey PRIMARY KEY (id);


--
-- Name: start_locations tour_start_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_locations
    ADD CONSTRAINT tour_start_location_pkey PRIMARY KEY (id);


--
-- Name: tours_guides tours_guides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours_guides
    ADD CONSTRAINT tours_guides_pkey PRIMARY KEY (id);


--
-- Name: tours_guides tours_guides_tour_id_user_id_b892e24c_uniq; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours_guides
    ADD CONSTRAINT tours_guides_tour_id_user_id_b892e24c_uniq UNIQUE (tour_id, user_id);


--
-- Name: tours tours_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_name_key UNIQUE (name);


--
-- Name: tours tours_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_pkey PRIMARY KEY (id);


--
-- Name: tours tours_slug_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours
    ADD CONSTRAINT tours_slug_key UNIQUE (slug);


--
-- Name: tour_reviews unique_review; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT unique_review UNIQUE (tour_id, user_id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: bookings_tour_id_c0a7df5b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bookings_tour_id_c0a7df5b ON public.bookings USING btree (tour_id);


--
-- Name: bookings_user_id_6e734b08; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX bookings_user_id_6e734b08 ON public.bookings USING btree (user_id);


--
-- Name: locations_tour_id_e872c614; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX locations_tour_id_e872c614 ON public.locations USING btree (tour_id);


--
-- Name: tour_images_tour_id_3dc48856; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tour_images_tour_id_3dc48856 ON public.tour_images USING btree (tour_id);


--
-- Name: tour_reviews_tour_id_9332dea3; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tour_reviews_tour_id_9332dea3 ON public.tour_reviews USING btree (tour_id);


--
-- Name: tour_reviews_user_id_784650be; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tour_reviews_user_id_784650be ON public.tour_reviews USING btree (user_id);


--
-- Name: tour_start_dates_tour_id_510c2a19; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tour_start_dates_tour_id_510c2a19 ON public.start_dates USING btree (tour_id);


--
-- Name: tour_start_location_tour_id_49394464; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tour_start_location_tour_id_49394464 ON public.start_locations USING btree (tour_id);


--
-- Name: tours_guides_tour_id_2ef086f2; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tours_guides_tour_id_2ef086f2 ON public.tours_guides USING btree (tour_id);


--
-- Name: tours_guides_user_id_cc743e59; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tours_guides_user_id_cc743e59 ON public.tours_guides USING btree (user_id);


--
-- Name: tours_name_89ea1378_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tours_name_89ea1378_like ON public.tours USING btree (name varchar_pattern_ops);


--
-- Name: tours_slug_d25f3bcc_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX tours_slug_d25f3bcc_like ON public.tours USING btree (slug varchar_pattern_ops);


--
-- Name: users_email_0ea73cca_like; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX users_email_0ea73cca_like ON public.users USING btree (email varchar_pattern_ops);


--
-- Name: bookings bookings_tour_id_c0a7df5b_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_tour_id_c0a7df5b_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: bookings bookings_user_id_6e734b08_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.bookings
    ADD CONSTRAINT bookings_user_id_6e734b08_fk_users_id FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: locations locations_tour_id_e872c614_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_tour_id_e872c614_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: profiles profiles_user_id_36580373_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_user_id_36580373_fk_users_id FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tour_images tour_images_tour_id_3dc48856_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_images
    ADD CONSTRAINT tour_images_tour_id_3dc48856_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tour_reviews tour_reviews_tour_id_9332dea3_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT tour_reviews_tour_id_9332dea3_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tour_reviews tour_reviews_user_id_784650be_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tour_reviews
    ADD CONSTRAINT tour_reviews_user_id_784650be_fk_users_id FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: start_dates tour_start_dates_tour_id_510c2a19_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_dates
    ADD CONSTRAINT tour_start_dates_tour_id_510c2a19_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: start_locations tour_start_location_tour_id_49394464_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.start_locations
    ADD CONSTRAINT tour_start_location_tour_id_49394464_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tours_guides tours_guides_tour_id_2ef086f2_fk_tours_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours_guides
    ADD CONSTRAINT tours_guides_tour_id_2ef086f2_fk_tours_id FOREIGN KEY (tour_id) REFERENCES public.tours(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: tours_guides tours_guides_user_id_cc743e59_fk_users_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tours_guides
    ADD CONSTRAINT tours_guides_user_id_cc743e59_fk_users_id FOREIGN KEY (user_id) REFERENCES public.users(id) DEFERRABLE INITIALLY DEFERRED;


--
-- Name: report_2021; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.report_2021;


--
-- Name: report_2022; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.report_2022;


--
-- PostgreSQL database dump complete
--

