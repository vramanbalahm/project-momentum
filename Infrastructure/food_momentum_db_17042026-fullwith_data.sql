--
-- PostgreSQL database dump
--

\restrict JYOMQAAC6138T7s3EWhRijSXr7x01TBw8RI9JTwFbpAdYC3ZlPArH7TeiO3MWXv

-- Dumped from database version 17.8
-- Dumped by pg_dump version 17.8

-- Started on 2026-04-17 13:26:13

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
-- TOC entry 5302 (class 0 OID 90344)
-- Dependencies: 260
-- Data for Name: api_config; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.api_config VALUES ('ce2483a0-5bf5-4d29-b74b-af2c6ada03a9', 'tenor', NULL, 'https://tenor.googleapis.com/v2', true, 100, 'GIF search for lunar calendar events. Key from Google Cloud Console.', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');
INSERT INTO public.api_config VALUES ('c3e2690b-ed7c-48dc-b48f-fa0845a3d687', 'agmarknet', NULL, 'https://agmarknet.gov.in', true, 100, 'Primary mandi price portal — Modal Price source', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');
INSERT INTO public.api_config VALUES ('dfdf415a-26ea-48e4-9a9b-f0b11569f938', 'odg_api', NULL, 'https://api.data.gov.in/resource', true, 100, 'OGD API — structured JSON for daily automated price fetch + 14-day RSI', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');
INSERT INTO public.api_config VALUES ('99494438-ed3c-4614-8282-168119dae2a5', 'enam', NULL, 'https://www.enam.gov.in/web/api', true, 100, 'e-NAM trading volumes — high confidence divergence signals', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');
INSERT INTO public.api_config VALUES ('24a8bb8b-3f5f-4613-845d-90b76d19aa87', 'twilio', NULL, 'https://api.twilio.com/2010-04-01', true, 100, 'WhatsApp meal card export via Twilio', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');


--
-- TOC entry 5299 (class 0 OID 90253)
-- Dependencies: 257
-- Data for Name: behavioral_tracker; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5296 (class 0 OID 90192)
-- Dependencies: 254
-- Data for Name: complexity_levels; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.complexity_levels VALUES ('830f871c-a2ef-4a91-83f2-4d541745837e', '8b4f002f-b78e-478a-8f75-81b427f03786', 1, 'Simple', 1, 1, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('27a47b13-a2ab-43ef-86e2-cb4a93d52b2d', '8b4f002f-b78e-478a-8f75-81b427f03786', 2, 'Standard', 1, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('ba16d2b4-f609-41b4-9cf5-8685ec40424c', '8b4f002f-b78e-478a-8f75-81b427f03786', 3, 'Elaborate', 1, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('9fb45d6b-a402-41fa-8809-8361899a318e', '8b4f002f-b78e-478a-8f75-81b427f03786', 4, 'Special', 2, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('57e8bb61-b5fc-4c23-9334-71b61aa61a2f', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 1, 'Simple', 1, 1, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('e787c0ef-d3bc-480d-956f-b502bfc02b0c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 2, 'Standard', 1, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('bea59032-e6df-40da-9c9a-72d3604608da', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 3, 'Elaborate', 1, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.complexity_levels VALUES ('18da32e7-d9f3-4539-bc06-23b9cb49e7e4', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 4, 'Special', 2, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');


--
-- TOC entry 5297 (class 0 OID 90210)
-- Dependencies: 255
-- Data for Name: daily_meal_pattern; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.daily_meal_pattern VALUES ('be0fdcd5-bffb-417c-a2f9-6867399a69bd', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Monday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('57f50193-91b5-4c6f-8437-6e4aa605fc11', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Monday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('4d6c2c9e-4815-40b5-adf7-774dc13f3788', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Monday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('401da005-d401-479a-b20b-3fbf3fc12544', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Tuesday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('5689d7e6-d15e-4025-a692-fd908e654ba2', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Tuesday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('6cba0e6c-71fe-4760-8c19-68b0db6e2ede', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Tuesday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('72ef7ca6-9863-4f66-8d18-9633ea39882f', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Wednesday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('830cdcdd-4410-49db-b1be-ea2f3779316c', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Wednesday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('7aad06a1-e452-421d-a594-386271e3b9fb', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Wednesday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('dd2b9201-57c0-4f09-96df-b76517fca65c', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Thursday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('25123192-c5bf-4e3e-b6a6-4e92721fd78b', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Thursday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('82e71624-3aba-4a9f-bd2e-3f1a048c733e', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Thursday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('36728766-6096-4475-b617-7bf2e49a1d10', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Friday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('c020d50d-c33c-42af-b280-5803daf8dcf5', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Friday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('898e3e3a-5a38-4d4e-ab67-a0647a8c4fbe', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Friday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('ec09b237-b9e0-4c5c-9a7d-9f4cf0c054a3', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Saturday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('b7f2004e-0dbf-4cc3-8f66-1d9e3545254f', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Saturday', 'Lunch', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('40160f3f-1ae9-4224-839a-ac1f79899e77', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Saturday', 'Dinner', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('4f943f9c-d65a-4326-8399-a542e22ed1bf', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Sunday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('9aefed97-a157-41bd-8373-80a6fed4b89b', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Sunday', 'Lunch', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('9f87746b-6a37-4264-92ee-6df6f3c8a239', '8b4f002f-b78e-478a-8f75-81b427f03786', 'Sunday', 'Dinner', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('ba3dfec1-3c7e-43aa-933d-edf2cd185f58', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Monday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('1742653a-02b3-41a4-b6c1-d3c70981e5b4', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Monday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('5ac0c1a3-4c28-44e0-8781-847dbec3bb2e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Monday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('bfc7fca0-98bc-4ffb-a23c-529a5dfcb64a', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Tuesday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('e17ffe1f-96ec-4f14-9c41-3e115d2e8193', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Tuesday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('b4c13cfc-5009-413b-b330-f552d644e655', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Tuesday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('27948842-93f9-4186-8767-c89b05b1beef', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Wednesday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('d3a70b0c-ad0f-4e6a-a233-4d568a444921', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Wednesday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('c63b403e-cd3c-44db-b641-1b97c255a9d5', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Wednesday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('d3ca60ce-ac0b-4b6f-8830-5d76051e686d', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Thursday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('3a3ba7d9-1afd-41d3-8a0f-b71b74284592', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Thursday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('7e180890-0449-401b-b7be-f0e1d46669c9', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Thursday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('9ba3018e-65e1-4250-b516-1a5052ad5f00', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Friday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('8ba004c1-93f8-4505-bace-88d99284633f', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Friday', 'Lunch', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('b2cc054a-e2c6-4b67-8fdc-326b48cc4e9b', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Friday', 'Dinner', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('1f08dd4d-695d-4514-9639-6c47e18e3697', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Saturday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('444cae10-da33-4a89-b8d3-e0169b6c4f97', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Saturday', 'Lunch', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('4df57493-5a10-4fea-899e-a3a5fef25e5a', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Saturday', 'Dinner', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('763a1822-0bfd-414d-9397-4392fa9bdf58', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Sunday', 'Breakfast', 2, 2, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('9cb044d2-fc46-4dba-bb31-d2dd3741f405', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Sunday', 'Lunch', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.daily_meal_pattern VALUES ('e2d9fe45-5ebb-4b1d-8b0b-b5e3b7614cb4', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Sunday', 'Dinner', 3, 3, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');


--
-- TOC entry 5301 (class 0 OID 90333)
-- Dependencies: 259
-- Data for Name: event_gif_repository; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.event_gif_repository VALUES ('dd2275d0-340e-4f39-ae49-16a908b07140', 'Birthday', '/assets/gifs/birthday_cake_01.gif', 'Birthday cake', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('ac70f190-c9e7-4b2e-9b74-274d82d074fe', 'Birthday', '/assets/gifs/birthday_confetti_01.gif', 'Confetti burst', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('f25f1137-88dd-4037-85f7-9cc435e31875', 'Birthday', '/assets/gifs/birthday_balloon_01.gif', 'Balloons', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('9b936c9c-04f0-4bb7-8c81-a0898b27706f', 'Birthday', '/assets/gifs/birthday_sparkle_01.gif', 'Sparkle', NULL, true, 4, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('1b3f5127-64f7-45d5-b8a5-cae7f3e04dec', 'Birthday', '/assets/gifs/birthday_candles_01.gif', 'Candles', NULL, true, 5, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('72135ae0-025e-4d76-8226-686274e3acc2', 'Anniversary', '/assets/gifs/anniversary_rings_01.gif', 'Wedding rings', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('a86175b7-88ce-4e0a-909f-152ea57000ef', 'Anniversary', '/assets/gifs/anniversary_hearts_01.gif', 'Hearts', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('541b0db0-52a0-4c24-a60b-8240f226c4f6', 'Anniversary', '/assets/gifs/anniversary_flowers_01.gif', 'Flowers', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('50adda27-e6da-4dff-82af-7ff65da16ba4', 'Anniversary', '/assets/gifs/anniversary_candle_01.gif', 'Romantic candle', NULL, true, 4, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('5db614b1-2a6a-4d54-86af-ffac31fa2afa', 'Memorial', '/assets/gifs/memorial_diya_01.gif', 'Diya flame', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('058f2d3f-1018-46e4-a360-4d9ec7329153', 'Memorial', '/assets/gifs/memorial_lotus_01.gif', 'Lotus', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('9cbd18f8-6dcc-4b39-92d3-3a28c450d1f0', 'Memorial', '/assets/gifs/memorial_candle_01.gif', 'Memorial candle', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('273a45eb-9539-417f-9369-debdeadf95ed', 'Housewarming', '/assets/gifs/house_new_01.gif', 'New home', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('4cee6394-66b1-4a2c-a600-e8e6238b94ca', 'Housewarming', '/assets/gifs/house_key_01.gif', 'Keys', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('a068902c-436a-409e-a7d1-23be6784bb6b', 'Housewarming', '/assets/gifs/house_puja_01.gif', 'Griha Pravesh', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('43ca33bb-2967-43d0-92eb-e92ee9f364e2', 'Celebration', '/assets/gifs/celebrate_fireworks_01.gif', 'Fireworks', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('f6a69ed0-503a-4310-8ae1-32f7c89861ed', 'Celebration', '/assets/gifs/celebrate_party_01.gif', 'Party', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('959fce1a-486c-41c1-ad55-04f1137b8dac', 'Celebration', '/assets/gifs/celebrate_stars_01.gif', 'Stars', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('6133395c-955a-4ac8-83a6-13b5aa93d017', 'Celebration', '/assets/gifs/celebrate_dance_01.gif', 'Dance', NULL, true, 4, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('971a8291-19bb-4449-86cf-69933db18ec7', 'Religious', '/assets/gifs/religious_diya_01.gif', 'Diya', NULL, true, 1, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('b192c476-bf2f-44da-bee9-e489d043ade3', 'Religious', '/assets/gifs/religious_om_01.gif', 'Om', NULL, true, 2, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('35fa784c-d809-4011-b328-aca3369ad793', 'Religious', '/assets/gifs/religious_kolam_01.gif', 'Kolam', NULL, true, 3, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('e6968803-63f2-47a0-aa22-35a40c52abbc', 'Religious', '/assets/gifs/religious_bell_01.gif', 'Temple bell', NULL, true, 4, '2026-04-14 13:05:45.457279');
INSERT INTO public.event_gif_repository VALUES ('b3814782-f4e1-4f8d-a9c4-e56f7303cf86', 'Religious', '/assets/gifs/religious_lamp_01.gif', 'Lamp', NULL, true, 5, '2026-04-14 13:05:45.457279');


--
-- TOC entry 5286 (class 0 OID 16841)
-- Dependencies: 242
-- Data for Name: event_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.event_master VALUES ('6e680e07-0b1d-4462-b616-0f8186bf6916', NULL, 'Pradosham', '2026-01-01', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0012026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('1854aa57-e235-4ad1-978a-0ac49968bbbb', NULL, 'Sashti', '2026-01-09', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0022026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('d01c953e-0f7d-4a8b-89dd-d4ee4d5b916c', NULL, 'Thai Pongal', '2026-01-14', 'Social', false, false, '2026-03-06 14:24:52.465665', '🌾', 'TN0032026', 'ADMIN', 'TN', true, 2026, NULL, 'தை பொங்கல்', NULL, 'none');
INSERT INTO public.event_master VALUES ('620f2fe9-21c2-41ac-906a-e028542efee8', NULL, 'Mattu Pongal', '2026-01-15', 'Social', false, false, '2026-03-06 14:24:52.465665', '🐄', 'TN0042026', 'ADMIN', 'TN', true, 2026, NULL, 'மாட்டுப் பொங்கல்', NULL, 'none');
INSERT INTO public.event_master VALUES ('7a2123f2-056a-4401-bcdc-8d09aab98cbc', NULL, 'Pradosham', '2026-01-16', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0052026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('a2970112-75d9-46cb-b3c9-a3d55e99afc3', NULL, 'Amavasai', '2026-01-18', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0062026', 'ADMIN', 'TN', true, 2026, NULL, 'தை அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('f4d3b329-c0d4-47b6-b706-832131380eb6', NULL, 'Sashti', '2026-01-24', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0072026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('6f646f13-f6b3-4112-b756-95c60432319a', NULL, 'Pradosham', '2026-01-30', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0082026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('a67e99dc-0145-40a0-afbe-d2adc19d9c2e', NULL, 'Pournami', '2026-02-01', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0092026', 'ADMIN', 'TN', true, 2026, NULL, 'தை பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('ce691db0-928c-48a6-bd9d-7dc499f7b169', NULL, 'Thai Poosam', '2026-02-01', 'Social', true, false, '2026-03-06 14:24:52.465665', '🔱', 'TN0102026', 'ADMIN', 'TN', true, 2026, NULL, 'தை பூசம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('18b91587-c130-4931-82e8-30587a45e392', NULL, 'Sashti', '2026-02-07', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0112026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('4fe8ca92-492b-4036-a05c-231f4d978848', NULL, 'Pradosham', '2026-02-14', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0122026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('c07320c5-2fb1-4248-b299-69fc8cfbc395', NULL, 'Maha Shivaratri', '2026-02-15', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🕉️', 'TN0132026', 'ADMIN', 'TN', true, 2026, NULL, 'மகா சிவராத்திரி', NULL, 'none');
INSERT INTO public.event_master VALUES ('d0c323c1-114c-45dc-a471-15866e998121', NULL, 'Amavasai', '2026-02-17', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0142026', 'ADMIN', 'TN', true, 2026, NULL, 'மாசி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('a7db7e12-efc4-42ee-b5d8-33fa6fa016e0', NULL, 'Sashti', '2026-02-22', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0152026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ae9edf49-3c78-440f-8361-d1574bf44874', NULL, 'Pradosham', '2026-03-01', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0162026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('91559ced-11bf-45ba-bb6c-24c3d94b4245', NULL, 'Pournami', '2026-03-03', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0172026', 'ADMIN', 'TN', true, 2026, NULL, 'மாசி மகம் / பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('138e7d03-9d93-4d2e-b7f3-19a1c82f6b05', NULL, 'Sashti', '2026-03-09', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0182026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('41b3cc3e-eaee-45b9-a813-92200d46a295', NULL, 'Pradosham', '2026-03-16', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0192026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('6684f19d-54b7-457a-878f-871164dc4428', NULL, 'Amavasai', '2026-03-18', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0202026', 'ADMIN', 'TN', true, 2026, NULL, 'பங்குனி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('ffdf734b-7b01-4104-be17-6f7f0feb4984', NULL, 'Sashti', '2026-03-24', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0212026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('e00510ec-fbe5-4b17-8fbc-3d5a1f95017f', NULL, 'Pradosham', '2026-03-30', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0222026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('f2fac3ce-597b-44f6-8273-99f389780a2c', NULL, 'Pournami', '2026-04-01', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0232026', 'ADMIN', 'TN', true, 2026, NULL, 'பங்குனி உத்திரம் / பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('433436ac-eb17-4032-8ca3-94e11bc1c32b', NULL, 'Sashti', '2026-04-08', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0242026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('e862b3df-a5e3-4c57-b492-68beed2f8ce3', NULL, 'Tamil Puthandu', '2026-04-14', 'Social', false, false, '2026-03-06 14:24:52.465665', '🍌', 'TN0252026', 'ADMIN', 'TN', true, 2026, NULL, 'தமிழ்ப் புத்தாண்டு', NULL, 'none');
INSERT INTO public.event_master VALUES ('70dd4da4-f66a-4d8c-a655-277176361f6e', NULL, 'Pradosham', '2026-04-15', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0262026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('de7c3190-edeb-4736-84de-f775aeeb31a2', NULL, 'Amavasai', '2026-04-17', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0272026', 'ADMIN', 'TN', true, 2026, NULL, 'சித்திரை அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('b7bee568-1a43-40fa-909c-6558d759ea1b', NULL, 'Sashti', '2026-04-22', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0282026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('5900817c-b8ae-48c7-b5ef-6920ef14c693', NULL, 'Pradosham', '2026-04-29', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0292026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('879f85c0-36be-4b1c-a845-1525e3cf1576', NULL, 'Pournami', '2026-05-01', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0302026', 'ADMIN', 'TN', true, 2026, NULL, 'சித்ரா பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('2a16087a-bf89-4eb3-9d20-064857924afb', NULL, 'Sashti', '2026-05-07', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0312026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('498fbf18-c698-4296-a74d-221e51c62704', NULL, 'Pradosham', '2026-05-14', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0322026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ff7d3b74-6bac-4c4f-b4e9-cc75d7b45812', NULL, 'Amavasai', '2026-05-16', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0332026', 'ADMIN', 'TN', true, 2026, NULL, 'வைகாசி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('753cca04-5761-437e-973c-2d21eaf84f38', NULL, 'Sashti', '2026-05-22', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0342026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('8d0e7b04-3f0a-4de6-8196-f68ec5402fe5', NULL, 'Pradosham', '2026-05-28', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0352026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('23edcb0c-2449-4445-8035-ce24476eb263', NULL, 'Vaikasi Visakam', '2026-05-30', 'Social', true, false, '2026-03-06 14:24:52.465665', '🔱', 'TN0362026', 'ADMIN', 'TN', true, 2026, NULL, 'வைகாசி விசாகம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('cc3fe6b4-6ab3-4ef4-b606-fb4a1ca0fe2c', NULL, 'Pournami', '2026-05-31', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0372026', 'ADMIN', 'TN', true, 2026, NULL, 'வைகாசி பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('d7ac3ffa-7254-4cd3-9d17-343314f921fa', NULL, 'Sashti', '2026-06-06', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0382026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('90f448ac-58a6-40f0-9a5c-39a9082e666e', NULL, 'Pradosham', '2026-06-12', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0392026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ffcf12ab-c709-4852-913b-32c143d10d45', NULL, 'Amavasai', '2026-06-14', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0402026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆனி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('24fdc896-2fc0-4557-9dc9-42f42e287a39', NULL, 'Sashti', '2026-06-20', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0412026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('dd776afb-a2f0-42dd-a1e2-aa7122b1433f', NULL, 'Pradosham', '2026-06-27', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0422026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('6b330fb2-78ab-4a8b-8aff-14d71feb7a71', NULL, 'Pournami', '2026-06-29', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0432026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆனி பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('9f5a6719-ba80-4695-b9a6-47dbbed219c0', NULL, 'Sashti', '2026-07-05', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0442026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('406a981a-1a6e-4d0b-84a7-f203177d0c5a', NULL, 'Pradosham', '2026-07-12', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0452026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('d573a013-46d5-4dca-9081-8d9c073bdb49', NULL, 'Amavasai', '2026-07-14', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0462026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆடி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('04d5a9a5-0403-478f-9c14-6f3e251eca4d', NULL, 'Sashti', '2026-07-19', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0472026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('86472e82-b93a-4281-ae4b-c23f7b9d1f64', NULL, 'Pradosham', '2026-07-26', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0482026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('5b2a8f35-2efb-4c11-ac5f-37ab25c61aae', NULL, 'Pournami', '2026-07-29', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0492026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆடி பௌர்ணமி / குரு பூர்ணிமா', NULL, 'none');
INSERT INTO public.event_master VALUES ('c44a4a29-b7fe-4057-b328-1c9bd4e66400', NULL, 'Sashti', '2026-08-04', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0502026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('07a4d6b5-6999-4382-8a1f-366bb0d5f5aa', NULL, 'Pradosham', '2026-08-10', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0512026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('75c0993e-096c-4663-a4d5-7a3b5dbe3b9a', NULL, 'Amavasai', '2026-08-12', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0522026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆடி அமாவாசை (2)', NULL, 'none');
INSERT INTO public.event_master VALUES ('d7a17db5-dbdb-4fde-bf8d-7340fbabbba7', NULL, 'Sashti', '2026-08-18', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0532026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('bcf41ee3-c93a-4b2b-9dcf-0d7eb8bb4e43', NULL, 'Pradosham', '2026-08-25', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0542026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ebd195f3-24a1-44d6-be5f-e832bd646731', NULL, 'Avani Avittam', '2026-08-27', 'Ritual', true, false, '2026-03-06 14:24:52.465665', '🧵', 'TN0552026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆவணி அவிட்டம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('7936183e-d494-4983-a4f5-bd05e3e9966c', NULL, 'Pournami', '2026-08-28', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0562026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆவணி பௌர்ணமி / காயத்ரி ஜெபம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ba0a1b5d-ae29-4d8a-9ff6-e8cd84f5c4f9', NULL, 'Sashti', '2026-09-02', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0572026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('3e769f37-dee6-4056-b85f-e70ea3388697', NULL, 'Pradosham', '2026-09-08', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0582026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('e20a03df-5bc0-4897-828f-af482cd36212', NULL, 'Amavasai', '2026-09-10', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0592026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆவணி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('d4d77f1e-f3ad-43d3-8107-2beeb08489b1', NULL, 'Ganesh Chaturthi', '2026-09-14', 'Social', true, false, '2026-03-06 14:24:52.465665', '🐘', 'TN0602026', 'ADMIN', 'TN', true, 2026, NULL, 'விநாயகர் சதுர்த்தி', NULL, 'none');
INSERT INTO public.event_master VALUES ('bebdd21d-81ca-40d9-b725-ab39344f5345', NULL, 'Sashti', '2026-09-16', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0612026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('d06f88d9-b2b6-44dd-b0b1-8628a538a746', NULL, 'Pradosham', '2026-09-24', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0622026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('eb3f3cef-c280-4ede-bf08-0fbff52fe24a', NULL, 'Pournami', '2026-09-26', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0632026', 'ADMIN', 'TN', true, 2026, NULL, 'புரட்டாசி பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('2a1f0095-837b-44e5-9d55-faa6aae9466a', NULL, 'Sashti', '2026-10-02', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0642026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('b3964ed4-8a5e-4ccc-b8eb-2b4d42b57981', NULL, 'Pradosham', '2026-10-08', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0652026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('2d35064d-eb47-4b61-bbec-113ff1e72473', NULL, 'Mahalaya Amavasai', '2026-10-10', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0662026', 'ADMIN', 'TN', true, 2026, NULL, 'மஹாளய அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('66b48e97-3125-464b-bbc7-2daff8c8d0d6', NULL, 'Ayudha Puja', '2026-10-20', 'Social', false, false, '2026-03-06 14:24:52.465665', '🛠️', 'TN0672026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆயுத பூஜை', NULL, 'none');
INSERT INTO public.event_master VALUES ('e975fff8-9c3f-4251-b9b4-20dd04b8e76f', NULL, 'Vijayadashami', '2026-10-21', 'Social', false, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0682026', 'ADMIN', 'TN', true, 2026, NULL, 'விஜயதசமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('aaa644b9-5469-48cf-ac06-1b17f0dd7071', NULL, 'Pradosham', '2026-10-23', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0692026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('0c6d2e90-bb82-4c83-8ab4-eb48ed28cdf4', NULL, 'Pournami', '2026-10-25', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0702026', 'ADMIN', 'TN', true, 2026, NULL, 'புரட்டாசி பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('6f2fbd16-1e3f-43fa-96cc-3666fa501bee', NULL, 'Sashti', '2026-10-31', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0712026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('6f4bd3f7-06b9-4e80-9d04-07b547086142', NULL, 'Pradosham', '2026-11-06', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0722026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('13c1de6e-5f33-482e-8745-4928846cec9a', NULL, 'Deepavali', '2026-11-08', 'Social', false, false, '2026-03-06 14:24:52.465665', '🪔', 'TN0732026', 'ADMIN', 'TN', true, 2026, NULL, 'தீபாவளி', NULL, 'none');
INSERT INTO public.event_master VALUES ('69d20f44-a396-434d-bf9d-ab9fe3e43e60', NULL, 'Amavasai', '2026-11-08', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0742026', 'ADMIN', 'TN', true, 2026, NULL, 'ஐப்பசி அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('5b5abfa1-d11e-4f25-9a8c-891d0eb9827c', NULL, 'Soorasamharam', '2026-11-15', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0752026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம் / சூரசம்ஹாரம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('ee7f37fe-3ed3-4936-a55b-dc2f05cfe9f3', NULL, 'Pradosham', '2026-11-22', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0762026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('0d22ba73-79aa-4ef3-a6b9-ffc2dd5f0c12', NULL, 'Karthigai Deepam', '2026-11-24', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🔥', 'TN0772026', 'ADMIN', 'TN', true, 2026, NULL, 'கார்த்திகை தீபம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('790bcf50-0528-4334-a2c7-e3ee733ed1bf', NULL, 'Pournami', '2026-11-24', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0782026', 'ADMIN', 'TN', true, 2026, NULL, 'கார்த்திகை பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('fa5e41f4-80b9-4d74-8b14-7de806688c4b', NULL, 'Sashti', '2026-11-29', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0792026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('b0eaf44c-60e1-4e5c-8afb-3e0e35f704bb', NULL, 'Pradosham', '2026-12-06', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0802026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('6df4a7d6-3aad-49d0-98d6-751f2ad4c210', NULL, 'Amavasai', '2026-12-08', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌑', 'TN0812026', 'ADMIN', 'TN', true, 2026, NULL, 'கார்த்திகை அமாவாசை', NULL, 'none');
INSERT INTO public.event_master VALUES ('dd4b2695-f69a-4722-b889-1a9b538a67c2', NULL, 'Sashti', '2026-12-15', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0822026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('c07bec9f-d2ec-4ec1-8cb3-4ea9472048a9', NULL, 'Pradosham', '2026-12-21', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🐂', 'TN0832026', 'ADMIN', 'TN', true, 2026, NULL, 'பிரதோஷம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('8c9ddc4c-70e1-4ae8-8573-78e1a8e93096', NULL, 'Pournami', '2026-12-23', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🌕', 'TN0842026', 'ADMIN', 'TN', true, 2026, NULL, 'மார்கழி பௌர்ணமி', NULL, 'none');
INSERT INTO public.event_master VALUES ('755a70d8-344c-47e6-856e-8d815ef7186d', NULL, 'Arudra Darisanam', '2026-12-24', 'Social', true, false, '2026-03-06 14:24:52.465665', '🕉️', 'TN0852026', 'ADMIN', 'TN', true, 2026, NULL, 'ஆருத்ரா தரிசனம்', NULL, 'none');
INSERT INTO public.event_master VALUES ('d4cd3fb7-54bc-4a94-8de4-1f7b16518417', NULL, 'Sashti', '2026-12-29', 'Lunar', true, false, '2026-03-06 14:24:52.465665', '🏹', 'TN0862026', 'ADMIN', 'TN', true, 2026, NULL, 'சஷ்டி விரதம்', NULL, 'none');


--
-- TOC entry 5293 (class 0 OID 90137)
-- Dependencies: 251
-- Data for Name: feature_registry; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.feature_registry VALUES ('FT-001', 'Household profile setup', 'setup_household_profile', 'routers/profile.py', true, true, '{}', 'Create household, native region, current city, dietary type', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-002', 'Household members management', 'manage_household_members', 'routers/profile.py', true, true, '{FT-001}', 'Add/edit/remove members with individual dietary types', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-003', 'Complexity level definition', 'define_complexity_levels', 'routers/profile.py', true, true, '{FT-001}', 'User defines mains + sides count per level L1-L4', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-004', 'Daily meal pattern setup', 'setup_daily_meal_pattern', 'routers/profile.py', true, true, '{FT-003}', 'Assign complexity level per meal type per day', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-005', 'Household Satvik profile', 'setup_satvik_profile', 'routers/profile.py', false, true, '{FT-001}', 'User-defined Satvik rules — never hardcoded', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-006', 'Two-pattern model management', 'manage_pattern_model', 'routers/profile.py', true, true, '{FT-004}', 'Maintains default_level and current_level separately', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-010', 'Fridge inventory management', 'manage_fridge_inventory', 'routers/inventory.py', false, true, '{FT-001}', 'Add/update/remove items in household_inventory', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-011', 'Fridge check against plan', 'check_fridge_against_plan', 'routers/inventory.py', false, true, '{FT-010,FT-030}', 'Check if planned meal ingredients are in stock', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-012', 'Smart purchase form', 'record_purchase', 'routers/inventory.py', false, true, '{FT-010}', 'User enters prices, updates inventory and price_input_buffer', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-013', 'Inventory usage tracking', 'track_inventory_usage', 'routers/inventory.py', false, true, '{FT-010,FT-032}', 'Marks ingredients as consumed after plan is locked', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-020', 'User event creation', 'create_user_event', 'routers/events.py', false, true, '{FT-001}', 'Personal events with custom ID format UE0012026', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-021', 'Event active/inactive toggle', 'toggle_event_status', 'routers/events.py', false, true, '{FT-020}', 'Toggle events on/off — no hard delete', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-022', 'Admin lunar calendar', 'populate_lunar_calendar', 'routers/events.py', false, true, '{}', 'Admin batch populates event_master — ID format TN0012026-LC', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-023', 'Event surface in planning', 'get_week_events', 'routers/events.py', false, true, '{FT-020,FT-030}', 'Shows active events during weekly attendance step', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-024', 'Annual event copy', 'copy_events_to_new_year', 'routers/events.py', false, true, '{FT-020}', 'Copy previous year events to current year', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-025', 'Event calendar view', 'get_event_calendar', 'routers/events.py', false, true, '{FT-020}', 'Read-only calendar view of all active events', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-030', 'Weekly plan generation', 'generate_weekly_plan_rule_based', 'routers/weekly_plan.py', true, true, '{FT-003,FT-004,FT-006}', 'Rule-based 7-day multi-dish plan. No AI dependency.', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-031', 'Weekly questionnaire', 'process_weekly_questionnaire', 'routers/weekly_plan.py', true, true, '{FT-002,FT-030}', 'Collects attendance, cook energy, veg/non-veg split', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-032', 'Save and lock plan', 'save_and_lock_plan', 'routers/weekly_plan.py', true, true, '{FT-030}', 'State machine: Review -> Save and Lock -> Plan Locked', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-033', 'Multi-dish per meal slot', 'manage_meal_slot_dishes', 'routers/weekly_plan.py', true, true, '{FT-003,FT-030}', 'Main + side dishes per slot via meal_event_detail', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-034', 'Clone previous week', 'clone_previous_week', 'routers/weekly_plan.py', false, true, '{FT-030,FT-032}', 'Copy previous week as template with conflict warnings', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-035', 'View previous weeks', 'get_previous_week_plan', 'routers/weekly_plan.py', false, true, '{FT-032}', 'Read-only view of any past week plan', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-036', 'Plan audit check status', 'run_plan_audit', 'routers/weekly_plan.py', false, true, '{FT-032,FT-011}', 'Re-audit saved plan against current inventory and market', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-037', 'Planning notification', 'send_planning_reminder', 'routers/notifications.py', false, true, '{FT-030}', 'Push notification when next week has no plan', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-040', 'Universal recipe search', 'search_recipes', 'routers/search.py', true, true, '{FT-001}', 'Search system vault + Signature Vault. Satvik warnings shown.', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-041', 'Meal slot edit', 'edit_meal_slot', 'routers/search.py', true, true, '{FT-040,FT-030}', 'Replace any dish from current date. Override logged.', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-042', 'Surgical swap AI alternatives', 'get_ai_swap_alternatives', 'routers/search.py', false, true, '{FT-041,FT-060}', 'AI Best Match + Regional Swap options on meal click', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-043', 'Cross-day swap pure move', 'swap_meals_across_days', 'routers/search.py', false, true, '{FT-041}', 'Swap entire day or slots across days with conflict check', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-044', 'Swap reason capture', 'log_swap_reason', 'routers/search.py', false, true, '{FT-041,FT-071}', 'Complexity/Inventory/Variety/Other — feeds behavioral tracker', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-045', 'Signature Vault', 'manage_signature_vault', 'routers/search.py', false, true, '{FT-001,FT-040}', 'User creates custom recipes with image upload', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-050', 'Manual price entry', 'record_manual_price', 'routers/market.py', false, true, '{FT-001}', 'User enters staple prices, writes to price_logs', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-051', 'OGD API price fetch', 'fetch_mandi_prices', 'routers/market.py', false, true, '{FT-050}', 'Daily batch fetch from data.gov.in OGD API', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-052', 'RSI calculation engine', 'calculate_rsi', 'routers/market.py', false, true, '{FT-051}', '14-day rolling RSI per staple from price_logs', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-053', 'Wave 5 divergence detection', 'detect_wave5_divergence', 'routers/market.py', false, true, '{FT-052}', 'Detects price peak with e-NAM volume confirmation', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-054', 'Market signal dashboard', 'get_market_signals', 'routers/market.py', false, true, '{FT-052}', 'Green/Yellow/Red signal per staple in context header', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-055', 'Market stress complexity cap', 'apply_market_complexity_cap', 'routers/market.py', false, true, '{FT-053,FT-030}', 'Caps complexity at C<=3 when signal is Red', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-060', 'Gemini AI weekly draft', 'generate_weekly_draft_ai', 'routers/intelligence.py', false, true, '{FT-030,FT-071}', 'AI-powered plan via context packet -> Gemini -> JSON', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-061', 'Observation window', 'get_observation_window', 'routers/intelligence.py', false, true, '{FT-071}', 'Manages W_obs parameter — default 4 weeks', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-062', 'Taste DNA analysis', 'analyze_taste_dna', 'routers/intelligence.py', false, true, '{FT-061,FT-071}', 'Analyzes rolling history for complexity and regional patterns', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-063', 'Behavioral drift detection', 'identify_behavior_drift', 'routers/intelligence.py', false, true, '{FT-062}', 'Detects sudden shifts — triggers W_obs reset', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-064', 'Confidence score engine', 'calculate_confidence_score', 'routers/intelligence.py', false, true, '{FT-062,FT-063}', 'CS 0.0-1.0 drives Discovery/Learning/Autonomous mode', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-065', 'Low energy zone detection', 'detect_low_energy_zones', 'routers/intelligence.py', false, true, '{FT-062}', 'Tags recurring busy days from complexity downgrades', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-066', 'Regional bias detection', 'detect_regional_bias', 'routers/intelligence.py', false, true, '{FT-062}', 'Identifies consistent regional cuisine preference', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-067', 'Market stress pivot', 'monitor_market_pivot', 'routers/intelligence.py', false, true, '{FT-053,FT-062}', 'Monitors Wave 5 peak — triggers complexity cap', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-068', 'Recipe gap detection', 'detect_recipe_gap', 'routers/intelligence.py', false, true, '{FT-060}', 'Flags AI suggestions not in vault — writes to recipe_gap_analysis', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-069', 'AI reasoning explanation', 'get_ai_reasoning', 'routers/intelligence.py', false, true, '{FT-060,FT-064}', 'Explains why system suggested a dish — builds trust', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-071', 'Behavioral tracker', 'log_behavioral_event', 'routers/tracking.py', false, true, '{FT-041}', 'Logs original vs new recipe on every swap with reason', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-072', 'Weekly session context log', 'log_weekly_session_context', 'routers/tracking.py', false, true, '{FT-031,FT-071}', 'Saves input snapshot when plan is generated', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-073', 'Pattern update after save', 'update_current_pattern', 'routers/tracking.py', false, true, '{FT-071,FT-006}', 'Updates current_level incrementally after every locked week', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-080', 'Recipe vault management', 'manage_recipe_vault', 'routers/recipes.py', true, true, '{}', 'Admin CRUD for recipe_dna_master and recipe_content_vault', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-081', 'AI batch image generation', 'generate_recipe_images', 'routers/recipes.py', false, true, '{FT-080}', 'Batch AI image generation for all vault recipes', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-082', 'User recipe image upload', 'upload_recipe_image', 'routers/recipes.py', false, true, '{FT-045}', 'Upload interface for Signature Vault recipes', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-090', 'WhatsApp meal card export', 'send_whatsapp_meal_card', 'routers/notifications.py', false, true, '{FT-032}', 'Formatted weekly summary via Twilio to household WhatsApp', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-091', 'In-app planning reminder', 'send_planning_reminder', 'routers/notifications.py', false, true, '{FT-030}', 'Push notification when next week has no plan', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-100', 'Feature registry management', 'manage_feature_registry', 'routers/admin.py', true, true, '{}', 'Admin CRUD for feature_registry table', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-101', 'Household entitlement mgmt', 'manage_entitlements', 'routers/admin.py', true, true, '{FT-100}', 'Admin enables/disables features per household with dependency enforcement', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-102', 'Bulk entitlement management', 'bulk_manage_entitlements', 'routers/admin.py', false, true, '{FT-101}', 'Enable/disable feature for all households at once', '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.feature_registry VALUES ('FT-026', 'Lunar event GIF fetch', 'fetch_event_gif', 'routers/events.py', false, true, '{FT-022}', 'During lunar calendar batch population, calls Tenor API to fetch and store GIF URL per event. One-time per event at population.', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');
INSERT INTO public.feature_registry VALUES ('FT-027', 'User GIF picker', 'get_gif_repository', 'routers/events.py', false, true, '{FT-020}', 'Returns curated GIF repository grouped by category for user personal event creation. User browses and selects.', '2026-04-14 13:05:45.457279', '2026-04-14 13:05:45.457279');


--
-- TOC entry 5294 (class 0 OID 90149)
-- Dependencies: 252
-- Data for Name: household_entitlements; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5282 (class 0 OID 16728)
-- Dependencies: 237
-- Data for Name: household_inventory; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.household_inventory VALUES ('733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'STP-PNR', 'In-Stock', '2026-03-10 17:00:26.250493');
INSERT INTO public.household_inventory VALUES ('733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'STP-TDL', 'In-Stock', '2026-03-10 17:00:26.250493');
INSERT INTO public.household_inventory VALUES ('733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'STP-RCE', 'In-Stock', '2026-03-10 17:00:26.250493');
INSERT INTO public.household_inventory VALUES ('733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'STP-MSH', 'Out', '2026-03-10 17:00:26.250493');


--
-- TOC entry 5279 (class 0 OID 16705)
-- Dependencies: 234
-- Data for Name: household_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.household_master VALUES ('8b4f002f-b78e-478a-8f75-81b427f03786', 'Main Sanctuary', 'Bengaluru', 'Veg', NULL, NULL, '2026-04-14 11:47:02.575629');
INSERT INTO public.household_master VALUES ('733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lead Developer Home', 'Tamil Nadu', 'Veg', NULL, NULL, '2026-04-14 11:47:02.575629');


--
-- TOC entry 5280 (class 0 OID 16711)
-- Dependencies: 235
-- Data for Name: household_members; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5295 (class 0 OID 90169)
-- Dependencies: 253
-- Data for Name: household_satvik_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5265 (class 0 OID 16389)
-- Dependencies: 219
-- Data for Name: ingredient_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ingredient_master VALUES (1, 7, 1.50, 1277.00, '2026-02-25 12:01:16.40542', 80.00);
INSERT INTO public.ingredient_master VALUES (2, 30, 1.40, 1277.00, '2026-02-25 12:01:16.40542', 65.00);
INSERT INTO public.ingredient_master VALUES (3, 15, 1.30, 1277.00, '2026-02-25 12:01:16.40542', 120.00);
INSERT INTO public.ingredient_master VALUES (4, 14, 1.10, 1277.00, '2026-02-25 12:01:16.40542', 150.00);
INSERT INTO public.ingredient_master VALUES (5, 30, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 300.00);
INSERT INTO public.ingredient_master VALUES (6, 4, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 30.00);
INSERT INTO public.ingredient_master VALUES (7, 14, 1.10, 1277.00, '2026-02-25 12:01:16.40542', 40.00);
INSERT INTO public.ingredient_master VALUES (8, 21, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 50.00);
INSERT INTO public.ingredient_master VALUES (9, 10, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 60.00);
INSERT INTO public.ingredient_master VALUES (10, 7, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 45.00);
INSERT INTO public.ingredient_master VALUES (11, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 70.00);
INSERT INTO public.ingredient_master VALUES (12, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 65.00);
INSERT INTO public.ingredient_master VALUES (13, 180, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 160.00);
INSERT INTO public.ingredient_master VALUES (14, 180, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 180.00);
INSERT INTO public.ingredient_master VALUES (15, 120, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 110.00);
INSERT INTO public.ingredient_master VALUES (16, 365, 1.10, 1277.00, '2026-02-25 12:01:16.40542', 1000.00);
INSERT INTO public.ingredient_master VALUES (17, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 450.00);
INSERT INTO public.ingredient_master VALUES (18, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 150.00);
INSERT INTO public.ingredient_master VALUES (19, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 180.00);
INSERT INTO public.ingredient_master VALUES (20, 365, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 400.00);
INSERT INTO public.ingredient_master VALUES (21, 180, 1.30, 1277.00, '2026-02-25 12:01:16.40542', 350.00);
INSERT INTO public.ingredient_master VALUES (22, 180, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 250.00);
INSERT INTO public.ingredient_master VALUES (23, 2, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 70.00);
INSERT INTO public.ingredient_master VALUES (24, 30, 1.10, 1277.00, '2026-02-25 12:01:16.40542', 60.00);
INSERT INTO public.ingredient_master VALUES (25, 365, 1.20, 1277.00, '2026-02-25 12:01:16.40542', 200.00);
INSERT INTO public.ingredient_master VALUES (26, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 600.00);
INSERT INTO public.ingredient_master VALUES (27, 60, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 60.00);
INSERT INTO public.ingredient_master VALUES (28, 45, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 80.00);
INSERT INTO public.ingredient_master VALUES (29, 15, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 25.00);
INSERT INTO public.ingredient_master VALUES (30, 365, 1.00, 1277.00, '2026-02-25 12:01:16.40542', 20.00);


--
-- TOC entry 5266 (class 0 OID 16399)
-- Dependencies: 220
-- Data for Name: ingredient_translations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.ingredient_translations VALUES (1, 'en', 'Tomato');
INSERT INTO public.ingredient_translations VALUES (1, 'ta', 'தக்காளி');
INSERT INTO public.ingredient_translations VALUES (2, 'en', 'Onion');
INSERT INTO public.ingredient_translations VALUES (2, 'ta', 'வெங்காயம்');
INSERT INTO public.ingredient_translations VALUES (3, 'en', 'Small Onion (Shallots)');
INSERT INTO public.ingredient_translations VALUES (3, 'ta', 'சின்ன வெங்காயம்');
INSERT INTO public.ingredient_translations VALUES (4, 'en', 'Ginger');
INSERT INTO public.ingredient_translations VALUES (4, 'ta', 'இஞ்சி');
INSERT INTO public.ingredient_translations VALUES (5, 'en', 'Garlic');
INSERT INTO public.ingredient_translations VALUES (5, 'ta', 'பூண்டு');
INSERT INTO public.ingredient_translations VALUES (6, 'en', 'Coriander Leaves');
INSERT INTO public.ingredient_translations VALUES (6, 'ta', 'கொத்தமல்லி');
INSERT INTO public.ingredient_translations VALUES (7, 'en', 'Green Chilli');
INSERT INTO public.ingredient_translations VALUES (7, 'ta', 'பச்சை மிளகாய்');
INSERT INTO public.ingredient_translations VALUES (8, 'en', 'Potato');
INSERT INTO public.ingredient_translations VALUES (8, 'ta', 'உருளைக்கிழங்கு');
INSERT INTO public.ingredient_translations VALUES (9, 'en', 'Brinjal');
INSERT INTO public.ingredient_translations VALUES (9, 'ta', 'கத்தரிக்காய்');
INSERT INTO public.ingredient_translations VALUES (10, 'en', 'Drumstick');
INSERT INTO public.ingredient_translations VALUES (10, 'ta', 'முருங்கைக்காய்');
INSERT INTO public.ingredient_translations VALUES (11, 'en', 'Raw Rice');
INSERT INTO public.ingredient_translations VALUES (11, 'ta', 'பச்சரிசி');
INSERT INTO public.ingredient_translations VALUES (12, 'en', 'Boiled Rice');
INSERT INTO public.ingredient_translations VALUES (12, 'ta', 'புழுங்கல் அரிசி');
INSERT INTO public.ingredient_translations VALUES (13, 'en', 'Toor Dal');
INSERT INTO public.ingredient_translations VALUES (13, 'ta', 'துவரம் பருப்பு');
INSERT INTO public.ingredient_translations VALUES (14, 'en', 'Urad Dal');
INSERT INTO public.ingredient_translations VALUES (14, 'ta', 'உளுத்தம் பருப்பு');
INSERT INTO public.ingredient_translations VALUES (15, 'en', 'Green Gram');
INSERT INTO public.ingredient_translations VALUES (15, 'ta', 'பச்சைப்பயறு');
INSERT INTO public.ingredient_translations VALUES (16, 'en', 'Black Pepper');
INSERT INTO public.ingredient_translations VALUES (16, 'ta', 'மிளகு');
INSERT INTO public.ingredient_translations VALUES (17, 'en', 'Cumin Seeds');
INSERT INTO public.ingredient_translations VALUES (17, 'ta', 'சீரகம்');
INSERT INTO public.ingredient_translations VALUES (18, 'en', 'Mustard Seeds');
INSERT INTO public.ingredient_translations VALUES (18, 'ta', 'கடுகு');
INSERT INTO public.ingredient_translations VALUES (19, 'en', 'Fenugreek');
INSERT INTO public.ingredient_translations VALUES (19, 'ta', 'வெந்தயம்');
INSERT INTO public.ingredient_translations VALUES (20, 'en', 'Dry Red Chilli');
INSERT INTO public.ingredient_translations VALUES (20, 'ta', 'காய்ந்த மிளகாய்');
INSERT INTO public.ingredient_translations VALUES (21, 'en', 'Gingelly Oil');
INSERT INTO public.ingredient_translations VALUES (21, 'ta', 'நல்லெண்ணெய்');
INSERT INTO public.ingredient_translations VALUES (22, 'en', 'Coconut Oil');
INSERT INTO public.ingredient_translations VALUES (22, 'ta', 'தேங்காய் எண்ணெய்');
INSERT INTO public.ingredient_translations VALUES (23, 'en', 'Milk');
INSERT INTO public.ingredient_translations VALUES (23, 'ta', 'பால்');
INSERT INTO public.ingredient_translations VALUES (24, 'en', 'Coconut');
INSERT INTO public.ingredient_translations VALUES (24, 'ta', 'தேங்காய்');
INSERT INTO public.ingredient_translations VALUES (25, 'en', 'Tamarind');
INSERT INTO public.ingredient_translations VALUES (25, 'ta', 'புளி');
INSERT INTO public.ingredient_translations VALUES (26, 'en', 'Asafoetida');
INSERT INTO public.ingredient_translations VALUES (26, 'ta', 'பெருங்காயம்');
INSERT INTO public.ingredient_translations VALUES (27, 'en', 'Jaggery');
INSERT INTO public.ingredient_translations VALUES (27, 'ta', 'வெல்லம்');
INSERT INTO public.ingredient_translations VALUES (28, 'en', 'Semolina (Rava)');
INSERT INTO public.ingredient_translations VALUES (28, 'ta', 'ரவை');
INSERT INTO public.ingredient_translations VALUES (29, 'en', 'Curry Leaves');
INSERT INTO public.ingredient_translations VALUES (29, 'ta', 'கறிவேப்பிலை');
INSERT INTO public.ingredient_translations VALUES (30, 'en', 'Crystal Salt');
INSERT INTO public.ingredient_translations VALUES (30, 'ta', 'கல் உப்பு');


--
-- TOC entry 5275 (class 0 OID 16505)
-- Dependencies: 230
-- Data for Name: market_locations; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.market_locations VALUES (1, 'Main City Market', 'INR');


--
-- TOC entry 5285 (class 0 OID 16805)
-- Dependencies: 240
-- Data for Name: meal_attendance_link; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5288 (class 0 OID 16859)
-- Dependencies: 244
-- Data for Name: meal_attendance_log; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5292 (class 0 OID 49171)
-- Dependencies: 250
-- Data for Name: meal_audit_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.meal_audit_logs VALUES ('56ce92f0-7f0c-4530-bfe9-f78f2fdacd93', '5484dc0e-4461-4c27-b3c9-972fcabc98b7', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('a797b1f6-8d6c-4667-88c9-c5bd31f3beb9', 'f7c9c437-6199-488c-8c55-9dbe9a9b6f44', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('2ba80930-fe2b-43aa-a51c-f9b577ba722d', 'e462143a-6a84-4865-970e-460a73f4a5c2', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('11154041-9d47-4355-b1bf-6d43dbbe3460', 'bbfd1011-2b22-4aef-b7ec-e8e3e5f1d00f', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('85120236-4859-4bba-a1cb-0f95330c6b30', '44429c43-58da-4701-8ad1-4e7dc7692352', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('cf4682a2-55c0-4676-aca4-65796acdbd6e', 'b784eb31-503d-4904-a184-ab26613a4040', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('330697a7-4f29-4bea-8e00-69d7e29a0125', 'b5e8a1f8-3b44-4e84-819e-ce247196a88d', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('ea52f0bf-9807-4af7-b5d8-bf1ae3e57818', '8e4892f2-7131-42a7-98d4-fb4e0cc3a69e', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('4fab4c31-8c79-409f-8e8f-2576b19107c9', 'cc56c71a-1c7a-4224-8bf8-b6a009663792', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('7d1ed958-452e-4d2a-9ca7-5ce62387580b', '8ceeca33-4167-4c08-9356-5b9365ca9d90', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('26046e02-9f83-4f74-9959-ce5ca16a0019', 'bdc6d42d-0bdd-4c97-b0f3-d3883699723c', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('09e293b1-a27d-4fad-988c-cc99939abe17', '771e9a5d-d008-46fa-ba74-d5853ca0fe4c', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('b8e53370-cee9-4bd2-9d80-e89ca040ecb2', '685d13d9-8fbb-4dbd-9049-ef68f5994a85', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('23bc95b5-dd87-4bdf-9181-3795f47d56c8', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('5a3e124b-30a2-4c1c-82d6-0a830a95c1ea', 'af727d71-7f00-4add-84cb-dc5bd631904e', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('957c95a9-7727-4ad6-9e94-e7dd20ef66d7', 'e1041696-59d4-4383-a7d9-32cbf8fe2cf9', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('519ec76c-f53a-40e4-8b71-35efae225577', '5f4afee5-971c-4724-89a5-f7c0eca3c6ff', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('6118da59-391a-4310-9074-6706a2ead287', '53ccaf1d-0382-4602-9cda-c1a7d5b9d886', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('e3da2ee2-6e00-4c05-ab56-ac687a5bf251', 'bade33e0-792e-496c-be21-48a73b707c73', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('4c667f06-6683-41e2-9a66-727da9e67894', 'bb8f3693-5e8e-4706-9c04-d6e17cf6528b', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Manual', false);
INSERT INTO public.meal_audit_logs VALUES ('ae992f58-6677-4f37-8145-0c74b027c728', 'b07183fe-8890-4f98-945e-bb772626b711', 'Save', 'Manual_Save', '2026-04-17 11:47:35.712054', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', 'Manual', false);


--
-- TOC entry 5290 (class 0 OID 32788)
-- Dependencies: 247
-- Data for Name: meal_event_detail; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.meal_event_detail VALUES ('9a70893f-5920-4bfd-a60a-8faaf9cbac20', '695ccd39-a99f-422e-adf4-4b8a9b00afbf', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bbd5f69e-4a55-4db3-a1fa-edd4657945ad', '7088f58e-d99e-43e0-b25f-3a6fa9dba5f9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('350d3225-ee29-4e79-84ea-eabb17f49b15', 'c5209bd6-c818-4723-b888-fb857a835506', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6aa0150e-1033-4e61-a2d9-10a7813615a8', '889c87c1-ceab-4aac-bf4a-6efe1dd1b0be', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e185b2dd-41f0-4bb2-9cdc-d93f14d3389f', 'ad718b0c-986c-4b0e-b6c9-165c5f27b9b0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b9482c5f-8172-4449-8e85-fcc06c8aeb6b', '87789e73-25b3-4647-9edf-5959e1643cd2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a4b9ff0f-0982-43ea-8ab7-7f731fea1800', '9b6b54ac-0fcc-4e38-9417-fd19eff85883', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c1c126e1-f5cd-424b-8db9-2d93323143bd', '89111965-51b1-4140-96b4-d1245af7b057', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('02f1f9af-374a-466c-8ef3-5b300bd962b8', '674cfc56-372f-4ba8-b2c2-d49de1ab31f0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ffcb0061-d200-4085-8a85-7a488758450b', '6dc2a5ec-6280-4f28-b1a4-7433ca0f2859', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('211361a1-2d3f-4950-b4db-cc91e97a8bd6', 'aa7930a5-de00-4bce-8835-e55e5da4c50f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7c0ce63b-db10-4cd4-bd4a-d82c7701771a', 'ebdf7351-b5c7-4ad7-9ccd-367f80268440', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('280c74f6-b2b7-4c87-a12e-ed2e0e7b5696', 'ab51093c-b2ce-4da5-afa5-b96ffd944252', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a140e4ec-2733-420d-b611-d9a8112244bf', 'd24772ca-3e40-467b-9676-d6cafb66ab28', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('45a95b7e-edc5-4d08-afe3-c26e475532f9', 'c84f642d-484e-4442-93a4-2ebe21f1dbdf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a9bf739d-f498-4db3-9141-943802b3ae82', 'e0244865-5250-4463-af53-521f7c2f13e9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('393feb89-7b7d-42d3-8c0d-15e6450fb1fe', 'dfe7df7c-2eca-45c0-a1e5-c187d38ede1b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('419c70fc-d5e2-4625-8310-19f947a9283f', 'f7803ba4-fafc-4d62-bf74-05864b1b5ac1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7b574f95-d64b-49f9-9855-64909457ffa8', 'd0bde7bf-cbd1-46e7-86bc-e900771ffd8a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2a2fe008-44e5-4fc4-9b29-33506a26a1af', '11066a04-b4fe-4afa-ba90-33fd5d821697', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5f8a447f-95de-47bc-8353-15128f92f4dd', 'f8a4095c-8a98-4526-9cf3-809c2318d1c1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('559b6deb-ff08-4927-bb89-3d90b2a0ff06', '3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ba34fe04-0fd1-4451-b10b-87429213f238', '361ab7ab-b76c-4596-bc10-908d0e5977dc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('70505edf-9b11-425e-bf3c-15d110f18797', '03005c76-5533-4ee8-b7d5-6f52fb118077', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e7f92a2f-8e5d-426c-bf5c-8090c76107d7', 'a1e16b13-3878-4224-b711-6379641d3afe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d922833d-662a-4121-9064-c1b4a0bdb992', '1f99dd5a-6e27-4b5f-9921-69a71174ed05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c9fe5bce-e6ed-419d-ac2b-afe73e98c1f3', '247ea03f-cc1a-4cb6-ae18-6c97160c093c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9825956c-9d6b-4ae5-b2ca-744c39167a43', '705874b7-7dd9-4bc7-91b8-bb7c140fbc86', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('12a85ab9-2d3e-445c-8902-1e7fd3b6f159', '5bf7c543-2d7c-47d3-80af-049eb2dd43ab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('65851ace-c055-4e79-aa0b-10d82e122057', '5927c122-bc55-4690-a831-d7f4a1fe9d86', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('715f07d6-ad40-43f4-bdac-a3355f2e19c7', '5437ef6b-54b1-415c-ac64-b93530c6557e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('76e2ae7b-106d-4ba3-a9b5-3933af283ee5', '232032e2-b760-4111-a33a-e7bbbfeea64f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b47c4b07-876a-4772-9d8b-38ba8bb2d6bb', '4066785a-2e99-44b4-a625-bd7f9ae8469b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('155a2135-7dbd-4e11-a717-ec2de80b40d6', '6fbc0039-e261-4941-a129-ed9c163b81c8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6077ddb5-b700-4a1d-b9d3-6510746f3857', '03a11d42-8d40-4873-8e1b-c64c5c606100', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('da79ec83-b7c0-46cb-a0f7-ee93f210a952', '955c5848-4979-4873-a233-01157f2cb5b7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0705fa14-336c-4140-81f7-1b116b820b71', '07119274-a390-49ac-bba3-0292814d0ccf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bd52f99e-aa8c-4ebc-a2ce-58130a8f3a93', 'fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('64de1c9d-69be-45c5-9bbc-66a4f285a2cf', '7475cd18-81c8-425f-a87b-06e4a3cbbfdf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('605a602b-ee27-4295-93db-83210b4fe5f7', 'e0850e47-3d4d-4f59-ae5e-5c5216e778ba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7d57a1c7-4f96-456e-96b5-938b77e8b44a', '25645465-c92f-4b38-8374-45751b7061e2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('36c7de76-2490-4f37-99e2-22b45a5046bb', '9fae68e6-11ab-45b8-9f49-f63d710d867c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f125fa7e-3aac-4d12-81f0-d04a8d8748cb', '03015ea6-a0ba-48c1-a4c7-7381799f9342', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('94a016d6-1c7a-40ea-a2da-ba55878d34da', '718d972c-6553-4ec5-ac88-28dd81e3ed2d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('40bcefdf-62ba-4df5-a803-bd44c635bfab', '27160bd1-d41c-46ff-9737-5448c5cff098', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('431f82ea-ccbe-4a92-b9de-07585c8aae6f', 'c1ab2193-74ec-462b-8ae2-76a69d394102', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cd227867-0fd4-4528-a0b5-4fa130c4a71e', '00942178-64d4-4bfa-88d6-9879363c7f8c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('82d960a6-beac-408a-9841-ed280e81c3b1', '54542518-02a8-4dcd-942b-500c32601f8c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1cd74612-587a-48c9-bee0-875106890ee4', '1e021341-b4ca-4173-98d2-2fbc879b7177', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c04fdcd0-ad20-41ed-ba3a-5c606bf79c0f', '01cdf071-00c4-4850-87e4-142ab0363bd9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0820c55c-e06e-42e7-9b64-14d4038cb7e0', 'dbf8c1c6-976d-4094-8d4d-6dc21740a688', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4c873b41-f7ce-49b8-aa9b-d82863a2d6fd', 'aa52f754-1f78-48e1-a64f-8a2885ec4dfc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('052f1489-9949-4333-89dc-1afa62cd3463', '33ade968-d13f-4a6d-a31c-571e26c07272', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ec4101c4-2c78-49be-903a-c68f1a248108', '1901c785-6dea-4eac-a4a9-573eddcd2a84', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8bc6c3a0-4452-4950-b919-e35f62033a2c', '5fd92fec-67a5-4922-9f3d-b4f8a25dc446', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('76f38e6c-f5ef-4a0c-b71c-dd5562781a62', 'cb6353af-0e89-476a-a289-74d4f1869188', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eebd488f-9da4-4dc3-8e10-c1880bbfe510', '111d701c-9202-440a-b4a0-6fbf925005ea', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('95d10524-e5cb-4b61-8ce1-6a91d542d8de', '1ec09257-e5c1-4afb-856b-04488c43d513', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5941d2f2-b664-43e0-9d30-6266c0716e90', 'f424774c-0842-451f-93d3-62a42ec8ff19', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('36d1896e-117a-47c0-ab3d-9955d16f898f', 'de3a1aaf-e336-4544-8340-9dd14cc05501', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b6b70125-87fd-4146-84bf-c0b1c2b8ce97', 'e94b8fd6-0a07-4ab8-998d-15bcf09cfe05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('28713b98-8433-4ec7-a7f2-1c0aedf7e043', 'ed536348-ac58-4365-8a89-5dc34905e7a2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7282054d-4f04-404e-afaf-3abe5d437e5a', '0b05103e-50ef-4528-bd1c-7067fb90799e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('55713626-3ff4-454f-82ed-cc597763e015', '593cd4d3-0c6a-40ea-8bba-cf62a929b3bd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('87391453-d14f-45d7-9bb3-a25a1ed4cc3a', '7a5204ec-996b-477d-a01d-3e5ab2203593', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('232dc3c7-7408-472e-b271-8a43a3e84eed', '03e718de-545a-46b1-8d8d-74dfb82cc2ea', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c5e99c5b-e4c9-4ba7-9351-03bf07b12076', '08febdc9-65ba-4de8-aa56-fd8c225cf667', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d7194a5e-cef7-42e4-ae50-b76d33b915b8', 'f795aabb-da2e-48bf-9af8-db7297cd48dc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2b100391-21d5-4ca0-9538-87a236d92af4', 'f9b7ca53-0141-4e0d-95fe-a060f5476ce0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a0484ce4-9b2b-4490-92d9-a8e97e4ce0f5', '7b1dd89c-9abd-4245-b7b5-582f0342e17e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d94165aa-ca7e-4827-a139-5979ab069b29', '973f29b0-697b-4ef6-a8cd-be11fa396c95', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6941312c-4085-4759-940a-4dcd7c062cf4', '021fa17d-1be9-4939-a934-043c564c7e7e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2d5cb697-d138-4efc-b377-621e87cba029', 'fd4953e2-3082-4e1d-b6c9-0fbf339a976a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('923e81e3-cbff-42dd-89d3-dee701460090', '65346b49-1538-4baf-bc58-b0c16233543b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a2195050-ff31-49e8-9c32-9316d88ec94e', '9802c181-0c7e-414e-8a51-c3d39a7aa6c1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ad5cf1fe-d516-4096-8d23-a05a5d24e9d4', '8e91b003-3444-486a-aa41-c015daf65fd0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fdfe0240-4172-42a0-ad73-8d44e34265b0', 'fedb3245-4c36-4e4a-9c0d-28732cc6536e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('32cf97de-1a35-40d1-8938-89e16eb4a0fd', '8066b63c-83c0-4f89-aae5-02cadb950a18', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7224e3d9-30e9-49df-8bc5-460599110b12', '9fd5f317-b2dc-4eae-81f7-29ac34cf25fd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('426dfbd7-a2e8-49e4-8fdf-3746c46aa3dc', '4919d1d1-f3e4-4f73-b91a-db2ed794bd7c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b52310a9-b73d-44ba-9a93-fdfac4fa6f75', '1e9177c6-8dba-4e7b-a300-a42908c5de0c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9eb1a224-29f8-4127-86c9-b8300fe748c0', 'ac39b97e-759a-4a6a-a327-a125e2da27f9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('496a6c83-564a-4fa0-9772-7e6653cea8f1', '96504a95-770a-496c-b3d1-68734b64e89b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('36803687-a2a6-4b1d-ba67-f48753b7fb86', 'ad8c58cf-c7e7-40a3-a671-af177a7d5dd6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1d175603-4d2c-423c-8250-9194ad75bd4b', '3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fb0f0416-fa7f-4ce3-ba54-49c7fcc775c6', '361ab7ab-b76c-4596-bc10-908d0e5977dc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('db713a82-8506-4da7-8db0-af13a420dd9d', '03005c76-5533-4ee8-b7d5-6f52fb118077', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('74420547-bdc0-4f0f-bd10-cb5f7911ab89', 'a1e16b13-3878-4224-b711-6379641d3afe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('033ab4ae-d5e1-43ff-919e-6b57a7be6b73', '1f99dd5a-6e27-4b5f-9921-69a71174ed05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('495a4fa0-aec1-4c45-863e-b808886160d1', '247ea03f-cc1a-4cb6-ae18-6c97160c093c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0d143d96-cd99-46f0-b116-95721f117a25', '705874b7-7dd9-4bc7-91b8-bb7c140fbc86', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6ad564bc-6a6b-4bb3-b001-8e699fabf052', '5bf7c543-2d7c-47d3-80af-049eb2dd43ab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('79c226a3-4f91-45ba-a81b-fd4c8fbebe3d', '5927c122-bc55-4690-a831-d7f4a1fe9d86', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dd1dc35b-e15f-46de-8a06-95e6844d77da', '5437ef6b-54b1-415c-ac64-b93530c6557e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('34f6bda3-dc4e-439b-9ec8-93b8207cd4ac', '232032e2-b760-4111-a33a-e7bbbfeea64f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c137d59a-1dc5-4896-99f8-4192d8d6b2e1', '4066785a-2e99-44b4-a625-bd7f9ae8469b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8b593bf5-14dd-4cbe-a4f4-9f4a1e54fc5b', '6fbc0039-e261-4941-a129-ed9c163b81c8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('86fb8eab-45ac-4a6a-919b-d42a5c699b23', '03a11d42-8d40-4873-8e1b-c64c5c606100', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('77aea0cc-1561-4a42-acc4-2d33417225ea', '955c5848-4979-4873-a233-01157f2cb5b7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('784c0e1e-47a7-4c4d-826f-363dd7c1911e', '07119274-a390-49ac-bba3-0292814d0ccf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d75660af-e989-4558-9a64-8a2e5477fbf8', 'fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('00e3bf66-d044-4b2d-acc4-69f5feaedb6b', '7475cd18-81c8-425f-a87b-06e4a3cbbfdf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('caa4b927-8c42-46df-b1ca-7fbe38799418', 'e0850e47-3d4d-4f59-ae5e-5c5216e778ba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('03d93d79-6796-416a-840e-87bf95f1a49c', '25645465-c92f-4b38-8374-45751b7061e2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6604f8aa-cad0-45c0-bcec-12c8f99610db', '9fae68e6-11ab-45b8-9f49-f63d710d867c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bce9d307-34f2-4b2c-9898-8fe9b0762419', '03015ea6-a0ba-48c1-a4c7-7381799f9342', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5696526c-f53d-43b3-b057-f0ef182f15ee', '718d972c-6553-4ec5-ac88-28dd81e3ed2d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('164f40aa-dea8-4b80-8876-9cdf13109d2f', '27160bd1-d41c-46ff-9737-5448c5cff098', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b59b8ff9-f38b-44c3-b9b2-32b4a36afb7c', 'c1ab2193-74ec-462b-8ae2-76a69d394102', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ec7d689e-4a2e-4603-a20c-24a21b4b5f51', '00942178-64d4-4bfa-88d6-9879363c7f8c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f194b520-18e7-470c-8880-72b905336987', '54542518-02a8-4dcd-942b-500c32601f8c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2a9eb256-f457-4e74-9b05-2ed3f6b467e3', '1e021341-b4ca-4173-98d2-2fbc879b7177', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ab71a4cd-d31a-4a9c-b951-ef66b416f749', '01cdf071-00c4-4850-87e4-142ab0363bd9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c299dced-c58a-4cdf-a327-c267eb0abe6f', 'dbf8c1c6-976d-4094-8d4d-6dc21740a688', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e9f7f9a2-9c94-4d6d-ae98-e4ddc8d7d811', 'aa52f754-1f78-48e1-a64f-8a2885ec4dfc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('01efd69d-0c3d-4f35-aa28-58b01d4b1dba', '33ade968-d13f-4a6d-a31c-571e26c07272', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('354e4b2e-a789-4390-9d09-898a980d0f6e', '1901c785-6dea-4eac-a4a9-573eddcd2a84', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8079d601-a25f-44a7-ade6-1d486f361831', '5fd92fec-67a5-4922-9f3d-b4f8a25dc446', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fc7aa167-ecf7-49e7-9cb7-c151aa45f292', 'cb6353af-0e89-476a-a289-74d4f1869188', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6621cfbe-30e2-4702-b35c-b88595a5bbe2', '111d701c-9202-440a-b4a0-6fbf925005ea', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('969c2b97-33d1-48a2-89d4-87241cd4a144', '1ec09257-e5c1-4afb-856b-04488c43d513', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7a5dc864-02b7-48ec-b9a8-d079ce27b0b3', 'f424774c-0842-451f-93d3-62a42ec8ff19', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('df00bec2-4be0-4e95-8adc-67ce4846e9ce', 'de3a1aaf-e336-4544-8340-9dd14cc05501', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('20e7a501-1369-439d-9d81-74d12c29e72c', 'e94b8fd6-0a07-4ab8-998d-15bcf09cfe05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b90f5410-cced-4a43-8b6e-92d15fc79229', 'ed536348-ac58-4365-8a89-5dc34905e7a2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('611f1cd9-bb71-4503-a309-5b95e86ab947', '0b05103e-50ef-4528-bd1c-7067fb90799e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('efab3a3e-1643-467c-b9b8-9467574cd7c9', '1bc2fc7c-50d7-48d0-b739-a0812ca63b08', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('48453070-baa8-4972-8166-3b32fef12a52', '7d089548-6a62-4e43-ad50-c6130c9359c3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1155998e-7015-48f8-a936-8c728fe6d104', '01c47015-ffdc-4cb2-b1d4-dac4949181c1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('171a7dd7-a04e-42e7-b35f-8ecbf5a35c93', 'cce373e8-938a-474f-92c6-453bbb0e12c0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1bd58920-604b-4751-86bc-b335365361e8', '89fc4e8e-d7e7-48c0-92e3-e6e532ec0e97', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4cb8c7ea-b792-42bf-9138-1b588c096638', '7daac1d0-3479-44f3-b528-7dcdc83f88bd', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('17658475-3738-4240-a37d-4b0f7cc59bdb', 'f387f839-dec2-48ab-bf57-42526fead56c', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fffe7cb7-07e7-48b6-a9da-0edfc65b0397', '65c2b7e5-2b13-43c0-874f-e87a07b8afad', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ecc2e1d4-54d0-47d2-b706-387db1f55ace', '17f9889a-7822-4f0d-b54d-b6c800b82496', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('30bcf47c-88c6-4859-9242-a0e6429e8771', '36b38f89-2cb1-4851-801f-b12457451cfc', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dd760bf2-0d4c-4e03-9a54-e84da373e73c', 'a779b73e-4acf-418e-89fa-9cb186efde26', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e2ddd3ed-ba41-4058-a810-bf3b8f8fdc35', '36947847-1484-4297-bc27-48d4a411920d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d3f44b58-9c50-4cc5-b4f0-a9d301b2167a', '154d55d6-8c41-4bc6-be18-70450d936a46', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fd912157-54d4-41c0-9e79-c4e62548ddc3', 'd3807c97-dc51-4004-930e-275634348d46', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c5c7fbb2-5a2d-40ac-a24f-77f3b2522e30', 'ee0c8c0b-b4d3-4bb5-959d-bf384418bf7d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('909a73cb-7d26-4d18-8828-7d915341b072', '49beeb4d-db3c-4bd8-b669-48bd3b992014', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('de394ea8-b95b-4701-9ad5-87c7d28dc445', '7ceac529-4160-40f8-b291-f7a7e057966f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f25ff6b9-ff46-4a22-ad81-465491b5298c', 'de42d264-5233-4396-8ce1-61042cf694ff', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('58e8ca80-9dd5-400a-a6e8-f8b7d3900d2c', 'eb0fb6b7-1d36-4ec3-b2cb-3f0c7074b9bb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('92231c24-dc47-4d6a-8e72-3af168007d7b', 'd003bdae-ee03-4eef-8c29-8cbca3c34738', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b47f6594-8bbf-469f-aeb9-4c99adb38dcb', '9b792c67-042d-4734-8bbb-e99c55ba9167', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f8a8eab1-ed4f-4d74-9a4d-62e30b842b59', '2cbec3cf-1a15-49dd-b03d-ef533834ce79', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1851deda-fd1c-4ad2-ac5f-068691e74fc2', '2f96de10-09cd-458d-b1bf-0c21cc79731a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('af38939d-55f8-4079-94fa-54cad7dd274c', '8da4116d-e2f0-4867-af5d-b20b5525941f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('41fd5a15-8fff-406b-ae09-243a841fcba6', 'b2f991f5-3fa2-413e-83a2-f2272d9fd787', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('03d7f89c-10a0-4e3d-9b9f-7319eccb6e10', '14794b79-a3fe-4ec2-abf5-d5c450cb47fd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('898a288c-997a-4b3d-bafb-a518058263e5', '58a4b8ce-0860-446a-be6d-2c285cb7bbf7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bd49de2b-ceb5-4628-8298-6ee0ea8037a4', '6e476397-df7c-4f9f-b77a-4acd07c746ef', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d1317f3a-6c79-4b27-8121-21513c43221c', '9f570988-97b6-4f52-be8e-3d9d0769f450', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bd3ba446-53b6-433c-8815-98e1f1b445f4', '11eb074c-06c2-483a-9d52-60b7adf75d03', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fa3b6dbb-b6f3-459c-a93b-aba5eae555dc', '1a9f57de-4f65-42ff-9952-512297758ea6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('266f1447-48ea-4793-adfd-89806ae6bfd3', '76af3958-4a9b-4f6c-8432-9a06824fa76e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d53f6dca-e3d7-4f6d-a44a-b02e6a191507', '89efd574-c770-4365-a049-93d8fe47e834', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('50915562-3e31-4ff7-af71-2214308f2d1c', '8b8d5120-5b13-45ec-a9be-f3df80f0b351', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('80e25c65-d287-4f3c-bf73-8fc5b04f910f', '2e27dae5-3dcf-4b3b-9b5c-004aa392dfc3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bdc1e6a6-937b-4ba9-b09d-4847a9fe9a4f', '542f57ab-fedb-46d1-8adb-7a1c53ebaf25', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6b61e4d3-f592-43be-953a-cac05261c820', '9768eeab-de17-4455-90bc-afc2cea28ec4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('791f9c22-3282-42b8-8017-939aa2081952', '7702a50b-438f-4c90-a451-c54971d1ac7d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('00bbc010-1d0c-48b8-a59c-b09f3ab32ac4', 'e119b759-2be7-4779-a4b5-f5d99dc88720', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('27e30f83-ebdd-4dc1-b62e-3aaa0192c862', '51c2e38a-fffe-4f1c-ab5f-bf238c2385b1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('84e72057-c6d1-478b-938f-6b9af06f9729', '3820aa34-d027-4dd0-8e6e-767f5116a744', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('54751c87-ad2f-46c8-9486-49d723fe78ae', 'ac36176f-ec84-4d86-ac4c-bfcac55f6ce9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('38c009f1-ee00-4c8a-a177-07f0258268a9', 'ddb7e29d-e5bf-49eb-8b96-1e654157ffff', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8bb6deca-7065-4e53-afd8-3fad06a30e06', '9606d5e2-80ff-4816-8333-fc9f64e422bb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ca412f0b-dc5f-4944-9da4-892818b0c77a', '4b3f814b-89d2-46b8-b290-5ed4a7a0795e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('88ba90db-5ba4-42ac-941d-cb1195a9c04f', 'd8cc98e5-afa8-40ab-a4c3-845bbf5ba878', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('960e5ea2-96d5-4669-bd40-c12035a244b2', 'f86f29b6-33ae-48eb-8d00-a4f907010fa7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ffe12497-0cdf-43f5-84b0-3eea0e8ef724', 'e9734fc0-cde6-4fa1-a998-e8e2792c9d11', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0a74a570-c10e-417e-b15d-a505f57585de', 'e0407279-e656-4bc1-b8bf-9809fd1dee55', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5688798b-aa45-41dc-a04b-050a50ed8ab4', '6a23fe79-66e3-4003-a2f7-9528b9183168', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ce5ea866-0fe8-4f34-82d0-9b2508b43fb5', 'edb32c06-8952-4f4c-8208-971ffa9f94ab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1b681613-280c-4eb7-983e-932d11c39855', '7ae79343-b38d-4887-8191-e16e5726a08d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('32808b21-2b30-41f2-9feb-4e7514e6a18e', '67ceee09-b283-4e6b-a1dd-f48955dd01c2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('28dd73c2-0fbb-423b-bfb8-086bc7d025ba', 'c1e72906-300b-49b9-bac6-339b481da624', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cb1af002-b899-413b-a497-f491b6d48dbd', 'abf9eb30-ec74-4a3d-a4c7-326950ed5e07', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('83f422cb-3920-4233-bc74-c4f754a5fc5a', '9d006281-13ed-42c0-a644-ba5046ab35db', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d99a7c32-9749-4fef-a656-5f0f7639393e', '8f5caef9-4cc2-4ec2-a92d-0d1f4f61b75b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fca33130-85a4-48bf-b507-803065bce6de', '67923a8c-32ba-4560-a9d3-44f341c5e42c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('38935498-ff0f-4a98-917f-7f7efdac4b06', '2b86df00-e479-40a3-89fa-0f331cfd6fdc', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eff63606-5f34-44f3-9426-66e45e8266aa', '2becc675-3821-4922-b5e3-71b299aa746f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('76162484-2cd6-4295-beba-577ef71c87b0', '2370ae7c-2760-4fde-9638-c8ec94fa4a59', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8ca2b895-8004-420b-98a7-033bc9e150a8', 'a9982a6d-3631-47c5-b94a-ed1946196649', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5b1a0d59-d619-4946-9b41-efdfb17f8842', '5ee93f03-4f91-44d6-bf87-f99c240e75a5', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cda867e5-27cc-4aa3-94c9-df0392fd4f9a', '3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b9d33a1c-0a28-401e-a9a3-a608d0d9be50', '361ab7ab-b76c-4596-bc10-908d0e5977dc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('574c7abb-7485-46c9-8b76-08835fd30465', '03005c76-5533-4ee8-b7d5-6f52fb118077', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('94b168c1-adf9-49b7-bea0-76c8b793241b', 'a1e16b13-3878-4224-b711-6379641d3afe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9e001bfb-9208-45c4-9711-f5cd77a43c3a', '1f99dd5a-6e27-4b5f-9921-69a71174ed05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('95e96c91-f8da-4187-8b9a-d2689a626cef', '247ea03f-cc1a-4cb6-ae18-6c97160c093c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d88f1541-86bf-463a-bd5c-8056e13fbe3a', '705874b7-7dd9-4bc7-91b8-bb7c140fbc86', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fe48fbe3-76f5-48b9-a815-04ec372004dd', '5bf7c543-2d7c-47d3-80af-049eb2dd43ab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2ecde01f-5b16-449b-a123-ab5da994112d', '5927c122-bc55-4690-a831-d7f4a1fe9d86', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bf85165f-338d-4418-a66a-a6778be3f38a', '5437ef6b-54b1-415c-ac64-b93530c6557e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a8dd05ab-7087-47ac-bfd3-15d1d3f286d3', '232032e2-b760-4111-a33a-e7bbbfeea64f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9a532608-c195-4046-8a47-eaaa15fa4d2f', '4066785a-2e99-44b4-a625-bd7f9ae8469b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('20066986-d694-416a-be9c-bff76abc44f7', '6fbc0039-e261-4941-a129-ed9c163b81c8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('390e290e-7d60-45f3-ace8-da1e6d7c36d3', '03a11d42-8d40-4873-8e1b-c64c5c606100', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b25cb4d8-7b48-485a-8345-c3b7ed619001', '955c5848-4979-4873-a233-01157f2cb5b7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('11de1f36-6217-4b6c-9c8b-9d4fcab647eb', '07119274-a390-49ac-bba3-0292814d0ccf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1007808d-f385-4d8f-b57a-c0d46f0e8824', 'fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('800a8b04-f5f4-4a17-8414-64ba3570f916', '7475cd18-81c8-425f-a87b-06e4a3cbbfdf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0138d119-1504-4d49-a3b9-16bf1823edb2', 'e0850e47-3d4d-4f59-ae5e-5c5216e778ba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('af748a3f-c39d-469a-a048-750e1fbd5287', '25645465-c92f-4b38-8374-45751b7061e2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('edc6f55f-5143-4210-a346-ed867feed494', '9fae68e6-11ab-45b8-9f49-f63d710d867c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4038dcee-be27-4834-b0de-1b7ed87d3cc3', '03015ea6-a0ba-48c1-a4c7-7381799f9342', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('23324154-871e-4fe6-b8e4-193162d85a6c', '718d972c-6553-4ec5-ac88-28dd81e3ed2d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7ed5c412-83d7-478f-a917-1b66cac0023d', '27160bd1-d41c-46ff-9737-5448c5cff098', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('86836978-4820-46bb-9816-4c7216635078', 'c1ab2193-74ec-462b-8ae2-76a69d394102', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('34681792-637c-49f6-8684-a2e65a05b817', '00942178-64d4-4bfa-88d6-9879363c7f8c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f86b441b-7ded-4962-b45a-4741cad36dec', '54542518-02a8-4dcd-942b-500c32601f8c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('68b103f1-48ce-47e2-8cb1-66afaf96dbb1', '1e021341-b4ca-4173-98d2-2fbc879b7177', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d7c99fe1-8d95-4de4-9fbb-2729cd51c192', '01cdf071-00c4-4850-87e4-142ab0363bd9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('049a9bae-db50-403e-9094-65e28abfd50c', 'dbf8c1c6-976d-4094-8d4d-6dc21740a688', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7542c82c-7ac4-44dc-ad8b-46b8f70b28ce', 'aa52f754-1f78-48e1-a64f-8a2885ec4dfc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('34fb4c12-c392-40ff-8f0e-05f7f1fd1f94', '33ade968-d13f-4a6d-a31c-571e26c07272', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('16f42b10-b926-4af5-adcc-be138c8c4fff', '1901c785-6dea-4eac-a4a9-573eddcd2a84', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0a5fb689-d668-4ad0-a7a2-87986d5c25b6', '5fd92fec-67a5-4922-9f3d-b4f8a25dc446', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('774f7a4a-0f0b-48ea-b99d-e9b443bce13b', 'cb6353af-0e89-476a-a289-74d4f1869188', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fc2165b4-e3eb-4898-9bea-40d0614cbf6c', '111d701c-9202-440a-b4a0-6fbf925005ea', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3042a5b6-8117-498c-af9a-061d928ee206', '1ec09257-e5c1-4afb-856b-04488c43d513', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fc56e8d1-1978-47d4-be42-7b5cffb8da70', 'f424774c-0842-451f-93d3-62a42ec8ff19', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('27a1f438-33c5-4dcf-b2fd-26cb887ea6cf', 'de3a1aaf-e336-4544-8340-9dd14cc05501', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a4e124ff-b927-4d86-9562-b371209d53bb', 'e94b8fd6-0a07-4ab8-998d-15bcf09cfe05', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3a1547ec-c2c8-49e3-b622-1fdd62443678', 'ed536348-ac58-4365-8a89-5dc34905e7a2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('27bc3fcd-cba9-4efa-aba3-6e3b9c594769', '0b05103e-50ef-4528-bd1c-7067fb90799e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cfe9b19e-7236-466c-9721-e25b54a0f28f', '44422798-5f81-4a40-ad9d-6d703c48f6a8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3acb65cc-8e0b-4e07-8544-eed19ac74e38', '7cadba8b-76af-4e78-8e4b-273d445b8055', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4d7d7d32-179f-4413-a33b-c4e54f961061', 'bfa0cf37-b4f1-415a-b9fe-7d27ef136550', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a6e96cba-94a0-44e0-8247-8a489171339f', '0614e02c-7c22-4c5e-b2b1-2fa8ca75e6cd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b038b3bf-0503-4318-9da9-b6ff7f4f1d89', '37139f45-dac5-43d0-ba60-fca0dc2578ee', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ce596f4e-ab6b-4cd3-8c28-9089273cb089', '2e0b19c6-9b64-4724-a3f0-6e394d49d2fa', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('57a39d6f-e339-43cc-a770-a644344575da', '2204ca47-0541-44da-a517-5f680651776f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1b96d440-ae90-46e4-8d0f-19604d44472a', '4a2c67bd-5f30-4a1c-947e-b28b8f037367', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d968829b-73b9-4f30-b177-48fe2f175af9', '8925a41d-484a-483a-8a55-59169d0f9c99', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0875e80e-8dc1-42ca-84ec-68982c926b16', '0cf66449-f611-44f3-b006-f68092531b31', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('69159d7c-8086-48b1-8e90-003a80aeb821', '98fbd202-bdb0-4053-bf4e-b8ebf17b100d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0f88966f-f73c-435c-bf32-c90d232df61c', '15c991d7-d6ec-46e6-af36-8f9644c71f11', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7629aec3-36fa-40da-9a7f-cd5c16570043', 'fbdbcaae-16a9-4c13-89ad-f90f2f300f85', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5f413992-0067-4369-af91-5a1372b0fcf7', '0a6449d0-c490-44ae-ae4d-14440d2a6c2e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1b847ae0-c448-4d7d-a198-0d5c0c6ea27c', '264a10f2-cdb6-483b-8e75-5d831729228c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('42158dd7-fd5e-4dc2-b7db-02fca15605ff', 'd6aecccd-7141-4bf4-a84e-a1078d908419', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('76d375ea-7a34-4064-9535-0786b59a9ab7', 'e0ec44dd-f0fd-4b61-8803-1e7e81c09254', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d814e8cf-22c3-44c9-8d1e-598e544c5309', '22e1de12-5c55-4cb2-8a23-74b7681a2e2a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ec92032c-c377-4a42-b1fe-954fbb374b6c', '99e00dcb-4080-4dbd-97c5-8ac118dafb38', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3b4e9411-801c-4b5a-b04b-e1e06a40e13f', 'fd01028d-e90d-4845-ad8b-8ba38bbe4e39', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fdcc0c45-d73c-46b3-8acf-e85c853ed4c4', '7776a66d-4565-4918-bb17-60b8505b64a2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eb56675e-62e1-479b-8c7e-e6d5df93c977', '6137f2a9-80e3-4517-b158-58579f80b641', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f471cd10-3602-4dd0-a8b3-35879a423066', '11d38681-bee3-4def-83a4-70f94b168c59', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8442fe4b-9502-4c4d-85b2-bde791ce0615', '76098b24-a861-4c42-8091-7c221458b16a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9a861c78-d1a5-45e2-a46e-3e809dcfa4e6', 'c8619c2d-a43c-485c-9d9f-90a091f332d5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6437d327-7464-4e46-8ded-23b1c9ced753', '9d441266-7b54-4161-9a99-b7367f105bc8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('326280bc-129c-4c85-a917-2cdbbdaaba83', 'd8636725-8067-462e-a243-a5eb995017c4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3336fd71-cddd-4692-8a6b-0e36d8d4a2cc', 'b30df46f-d333-4447-ad6b-d519d9f4dac4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fee6ceac-302c-4c93-8f02-1f38396a791f', '545a1ada-f0fd-424d-b569-7985db8750b2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d2ac1beb-a9b2-4f6b-9496-0d525d03ade6', '71b99f7a-0e22-4ab9-b9fb-43a9e3bf19c6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fa8f9474-ab42-4644-ab34-21c30ba535b4', 'dd81dee6-f6cb-4c6c-9b8e-e3c2934ef04d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4062fb6c-4332-4a3c-bdfc-c1e95fb86fc6', '45880b9e-1b54-4c5a-9ba9-54319ea3f79a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0d15e5b4-6783-402e-b997-0b71b49e4cf7', 'aa065ca8-7ab1-46f7-a77f-0ec06d95fa77', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b174cdaa-ceda-414f-9690-51c6cc06294d', '2947e7f1-e3e1-45bd-ab39-6555b4209583', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('589fe353-bcd7-49bd-88f0-d4785c1c84e6', '8540a807-61ef-4f49-a567-74fc2f903777', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('02cf9437-8385-4674-9fa9-8a7f21ac49cc', 'f627f2d8-28a4-43a9-a1b0-32dd72a18506', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4e9f4176-5a89-4e37-a7d7-f794ac897355', 'f32b3037-57db-4594-88d7-9d9b71eaec87', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bf169e5a-1801-47a9-b336-d16ef4e708dd', '0ff16429-7729-4ba1-86ac-6826602af7b4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f4d47ce9-a7b1-474e-adac-575fa07251cc', '6aab2f5b-d838-4e0f-85dc-aaed568cfeb2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('62e8eb20-8a93-4b02-a1ab-9a239b77caf1', 'b092616f-b2a3-428d-887b-be477e53fde6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5f848460-afc8-4fed-b521-3d146a9ae7d2', 'edd5b52d-02ab-46ca-9e97-b0e552f29e00', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ce3698fe-73eb-48ea-985a-af2d7110fb5e', 'c3f73b64-f1a0-4e35-80e1-f616c9057bf4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('83a6f7b6-cc38-4499-9906-18c9401bd9d0', 'abbbec89-c052-446f-8f1a-343d7eb86b07', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1dfeafa0-e9cb-4946-ab91-cd231e03c135', '9761381b-4ee5-434a-9421-593855382fad', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('570b19a4-8d5e-4767-af7e-5529549570da', '4b18422a-7041-4107-9cfe-ed222c92db3f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b4a234b3-1688-4c91-9f9e-425e2cf81e67', 'af076bc3-eb63-4938-9a16-f7dae1e63693', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('181dde6b-25ee-41b1-8298-c4c45f3ca025', 'c08bb5fe-2e9f-4589-8a3d-dfb5e42bbf1c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('949bbb6e-4f4f-4c06-a40d-2c4eb1252499', 'cc20bcef-3e7e-42aa-aa54-273ca836ee4f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('52d44854-d35c-42b7-a0d9-a3ab4265193b', 'fb91ff42-cd3b-4dae-9166-0fc52777cdad', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fe43ef47-0721-4e76-a0de-9e01d00d9320', '24eddedd-2cf1-47d0-b47c-d258a83027dd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('12ab2ce0-be19-431a-8e4c-b5a6de68f198', '7a8377df-3cbf-49f6-8276-0c8aadfac3e5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8ce4cd3f-346d-44ac-ae5f-13e3facc5753', '558e56bf-f5d1-4376-a8ea-4bffce4afd73', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a6d72ddb-38da-4d45-ab3d-1b1fca006171', '12d07b63-071a-400d-8461-b62fdffbf00c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('712d644c-44f8-4e32-8c4f-7d53f99ef08c', '08073562-bd5b-4b98-9fbf-48d2de401b31', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ab88030c-bf63-4e80-8f39-83cbce1c6c78', '8c2bbf73-0e7b-4e76-9d47-93472e4385bf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('050ff414-e3a3-4089-be6d-9e99b0419723', '112cf86b-5b43-4422-95cb-7301a5ef139f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fb64f0a1-6bd7-4aba-8a68-a53ff1191e3a', 'ba9989a8-eadb-448b-95cc-14d0301eb0b8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e3b31447-0752-4091-a62e-25ee26dac467', '1394ead6-7e56-4981-b53e-0a5957ea99ad', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('59006d0b-5aab-4428-8abe-3244ab913998', 'a2e22df5-22fe-488d-981f-23e514360639', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1f1f7491-9e21-4ebf-8c4a-5cdb39ec3444', '7b2b0c98-b647-48c8-a2bd-c9e7d491e407', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f818c1ef-6a12-4e81-a5d6-40b29cb8f012', 'b1ead61a-ccf8-4dbc-8f95-401049e32ddd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a1859c84-8ab3-435c-86e8-9eb796d80508', 'fc4f6d86-45a0-4b55-b820-30257b09fc49', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ddd12062-a4f6-4133-916e-5e98d6b232f4', '91c28e9d-8e44-4f1f-b7a0-fd9e34e8c3be', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e2bd07fa-9a7d-4995-8e12-0874813a36b7', '08073562-bd5b-4b98-9fbf-48d2de401b31', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('aa5420a0-70f3-4e87-8d64-e4a2957df370', '08073562-bd5b-4b98-9fbf-48d2de401b31', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dd16fab7-e477-496d-b454-b029c7e96dcc', '112cf86b-5b43-4422-95cb-7301a5ef139f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6d3f30f6-000a-4410-91c4-59c364da03a1', '112cf86b-5b43-4422-95cb-7301a5ef139f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('139e955a-91c0-4d6c-8949-04e1d6934482', '12d07b63-071a-400d-8461-b62fdffbf00c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('206cc94f-947d-4ac7-9b6e-9a2bbf4563a3', '12d07b63-071a-400d-8461-b62fdffbf00c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('85737cf9-41f1-42b6-8051-2218c04098e7', '1394ead6-7e56-4981-b53e-0a5957ea99ad', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a640408e-922f-402a-9626-e952d3a700df', '1394ead6-7e56-4981-b53e-0a5957ea99ad', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('adf32f51-9cbc-4df3-82b0-00cdb01c57b7', '24eddedd-2cf1-47d0-b47c-d258a83027dd', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a0a11a63-d4f0-41b8-af6b-e8ac4e26f442', '24eddedd-2cf1-47d0-b47c-d258a83027dd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d66aa1bd-c776-4f1d-b177-dbf11c879e85', '4b18422a-7041-4107-9cfe-ed222c92db3f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7e946da6-ffb8-4dd9-b35a-d0fb2db4a7cb', '4b18422a-7041-4107-9cfe-ed222c92db3f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('849529a6-0ceb-4b52-abd7-297fb7f3e756', '558e56bf-f5d1-4376-a8ea-4bffce4afd73', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1d49774b-fef1-4116-82af-fd30aef24dae', '558e56bf-f5d1-4376-a8ea-4bffce4afd73', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9b60beea-6281-4c86-b9a6-0a9d26a6ce1c', '7a8377df-3cbf-49f6-8276-0c8aadfac3e5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2f3aed79-cbfa-4851-8574-3b50e06123a6', '7a8377df-3cbf-49f6-8276-0c8aadfac3e5', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b83186e4-1c85-4b3c-8b71-80ebfe980434', '7b2b0c98-b647-48c8-a2bd-c9e7d491e407', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9f7034d5-c0f4-4670-bd72-96da584385cd', '7b2b0c98-b647-48c8-a2bd-c9e7d491e407', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a1ecca20-654f-4ef1-8cf1-19a115271763', '8c2bbf73-0e7b-4e76-9d47-93472e4385bf', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8f243be2-ae1f-4029-9d79-a4ea85264bf5', '8c2bbf73-0e7b-4e76-9d47-93472e4385bf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('67f65415-fafa-4f4d-8ec9-105ab7e02eca', '91c28e9d-8e44-4f1f-b7a0-fd9e34e8c3be', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4a1566b5-b823-4ec4-a069-69459c94b5ad', '91c28e9d-8e44-4f1f-b7a0-fd9e34e8c3be', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f81991ac-eef1-4913-9f83-4dc3de604070', '9761381b-4ee5-434a-9421-593855382fad', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c0548530-f628-4076-be41-af91c5d0d270', '9761381b-4ee5-434a-9421-593855382fad', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7b51b6ab-a33a-45a4-b9d4-5084ce0a6285', 'a2e22df5-22fe-488d-981f-23e514360639', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('582d72df-f8ca-4621-be93-c707ae565516', 'a2e22df5-22fe-488d-981f-23e514360639', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7a365124-7ed6-4876-8b7b-ebf70bec6a0f', 'abbbec89-c052-446f-8f1a-343d7eb86b07', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e1b12e8d-4128-4f95-ba6a-bb3070afe61a', 'abbbec89-c052-446f-8f1a-343d7eb86b07', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('593dad1b-806d-483c-8467-13101ccd79ac', 'af076bc3-eb63-4938-9a16-f7dae1e63693', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('abba021f-8cca-4b1f-a82d-8962e2b58d4b', 'af076bc3-eb63-4938-9a16-f7dae1e63693', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b37a53f2-e3ee-4f36-8221-eda84c1702e0', 'b1ead61a-ccf8-4dbc-8f95-401049e32ddd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7ecc9284-a00e-4d84-8fd5-775411503c8f', 'b1ead61a-ccf8-4dbc-8f95-401049e32ddd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4fda2211-e47e-4f71-8b0f-ed7d43404681', 'ba9989a8-eadb-448b-95cc-14d0301eb0b8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('114a125f-a734-425c-9f45-8b654cf9fdae', 'ba9989a8-eadb-448b-95cc-14d0301eb0b8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d2f9ed84-9df9-4b70-92de-251a928b99f1', 'c08bb5fe-2e9f-4589-8a3d-dfb5e42bbf1c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5fedda96-bbd9-4bd6-9661-9174d3556a0e', 'c08bb5fe-2e9f-4589-8a3d-dfb5e42bbf1c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('335754e8-0cc4-4872-b2a2-05aede6fc1cf', 'cc20bcef-3e7e-42aa-aa54-273ca836ee4f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('099d3a3f-422f-4cce-9b8f-66e4d60e1bb0', 'cc20bcef-3e7e-42aa-aa54-273ca836ee4f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7a00659b-4002-43b5-916f-875c2d1c46b4', 'fb91ff42-cd3b-4dae-9166-0fc52777cdad', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d72d15cb-7688-4c34-98da-ae884f7599fb', 'fb91ff42-cd3b-4dae-9166-0fc52777cdad', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2e46c51a-7839-444d-9ca8-29de4a8d30b5', 'fc4f6d86-45a0-4b55-b820-30257b09fc49', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('88881510-decb-48a6-bd2e-2f325a1fcb36', 'fc4f6d86-45a0-4b55-b820-30257b09fc49', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('07814666-c434-487a-b461-7914bc952835', '3fa82e69-f443-4adf-9522-b77d5ea8946f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('39c5dc97-4fa9-4b2e-a43a-a7d2afacc32e', '3fa82e69-f443-4adf-9522-b77d5ea8946f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d790e8db-7af3-425d-844c-db178135f769', '3fa82e69-f443-4adf-9522-b77d5ea8946f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ecdff4c0-7dd2-4721-81c9-17f147dd3ac8', '6270f44e-ce18-49fd-ab0e-e25c730742f8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('12faa809-ea81-47c6-8121-6339e98ed784', '6270f44e-ce18-49fd-ab0e-e25c730742f8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('41ed3c70-28c5-4a01-b2c2-b086021a1fac', '6270f44e-ce18-49fd-ab0e-e25c730742f8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('95375afc-b68a-4937-85dd-d7235efcc278', 'bc9e99ce-944c-48d8-b15f-647a8f3be1c8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7c9ea60f-fdfa-4ae7-82b3-4bf080af6de0', 'bc9e99ce-944c-48d8-b15f-647a8f3be1c8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('251c2900-e815-463c-b4b3-b285552c061f', 'bc9e99ce-944c-48d8-b15f-647a8f3be1c8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f3e2af9e-b4fd-4102-8873-e9ef18297c45', '2a2800c6-10b6-4b86-92de-2b35f05bc302', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('08a3508e-1d51-485c-bdbc-967d901a7756', '2a2800c6-10b6-4b86-92de-2b35f05bc302', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('66553f05-ee8a-4a8b-88f2-c23aa42360b4', '2a2800c6-10b6-4b86-92de-2b35f05bc302', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9444fa58-dbb0-4231-98da-562d487cf61e', '5d69f967-231a-46c0-9e54-2822d1a323a2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('89ee5847-066a-4cc7-ab7e-31af727c84b3', '5d69f967-231a-46c0-9e54-2822d1a323a2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a4f04639-c3a5-4d37-ae9a-c92d9f01ee23', '5d69f967-231a-46c0-9e54-2822d1a323a2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fb1bf1cf-f242-4589-99b1-80dd9926512c', '232333d4-a453-4007-bbb0-76cc3cadcb88', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a1969221-b40f-45c6-af1f-747fdab9c3c8', '232333d4-a453-4007-bbb0-76cc3cadcb88', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9b089d4f-45c0-496a-b5e6-4b703add818c', '232333d4-a453-4007-bbb0-76cc3cadcb88', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c41a04d6-97a1-4807-8508-b758f12483cb', 'a9ff3693-963d-4893-8bbf-aa20b66a122f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dbadb446-0cad-4097-ab2a-b3d98a459505', 'a9ff3693-963d-4893-8bbf-aa20b66a122f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('cf37d75d-07ee-4207-81f8-e287f7dcb643', 'a9ff3693-963d-4893-8bbf-aa20b66a122f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('83c1d924-e184-4bcd-bf32-40ae1c0fbf6d', '5b161019-50d6-4126-a08f-ed1f100de68d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('664b08ed-338a-4144-bead-4f23fc84f66f', '5b161019-50d6-4126-a08f-ed1f100de68d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c804e2af-09e3-4bfc-9eb4-ae0dc52ecf02', '5b161019-50d6-4126-a08f-ed1f100de68d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3a047f4a-697e-47d0-9f58-ac8a1663eeaa', '096293f7-56fc-4d6a-8c9f-a1c23eb1ebeb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b86c031d-3a0e-4cf1-89a9-3a34745a8797', '096293f7-56fc-4d6a-8c9f-a1c23eb1ebeb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5f3c7061-4258-4bf2-b647-bca7fdf1cbd7', '096293f7-56fc-4d6a-8c9f-a1c23eb1ebeb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fca30d99-edda-48ac-abe6-317832028418', '03a80f3c-12f6-499b-ba82-f459d8fef8d5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dc77ec0f-0222-468e-850a-35b2c572bfba', '03a80f3c-12f6-499b-ba82-f459d8fef8d5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('194600f3-71d0-4510-a15a-5c87aa8a9631', '03a80f3c-12f6-499b-ba82-f459d8fef8d5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ca09aa55-e857-4bd8-b3c4-f672a1c702b1', '9c4b884d-66a7-4035-b643-880d1fedebcc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4da31b38-c12b-41ef-8ee1-e228734f2c16', '9c4b884d-66a7-4035-b643-880d1fedebcc', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b67cd9b6-3c3e-45a4-ae35-a35715b28171', '9c4b884d-66a7-4035-b643-880d1fedebcc', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a25d0670-e160-4ade-9924-1ebda0fcd709', 'f1596b47-1013-4e1e-886f-4ba4cab37638', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d09618ba-f0e3-4637-a7ac-23cd07fff328', 'f1596b47-1013-4e1e-886f-4ba4cab37638', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8012cec2-2548-4be2-ba15-2fda3057fcf8', 'f1596b47-1013-4e1e-886f-4ba4cab37638', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('94e1f839-6676-46e2-a27f-691f60befbaa', '3123ef87-54e2-4e25-a1e8-0105773ce9bd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('234d6d90-7805-4b7e-80e2-9a52ce0b51f3', '3123ef87-54e2-4e25-a1e8-0105773ce9bd', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('79cb3552-79c0-4023-9cec-79a134f7649f', '3123ef87-54e2-4e25-a1e8-0105773ce9bd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8644a3a9-5391-4812-9657-9487d8c999de', '2efa253d-4ee3-442a-9eab-c49306a254ca', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cb845a06-4e76-4443-8c3c-3e70ae178765', '2efa253d-4ee3-442a-9eab-c49306a254ca', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('406abd3b-74c1-41d7-aa55-8d74fbdf052a', '2efa253d-4ee3-442a-9eab-c49306a254ca', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bde5f0b9-8944-48dd-b02f-f503f4b781c8', '7fd0d3a4-5332-4f15-8af4-b9db7d4fc928', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('edb702c8-afeb-4b4b-98cd-4ae08aaff9fc', '7fd0d3a4-5332-4f15-8af4-b9db7d4fc928', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('67cefdbe-0dd0-4e96-afdf-4c492945972d', '7fd0d3a4-5332-4f15-8af4-b9db7d4fc928', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('850403bd-032d-4b27-9f79-653d0302ec8e', '95b5fc15-9b58-412a-b655-1539705362d2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5c9c8443-18e1-4682-91a9-6b07a93aff29', '95b5fc15-9b58-412a-b655-1539705362d2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c8d8d387-cbcb-46f3-b7ea-4531a9ac8b9f', '95b5fc15-9b58-412a-b655-1539705362d2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('27854153-282f-4062-977e-d4f119170810', 'aadaf67e-ed82-41af-ae9c-5587e3c9f0f3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bede6933-0164-4f5f-a574-495a1ceee214', 'aadaf67e-ed82-41af-ae9c-5587e3c9f0f3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e1d36bb5-63dd-4e75-8127-c91ba0553038', 'aadaf67e-ed82-41af-ae9c-5587e3c9f0f3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('394dccab-9f50-4072-9706-d29cf5dbbb49', '5a4368ae-99ca-434d-acd3-7c56ec255333', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('06b6d53d-04f0-427c-9ff4-14a2974620ab', '5a4368ae-99ca-434d-acd3-7c56ec255333', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ff280762-b03a-47b7-bc7f-1c68b0221fa3', '5a4368ae-99ca-434d-acd3-7c56ec255333', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('106ddf38-deeb-4502-bac6-5b242306e052', 'b0fdd849-36fd-4713-b59d-9bbebe761987', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9c7853f0-661e-4c97-9ff8-e9f7a82cac4f', 'b0fdd849-36fd-4713-b59d-9bbebe761987', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('73cdc07c-89b1-4e70-ada8-b322c54d80e1', 'b0fdd849-36fd-4713-b59d-9bbebe761987', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f7c24c9a-4891-48c5-b013-7d16a75f4507', '2c9655f0-1ec7-4d23-a77c-ef0808066da0', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('01cf770d-13ce-40cd-9c45-284dbab96ccc', '2c9655f0-1ec7-4d23-a77c-ef0808066da0', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('95c168ba-9209-43d7-9b0e-537754c19676', '2c9655f0-1ec7-4d23-a77c-ef0808066da0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('32dbc81a-e4e6-45b8-9cb0-a510c8205397', 'ec5ddeec-eadc-4e42-aa73-252a28daab1f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4c593da1-4961-478f-85d6-f6017f00d3d7', 'ec5ddeec-eadc-4e42-aa73-252a28daab1f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b2fadfd4-0abf-4023-a56f-7bd998f93538', 'ec5ddeec-eadc-4e42-aa73-252a28daab1f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d5db89cd-ffec-4920-8b0e-fd4f53c725cd', '4f2e8334-5bcd-4d5d-9932-dacc9778f2f0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('73a302c4-be25-4a2d-aa87-5ee13212f18a', '4f2e8334-5bcd-4d5d-9932-dacc9778f2f0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('30031902-beab-43c5-b448-b5f16cc6338d', '4f2e8334-5bcd-4d5d-9932-dacc9778f2f0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9d89148e-25ea-4d0e-bb25-46017850ac3a', '3ffe923b-2ded-4773-a058-56476818c0f6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e7029e9f-0186-4571-85db-b46ca403c1a2', '3ffe923b-2ded-4773-a058-56476818c0f6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1138b80d-af1b-4f7c-a9b2-5f1059a9684b', '3ffe923b-2ded-4773-a058-56476818c0f6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('df6a7c59-1c3e-4805-9fb5-07269bb21dde', '0678eca9-23c6-47e1-9f60-2c1a1ba3ebed', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('266292d0-14f8-4452-90dc-1f864087f26e', '0678eca9-23c6-47e1-9f60-2c1a1ba3ebed', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('96b98672-64e1-4a17-abbb-2005adbe07ed', '0678eca9-23c6-47e1-9f60-2c1a1ba3ebed', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f4c061af-7c22-4aa1-b3c3-89c307e53bef', '6d518631-2f6b-4de2-b853-17157d139bec', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('71ca747c-2ccd-4075-8b81-fbb6b03946bb', '6d518631-2f6b-4de2-b853-17157d139bec', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('294da2e4-b12b-4691-a48f-ae759d0b33c1', '6d518631-2f6b-4de2-b853-17157d139bec', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('70673e89-b849-4256-b822-be62c8ec33f8', '64c925da-3ba0-4e9c-9813-a9cd8f48817b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('adbc2867-5a83-467d-a7a5-428b772390aa', '64c925da-3ba0-4e9c-9813-a9cd8f48817b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('20d0f6f7-9368-485c-b042-6d898b9b5581', '64c925da-3ba0-4e9c-9813-a9cd8f48817b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('44901e92-d20d-4c41-9859-4da828c5d3e4', '039b912c-45ce-4059-8a4f-91e8d577a357', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4a41e2ee-bc9d-4973-9abd-cf8e8ce0bca2', '039b912c-45ce-4059-8a4f-91e8d577a357', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('61d42f67-de33-4bd9-8dbd-f59671579726', '039b912c-45ce-4059-8a4f-91e8d577a357', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('679d0298-c562-42f8-9b49-16bae3d0f9ce', '1fc04865-c369-4961-bd31-db4289b4b790', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3fd936f3-0f8f-48a5-b6ad-9bda6ee1b829', '1fc04865-c369-4961-bd31-db4289b4b790', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f85bf4d2-7374-41a7-8443-45f9bf6d98f3', '1fc04865-c369-4961-bd31-db4289b4b790', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4e9e1eeb-ce76-4566-83a6-59c07f73c7f6', 'd49841d2-cfeb-45c0-874e-73af29cda5e5', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('22fac3bd-38d6-46d7-ab92-a0c80353bb05', 'd49841d2-cfeb-45c0-874e-73af29cda5e5', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2ec51091-5bb5-4cb7-9037-280bdd17ff49', 'd49841d2-cfeb-45c0-874e-73af29cda5e5', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('387f8fb2-80b8-4632-b5d8-c953202751cf', 'd783a9da-96c4-4e8c-b05e-270c62a86fc0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('07bdcc10-0d40-41be-bc7e-7c6f3ad17382', 'd783a9da-96c4-4e8c-b05e-270c62a86fc0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b2821221-7620-4451-80f5-1e954e7d114e', 'd783a9da-96c4-4e8c-b05e-270c62a86fc0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c4815cac-1a37-4a52-a096-b33e5fc2b163', 'b2787b3d-f7cb-496b-a2ba-760f26f84e08', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('71a62540-2cfc-429c-83a5-241406ad77d8', 'b2787b3d-f7cb-496b-a2ba-760f26f84e08', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('07969018-7461-4974-821e-76fa8d957418', 'b2787b3d-f7cb-496b-a2ba-760f26f84e08', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e2c2a27f-c02d-489d-837e-2012b3b80bff', '8a48ebb5-0eed-4c19-adaf-ed47549ac86b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('573b5128-26c7-40b9-bbba-883079b6a414', '8a48ebb5-0eed-4c19-adaf-ed47549ac86b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('84c816b0-3457-4846-86af-e7980eff0790', '8a48ebb5-0eed-4c19-adaf-ed47549ac86b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ab2f334b-4a85-4659-8e88-5f17f35fab3a', 'e53c14ce-42f4-48be-ad22-54c778e9827a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6ec04400-b76d-453c-af42-dbb435c90ce3', 'e53c14ce-42f4-48be-ad22-54c778e9827a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('30292384-75de-4112-96e0-9a3018672d77', 'e53c14ce-42f4-48be-ad22-54c778e9827a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9d5d9981-e3d4-4062-8c29-2016cd8aae7c', '8ea4b97a-7be7-4304-84e1-8825d88e2a76', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e7ddbabb-0357-4e65-a04d-a9518ffa6c54', '8ea4b97a-7be7-4304-84e1-8825d88e2a76', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('16842453-f4dc-490b-bb21-0a9bf6da4819', '8ea4b97a-7be7-4304-84e1-8825d88e2a76', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('24235aec-3bde-4e54-865a-917bf91c31cc', 'd91ef2ee-26d1-4073-91cd-891aa15942c6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3a924406-0c42-4564-a9b0-3a77bdc46869', 'd91ef2ee-26d1-4073-91cd-891aa15942c6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e74a785c-bf94-4233-82ba-64252da2344d', 'd91ef2ee-26d1-4073-91cd-891aa15942c6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8fca509c-d881-4ba1-a904-f8ebfb00ccca', 'f464af40-2a7e-42a5-9b9f-673f7f56d11c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fc54a980-c5da-41f7-a628-b83188b28fd4', 'f464af40-2a7e-42a5-9b9f-673f7f56d11c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b40f3176-5a52-4d04-8091-b3c28b4abc14', 'f464af40-2a7e-42a5-9b9f-673f7f56d11c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('08bf351d-e8de-434f-99f5-63f00f886a76', '2880e9e2-1921-45e3-82e4-587bf40744e6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('22152357-950c-4b74-8219-437b350aff3c', '2880e9e2-1921-45e3-82e4-587bf40744e6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('17b8ee1d-703f-4d5f-8507-1e2640ca1156', '2880e9e2-1921-45e3-82e4-587bf40744e6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('31944f20-19b8-4bf6-97ff-048ba33844ac', 'bbf0d32e-6a94-4ce0-927b-d448d3a0868e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bf220570-74b6-45bb-9596-36f4576cfd6b', 'bbf0d32e-6a94-4ce0-927b-d448d3a0868e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('261bd68a-1705-4380-a5ad-3eae2daa4fce', 'bbf0d32e-6a94-4ce0-927b-d448d3a0868e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1727beba-77c6-4d00-91d4-3341a037ce21', '71bab9bd-d945-47b2-8015-d097c2c84fe8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b4e25ddb-2699-493a-9525-63d8fe31c1d5', '71bab9bd-d945-47b2-8015-d097c2c84fe8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('94ffaa78-0e8b-4cea-9c6c-22244483c850', '71bab9bd-d945-47b2-8015-d097c2c84fe8', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f1c3a235-dc71-4c92-a5e2-6d156ea0d103', '9a85f0d9-2fb8-4c0d-a170-c31401712a3b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e302290a-9316-4074-9bac-5f328788b7c9', '9a85f0d9-2fb8-4c0d-a170-c31401712a3b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('475ecb20-1e39-4097-beea-c19be2110db5', '9a85f0d9-2fb8-4c0d-a170-c31401712a3b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b8123f62-db98-4990-bf38-4854743a2868', '7130ae66-b625-4e7f-92bb-00dc035b56ae', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ae6997bb-d0fc-4ca4-a26c-18d46f77efd8', '7130ae66-b625-4e7f-92bb-00dc035b56ae', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('cc03282d-e754-4c9f-a9cc-8a292088d0c7', '7130ae66-b625-4e7f-92bb-00dc035b56ae', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('81baa991-a265-4f64-b244-aeef59f4a109', 'de8baf97-ec0b-43d3-a869-b7e092d02903', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b682bdb8-fd05-4dfb-b3de-22d3459cccab', 'de8baf97-ec0b-43d3-a869-b7e092d02903', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e53a7591-9b07-4523-a5fd-be84c036c495', 'de8baf97-ec0b-43d3-a869-b7e092d02903', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7c749ae3-fa0d-4e2f-9c4a-c6ff76696776', '243d5b61-0b04-488d-b11f-73c95c36e69e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('22cc638c-f73c-4880-bd18-0674f0e3610c', '243d5b61-0b04-488d-b11f-73c95c36e69e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9a0b8b45-2b96-4270-8b8d-c531fd449cdf', '243d5b61-0b04-488d-b11f-73c95c36e69e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a53ea8c4-69c3-43cd-966b-b0ea9555529c', '336db361-c314-4db5-8f77-c02e3a24e546', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9af54907-c416-4cf8-97f5-bb24eef40d8f', '336db361-c314-4db5-8f77-c02e3a24e546', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('354e95f3-25f8-4389-b57f-ab9e6c99c786', '336db361-c314-4db5-8f77-c02e3a24e546', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5b3f7aeb-354c-47c3-8e97-2ecf95bd5aa5', '88e00fce-768f-49fa-9243-a4d0492a540d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8cf090cd-d580-4c1a-8a17-b67f3b5429a9', '88e00fce-768f-49fa-9243-a4d0492a540d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('47275cc2-45db-4720-bf24-a4b4dfd308d6', '88e00fce-768f-49fa-9243-a4d0492a540d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('683de2d1-8336-429d-b8d7-1ded848cdd7f', '96205f49-7cbe-4723-b04e-437aeb6d7d67', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f955a689-c0a1-4f83-9812-2a4f6e823367', '96205f49-7cbe-4723-b04e-437aeb6d7d67', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('374207de-8ebf-4716-abc9-961e568f0081', '96205f49-7cbe-4723-b04e-437aeb6d7d67', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5571180a-9ebd-40dd-8420-cc5aaeb10378', '5095b8f6-2503-4aa0-8a9d-9a9741c756e7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fd926aca-6ab9-424e-b70d-dd7a77fa6dc2', '5095b8f6-2503-4aa0-8a9d-9a9741c756e7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('cb5360ca-b210-43f1-bc04-1946208c8d5b', '5095b8f6-2503-4aa0-8a9d-9a9741c756e7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('981f018d-6d91-43e6-81a0-9ac1374a8639', '497c7911-3187-472d-b195-267bd0b93ba6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f0a695e0-bc51-4685-b262-9ee7fe5fe40d', '497c7911-3187-472d-b195-267bd0b93ba6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c214734c-9e7b-4cf6-99c1-3587ad0fc3fa', '497c7911-3187-472d-b195-267bd0b93ba6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('24925022-d1f8-41f5-a704-c41765f52e67', '3c0774cc-b179-4478-967b-208e973611cf', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3a9e925a-83dc-418c-b7fd-9c7e03b494a6', '3c0774cc-b179-4478-967b-208e973611cf', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c7e38070-0af9-4262-90fd-11d98c504824', '3c0774cc-b179-4478-967b-208e973611cf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e1091327-d90f-477d-b52d-176920cdd6e6', 'd85a4839-0279-4ef4-b4e6-e653481611d1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9169f331-e75b-413e-ab9a-b7aa83f2ae5c', 'd85a4839-0279-4ef4-b4e6-e653481611d1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7dc004e1-e71d-4533-a6e7-25a37ed3b8d3', 'd85a4839-0279-4ef4-b4e6-e653481611d1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6869409a-bc49-45a8-9e88-c16670c849dd', '84967bbf-a8aa-4dac-b30a-d4191a2cba24', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b0829a26-28ab-45bb-b260-17c441285ba7', '84967bbf-a8aa-4dac-b30a-d4191a2cba24', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('27a8e5d6-a200-44de-8993-263156fb72d0', '84967bbf-a8aa-4dac-b30a-d4191a2cba24', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d30ed131-e2e2-4e09-a077-f490b1546b50', '25052454-3ec1-4671-936b-6e387ae87adb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eacff4c9-ed76-47da-a0ea-c0bb6efa54de', '25052454-3ec1-4671-936b-6e387ae87adb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fb9b46aa-1934-427c-9a5a-8b10224bf2e7', '25052454-3ec1-4671-936b-6e387ae87adb', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cd467606-c6b7-4e01-b2e3-baf378c065de', '16631865-9f17-4169-8dd4-dac2bf621cb9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('956566bd-38eb-43f9-a922-2097f5f4ddbe', '16631865-9f17-4169-8dd4-dac2bf621cb9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('094cd91e-d498-4f52-bd2c-5e59fdeb86f2', '16631865-9f17-4169-8dd4-dac2bf621cb9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9ac69b90-eee5-48ff-853a-06d5fd6a314a', 'f8629fd9-0e6c-4fe8-a297-af630957e67f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f93c30f5-3e74-482d-8ea6-713e213d7835', 'f8629fd9-0e6c-4fe8-a297-af630957e67f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9fbbf933-4b85-45e9-9d51-8a4ad926ce55', '8319b36d-0f62-46ab-be5a-fe7881d38895', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('007b5dea-9354-4bc6-8911-11128266f182', '8319b36d-0f62-46ab-be5a-fe7881d38895', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('08360a5f-7bd5-4eed-b98f-f8c68689aa49', '8319b36d-0f62-46ab-be5a-fe7881d38895', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('763ae1b7-0d35-448f-8e41-47246be2fec4', '5ed2980c-8e76-4628-95d6-8736921eba4b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('03954f7e-59e8-427f-b2ca-fdd96267198c', '5ed2980c-8e76-4628-95d6-8736921eba4b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3b4a6cac-38db-42a5-90b5-8b9192d64222', '5ed2980c-8e76-4628-95d6-8736921eba4b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('20907c0f-6191-455d-8ee4-c86ba10d0fa4', '463c62f8-f6b3-4078-a211-ef02ee734e6f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('038ace9a-530b-45d0-a22b-550fbbbccfd0', '463c62f8-f6b3-4078-a211-ef02ee734e6f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2ba4edba-7b97-4385-97be-fa5413c856cc', '463c62f8-f6b3-4078-a211-ef02ee734e6f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('54b974ba-54b6-4686-8084-3bb9ca28e7fc', 'a4695ebe-42ba-4318-b85a-640517c3416d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d63f45c2-1cb8-4cb7-a01d-3b7b100f3b5d', 'a4695ebe-42ba-4318-b85a-640517c3416d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0c5c36a6-bd21-4102-83da-e37e76fdcb6f', 'a4695ebe-42ba-4318-b85a-640517c3416d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc162dce-26c5-46b8-bd6f-c774fc95d40b', '840d2ef2-10a6-43e5-87cf-d69910a0c928', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('89e309fc-aafc-469d-bbc4-0bd73e0709e3', '840d2ef2-10a6-43e5-87cf-d69910a0c928', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('99cddeae-7b6b-4c7e-a3f4-a3c84116f55e', '840d2ef2-10a6-43e5-87cf-d69910a0c928', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ed97ebca-2099-487f-b952-8aced28f166d', 'fc52c23d-05ad-4225-bb45-d30c93c49617', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('67716aaa-6672-44b0-b56a-d48a8487b741', 'fc52c23d-05ad-4225-bb45-d30c93c49617', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('376149bb-143e-4cb1-be6e-3501dcba5e8d', 'fc52c23d-05ad-4225-bb45-d30c93c49617', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('095347b3-b47a-4a89-bc20-304abd44566a', 'ef1d4e8a-f7fc-4cb0-8da8-cdfbc2d0657d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('204c86b7-1b7c-4f37-8711-d37e55b95c15', 'ef1d4e8a-f7fc-4cb0-8da8-cdfbc2d0657d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('626653a8-b813-498a-8193-1c69dd9e5ae2', 'ef1d4e8a-f7fc-4cb0-8da8-cdfbc2d0657d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5dc82b4f-3227-4a10-9b76-ea5fa558ea79', '2172c568-0225-45ce-9436-9a8dcebe7806', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('46a9d7f1-1925-4e42-9187-a2126abb3d2f', '2172c568-0225-45ce-9436-9a8dcebe7806', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('65c69c8e-e08f-4d4b-86a6-df1fe59cd90b', '2172c568-0225-45ce-9436-9a8dcebe7806', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('258a267b-b626-4056-b333-5b70a7a2b810', 'ca6201e3-23d2-441c-9d86-f20e8b448c50', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('490295c3-de58-4cf6-8019-184bf70c8802', 'ca6201e3-23d2-441c-9d86-f20e8b448c50', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2da951aa-4215-45ae-aa73-86a7710fd326', 'ca6201e3-23d2-441c-9d86-f20e8b448c50', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6cd9077c-cb9d-444f-be36-3db7fc92199c', 'cf36ddc2-7dde-41f6-bff3-9cabdf6a2c4e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8d9e3842-2246-4113-a4f8-6583084e1583', 'cf36ddc2-7dde-41f6-bff3-9cabdf6a2c4e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4b5f3676-8f85-4c01-992b-1047c69fb4ea', 'cf36ddc2-7dde-41f6-bff3-9cabdf6a2c4e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6042a67c-172e-4b42-a4d9-1a47f6d69232', '3a657420-9940-4390-89b6-fb5eb121b82c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7b5bd535-f438-406d-ad34-523d6218b39f', '3a657420-9940-4390-89b6-fb5eb121b82c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3d53a08f-4305-4af7-80eb-8fda3bbbb7ad', '3a657420-9940-4390-89b6-fb5eb121b82c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('69154cfa-97e9-49f2-8bd5-cf734f8adf9e', '7f718c0b-70d0-42e0-bb59-8c05a3840327', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7eea7e48-3c41-42e0-9062-dd8399a34617', '7f718c0b-70d0-42e0-bb59-8c05a3840327', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2dbea843-1ab0-42d3-87eb-2161199dc784', '7f718c0b-70d0-42e0-bb59-8c05a3840327', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1bcc3736-75f1-41e6-8167-75eaba22e0bf', 'f8627be5-212c-40cc-8685-e6567f3a24a3', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7374b464-824b-4599-a680-7eeefeec7b66', 'f8627be5-212c-40cc-8685-e6567f3a24a3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('24b9bb82-183f-4892-8ad0-10b57ac41dd6', 'f8627be5-212c-40cc-8685-e6567f3a24a3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('80fca0e8-73e4-4dff-8eb7-fe948717083c', '48d04fab-1f0b-49a4-8630-95c88e8565f3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dac7b413-388b-4262-9528-ac7093b0e5db', '48d04fab-1f0b-49a4-8630-95c88e8565f3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('56b7453b-ae0f-42e0-9e65-f9fb222e981f', '48d04fab-1f0b-49a4-8630-95c88e8565f3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9198e2a6-87c5-4b43-a791-a4fa1e51aad7', 'fd404f43-712c-4c09-92a8-50089be5365a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6aac8333-5df3-4805-b559-ef4b47bcfb6a', 'fd404f43-712c-4c09-92a8-50089be5365a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('37f2a646-b91f-48a4-b1b0-80552ec0de06', 'fd404f43-712c-4c09-92a8-50089be5365a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8a445b8e-be37-4df0-a88a-dc6f1101f040', '8a434d72-05cd-492e-818e-bc1af3f6498d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cf2f50be-e34d-46d7-a1c6-1c78f3bb58c1', '8a434d72-05cd-492e-818e-bc1af3f6498d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5e54ac9f-3726-4eaf-89f5-d01c4b0cc53b', '8a434d72-05cd-492e-818e-bc1af3f6498d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9b18e4cf-1a08-4197-aaf8-ffb2e269597c', 'ac1336fa-22a0-405c-ae18-2bb2d8822c1e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('515e3afc-b298-4cb0-8c74-52cbeaef0ac8', 'ac1336fa-22a0-405c-ae18-2bb2d8822c1e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('13f597aa-840b-49a7-98b2-73197510f709', 'ac1336fa-22a0-405c-ae18-2bb2d8822c1e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('498ac7fa-41b6-4f70-88bd-37e181ce85ad', '7b45b1b8-bc9f-46c1-8149-1a8ffdc52d87', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f159f869-8035-4fbb-ac90-d9abf2d92fde', '7b45b1b8-bc9f-46c1-8149-1a8ffdc52d87', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('cb8f24a5-eacd-4d80-af58-e22a37cad52c', '7b45b1b8-bc9f-46c1-8149-1a8ffdc52d87', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1d01f1c8-aeff-4798-a8dc-626e5ba4846d', 'eca0d10c-6b27-445d-aca9-13cf9c38d7ef', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6981cb2d-74c6-4204-a514-732c72164891', 'eca0d10c-6b27-445d-aca9-13cf9c38d7ef', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('525ee50f-1d44-4650-b74f-c79e1e3e1ce4', 'eca0d10c-6b27-445d-aca9-13cf9c38d7ef', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8c8e9eff-f45a-4ec5-a7a7-fc6e526eb7c0', 'd97d07cf-c189-440c-8a86-a29515b7fe8e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1070c185-ad85-4107-ba92-1cc7314bf983', 'd97d07cf-c189-440c-8a86-a29515b7fe8e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4cdf03fa-9f1a-49ee-aa1a-d002db407a38', 'd97d07cf-c189-440c-8a86-a29515b7fe8e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('44b6bd91-c579-4d08-ad5f-5fff05cb5796', '63538b0b-42d5-4510-b1c6-492acbd4b8f6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('55d68f7b-4a13-4de5-8407-dd8657b053d1', '63538b0b-42d5-4510-b1c6-492acbd4b8f6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d49882ba-3643-4d65-b1e8-f94d45484cb0', '47e6e5ba-6e20-4026-bef9-92759d0ec3d7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ec40ec08-0abf-4206-b786-4d780fbf0cbd', '47e6e5ba-6e20-4026-bef9-92759d0ec3d7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2d1901f0-5c4f-463b-9563-ef9387bcd6cc', '47e6e5ba-6e20-4026-bef9-92759d0ec3d7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4788bae5-fe37-4831-93c0-ff37471ca7cb', '2b2bd4c2-0b91-4fbc-bd0a-ec531376ffad', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('52fc8266-01e2-4a22-858e-a2d6ab1fb819', '2b2bd4c2-0b91-4fbc-bd0a-ec531376ffad', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('aaee35b5-c384-40d0-b9df-72fe71cc432b', '2b2bd4c2-0b91-4fbc-bd0a-ec531376ffad', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ecedf978-787a-408b-a074-c008447d1467', '6c902a48-5af3-44d0-a2f5-0d395d4bc014', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('00c00b73-4858-4c40-99c4-55d93fb36262', '6c902a48-5af3-44d0-a2f5-0d395d4bc014', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('dd9020c4-2606-480f-8864-f4d9c6b51e95', '6c902a48-5af3-44d0-a2f5-0d395d4bc014', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('955bd1cb-20ec-455e-af36-4a5e7e2038a8', '1171ef19-6e76-4cfd-89c7-ffca8f6110a2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c436d60e-f492-4efc-af76-821cc89ea6a0', '1171ef19-6e76-4cfd-89c7-ffca8f6110a2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5294517a-996c-42a3-aac8-b716d8e57285', '1171ef19-6e76-4cfd-89c7-ffca8f6110a2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('139947b1-c78d-4e21-a2ef-94d30feb33d3', 'c92084cc-b519-448b-b197-aff95b8439cd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f635296c-0350-41a1-a74d-ebd4317be031', 'c92084cc-b519-448b-b197-aff95b8439cd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1d96a391-0796-4092-9300-f09d3a02ec66', 'c92084cc-b519-448b-b197-aff95b8439cd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0f7f8e15-e262-4f1a-8cd0-d9ca30688df6', 'c9c13c81-e59b-459e-9c77-e709a3be7fdc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9fa92b07-e927-43bf-97c7-64c5bb0309e6', 'c9c13c81-e59b-459e-9c77-e709a3be7fdc', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6eaad796-efa4-477b-bd9c-36acd075d5bb', 'c9c13c81-e59b-459e-9c77-e709a3be7fdc', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0577c9eb-b58b-480b-994b-7fecfbb41802', '7e04939d-5f79-46e1-8ec1-d7799ba55478', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f01d9373-f6fe-407a-b87a-5136657e6e13', '7e04939d-5f79-46e1-8ec1-d7799ba55478', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('92948ffc-f0d2-4b1a-94cb-c57f15cd7a5e', '7e04939d-5f79-46e1-8ec1-d7799ba55478', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('20f8ca2f-90b7-4bbd-ab4c-5dde6eac5c7f', 'e4fd05a5-8be4-48d8-8367-7d298f1b6cc4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f1c95d31-bbe5-4e00-bfce-020409fb6b0b', 'e4fd05a5-8be4-48d8-8367-7d298f1b6cc4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('83200215-323f-4758-843c-71cbb1e146ac', 'e4fd05a5-8be4-48d8-8367-7d298f1b6cc4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d39e7e97-5182-40a2-8785-f47c39f2c536', 'af93c46c-0783-4e3f-ac87-6534a28a85c3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7bd28013-454b-42dc-ae66-a02d31fcb157', 'af93c46c-0783-4e3f-ac87-6534a28a85c3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('30cca312-6f16-44b9-8e10-cd9395ed49f9', 'af93c46c-0783-4e3f-ac87-6534a28a85c3', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2f0e2b92-0919-4a63-b6ec-4cbd8efa0a3e', '9f17ae42-290a-40c6-a04c-5cb34e002343', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5eea82ce-0189-4a98-8354-bee7ca1a18b7', '9f17ae42-290a-40c6-a04c-5cb34e002343', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ff243da2-6b68-4010-a94b-a877985cd90a', '9f17ae42-290a-40c6-a04c-5cb34e002343', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4244056c-a90f-45b5-bf94-21686ea368ce', '5809d8ad-16d1-4588-862b-8ec3d704129e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('94e215c3-68de-42e4-9a9c-35fa1a1fbe62', '5809d8ad-16d1-4588-862b-8ec3d704129e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9b3e3e43-0eb6-4045-8089-46f8b97d0c4d', '5809d8ad-16d1-4588-862b-8ec3d704129e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c861663c-3fb3-41cb-aedb-f19c6d39a864', '08e74d94-95e3-4777-bb53-610eaece818e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7320a8b7-935a-4312-860c-7a4817d75b37', '08e74d94-95e3-4777-bb53-610eaece818e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e5ac90b8-8086-410a-bd5f-fe14a117378e', '08e74d94-95e3-4777-bb53-610eaece818e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('10da1f26-10c4-481a-86bd-84b0ea8cec14', 'cb0eb68e-60e7-4695-8a99-924808c5c488', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('982b279a-47d5-4184-a76a-8e806d6670f6', 'cb0eb68e-60e7-4695-8a99-924808c5c488', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f260e7db-13d5-47fe-a651-69389618bfa9', 'cb0eb68e-60e7-4695-8a99-924808c5c488', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('88b60e39-9dfa-412d-91e6-bb6ed0f8ece6', 'f46d9973-8188-45cf-9425-aaed33fc835a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('32b8b286-0433-44d8-b0f7-8ecebc16c58f', 'f46d9973-8188-45cf-9425-aaed33fc835a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('105edd46-b80c-4e1f-918b-ec5eef85d5fd', 'f46d9973-8188-45cf-9425-aaed33fc835a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('23a69def-c395-44f6-9561-927c542286b2', '9cfebf67-7cef-4d9d-a83c-be84eb979950', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eccec3d6-7a08-4c13-b20f-ca9b6db85f99', '9cfebf67-7cef-4d9d-a83c-be84eb979950', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7231a265-c526-459f-8195-4e0cd1b40772', '9cfebf67-7cef-4d9d-a83c-be84eb979950', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e23bc99a-4100-4141-9ede-52de4c97fefd', 'cb0a8355-765e-48d2-b9ca-01427b54576d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cf627951-3e07-4e9b-9857-57a36314fc6b', 'cb0a8355-765e-48d2-b9ca-01427b54576d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9029e97e-046e-4c05-acd1-ffb623292006', 'cb0a8355-765e-48d2-b9ca-01427b54576d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cfc263bd-3c2d-4812-8d35-f35acc08bab0', 'aa13ced3-12f4-4945-a0e8-513df89ae981', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b0a12039-850f-4d25-8606-8905b3cb46d1', 'aa13ced3-12f4-4945-a0e8-513df89ae981', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d12dcc5b-1191-4950-8bde-41053a397b87', 'aa13ced3-12f4-4945-a0e8-513df89ae981', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('98683ff8-5d06-48dc-83ae-cca06956f31e', '7654e205-68b1-4085-b15c-e8ee0447eba6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('84284746-89fb-4ec0-9ba9-c42534408384', '7654e205-68b1-4085-b15c-e8ee0447eba6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('edec5714-92fd-4dc1-ba51-c51efc2d46dc', '7654e205-68b1-4085-b15c-e8ee0447eba6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8860e3ef-4345-4f65-a563-54643f9468d4', '222a30b3-f823-4310-8af9-e8a8088f7c5e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1b4eba6e-fc1f-455a-a83a-fd45f804a2a1', '222a30b3-f823-4310-8af9-e8a8088f7c5e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5434b441-1d0d-423c-9130-c065742c3c90', '222a30b3-f823-4310-8af9-e8a8088f7c5e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a6cad5b8-5e3f-45c1-9c04-29e362819b6f', 'cf0c0a56-dd11-499a-bd80-31e3adc6cf9d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('538f0ff6-4a5a-4610-8285-8749dbcd8e41', 'cf0c0a56-dd11-499a-bd80-31e3adc6cf9d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bf97573f-d494-4ee7-bb42-db8c49b09308', 'cf0c0a56-dd11-499a-bd80-31e3adc6cf9d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0954ddd8-4c8c-4ecf-82d2-2c9fec26b349', 'aafff709-6bb0-4278-aecd-a34060e356b7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('81a758a6-883c-451f-8b6c-2e0179966371', 'aafff709-6bb0-4278-aecd-a34060e356b7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('359c3e36-d7e2-4742-b7fd-5258eaf19bb0', 'aafff709-6bb0-4278-aecd-a34060e356b7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('37c3d2a4-7ca8-4176-b51a-84f8ba0fe749', 'cb12451a-49ae-42e3-aa8d-83325be4d9d9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1bf39de3-3655-4857-8f8d-9ba535b4d6b3', 'cb12451a-49ae-42e3-aa8d-83325be4d9d9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bd677b22-d453-4c26-b886-7d9a2bfc0990', 'cb12451a-49ae-42e3-aa8d-83325be4d9d9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('42aa6312-1e4b-4b74-9da6-99728307bf73', 'b6c92fa8-05e7-4dba-8ba5-f6eeaf36fba6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5ed57c85-81cd-4aa0-87c0-88cddbc8663e', 'b6c92fa8-05e7-4dba-8ba5-f6eeaf36fba6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d5d862d4-bedd-4837-b7fd-4a907980e56e', 'b6c92fa8-05e7-4dba-8ba5-f6eeaf36fba6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('08452814-3563-4080-8bc7-0dba73298ca3', 'b7c021c3-eacb-4737-87f6-d15af053f432', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b568f1ae-c325-4092-9b9f-199b3df59331', 'b7c021c3-eacb-4737-87f6-d15af053f432', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d67e46f5-9c8e-483f-9094-2c704fd243a3', 'b7c021c3-eacb-4737-87f6-d15af053f432', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('32ca01c3-2deb-4521-aba8-b7c2909ff44b', 'c3b23b60-a96f-4b79-9c20-36b5b12d2a9a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2393df19-5125-4ec7-953e-d77f65bb4399', 'c3b23b60-a96f-4b79-9c20-36b5b12d2a9a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1bbfb9c6-0ef8-40aa-8a01-3428f76e1596', 'c3b23b60-a96f-4b79-9c20-36b5b12d2a9a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c1668ce9-eaf0-4014-be25-8ebc22ef644f', '74401274-c3b5-44ab-99d8-f2b677d16f62', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ccd9b9d2-df7b-4966-b530-e17fe525c0ac', '74401274-c3b5-44ab-99d8-f2b677d16f62', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4d7db592-74c3-45e5-be32-d7c9de4c2c2c', '74401274-c3b5-44ab-99d8-f2b677d16f62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('00f07f76-68bd-440d-afba-18a432ca7126', '085cfedf-bcc4-4a16-957a-809e3c3672a3', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3c9b9a7a-7854-441a-870d-7601c472b055', '085cfedf-bcc4-4a16-957a-809e3c3672a3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1230a3fc-cdc6-4415-bbf3-15ee4d764b76', '085cfedf-bcc4-4a16-957a-809e3c3672a3', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ac1ebc5b-c2d2-4d2d-b53d-a13bb350c28e', '75dbc876-84b1-4b98-8d20-4dd9fe2b419a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8499a5c0-7697-40e8-84d3-a0607a647088', '75dbc876-84b1-4b98-8d20-4dd9fe2b419a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('41283bd1-30ad-4a4e-8fc6-d40eff98c933', '75dbc876-84b1-4b98-8d20-4dd9fe2b419a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cdb45f6b-a42b-4a91-b077-60c154973c08', '49b4edfb-6b5b-4735-b6dc-0fd39d41febc', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('81c67809-a848-4a34-9b27-b0206a56e997', '49b4edfb-6b5b-4735-b6dc-0fd39d41febc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fbc5c1c6-f803-4087-b3b2-ac6219a989cc', '49b4edfb-6b5b-4735-b6dc-0fd39d41febc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3f621499-76f6-478a-8da4-92b8370a7c21', '19a585c5-51d9-49d6-8952-e75941e6ccef', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4e71d380-93eb-4858-9b60-2de315842fa6', '19a585c5-51d9-49d6-8952-e75941e6ccef', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('748eb4d2-83da-4fa9-ac62-758a18fabfe4', '19a585c5-51d9-49d6-8952-e75941e6ccef', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('289f0823-5813-4614-bf08-fe8da2475a62', '3e8bed6e-e949-4ab6-8cb0-82bb81ff46c1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c7a24e2e-296a-4db8-9579-80d7784ccb94', '3e8bed6e-e949-4ab6-8cb0-82bb81ff46c1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2b89577b-094f-4198-9f91-d36c723dbec7', '3e8bed6e-e949-4ab6-8cb0-82bb81ff46c1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1f4457c6-7b8b-41ae-8652-dba0892d8fa5', 'cc692c1b-061f-4fe0-8bdb-e9bd83315b10', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ef5c50a7-317d-4ca1-ae49-1fd6d98fc19a', 'cc692c1b-061f-4fe0-8bdb-e9bd83315b10', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e1595b20-663e-432e-9e2a-6d46f0c29b75', 'cc692c1b-061f-4fe0-8bdb-e9bd83315b10', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('672cb5d4-ad0f-47b7-bac9-b8bbe613be97', 'f29fff16-7987-48bf-a055-92c507bbf09a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('080d208e-9288-4d78-907c-2f9b7c93b27c', 'f29fff16-7987-48bf-a055-92c507bbf09a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('91fb628e-69d1-4823-9e67-75a4ff2f412d', 'f29fff16-7987-48bf-a055-92c507bbf09a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fa5fce61-c7ef-499e-9bdf-20cefab56863', 'ec10f0be-ff5a-4e1b-ab84-6b7a010bf5b0', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d8575c07-abea-4d40-be6c-0182f2009186', 'ec10f0be-ff5a-4e1b-ab84-6b7a010bf5b0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3441295c-2ac1-4364-b855-204aefdf7e8f', 'ec10f0be-ff5a-4e1b-ab84-6b7a010bf5b0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ba053ebd-8f63-48ec-96ed-459c27699348', 'c927450c-dbb4-4091-a89c-178167b75a74', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('438b783e-4ea3-473a-8f16-124d5152acc0', 'c927450c-dbb4-4091-a89c-178167b75a74', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('900ec3e2-a62d-427b-878a-e2cf4f556ec0', 'c927450c-dbb4-4091-a89c-178167b75a74', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d3d12f83-5f21-464a-85fe-808d2ba0fee3', '165a3d3a-5952-4a59-97fd-eb4bab084f4b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('39f6cfa9-d9d1-4f69-a835-748da3c223f4', '165a3d3a-5952-4a59-97fd-eb4bab084f4b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fc0f0ac8-0e08-49f1-a6b2-a6bcd921c81d', '165a3d3a-5952-4a59-97fd-eb4bab084f4b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bf80cbd5-e0e6-44ed-b092-7e792d39026c', '4f326fe7-ccc6-4947-8e6a-945f3f33fcbf', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3262667d-8897-4d5e-9c28-23c5a3635153', '4f326fe7-ccc6-4947-8e6a-945f3f33fcbf', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1b516ea9-6c7d-4f84-ab46-ec4d5240bac8', '4f326fe7-ccc6-4947-8e6a-945f3f33fcbf', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dfbca219-eb5e-4046-95aa-bd80df374e2b', '94f21fee-d7e6-4630-b945-c357e31ee755', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4a263d17-2e3a-4e39-a5fd-76281bb17926', '94f21fee-d7e6-4630-b945-c357e31ee755', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bd1a9684-ccbd-433b-a7be-faa9cf6ead43', '94f21fee-d7e6-4630-b945-c357e31ee755', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0463f2e6-cf62-4d38-a628-59cbf8f614a5', '04e1bcf4-9bf9-4dec-87ce-0aeec3ed1700', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e0f90538-9bf7-4f8e-8a82-a78d30162f13', '04e1bcf4-9bf9-4dec-87ce-0aeec3ed1700', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('34e15177-32db-4b42-b22c-c216e1615116', '04e1bcf4-9bf9-4dec-87ce-0aeec3ed1700', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c315209d-4b73-49e2-865c-2e3802a4f88f', 'a1f0e742-b255-4529-88ed-dbc0599bc9dd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d49bf857-601d-4ad9-baff-a68f1383d4cc', 'a1f0e742-b255-4529-88ed-dbc0599bc9dd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bc691d1a-f82b-48b5-a044-e63747450b7c', '60590957-7633-4400-a0c3-fa82260e2cca', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bc6b0615-13de-4cc4-8a0c-02d56fee99bc', '60590957-7633-4400-a0c3-fa82260e2cca', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d5ec8157-b7b7-45f0-a4cd-823223236b7d', 'ee23121e-9447-46c0-9c2b-8fb638dc3afb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bb497766-eaf1-4192-a434-8e103d1c2c6d', 'ee23121e-9447-46c0-9c2b-8fb638dc3afb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('08d5fe70-5e95-4359-8bc7-58019cd70415', 'ee23121e-9447-46c0-9c2b-8fb638dc3afb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('792ec301-b450-4b88-8bd9-0c02746a0620', '2f2a95d4-c755-403f-94c2-403cd7928827', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e2444172-681f-4c4a-b775-cbf9fafb9a80', '2f2a95d4-c755-403f-94c2-403cd7928827', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f1d1b932-883e-46a3-8fe4-673f17f5e10f', '2f2a95d4-c755-403f-94c2-403cd7928827', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0d2f6657-eec1-4267-abd0-9c7fe1518861', '1542a4a2-4409-4809-8345-51c90678cd82', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e3699329-86c6-4043-b44a-16d0333f56e1', '1542a4a2-4409-4809-8345-51c90678cd82', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a142f184-fa01-4ba0-9154-e6bf675b0609', '1542a4a2-4409-4809-8345-51c90678cd82', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0048a93c-d338-4b64-a084-73eb0004a814', '2ea4bda8-13cc-4c6b-83cf-03eec2a7a531', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2df4eec4-52e0-410b-b631-6deed240f760', '2ea4bda8-13cc-4c6b-83cf-03eec2a7a531', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d5bd577f-b01d-484f-8bcf-0c8586b6cacd', '2ea4bda8-13cc-4c6b-83cf-03eec2a7a531', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('41a0fe14-a226-4c8e-bde1-b9d0148df130', '72e2118f-b2ae-4edc-a1f6-d2ced307f1f6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e5fc19b6-d140-4997-a8a4-6e0b5bb015bb', '72e2118f-b2ae-4edc-a1f6-d2ced307f1f6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6a8f172f-f217-4bcc-9499-bde9595d44ae', '72e2118f-b2ae-4edc-a1f6-d2ced307f1f6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('55beed3e-b6af-43b6-8526-870b5619ef47', '27a450ef-0129-4eac-8825-073e4864b718', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7c883a11-0c3a-4293-ba5f-159a6b5a5aeb', '27a450ef-0129-4eac-8825-073e4864b718', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e9a6820f-4f80-4267-9756-601482d5daea', '27a450ef-0129-4eac-8825-073e4864b718', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b8c2ba7c-81bc-4b87-8e15-84a1cd46655d', 'd1f5c989-210c-4a5a-913d-898f15928379', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('40b326aa-7094-40f8-9bb4-4b04553821db', 'd1f5c989-210c-4a5a-913d-898f15928379', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f400e92f-56b6-47b4-9f66-332da6dd3a8f', 'd1f5c989-210c-4a5a-913d-898f15928379', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('35d52cc1-cca6-4962-89ea-92eae6b8d1c6', 'fa6865ef-ad46-4769-9c4a-ee15ff61de43', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8861e1f7-0ef9-4d16-a352-f2c1fc26695a', 'fa6865ef-ad46-4769-9c4a-ee15ff61de43', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bb8d59da-02d2-4af8-aa24-ee1d3dc78410', 'fa6865ef-ad46-4769-9c4a-ee15ff61de43', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4376e224-8668-4bac-94d2-79a4b7c37275', 'bea0007a-f7da-4e8b-93d1-e43c12e5ed2b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('be9c52ce-3298-41f2-b97a-e435c15e8dfd', 'bea0007a-f7da-4e8b-93d1-e43c12e5ed2b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1f446cc7-551e-48b1-9ed6-b073877434f6', 'bea0007a-f7da-4e8b-93d1-e43c12e5ed2b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ffdb123b-61fc-4f8b-9113-2ccb5b19c8fa', '16c3cd43-f9d4-487a-a9ce-202ce5f4d19c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('216f53c1-61f4-4002-aba3-8f5f3bf70e65', '16c3cd43-f9d4-487a-a9ce-202ce5f4d19c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b8dcd338-f399-4c06-b545-45f5c417ca26', '16c3cd43-f9d4-487a-a9ce-202ce5f4d19c', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f97c6400-f538-4fa1-af30-f1b8c66a0ff2', 'e3db7520-2af4-4b94-ba1d-f574d50b42ce', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a2350f23-053f-4f15-a61d-f1fa0f5869de', 'e3db7520-2af4-4b94-ba1d-f574d50b42ce', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('26cd79af-7e5e-4f8f-88e4-4a48aa949299', 'e3db7520-2af4-4b94-ba1d-f574d50b42ce', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5f47eb98-6d8f-4fdb-80f0-48d980e92067', '20d05514-02b4-4437-8cbf-93b7fb8e18d5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('06638394-5ff6-4685-a8a9-776b297e274a', '20d05514-02b4-4437-8cbf-93b7fb8e18d5', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('113a6ecc-e819-42a0-bf53-b76c7ced2b3f', '20d05514-02b4-4437-8cbf-93b7fb8e18d5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('50063da4-1c6c-42fb-90f4-61216afba0ce', 'db2634cd-9ba5-4503-8d4f-d0f0e717bbfb', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4bb69180-e060-40b2-9da0-ab312acc6fc7', 'db2634cd-9ba5-4503-8d4f-d0f0e717bbfb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9f1b6d37-c1c3-4d24-8247-9267e3d8f5de', 'db2634cd-9ba5-4503-8d4f-d0f0e717bbfb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('80311c62-f7e1-42f0-b3e7-6e80e9909ed1', '337c0ff8-72fa-4016-b44a-8258c915db00', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('51230eb9-d049-44a1-abe4-32bfa37ec5f5', '337c0ff8-72fa-4016-b44a-8258c915db00', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e760ac20-6334-46e3-9fcd-7f0c5774830e', '337c0ff8-72fa-4016-b44a-8258c915db00', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('41cb4cc0-3ca5-407a-89e0-47c3d49ca350', '64cb498e-3ae0-4404-8820-fc687bd54e5f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('83223385-d71e-4287-87e8-d4124e98a7bd', '64cb498e-3ae0-4404-8820-fc687bd54e5f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a21470e8-6e49-4987-b5c8-5ce9ce6d0057', '64cb498e-3ae0-4404-8820-fc687bd54e5f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('28639d0a-ff7a-416a-91ed-f0f89dd529e0', '644771fc-6537-4080-aa11-0f4c1c365c0f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cced2227-ef97-41b5-8f90-c303f4f741de', '644771fc-6537-4080-aa11-0f4c1c365c0f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('83e15642-fe55-4ed0-97a7-a1cf99b7e696', '644771fc-6537-4080-aa11-0f4c1c365c0f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fbb58bc7-b7b0-4310-8974-d11a4a78e364', 'c0feaedc-71e4-42c7-9f8e-ef0b33dc34b1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cc32f7a8-01bf-457b-a361-417232543f19', 'c0feaedc-71e4-42c7-9f8e-ef0b33dc34b1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('254e25a1-d5ae-491a-b0ef-54ad89a3f552', 'c0feaedc-71e4-42c7-9f8e-ef0b33dc34b1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('af13ddcb-c00f-4858-b593-5173ab554514', '40885da8-f3a4-41f9-8ae4-01eceaa91d53', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6e220249-d0b3-4c58-91e9-3d239b95c9b5', '40885da8-f3a4-41f9-8ae4-01eceaa91d53', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8ef79c49-e0ba-404f-a136-065efa818a24', '40885da8-f3a4-41f9-8ae4-01eceaa91d53', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6e4443da-2883-4ee0-9e4e-35e27a8ecccd', '9aba35e3-46ee-453c-ab67-b73eed65cfe8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('74850370-79c3-46c9-b006-85e3e2e63d8b', '9aba35e3-46ee-453c-ab67-b73eed65cfe8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b0e4187f-2f43-4624-8f22-965eed9b2d34', '9aba35e3-46ee-453c-ab67-b73eed65cfe8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('12451fa4-9d93-4cb9-9b62-d1e62b306433', '09137020-04f3-4588-9919-c2c9db3d0e29', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('aba10198-baed-49f4-b124-b631214db8df', '09137020-04f3-4588-9919-c2c9db3d0e29', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8eb54f2d-8e52-4873-931e-323c2fa2f8eb', 'f41650de-7a46-486e-bd83-dc9c138d0de1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('89b42952-aba1-4097-8244-3f5e8fa23247', 'f41650de-7a46-486e-bd83-dc9c138d0de1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2b8a3496-6806-4677-8759-3c2c1fedd763', 'c6c1485a-c124-483d-90be-6603428e3605', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('25dcd1c6-11b7-4dea-9624-4e03f034a13a', 'c6c1485a-c124-483d-90be-6603428e3605', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('acbf7875-a6f0-4f4a-b33d-fb8babc63541', 'c6c1485a-c124-483d-90be-6603428e3605', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('04f3c932-6bb0-4287-a781-09411cf34082', '8a03da10-4fe2-4edb-acb6-6577eb2a043a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1120edc0-0e60-4448-bb99-454072b5cb29', '8a03da10-4fe2-4edb-acb6-6577eb2a043a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0baf207c-8c5e-46aa-97bc-4bbd39174c3f', '8a03da10-4fe2-4edb-acb6-6577eb2a043a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9cb5d6a9-42bf-4a64-859c-3878f9568d48', '29ba09e7-633d-4ae2-990d-aa2d89908d7e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('27180a8c-5fe7-428f-ab57-09e1198e4005', '29ba09e7-633d-4ae2-990d-aa2d89908d7e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a5351ef4-f0a3-444e-a704-dc998cca46f9', '29ba09e7-633d-4ae2-990d-aa2d89908d7e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('33e92856-1fd9-4b82-9d4e-084cd02facbc', 'c6091049-3b35-40f4-9282-8e681a031301', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4780ca41-1e8c-41df-b64a-99cfc2a97b47', 'c6091049-3b35-40f4-9282-8e681a031301', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('372fb7ae-fedf-4441-a568-387cca25840f', 'c6091049-3b35-40f4-9282-8e681a031301', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('84261f3a-1de3-44fa-a4dc-57acb79d7104', '14db8c33-f7b0-49e0-9bad-3331af3646b2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6c8c618e-eac9-4c96-b6bd-be2e66336ab2', '14db8c33-f7b0-49e0-9bad-3331af3646b2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('64a525b4-478f-4034-b418-eb71f18f5e78', '14db8c33-f7b0-49e0-9bad-3331af3646b2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6000d9ec-23bf-48a5-86fc-21b4911fac5e', 'e0d5177d-a9f2-4372-990b-fbed9d084823', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c2ebfb00-8d77-46be-b8f4-570477dc6242', 'e0d5177d-a9f2-4372-990b-fbed9d084823', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3533fcef-c9ce-4aad-a302-f63fd188cc93', 'e0d5177d-a9f2-4372-990b-fbed9d084823', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f487da57-f3ea-47bd-849d-e7b88f107ccd', '920fb352-0dd6-4073-868a-88bebf6d5129', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5ee66c22-c226-4cd3-afec-2b35e80f883c', '920fb352-0dd6-4073-868a-88bebf6d5129', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fa60025a-287b-44f4-8b19-72291ffec1ec', '920fb352-0dd6-4073-868a-88bebf6d5129', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6865983c-a402-4d79-aa2d-68961c369eb9', '0e7c41c6-4177-4eed-953f-45bb23029e5a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('82a8924d-c4af-4d15-8028-c62cfe86f49d', '0e7c41c6-4177-4eed-953f-45bb23029e5a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9946ee52-a433-4a78-83a8-153231607f17', '0e7c41c6-4177-4eed-953f-45bb23029e5a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d63c65f2-300a-42bf-9294-50a1b6d2ac0c', '4233907d-d3c5-4924-bdc2-4b779f21bd35', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6f68d4d6-e208-4da1-9a9b-e8b20a6f2c0a', '4233907d-d3c5-4924-bdc2-4b779f21bd35', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('772e858e-b032-4c05-a76a-b34bf6f31d55', '4233907d-d3c5-4924-bdc2-4b779f21bd35', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3c12186a-4c1f-4e0b-a514-98d6ed7d165e', '917eba8b-3ae6-4ac6-b0e2-942a5708d8c4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1c6f5e6f-352f-452f-82d5-df5101a0ac7d', '917eba8b-3ae6-4ac6-b0e2-942a5708d8c4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3546692e-7d70-4487-9349-bd4a54c054d1', '917eba8b-3ae6-4ac6-b0e2-942a5708d8c4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('adbf251b-96ee-4bb6-9379-4c129e1fe2ef', '86f70faa-0b06-4a9c-806f-a23c0f810b5a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e6a544a5-f9ac-4f04-b858-4916c5ac2dd4', '86f70faa-0b06-4a9c-806f-a23c0f810b5a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('12b48207-b0b1-481d-8ece-46de4849997b', '86f70faa-0b06-4a9c-806f-a23c0f810b5a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc2d90c2-0283-42ce-ad34-761d74eb07d9', 'd3cb8ada-a77c-4358-9d42-16f6f36b6ec9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('95c73343-75ca-4b7a-87fe-07749771a563', 'd3cb8ada-a77c-4358-9d42-16f6f36b6ec9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('faf9ca1b-8b4e-485f-972a-f04d16f9f7d1', 'd3cb8ada-a77c-4358-9d42-16f6f36b6ec9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e404e859-b807-4bb0-bab9-ffd8bd38b858', '57aa0ace-f75a-4848-be50-2cd79c035a04', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('736ded61-8cc9-4673-a33f-b0c870977c47', '57aa0ace-f75a-4848-be50-2cd79c035a04', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d08dcd72-a822-4496-a361-90eaa344365d', '57aa0ace-f75a-4848-be50-2cd79c035a04', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e9f4f539-fefe-4b45-a69b-3b320e04ad7d', '7c145b64-cfc0-40dc-a5bf-beec3b4778a4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dd7d246e-c858-4f03-ab0d-46563c25c114', '7c145b64-cfc0-40dc-a5bf-beec3b4778a4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ed6bf9cb-f082-4a46-9225-c52f1820e040', '7c145b64-cfc0-40dc-a5bf-beec3b4778a4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a8f4230a-072e-49bd-85be-f28f5c883bd0', '222f51f8-b84f-4dc6-a248-dc6e65d8db23', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5555d2b5-aa82-4a7b-9cb0-c1ea54684041', '222f51f8-b84f-4dc6-a248-dc6e65d8db23', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('effd9c71-bde4-44af-b963-d28b9e148551', '222f51f8-b84f-4dc6-a248-dc6e65d8db23', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('27566dd4-143f-4649-ab62-93b2a1f2d730', '334e7716-5a83-4e25-90de-34db53f6765b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e09ef56a-d779-44bc-8495-f890d7317023', '334e7716-5a83-4e25-90de-34db53f6765b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e5286b74-1c56-4ea8-9d0e-a67cc56a4566', '334e7716-5a83-4e25-90de-34db53f6765b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c7efdd54-8c1a-4bd6-9df4-c4977dc6db74', '1c62f154-65c0-4122-9f30-3d34273b1879', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('57aea582-d76a-485f-8a0f-32e048eeff41', '1c62f154-65c0-4122-9f30-3d34273b1879', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7f825d45-87e6-42bf-b95c-b25bcae1c63b', '1c62f154-65c0-4122-9f30-3d34273b1879', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bfd89178-55bf-4675-84bc-6624ca9ccae5', '362af81e-0b8d-4676-91eb-c2ce63709f7f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('338af48f-b0e4-4225-81a6-71505ea487c5', '362af81e-0b8d-4676-91eb-c2ce63709f7f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ec101724-9bba-46fc-b37b-33781a667cf1', '362af81e-0b8d-4676-91eb-c2ce63709f7f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('51191e37-5b09-4b65-86ca-f6b530b82057', '10b60642-a3e3-45fd-b4df-0315b9c19084', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('af9d7078-ae21-49ae-92f8-0d498901edfb', '10b60642-a3e3-45fd-b4df-0315b9c19084', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f8f224df-62c8-4aaf-be8a-d29a135a4c1c', '10b60642-a3e3-45fd-b4df-0315b9c19084', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ff1e5169-6c02-4d00-8ed8-16407bd30292', '87a7e241-f45b-4125-bb14-37f51b033933', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('413c3ce8-2f76-4113-9dc9-78695d5ce6ef', '87a7e241-f45b-4125-bb14-37f51b033933', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d3f81a9e-5b43-45a0-a1f5-1e53351870e7', '7ffb0821-a4b6-4e37-b38d-e3f98a1aab94', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b08b77f3-7c3f-4281-9b2f-a4b3781a01fe', '7ffb0821-a4b6-4e37-b38d-e3f98a1aab94', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('388e5ded-84ee-4ccb-9278-fd70b886f2cf', '0b3363bb-2273-4ef1-8ceb-58c89599fe12', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6527849b-5b77-41e5-be10-43782887f8d6', '0b3363bb-2273-4ef1-8ceb-58c89599fe12', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('706d1887-ae6b-4df8-b627-c8e0479d5632', '0b3363bb-2273-4ef1-8ceb-58c89599fe12', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ace7114c-32e6-4c32-ac9e-1a476c401041', 'd7366b2d-55e0-4f56-8361-afa3e222fa7c', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4c8ebc37-e1bf-45b5-a8c5-ba254d323ee9', 'd7366b2d-55e0-4f56-8361-afa3e222fa7c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7b1b7937-3c9b-4f10-b49c-d9380a862813', 'd7366b2d-55e0-4f56-8361-afa3e222fa7c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dc1cd276-7240-49c1-92d2-a2bbd8b04c5b', '81e5c06d-8034-4243-aad6-acb2e3718583', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0a27bdbb-95e4-4758-9873-3a6acad12449', '81e5c06d-8034-4243-aad6-acb2e3718583', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1fa87e3f-2112-4cb4-a97f-df5539032a93', '81e5c06d-8034-4243-aad6-acb2e3718583', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('960d433d-04c2-4e3c-92f3-c0f3a3e54a33', '74a52f08-db50-4070-89b3-832013994c70', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ebd72b75-4dfb-471e-9ea3-3245a7ccfab1', '74a52f08-db50-4070-89b3-832013994c70', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('abf87d3a-cf17-4cfe-94da-f8ea8c3f106e', '74a52f08-db50-4070-89b3-832013994c70', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8bd6755d-138a-428a-83c9-1035c5892833', 'b1c54d61-fe67-45f3-9b7b-720604ff6d97', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0b03f104-10de-4e63-91c8-07e7193e6eac', 'b1c54d61-fe67-45f3-9b7b-720604ff6d97', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b6aee815-17ac-477a-8de6-c5868906bf1d', 'b1c54d61-fe67-45f3-9b7b-720604ff6d97', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0d27ec2f-39f1-4292-b5d5-efe6e4e9687f', 'fdddc855-b6a6-4f5f-acff-215fb85624f0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a87158a4-d92f-436f-9b3d-908e0b4255f3', 'fdddc855-b6a6-4f5f-acff-215fb85624f0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('75174b92-35cd-4f51-b192-01bd2e03a06f', 'fdddc855-b6a6-4f5f-acff-215fb85624f0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ef7ef058-2287-45ee-ab22-55a416f7b366', 'c73b4108-4ec7-4f40-8915-6a8f0fde8d64', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3029c72a-ff1b-4166-9674-204a277a7e52', 'c73b4108-4ec7-4f40-8915-6a8f0fde8d64', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f080b29d-ab6f-4cb3-9fa2-efb264e53da3', 'c73b4108-4ec7-4f40-8915-6a8f0fde8d64', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dac16ba5-05c6-4d3a-bd44-a2127904a8cb', '0fdbf388-c067-40e4-a901-9bcb3ff1e231', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('aac95c81-c541-4b99-a0f6-e32f8c2b609e', '0fdbf388-c067-40e4-a901-9bcb3ff1e231', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f48b1e75-2ea9-485d-8a56-df99b3cf3cae', '0fdbf388-c067-40e4-a901-9bcb3ff1e231', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('34e04cfd-5dbc-4f8e-a803-4295c8e20fd3', 'c20d4753-8e19-44a3-af07-43dfec432685', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c169bd88-a4f4-4cc6-9430-248463d0724d', 'c20d4753-8e19-44a3-af07-43dfec432685', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f3f80e08-ab54-4b76-91ec-db50979d9715', 'c20d4753-8e19-44a3-af07-43dfec432685', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('be45788b-6507-490b-be29-4296ddbdaa7a', '717aae07-53a0-4a24-893a-85862d4e586f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2459bdbc-770f-451b-9faa-81b0911ff592', '717aae07-53a0-4a24-893a-85862d4e586f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6b97f621-a6a8-452d-b4ed-793dd5ed5ddd', '717aae07-53a0-4a24-893a-85862d4e586f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c3151601-ec8c-4df8-850f-0456c5fb0b8e', '1335f5b0-5487-448f-9279-1034dc3e31a2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('808de931-6cc8-49d1-a13d-a691f545303e', '1335f5b0-5487-448f-9279-1034dc3e31a2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('032882d4-49f7-4fb6-8599-fb9c42e282bb', '1335f5b0-5487-448f-9279-1034dc3e31a2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6549a003-5ae9-4a07-a097-c794356868f1', 'afb3736b-2a5f-4161-be82-7937e1f15919', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('748f7adf-e61d-46b8-a273-b3e5480b41f7', 'afb3736b-2a5f-4161-be82-7937e1f15919', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ebac3100-7af2-4ecb-be5a-d8cae2ff04bc', 'afb3736b-2a5f-4161-be82-7937e1f15919', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d81b1a69-ba26-4083-859a-8f1b8b2f3577', 'b2dd41e1-309f-4a98-a4cc-31776574f907', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('73c32ad2-77ef-47d1-b0ad-8b1f30a5a335', 'b2dd41e1-309f-4a98-a4cc-31776574f907', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('505a0f9a-965e-4c79-9d9c-c3b5270653b1', 'b2dd41e1-309f-4a98-a4cc-31776574f907', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b5d71b5e-bdaa-45e4-9301-992032cca48f', '45922587-1e44-467f-8be6-d681f48df7d9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fecea286-80f9-40ed-86dc-86099f904bf8', '45922587-1e44-467f-8be6-d681f48df7d9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5b91615c-132f-41d6-8724-e122c1ccff3e', '45922587-1e44-467f-8be6-d681f48df7d9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d7727221-20a1-43a8-a81f-0cec6d68cc0f', '5d19e415-265e-45cf-be9d-8493dde41cef', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1aa74e6b-4100-4e80-8674-3e9aacf52535', '5d19e415-265e-45cf-be9d-8493dde41cef', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('01c45097-b7c0-46f1-999f-a2b24999b8d8', '5d19e415-265e-45cf-be9d-8493dde41cef', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e5f93772-3367-426b-9941-cdfd950c6a44', '701fc5fd-c2b5-47ac-af0a-bc85433c7b62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a50daa18-5e9f-4483-b8f8-950c1492ad0b', '701fc5fd-c2b5-47ac-af0a-bc85433c7b62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6e197dfd-c47c-4cd9-934d-f47a8a5d41d1', '701fc5fd-c2b5-47ac-af0a-bc85433c7b62', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('041762cd-f61c-49a7-9f08-9299e10d946d', '95242ec6-b4d7-4f38-9181-724b578adffb', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('73390efd-edf8-4078-8cf4-eb557dc77f03', '95242ec6-b4d7-4f38-9181-724b578adffb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e6cbd8f5-ed94-4080-9d00-03452ed54fb4', '95242ec6-b4d7-4f38-9181-724b578adffb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d7be5eb0-53e8-450b-a37c-c711ae632800', '0cb9a6e5-c53f-43cb-9b52-b6295f26ee54', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2f9a4198-995c-40c5-a5c2-22410c59c666', '0cb9a6e5-c53f-43cb-9b52-b6295f26ee54', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fa266cd3-13c8-43bc-851c-e8bccf92a90a', '0cb9a6e5-c53f-43cb-9b52-b6295f26ee54', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('412a3305-3e81-4988-a2c3-f6f70bae3093', '25584d1c-9329-48a6-8b5b-bc1734010441', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('17c93457-c626-45ba-8c47-9c6b371a70b7', '25584d1c-9329-48a6-8b5b-bc1734010441', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9601e7d7-f735-458e-9f5b-c4505effc143', '25584d1c-9329-48a6-8b5b-bc1734010441', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9949ca56-b086-482e-af08-fa696588b68f', 'ca74e3ba-5a88-4543-bbe7-d2867bfaef9c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3c0ae72e-e709-4ad3-9b3f-41b1ea669c1a', 'ca74e3ba-5a88-4543-bbe7-d2867bfaef9c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('37503c34-1f3d-4b80-be6d-0228211c92b9', '49f03674-c025-4aac-8bad-bc4ed96c70f5', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2f2071ed-d51d-4147-99da-0ba33cfc26cb', '49f03674-c025-4aac-8bad-bc4ed96c70f5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0b73eb35-cce4-44d8-a481-6e17e72ee0ee', '57609f8b-89a1-4ae8-b1cd-ba8b1e63d4aa', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2f5e8a84-7825-4182-9da7-5c89fd85205e', '57609f8b-89a1-4ae8-b1cd-ba8b1e63d4aa', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7ce5f12b-a8ef-409a-96f4-8b1571a45276', '57609f8b-89a1-4ae8-b1cd-ba8b1e63d4aa', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ae1d871a-d30b-41dc-8b79-a440ff630494', '44b5481c-63b6-40a2-bdb0-ca3b9ea353e6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('37741081-4f32-4622-b878-d127bbf6732f', '44b5481c-63b6-40a2-bdb0-ca3b9ea353e6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b76aecde-24c8-46cd-b363-84ce12e437d6', '44b5481c-63b6-40a2-bdb0-ca3b9ea353e6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3a333755-0aea-4630-aded-a3980676a692', 'a14adf80-3962-418e-a506-5662f1996020', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3b07a980-bee3-440f-8ab8-48ecd0905bb8', 'a14adf80-3962-418e-a506-5662f1996020', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3bbb6f8c-2a8b-4fc4-8c66-ef0d4003564e', 'a14adf80-3962-418e-a506-5662f1996020', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('50f60b40-2f60-4bfc-83de-5876fc3daf6e', '60559b0e-dbe9-4a16-bb1a-4bcec1b17c6d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bc98b391-f343-4ba5-b787-5614274c6dac', '60559b0e-dbe9-4a16-bb1a-4bcec1b17c6d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0e89fc04-32d0-4f50-96b2-2cd395e05afa', '60559b0e-dbe9-4a16-bb1a-4bcec1b17c6d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fe80c1b6-621c-4388-b337-5e0db4e48e74', 'b0827efb-0fc3-4ce7-865c-60ea88d18de8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bb3ce3f4-d79d-4832-b48e-ece7e65e8cac', 'b0827efb-0fc3-4ce7-865c-60ea88d18de8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0edc8398-f421-450d-81db-a34644281a64', 'b0827efb-0fc3-4ce7-865c-60ea88d18de8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('54920dcf-49c2-47b7-9ce0-32ed5d33e75c', 'f0a1fce6-2263-4543-968f-5b0dbd5bf20d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1fa6f4e1-088a-4a66-a044-2d47c5661f87', 'f0a1fce6-2263-4543-968f-5b0dbd5bf20d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6382182b-7cfa-46fc-9d2a-ab47ed8e3145', 'f0a1fce6-2263-4543-968f-5b0dbd5bf20d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d3ae1f35-80ca-4188-b20d-e02b59431c7e', 'f9621f2e-f836-4f82-8cf5-d16c67ccae7d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0e2ed2b5-86ad-480b-8154-7db7d4b93024', 'f9621f2e-f836-4f82-8cf5-d16c67ccae7d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8ec24079-f0ff-4e6a-9442-3430b1616126', 'f9621f2e-f836-4f82-8cf5-d16c67ccae7d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f17f3db5-43e8-4af2-998d-1400d41a1d7e', '96b756af-5b21-42ed-a98e-c953c4df272a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('56551ebb-4f02-4622-b936-d9803a87848a', '96b756af-5b21-42ed-a98e-c953c4df272a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4abcdf9b-ca5b-4f66-8be3-0b6450be2f70', '96b756af-5b21-42ed-a98e-c953c4df272a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7aad5cdb-ba64-4804-893a-83e233a6aad8', '88335f47-69f0-49e6-997d-7258149d7561', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ff28acd7-95e4-4713-9f3c-0687421c8682', '88335f47-69f0-49e6-997d-7258149d7561', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6d235c2a-dc60-4f6a-b925-4f4055ffa064', '88335f47-69f0-49e6-997d-7258149d7561', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1a2e0f17-1cab-4fbf-82dc-b27d177c5253', '50f03aed-8d45-45b9-8912-23a8a854fa0f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bcdeff76-3a37-458c-ae15-7c9ac13a1a16', '50f03aed-8d45-45b9-8912-23a8a854fa0f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('634248b7-0d01-4004-b091-941882756923', '50f03aed-8d45-45b9-8912-23a8a854fa0f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7b35f903-ef02-41d5-b97b-ff0c475b2c26', '227d82fe-039f-4046-b532-e0328af9e961', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fcfe3fd8-8380-43c1-8d42-c70590aa3b06', '227d82fe-039f-4046-b532-e0328af9e961', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d50ac647-e3c2-495d-94b3-08b69e81c9a3', '227d82fe-039f-4046-b532-e0328af9e961', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3ee06d28-edd0-43b4-8183-6bb6bf7d9b7d', '92b6f6db-4927-447f-847b-3f8b4dd185cd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('80f54558-d518-4ba9-ae52-cb39a0e655ed', '92b6f6db-4927-447f-847b-3f8b4dd185cd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e8a77265-0b5b-4ac3-a729-f643bf8cd0e1', '92b6f6db-4927-447f-847b-3f8b4dd185cd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('796a4862-1a2b-4e3c-9cc4-ffa0100cbd04', '01aac4e3-d49a-44ab-a6dd-b680fab5354a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('221769d8-495e-46df-b6b8-b11623ceb3d0', '01aac4e3-d49a-44ab-a6dd-b680fab5354a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7048e597-aeda-48f2-920f-f21437b5a205', '01aac4e3-d49a-44ab-a6dd-b680fab5354a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1c52ce2c-39d3-4449-bea9-cf05d7fd66df', '51e2ca3a-7942-4113-a5fd-e4293efc18da', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eb4ef824-ee15-4d56-bd9d-88887d2c2264', '51e2ca3a-7942-4113-a5fd-e4293efc18da', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8d3bdea0-07c8-4bdc-97d3-9de8d26936c2', '51e2ca3a-7942-4113-a5fd-e4293efc18da', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a97bb65d-d481-4ef7-bee8-9834354db939', '9646b2de-ecaf-40bf-b94d-9bd3c6ba06d7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3d85dc91-54df-4d30-b1b2-5dc2a0e4e397', '9646b2de-ecaf-40bf-b94d-9bd3c6ba06d7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9836b80c-e4d9-4a48-8816-ef936edf77d8', '9646b2de-ecaf-40bf-b94d-9bd3c6ba06d7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ad6c1f56-bddc-47b3-8369-e01088b13a41', 'a6599d4e-ae01-48e6-ac22-182a8ce054c4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1d8f400c-88f8-4d2c-8c7b-ad0e04f28f8a', 'a6599d4e-ae01-48e6-ac22-182a8ce054c4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('19f20bb2-99e3-4811-a1fd-89720eaea520', 'a6599d4e-ae01-48e6-ac22-182a8ce054c4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a23d03b6-b5a9-413c-9270-68545a460579', 'c9d890f8-8847-4d48-afb0-4f493f88f3e4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0cb86448-d455-4c88-a903-5e8721b179ee', 'c9d890f8-8847-4d48-afb0-4f493f88f3e4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f8c5859a-e77a-41c0-ab40-e28a93f58745', 'c9d890f8-8847-4d48-afb0-4f493f88f3e4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e4a1b568-ff60-4a4f-b3c9-e0a0dce48db1', '6b8e0bc7-a8b0-44c5-bb56-940aeaf4140f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c5fa0904-e23f-435a-a7a6-405211f40c36', '6b8e0bc7-a8b0-44c5-bb56-940aeaf4140f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6a01bf1c-df83-4c52-a33b-f2d69d76ba25', '6b8e0bc7-a8b0-44c5-bb56-940aeaf4140f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('acb970ae-a73b-444f-86a9-d697f926f6be', '1275d728-b2fa-4889-b032-d59f10ac4c3e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('91b26de1-c858-4de2-bb5b-0b121358735c', '1275d728-b2fa-4889-b032-d59f10ac4c3e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3e067a96-bc91-49da-abc4-fbdc803a7bf9', '1275d728-b2fa-4889-b032-d59f10ac4c3e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5ad5f257-0af5-47a9-815c-494a43a55ab4', '300e16d1-bf65-4390-b8d8-48bbf3916db2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a8134c0c-0b27-4b15-ad6a-ba7d6134e17c', '300e16d1-bf65-4390-b8d8-48bbf3916db2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('65369b5c-999e-4d4c-bfc6-802a963adba7', '6ca77788-a011-4616-908b-ee93cf1fd6d7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('56e4e22f-5804-4b01-b5df-d5819eeb1265', '6ca77788-a011-4616-908b-ee93cf1fd6d7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ee29fae1-19af-4e14-b761-962bc8c19cb7', '2cc5d683-e918-4d8f-bdae-d8ebe26d1ad3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ea1fd54b-8bdb-4b8a-a848-ba0c95da9f22', '2cc5d683-e918-4d8f-bdae-d8ebe26d1ad3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3cc0203c-aaf1-4e23-9c9a-aa872293e1cc', '2cc5d683-e918-4d8f-bdae-d8ebe26d1ad3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e1cd81a8-0951-45bf-846c-ae660601eabd', '4f1f66b3-2bc0-4f37-9980-ecb7a5c6df36', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f405c30d-0c7c-4faa-ac37-8cec15fac8a1', '4f1f66b3-2bc0-4f37-9980-ecb7a5c6df36', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8d048567-d021-4823-b4dd-3d9c38dd1789', '4f1f66b3-2bc0-4f37-9980-ecb7a5c6df36', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('661226c8-7c68-4f65-b0db-58a0782e93ce', 'a5f97c92-252a-451f-8fd2-2f6a0ca35de6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3e2dd2ca-736f-4b28-bff1-26a97bc488b7', 'a5f97c92-252a-451f-8fd2-2f6a0ca35de6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ce0d6b68-616c-46c8-91f6-37c9759fdfce', 'a5f97c92-252a-451f-8fd2-2f6a0ca35de6', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('42fdd877-ab22-4b2a-9b24-3f0da056c6d6', '0ea62c20-e353-4578-8d9f-0d674d598a30', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('67794bae-f834-42c7-8f0d-a9ce543607f7', '0ea62c20-e353-4578-8d9f-0d674d598a30', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fb19d4b1-c95d-4440-99c5-261c1ef2205b', '0ea62c20-e353-4578-8d9f-0d674d598a30', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ae17f1ea-4e13-41c7-b4f9-b21b770a039b', '935a86a1-1ca8-4637-89ef-cbd637055546', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('184670c8-da86-427f-9e1f-2e434eedfde3', '935a86a1-1ca8-4637-89ef-cbd637055546', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c1878086-7c3a-439a-9348-4e4a232374ea', '935a86a1-1ca8-4637-89ef-cbd637055546', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e96db9d0-d11a-4c11-b252-345d354cc604', '9ac63bba-1622-4fe7-b3f9-b0285e6422f1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a1929422-65c8-4a13-bf5b-86ae982dbc57', '9ac63bba-1622-4fe7-b3f9-b0285e6422f1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1f6b7b32-d57b-4697-a458-0dbb0cc84398', '9ac63bba-1622-4fe7-b3f9-b0285e6422f1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('37a9a254-7411-49d3-a1ce-e49b62e08885', '85296a31-c602-44df-b642-586f351cf845', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c187a1c0-c474-4d83-b7d5-73792487d16f', '85296a31-c602-44df-b642-586f351cf845', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d19600d5-6323-41a4-86b4-1471c7539264', '85296a31-c602-44df-b642-586f351cf845', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('75837fab-f8b5-45c7-a87d-9062c2640356', '4c6a73a4-9281-4fd5-a2b3-692bbb33ed7d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bb9b350b-a0e4-4d14-a862-60a6d02ed296', '4c6a73a4-9281-4fd5-a2b3-692bbb33ed7d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c8c03a80-c112-4c9c-a4cc-e879934c2502', '4c6a73a4-9281-4fd5-a2b3-692bbb33ed7d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4033fc44-4205-401b-86d2-35ca37afe3bf', '1a46f6f9-639f-49a9-ac26-b59e8c18f8bd', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f3a6bb54-3d39-47ee-aff4-011cf7d5dbc0', '1a46f6f9-639f-49a9-ac26-b59e8c18f8bd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e212abde-b839-4b52-b60d-80f8e43aaaf2', '1a46f6f9-639f-49a9-ac26-b59e8c18f8bd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('434703a6-3f47-491b-b446-62ca6495053d', 'ccd265b2-3efe-47a3-b0fd-a00e57b6ed3c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('607d5c09-7be2-4d7d-9c86-a46b3a355c44', 'ccd265b2-3efe-47a3-b0fd-a00e57b6ed3c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9748aa7e-d9e0-40ee-b10a-8ebc5fd44fd7', 'ccd265b2-3efe-47a3-b0fd-a00e57b6ed3c', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('57cf9a1e-43e1-4eb2-a2cd-19a1d9864fd4', '8e1c8e82-1769-4df5-9bf2-2b273197b1f5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('637709f0-908c-4caa-8bc6-a85cdc8b678c', '8e1c8e82-1769-4df5-9bf2-2b273197b1f5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('99f13d8c-0697-4aa7-aecc-e134a91c8872', '8e1c8e82-1769-4df5-9bf2-2b273197b1f5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bafbea04-f0c5-406d-9ea8-0bce4e0cb8dd', '54592303-1f99-45dc-8af4-1af1ed73e327', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bf3106e7-d482-433b-9a52-5c35a55ce577', '54592303-1f99-45dc-8af4-1af1ed73e327', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fa8f93bd-0360-4564-8718-6e5f2c7ffe58', '54592303-1f99-45dc-8af4-1af1ed73e327', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7757d257-68c2-4a8d-8e41-9f300fe82d6f', '466821ee-5a50-417b-9b5d-e6faf8b615e2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3d4c0b16-e8d7-4df4-865e-f415360a0b83', '466821ee-5a50-417b-9b5d-e6faf8b615e2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b0430475-a0fe-464a-882a-d1f447bbc187', '466821ee-5a50-417b-9b5d-e6faf8b615e2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('574fed29-442b-47cb-af8d-4a0b075e1afc', '662dd316-70bc-4a60-bdd9-06f5949c64a8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('278fb470-d7ec-4ecb-8979-aa7878f0054b', '662dd316-70bc-4a60-bdd9-06f5949c64a8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fff5f9b5-9316-4bac-b850-0ac317c3a4da', '662dd316-70bc-4a60-bdd9-06f5949c64a8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6d460174-0d56-44e5-8115-223904a1a07f', 'a40e0994-99f3-46c3-853d-173417ccc344', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9cd450e3-1586-49df-bfb0-104cae7cce97', 'a40e0994-99f3-46c3-853d-173417ccc344', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ae1d7595-4abd-4d60-8a20-266a84409f35', 'a40e0994-99f3-46c3-853d-173417ccc344', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c4e43d1f-9bfb-4a80-85b2-a7e49fd6ab72', '6d7644b3-cb12-498a-a806-0a1711f8286b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4eadc57e-9b37-4330-b1c3-ea05c992416c', '6d7644b3-cb12-498a-a806-0a1711f8286b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d9b3f5d3-c5d4-4490-9972-3d72da355eb7', '6d7644b3-cb12-498a-a806-0a1711f8286b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('31ff9906-940c-4372-8604-8402a057aea6', 'f52b3464-5009-42c4-96da-03d1cd8bcb47', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f92fe062-8342-4380-a00e-e6588403de4a', 'f52b3464-5009-42c4-96da-03d1cd8bcb47', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ad09afd1-c00b-4bec-9a64-48f3a523859e', 'f52b3464-5009-42c4-96da-03d1cd8bcb47', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('50118a0e-7352-4969-8de2-80a0ecc4041f', '7df06b96-454d-4a51-9460-e8d031ca5d9d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4bed7482-39ef-446c-88e0-1727e4e382c8', '7df06b96-454d-4a51-9460-e8d031ca5d9d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e56fdff6-1bfb-41c3-9609-5a4d9db7afb6', '7df06b96-454d-4a51-9460-e8d031ca5d9d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('85c108bc-a45e-4692-b004-e0d663775f8d', '4c7d5b2f-205e-48a2-8fb2-50a0633d6145', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6568b7ab-4060-4414-8b9a-65810584c2a5', '4c7d5b2f-205e-48a2-8fb2-50a0633d6145', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('69a35d2b-52fe-4dac-8f36-955da4f6d166', '3a7f3b0b-b3ee-49a0-91d5-9404df14e202', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e83490e7-0187-4f93-9d46-f98d2e964dfe', '3a7f3b0b-b3ee-49a0-91d5-9404df14e202', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9b4fe4e0-c88c-411c-9c1b-9bfc5d635e3c', '3a7f3b0b-b3ee-49a0-91d5-9404df14e202', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0d8e7314-2784-4aa6-9543-0043db2bd6bc', 'fcaf1a39-ca83-45f4-97b1-a9a58bfb7e4d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3a0f578a-7991-48fc-bd23-ea42df7c6189', 'fcaf1a39-ca83-45f4-97b1-a9a58bfb7e4d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5f8e9d1c-93dc-400e-baad-9fcd762425e0', '41444709-5021-430a-9917-4f52368de1c6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ee092260-8ede-4257-b4b5-c19fb4fd8a4f', '41444709-5021-430a-9917-4f52368de1c6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0417baf5-dc34-4e11-b1db-08913ac90435', '41444709-5021-430a-9917-4f52368de1c6', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f4b16fd9-4406-4c29-837e-590be7561624', '2de3f495-fedd-4c20-88ab-acbc357cff5d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1a77a54f-849b-434e-aa34-7a649f17e6ea', '2de3f495-fedd-4c20-88ab-acbc357cff5d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9b117c33-3faf-4726-b20b-9189977bea8e', '2de3f495-fedd-4c20-88ab-acbc357cff5d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7f87b1a7-a756-47ab-b2b1-038782ad363f', 'ba654586-d8f7-4218-937a-2eb5a61339c1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1988ecea-fb48-419c-954f-7a305009c4a3', 'ba654586-d8f7-4218-937a-2eb5a61339c1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('325dd2c5-1310-4a10-a51d-c74f2df26fbd', 'ba654586-d8f7-4218-937a-2eb5a61339c1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('39599f83-b1f3-4990-b21a-9d88ea64335a', '997e6206-7c10-415a-9230-e95cedcb8c5d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1c50971a-31b5-43e2-a807-640ae568085f', '997e6206-7c10-415a-9230-e95cedcb8c5d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('17b5679e-1fc7-45a4-a46a-b7a17937ede6', '997e6206-7c10-415a-9230-e95cedcb8c5d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cd93f0a4-7f53-4df5-a72a-0537362db38a', 'b9608f71-7c90-45b6-8222-02a8f44f12d5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a3ad9c69-f9e2-4600-9aa4-b36a5c167caf', 'b9608f71-7c90-45b6-8222-02a8f44f12d5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c32eab4f-941b-408d-80b1-17dfb57ce733', 'b9608f71-7c90-45b6-8222-02a8f44f12d5', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9fe0df91-81a4-483b-b370-c730561f149b', 'f3a84d44-ceeb-4659-bedc-25be0b5cd461', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('26bff41e-fffc-4ad9-aff5-6ac0e1c9f11d', 'f3a84d44-ceeb-4659-bedc-25be0b5cd461', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d72bebc1-da98-45bf-b236-0d6ead04c5af', 'f3a84d44-ceeb-4659-bedc-25be0b5cd461', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('11fbc466-2d81-49d2-86b2-39360b14d1fc', '8b1e319c-b1da-40b4-8fda-62d9fcd907c1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c2f260eb-765d-495a-b082-bd27b604b17c', '8b1e319c-b1da-40b4-8fda-62d9fcd907c1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('58af2640-f93f-4089-841e-26d244c99ae5', '8b1e319c-b1da-40b4-8fda-62d9fcd907c1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2f0f4e66-a80c-47bc-b97c-043813a66bb2', 'fe663d33-a61d-4de1-9ab0-0e7d508550fd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bcdefc4b-7af1-4cbe-9a95-44281b0e12e5', 'fe663d33-a61d-4de1-9ab0-0e7d508550fd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('eb2a05f5-7cad-44ad-8c16-88ab4709b13a', 'fe663d33-a61d-4de1-9ab0-0e7d508550fd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6716cbb8-5568-4ee8-a9e7-db36c2c10d7f', 'e949056e-a72f-4307-8874-df7fb4b2dfab', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('efd3946b-6e51-4343-89f4-c0a6c2c57ad1', 'e949056e-a72f-4307-8874-df7fb4b2dfab', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('eeaed66a-dd04-421c-9220-6306ccd8e428', 'e949056e-a72f-4307-8874-df7fb4b2dfab', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('81845914-a28f-4c0c-8b42-ac1be2d906cc', '3ee4d84f-a69c-4dea-ac52-5dc1f38a04fe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3ed0e291-1692-4491-8b8d-7bd2b2a83002', '3ee4d84f-a69c-4dea-ac52-5dc1f38a04fe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9b48646c-4117-4989-a5ee-b55d9867f533', '3ee4d84f-a69c-4dea-ac52-5dc1f38a04fe', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('18796c1d-85c1-4727-a283-078f09246cce', '11098f74-7e5b-432c-94fc-481ff3473886', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4d48883b-46f1-4ca8-ab65-4a00c461176c', '11098f74-7e5b-432c-94fc-481ff3473886', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('64286e5b-d8f5-4fbb-a6bb-0a037d4b4a3d', '11098f74-7e5b-432c-94fc-481ff3473886', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('789a78c0-fe94-4b68-9dee-ebb7fdfa74f9', '828c8fa6-9340-4f0a-ac3a-d33a5bece175', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('760142dc-c784-4215-a83a-717792b945b0', '828c8fa6-9340-4f0a-ac3a-d33a5bece175', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d9ec4add-a80d-4d93-bfc4-bf6f8a87f9b5', '828c8fa6-9340-4f0a-ac3a-d33a5bece175', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('754d3ec2-4fe0-4a0f-bb86-4dd38ad3af36', '450ae4db-b409-4eaa-b3ca-b620de4e41c9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ea1df45f-3129-45de-8b8e-58b0f3326bf3', '450ae4db-b409-4eaa-b3ca-b620de4e41c9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('77bfaca6-6a56-4f60-9012-5e86ca7559f4', '450ae4db-b409-4eaa-b3ca-b620de4e41c9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('447a6665-2b21-464c-b9f9-9354b7dac7c4', '9e4fd619-c7ef-4866-9bd3-86ed219a00ec', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cbed71fc-dab5-4e90-9820-0f73ed6aa039', '9e4fd619-c7ef-4866-9bd3-86ed219a00ec', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7086fb06-43fb-4b88-9a89-8d2aabf21a18', '9e4fd619-c7ef-4866-9bd3-86ed219a00ec', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ff4657e0-e731-4301-bd90-5ad255385fdf', '828e02a8-2ad8-4218-9f93-f5722e3aac3a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4f2bbd01-b162-4c5b-baa7-aea9b8760af7', '828e02a8-2ad8-4218-9f93-f5722e3aac3a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a6ee1348-9852-493f-8cf5-290b4b73f4b0', '828e02a8-2ad8-4218-9f93-f5722e3aac3a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('537f11a0-ef5c-4859-b29a-f288809bba7a', '49a51dbc-94e9-430f-aab6-f7b4243556b1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3e05881c-7b44-4c6f-8d89-4b1d6b14e251', '49a51dbc-94e9-430f-aab6-f7b4243556b1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fd6f0a03-947d-40b1-ae3c-1efac25d1583', '49a51dbc-94e9-430f-aab6-f7b4243556b1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('64d9ae76-966f-4e14-99b3-ef9f3ead410d', '3cc76d5b-705c-41c2-91a3-390df3e8f2fe', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f4b3a387-e4fa-4b66-a047-8fb0aae6380a', '3cc76d5b-705c-41c2-91a3-390df3e8f2fe', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7fe8727c-ff27-44ab-b77d-7381a2ad6308', '3cc76d5b-705c-41c2-91a3-390df3e8f2fe', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1f17caee-6e95-4fdd-8843-c396823ff030', '0f051e3d-6c5b-4593-9df2-8905172043dd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d0f7add6-1f2c-42c4-826c-2106d22c4d4d', '0f051e3d-6c5b-4593-9df2-8905172043dd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('97269bd5-604c-4590-9009-eccbdf943efb', '0f051e3d-6c5b-4593-9df2-8905172043dd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0c0dd47f-b484-4341-accf-f97980c2d93e', '5139045d-a7ba-4533-bedf-667e9ef619de', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1a973ed0-12b8-4ee5-8ad5-4ad326eff61b', '5139045d-a7ba-4533-bedf-667e9ef619de', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e9ec1671-6c82-4b30-aedb-525a55079314', '46b5d48f-2ac4-48ce-84dc-bdab5a8d4db7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('48e90a17-8830-44fc-bcde-6b4966d1513a', '46b5d48f-2ac4-48ce-84dc-bdab5a8d4db7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ecdbf525-cf89-4d12-ae8e-6ccc7777c5cb', '46b5d48f-2ac4-48ce-84dc-bdab5a8d4db7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('57a3b176-3d0e-4383-8f08-2b823e54c2d4', 'e837de26-f7b9-4944-80c9-82d81c0a601b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('045187da-8dbb-4e07-afd7-29f2c8db7280', 'e837de26-f7b9-4944-80c9-82d81c0a601b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5aa170b9-aa6c-4718-8e06-afbcc1c28f61', '5e88605e-11a5-4eb5-9b85-81bfed4301da', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e27db9ca-b6b4-4d1f-a878-4c3832eb8543', '5e88605e-11a5-4eb5-9b85-81bfed4301da', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7005e58c-87d7-4912-b1a9-a2c2582c268d', '5e88605e-11a5-4eb5-9b85-81bfed4301da', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f0113aff-46dc-4787-8064-ffab9ef3092c', 'e4bcfcd4-9255-495b-98dd-a34a84f71969', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3ba98458-bf49-4aef-99b9-e8cfad1df2ac', 'e4bcfcd4-9255-495b-98dd-a34a84f71969', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c3eb5b8b-db0a-4ac5-a15b-1f158f6de00d', 'e4bcfcd4-9255-495b-98dd-a34a84f71969', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('08e912c6-3fe0-43a7-81d9-a5aea342fb2f', '48899330-342e-469b-bf47-ff57ddbca81c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('86b5e39f-0eb0-4984-a169-8f21161afdfc', '48899330-342e-469b-bf47-ff57ddbca81c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4ae8884e-7b42-411e-a956-84de58fe64d8', '48899330-342e-469b-bf47-ff57ddbca81c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ac87a7dd-0cbc-41f2-97ed-2b2800496d45', '1b94519e-11bd-4c01-898d-62612aaa1950', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c5323eef-9471-4a20-8638-5276f77bf294', '1b94519e-11bd-4c01-898d-62612aaa1950', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e75c1db6-7c9c-4c41-b996-34cdbdd36ae1', '1b94519e-11bd-4c01-898d-62612aaa1950', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('318ae97a-1d96-4cee-9560-f574f2cba353', '29d4e969-5555-4c19-8e51-1a46e0d22bf3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f533439c-d61f-48b3-8096-0ea5588804ce', '29d4e969-5555-4c19-8e51-1a46e0d22bf3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('dc9474f6-0e5d-428e-87a0-c5e409985e9a', '29d4e969-5555-4c19-8e51-1a46e0d22bf3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('441a2fe8-bb9f-48fd-845f-4ff6780c2c84', '6d53890e-7218-4985-bc06-7e272dfe8228', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8f4105a2-274d-4576-a64f-eb9d143f3b3b', '6d53890e-7218-4985-bc06-7e272dfe8228', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('41895e6b-39b2-426e-a298-d01c25cafa8c', '6d53890e-7218-4985-bc06-7e272dfe8228', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2345ce15-3149-4b56-93c0-447c0a9ce900', '16781866-ae04-4eb7-9a90-7054c0aec6ca', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('da38ebc6-1dac-4812-bb6c-1358c1c0578c', '16781866-ae04-4eb7-9a90-7054c0aec6ca', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('46f7f89f-5ebd-4d2f-89ad-c8e86b10ef1b', '16781866-ae04-4eb7-9a90-7054c0aec6ca', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('492714db-f74d-43fa-8b76-8b92d69fce61', '99951b38-5fd2-4dc8-b5f4-14b90fa96814', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1e639c08-e8db-443d-8de6-b3768cf9fb19', '99951b38-5fd2-4dc8-b5f4-14b90fa96814', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e9ff6246-72f6-4f58-bc26-1034d279bd81', '99951b38-5fd2-4dc8-b5f4-14b90fa96814', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d507f629-5128-4e1e-8a3c-3b829b22ad03', '994d7d6f-f588-483f-b841-0c0a000f23f4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d3006b7c-a710-49bd-a961-7957e6b8974c', '994d7d6f-f588-483f-b841-0c0a000f23f4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b8071738-4904-4ba8-bbc9-c40264c1a8a0', '994d7d6f-f588-483f-b841-0c0a000f23f4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('934aa623-07c5-4d9a-bb0e-bc2c19272940', '31ca292d-81f4-4721-9089-94b7eca81076', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e5592b71-e451-4fc7-b24a-16affdfe1db3', '31ca292d-81f4-4721-9089-94b7eca81076', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8bd87a65-870b-4347-8ba4-9d4f1a98140d', '31ca292d-81f4-4721-9089-94b7eca81076', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('13e26e3d-e336-44d0-ac17-f37db0cfff58', '9d7e79d2-a71f-4347-8170-fb6333581a14', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3d7e8a58-3f87-475f-94d4-6f9fb382bbd7', '9d7e79d2-a71f-4347-8170-fb6333581a14', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('017299c7-7a35-465c-8e5a-f26a0967a1c4', '9d7e79d2-a71f-4347-8170-fb6333581a14', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a48c92da-851c-4b7c-8724-8e2aa922b4fd', 'ae5acda2-4be1-4781-a0cd-90eb8d2305f6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d40c945a-8b3c-4a4a-bc8b-2ab6f221dda2', 'ae5acda2-4be1-4781-a0cd-90eb8d2305f6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fd476429-58b2-4a9d-93a1-450061b107f2', 'ae5acda2-4be1-4781-a0cd-90eb8d2305f6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('32fd0877-4a19-4c3a-9c8c-d308d5dfc689', '21a7d6e6-4ddd-4d83-9803-3999ba23c61e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8d2bb9b2-0247-4029-bdfc-9409e74f1ab7', '21a7d6e6-4ddd-4d83-9803-3999ba23c61e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5f52c760-303f-4372-a5d7-e8958bffbcd1', '21a7d6e6-4ddd-4d83-9803-3999ba23c61e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c5537072-8408-4579-9ab4-dcbc28e38534', '178d8426-58ab-4ea8-ac82-294060d33b29', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('733af600-f5c4-45a4-8b52-a3682db3b999', '178d8426-58ab-4ea8-ac82-294060d33b29', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3cab38f7-62c8-4b28-b002-f03acea38ada', '178d8426-58ab-4ea8-ac82-294060d33b29', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('42c0742c-ba9d-4bf4-ad12-c793d372793a', 'eb654053-c390-4fce-a92f-3afc45309b04', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c4c3ab0c-2478-42de-82eb-e7a2306ba5a7', 'eb654053-c390-4fce-a92f-3afc45309b04', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d0a252e9-81f7-4521-bd1c-f26d698db26c', 'eb654053-c390-4fce-a92f-3afc45309b04', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b488c1a0-e7f2-4095-8599-4db3592a7411', '7dc1ceea-39d7-4ba0-aaf2-140c991901f2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('931636ef-abb4-44cb-8bb3-e5c9be4daad3', '7dc1ceea-39d7-4ba0-aaf2-140c991901f2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1e4fc874-e9cb-40f5-89f2-e1cdf2a33cfb', '7dc1ceea-39d7-4ba0-aaf2-140c991901f2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6986eb7d-1d05-4b56-89ae-fa1f6675afa0', '69e7317f-ec84-4ca7-b76f-2f3232a85829', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ffcabbe9-1371-423a-aaf2-6090a9a236a9', '69e7317f-ec84-4ca7-b76f-2f3232a85829', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('03b604b1-54bf-41c6-9087-978293afae4c', '69e7317f-ec84-4ca7-b76f-2f3232a85829', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2f4b86a1-554a-4b5d-b0a0-552ee3e735db', 'c9e193d4-bca2-42ad-9638-24ad8a81480f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3c2e2326-bc52-4303-9a5a-85d1293e081a', 'c9e193d4-bca2-42ad-9638-24ad8a81480f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('978fe099-eb09-41d1-b781-818f291da427', 'c9e193d4-bca2-42ad-9638-24ad8a81480f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d16087b3-10d3-4c5c-acfa-f0e4669c1c45', '9e897fc0-4ca0-4c19-a298-bada3e188dc0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1ab26cef-6779-47da-a854-242ae4d39833', '9e897fc0-4ca0-4c19-a298-bada3e188dc0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4b43bde7-c125-4b46-bf26-1ced70c6d5ec', 'ae297dc3-f8cd-46f2-a3a0-4e0d6846cae2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dfbe24b7-4a15-4056-91da-e10253cc78c8', 'ae297dc3-f8cd-46f2-a3a0-4e0d6846cae2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9c0b9c3b-23e2-410f-940e-512f0105b1ef', 'ae297dc3-f8cd-46f2-a3a0-4e0d6846cae2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dd437280-1068-48b7-bd52-5b13bc6dc3f5', 'f1dde4c1-08ee-4673-954b-613ceeabfde7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('28f1542f-a35a-4c31-bbfe-bd9605c13a9a', 'f1dde4c1-08ee-4673-954b-613ceeabfde7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('da4f9f96-c593-4c6c-8073-66cabfa03f6b', '56ad48d3-446f-4018-b6cf-16dc7909b899', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c13e79db-6189-4e9d-9a84-359c65452729', '56ad48d3-446f-4018-b6cf-16dc7909b899', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9c3f60f2-3dec-4d94-ac8c-79f3af54e479', '56ad48d3-446f-4018-b6cf-16dc7909b899', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('019e3cdb-ed4a-441c-bc4d-9a4b46a6e30b', 'effdcd13-1723-4e48-a950-6a8e8713d35f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5ed00d24-501c-4afe-83e4-29265232ecbc', 'effdcd13-1723-4e48-a950-6a8e8713d35f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0ae01cb8-bbd2-43c5-9bf1-3b37f67f1f13', 'effdcd13-1723-4e48-a950-6a8e8713d35f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('216bc58d-a961-4663-afed-1e7fc425065c', 'a82625ea-4dc6-40b0-bbbb-b99056ac3e2c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ea984a5c-58b4-4b63-a07d-239764bd655c', 'a82625ea-4dc6-40b0-bbbb-b99056ac3e2c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('60bc6382-f6de-43ee-8d0e-f0fb5b65b075', 'a82625ea-4dc6-40b0-bbbb-b99056ac3e2c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e0016742-1c42-4735-bdd6-fdb3529fa597', '6c73538f-781a-4077-8dfd-cfdc0a2409c1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f9131b76-d272-4f3e-81f9-2bad9a46cd1c', '6c73538f-781a-4077-8dfd-cfdc0a2409c1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3f1c61eb-3311-48af-85c3-3438f12c66ac', '6c73538f-781a-4077-8dfd-cfdc0a2409c1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5db193c0-335b-4368-8092-1f514dfb472f', '8aec40d5-9db8-4eed-8b79-8b81534f3107', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d93c406c-e757-4ca4-8c32-045ddc05820b', '8aec40d5-9db8-4eed-8b79-8b81534f3107', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ba2d8aa2-6225-4720-8443-653ed41eabab', '8aec40d5-9db8-4eed-8b79-8b81534f3107', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('53140c04-f17e-4b95-940b-f209a36b402b', '7e6e211c-5a3c-40a6-8154-1af337f67f15', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e63fc2f4-3d37-406c-894c-798b85cb225a', '7e6e211c-5a3c-40a6-8154-1af337f67f15', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('441f968c-b038-40bc-815e-f87fc6a43dc6', '7e6e211c-5a3c-40a6-8154-1af337f67f15', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0a9fffe0-9ae4-4b7d-904a-fdd83f1f095a', '609d9a2e-eb99-49b4-95dd-07f10fb60adc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4123273b-9667-494c-8e10-192bdf2009f9', '609d9a2e-eb99-49b4-95dd-07f10fb60adc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fdca4a10-1307-46ff-bb09-14985a9fb959', '609d9a2e-eb99-49b4-95dd-07f10fb60adc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bfd5d05e-0c45-4523-b0df-f417512109aa', '76a7a609-16cd-4448-917b-0e8bf458031a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8fd3f0b6-0916-42c7-8d92-918d90947b63', '76a7a609-16cd-4448-917b-0e8bf458031a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('15f33bb4-c4fa-4ce7-b818-9a981adc38ca', '76a7a609-16cd-4448-917b-0e8bf458031a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('25cf6b41-90de-4e6f-8c02-fc148ca69cfb', '7c6d2d3b-efb0-453b-9994-7e7e6b182586', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2e3c7b4d-6dd2-40ee-8f9b-b391cedc9cb9', '7c6d2d3b-efb0-453b-9994-7e7e6b182586', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('252c3604-7338-4c08-93ed-88b64ad05f1f', '7c6d2d3b-efb0-453b-9994-7e7e6b182586', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('aa20e66e-30b1-4d3d-bb8f-8641074bff95', 'd82ebeb0-34ee-4fd2-a24a-ed60cfb6800e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fe3e713f-030f-4628-8800-0e406bf7bdac', 'd82ebeb0-34ee-4fd2-a24a-ed60cfb6800e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('621cd4ee-a122-4e79-b9c0-797bee651587', 'd82ebeb0-34ee-4fd2-a24a-ed60cfb6800e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('14af11a3-8705-431f-ad6a-ec362ea3f075', '311e8849-e9ea-45a3-a0c6-f7fe481ed9d3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4bbc5ba4-24b3-4e95-a44f-cb5555232648', '311e8849-e9ea-45a3-a0c6-f7fe481ed9d3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('10b89e67-eaab-4245-978d-78c58701f7f2', '311e8849-e9ea-45a3-a0c6-f7fe481ed9d3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9fd9e838-5c4b-4d68-9761-3a86c3cac884', '1aafd75b-996d-4fa6-ae7a-61e2ca5a1a16', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('faa5db4a-2418-4ee4-ac95-978f85698951', '1aafd75b-996d-4fa6-ae7a-61e2ca5a1a16', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8ed5d904-194e-43c2-a58f-48077ed0c897', '1aafd75b-996d-4fa6-ae7a-61e2ca5a1a16', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc0afd4f-2035-4f10-a22a-67a851070e81', '746a6936-3571-4537-9de3-14bad5f2e3ab', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e788b4c0-00c9-416b-9bae-3b4488017fdd', '746a6936-3571-4537-9de3-14bad5f2e3ab', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0b054adb-d03e-48e2-814f-a9bc65ffebd6', '746a6936-3571-4537-9de3-14bad5f2e3ab', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fe7551ae-64f1-446e-9e31-7e7a55662c32', '90c15136-6f91-47dd-8c76-72c838ea2074', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0d7fc07a-397f-4f11-b1fb-c8373169e879', '90c15136-6f91-47dd-8c76-72c838ea2074', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d6b255cb-380f-44a2-a089-752a55263760', '90c15136-6f91-47dd-8c76-72c838ea2074', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b1d44fdf-333c-480a-968a-45a0f4f8d48e', '6042fabc-3b40-4d6c-816a-a6410ed31e77', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eeb75d27-bf05-4d0e-84c3-c706b2db98e6', '6042fabc-3b40-4d6c-816a-a6410ed31e77', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2d0ba575-c7a5-4889-b265-8cf780771b18', '6042fabc-3b40-4d6c-816a-a6410ed31e77', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4e7f1ee1-8cb2-48b5-8580-e6ad7cbf720a', '17186283-d204-4603-a77c-e74ac179a75a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ef9d58fc-0cb1-45e1-9bdb-be6b8b9a753c', '17186283-d204-4603-a77c-e74ac179a75a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0bbb3b6f-16f5-435e-a4d4-0b31736c0838', '55a71f86-aa5c-474c-82d4-6f8f6263940e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('35bf5840-250e-4c82-b6e4-57378ab598f8', '55a71f86-aa5c-474c-82d4-6f8f6263940e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5d2c7ac7-5fb7-442d-9f10-36d36860f8ac', '55a71f86-aa5c-474c-82d4-6f8f6263940e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b0503e6f-face-42ee-914d-5f95bb946f03', '0c2499ff-538c-40da-a4ff-218a7a9de4d2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('022e475a-8c78-4087-b409-f25c2b1969f9', '0c2499ff-538c-40da-a4ff-218a7a9de4d2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3bcc1a54-4619-4eab-9e11-dc1ff18bd125', '0c2499ff-538c-40da-a4ff-218a7a9de4d2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a1a41b42-a7fe-4d4b-bdd3-aedd6c979eb2', 'fe57cf5a-e9f8-4b70-afb4-7647269872e7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6d34d6f0-b163-4d0f-8bc3-016cbe95804c', 'fe57cf5a-e9f8-4b70-afb4-7647269872e7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f0487a90-7ad0-42f3-a1cf-958a2244e6e8', 'fe57cf5a-e9f8-4b70-afb4-7647269872e7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6c5e7fa0-06a1-49aa-b7f0-7ba182f6506c', '055a00da-c8c2-4b77-9842-91c10ded357c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0dbdc376-0692-4d78-a2bf-73e68fa92409', '055a00da-c8c2-4b77-9842-91c10ded357c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b22a43fd-d830-428c-85ca-f0b701dfbc5d', '055a00da-c8c2-4b77-9842-91c10ded357c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('52a4608c-0d9c-46b8-9495-76b872d4d763', '87d6ac13-bdc6-4c01-a971-ed0c505bb841', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e2267e5f-6996-4100-8506-d9900ebb2ad0', '87d6ac13-bdc6-4c01-a971-ed0c505bb841', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8579eb0a-427f-4d3c-b1fa-eed42678838e', '6b7f404f-b707-4623-95d1-bfa09f6501fb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bd294153-8532-455d-8633-1f65e54fd3ae', '6b7f404f-b707-4623-95d1-bfa09f6501fb', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('43244c00-f967-428f-8b33-c651aa84300c', '6b7f404f-b707-4623-95d1-bfa09f6501fb', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b41f2a11-623a-492b-a818-02370ce5223e', '25edf5a2-3f15-4074-ab6c-4d5111d3ae4d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('78e61fec-c99b-44fe-bbbc-4a0432f0346d', '25edf5a2-3f15-4074-ab6c-4d5111d3ae4d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2d4b1227-ba50-42d4-b28a-39eb81241b11', '25edf5a2-3f15-4074-ab6c-4d5111d3ae4d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3f780478-c524-4f4d-a0da-9ecf15fe738e', 'fe14c26d-bbed-4d2e-b816-417d3cb78418', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a5166141-ae1a-4fb6-893b-a0741af682a3', 'fe14c26d-bbed-4d2e-b816-417d3cb78418', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e36aa7ff-5a98-4c27-8a1d-12476263c636', 'fe14c26d-bbed-4d2e-b816-417d3cb78418', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('81dccf73-3ff7-46dd-b9e6-6b4e1f7cd307', '41cada90-2813-4f6e-abef-f178d5f4425a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c37cf381-321e-4cac-8324-bd4da4fca800', '41cada90-2813-4f6e-abef-f178d5f4425a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ec2ec7cc-52e2-43c1-b67e-0ed68a68d11f', '41cada90-2813-4f6e-abef-f178d5f4425a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a172a0ba-c75a-4639-bc7e-bda0e7570232', 'd119acb8-a9e2-41af-9711-459c0088ac49', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('352dffc7-ef26-414d-ac0d-ee985738bb41', 'd119acb8-a9e2-41af-9711-459c0088ac49', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('910c9fba-c41f-48f9-944f-2d0f182c6ba8', 'd119acb8-a9e2-41af-9711-459c0088ac49', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8d17d11f-7955-4e86-977a-92d545528c10', '1fd3dda8-59a7-4b9d-8c44-670938018c95', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('151426d2-ceb8-43d5-b5ca-342d399c10fc', '1fd3dda8-59a7-4b9d-8c44-670938018c95', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6f17fc83-41b9-46a7-8782-92af448be7fe', '1fd3dda8-59a7-4b9d-8c44-670938018c95', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1903297b-0d5d-4776-9765-2852adc90d93', '9e4b5bb5-afa7-4f61-8050-b411b29fcae7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eb2d94b6-d90a-49e0-871e-ff4c898de3ac', '9e4b5bb5-afa7-4f61-8050-b411b29fcae7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('02f9f43e-ee1d-4065-bc42-7b6ed3887cef', '9e4b5bb5-afa7-4f61-8050-b411b29fcae7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fb3f93ca-6ed7-401d-8e87-ca838799de6f', 'fa44347e-8a45-4260-980e-23ff6747ff47', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c462dda7-5cc1-4b7a-8f4a-78a66f9fcd57', 'fa44347e-8a45-4260-980e-23ff6747ff47', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('000a5e64-04f5-438a-b26f-7f9ce3aa2509', 'fa44347e-8a45-4260-980e-23ff6747ff47', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('37926c08-7b0e-44de-963f-1a4560abb23e', '91175a00-0a3c-48b8-96cc-5671c62c6c90', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f085ff4d-ff0d-45d3-b04f-88382f9958d6', '91175a00-0a3c-48b8-96cc-5671c62c6c90', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('cb2870c0-477b-44eb-b512-dd96c5e6fa5e', '91175a00-0a3c-48b8-96cc-5671c62c6c90', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('821d273a-9698-46a5-8fd1-0dd2ad4f0c58', '45b30c91-51ac-4862-b6e7-e8de5a74cd69', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('214bdef3-72df-4f64-872c-634e1eeb6f69', '45b30c91-51ac-4862-b6e7-e8de5a74cd69', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('469018b6-b679-4e4b-b9f8-032316f94571', '45b30c91-51ac-4862-b6e7-e8de5a74cd69', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c127cc6f-bae4-4b75-8df0-81ee4380c5c3', '836027fe-20f6-4aca-bab9-ed6f5d6c189f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2dfd84d0-da2e-46f4-9972-bf2c984248c2', '836027fe-20f6-4aca-bab9-ed6f5d6c189f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e1b10c06-32ff-46d2-af98-530c8e6cb818', '836027fe-20f6-4aca-bab9-ed6f5d6c189f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2b57c284-9126-4261-889d-2ada4bc9b645', '3bca4e9c-4a9c-4edd-bf50-c3595d17a7ad', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1af98922-7e78-425e-b876-413f679ea049', '3bca4e9c-4a9c-4edd-bf50-c3595d17a7ad', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('abf6c742-63d6-4ef4-9789-538cbfdef994', '3bca4e9c-4a9c-4edd-bf50-c3595d17a7ad', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2e5a56fc-7809-491d-a3e9-cf8b4d38c79e', 'c3d52949-ad74-49d4-9b81-865260426762', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ac6fa3a7-e978-41be-a236-6ae274dfa9a2', 'c3d52949-ad74-49d4-9b81-865260426762', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('98babc57-e8a7-41c9-9966-2b3b21c79ab5', 'c3d52949-ad74-49d4-9b81-865260426762', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5aa95eeb-0458-4561-a384-cc9a47142803', '4260e2d0-59fd-4fda-a3f8-9610810242bf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9c9667a2-1d0b-4d6e-841f-99f82a0d85c3', '4260e2d0-59fd-4fda-a3f8-9610810242bf', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('dd091aa7-a15c-4024-9e47-4e3170a0937b', '4260e2d0-59fd-4fda-a3f8-9610810242bf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4f675ef8-db69-4c1d-8dfa-2fd00216d37f', 'b4b6a641-a4db-4e2c-bcc3-34e86e26c00d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c6c61ae2-5756-480b-8fd3-c6b669bc082b', 'b4b6a641-a4db-4e2c-bcc3-34e86e26c00d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d6d6f3c7-8650-4770-98f1-155bdbca2f6c', 'b4b6a641-a4db-4e2c-bcc3-34e86e26c00d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ef7556cb-cb1e-400d-9317-8cc6c7e556be', 'a102ec9a-0399-4242-a16c-284d39eeadc1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0fb6bf0e-ce8a-4f44-9285-b83c6fc5d1dd', 'a102ec9a-0399-4242-a16c-284d39eeadc1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d7c11f09-825b-4c93-a142-57cc436178c2', '9402a819-ca67-4df8-9a99-a7f4adc2f71e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a8432935-a7f1-404f-b7c0-e451126c15a9', '9402a819-ca67-4df8-9a99-a7f4adc2f71e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d40da43a-b2df-4693-b383-700055b95d8d', '9402a819-ca67-4df8-9a99-a7f4adc2f71e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('617d9865-7c87-4370-bab6-8382525946b4', '0ec4e4cc-3de9-4863-b6c0-0a9606bb742a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9cb76172-7e0a-4e56-a9fe-6877304f0925', '0ec4e4cc-3de9-4863-b6c0-0a9606bb742a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1d3c9989-1d23-4afd-b178-0a4737cb95e6', '0ec4e4cc-3de9-4863-b6c0-0a9606bb742a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('361f6620-617b-4f42-9ce8-591e2dd5418f', 'fbd410e2-bd8c-4adb-95b0-2bf07f485cba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7d47b4c2-2ab0-4da4-a02d-32643f497061', 'fbd410e2-bd8c-4adb-95b0-2bf07f485cba', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('86fd398b-edaf-47e8-a743-75c1354e1601', 'fbd410e2-bd8c-4adb-95b0-2bf07f485cba', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b4959b5f-d8b5-481d-b762-ed56cee8ad63', '77f6dd2d-77c6-483a-af69-7ef6544552e1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e7f92c29-3da4-401f-bd00-64ffb2a97531', '77f6dd2d-77c6-483a-af69-7ef6544552e1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('314353bf-e05f-409a-892a-d3a87e041f45', '77f6dd2d-77c6-483a-af69-7ef6544552e1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('84e6b72b-6dd6-44c3-8904-cdab97138db7', '773ae234-1c9e-46eb-829d-09dfe046e24b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('010e2527-14ea-4e2d-9ace-2de8f13f7739', '773ae234-1c9e-46eb-829d-09dfe046e24b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('67991412-0edf-4313-9097-91d146301e7f', '773ae234-1c9e-46eb-829d-09dfe046e24b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8d08f99b-d281-41dc-bd2b-11acd1e3ad0c', '773ae234-1c9e-46eb-829d-09dfe046e24b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('8472179a-6993-4603-baf3-4f73f6590c64', '4f8613d0-9602-4989-87da-27d961041789', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e77546c7-3475-4613-84c3-b1667aefce92', '4f8613d0-9602-4989-87da-27d961041789', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6b264142-1174-4b2d-95e9-181bfde2274a', '4f8613d0-9602-4989-87da-27d961041789', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c056d79c-4e6f-487c-9cfc-a419dc118be0', '61b6eed0-b3d1-4bf5-943a-5ef6742c675b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c6bab09f-e45c-4ee7-bcfa-e4734b053d79', '61b6eed0-b3d1-4bf5-943a-5ef6742c675b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7187c4f6-a340-4490-8eea-8fa41a097d16', '61b6eed0-b3d1-4bf5-943a-5ef6742c675b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fa391f25-e2f2-4a32-85e5-82248f87c620', '17b4c285-bdfe-4732-8c6e-c5ec636821e5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('863cc78b-4c13-48b9-a3b9-ac0957313d3f', '17b4c285-bdfe-4732-8c6e-c5ec636821e5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7a6bc65a-f8fb-4a88-9c5b-50e278c2f1d4', '17b4c285-bdfe-4732-8c6e-c5ec636821e5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fcf7e217-8616-4f89-bd03-c12f64d9bd79', '2b469019-0162-45a0-a76d-4609a799656e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3618f9fa-4f6c-46e4-8431-c2eb9ee933fa', '2b469019-0162-45a0-a76d-4609a799656e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b690d49e-b191-49cb-a2b8-38fa75e793ac', '2b469019-0162-45a0-a76d-4609a799656e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5d4450b0-1f69-4f6a-b368-2f05bdba766e', 'c2e739ec-3649-4cea-84a5-b3ff77fdcfd5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f880bb1b-1089-419f-b375-73f842d95867', 'c2e739ec-3649-4cea-84a5-b3ff77fdcfd5', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('358a35d1-ca2b-4596-851c-73b672d7682c', 'c2e739ec-3649-4cea-84a5-b3ff77fdcfd5', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fbea5ca4-ea32-4bb9-95a2-780548841f35', '2570fb35-8719-45b5-b611-63e4dff907f4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ac2c00d4-36cb-4700-8d94-4ecfc69562c0', '2570fb35-8719-45b5-b611-63e4dff907f4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('217eece1-7d3c-47d2-986a-fb69d090a015', '2570fb35-8719-45b5-b611-63e4dff907f4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4fd6e533-79fe-4347-9c84-3a031eab44cb', '9d735db1-f12b-48d7-a3bd-edbd8a9d24b6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ae726c29-aa62-45ea-bc1b-abac8a0cc650', '9d735db1-f12b-48d7-a3bd-edbd8a9d24b6', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('edcadab2-3a89-4915-a81d-61bbb715897d', '9d735db1-f12b-48d7-a3bd-edbd8a9d24b6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f9f34b7b-1d11-4e1d-a702-d61eae0e7ee6', '91d6dfca-64cf-4b19-bc47-b6c26bcdfabe', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1501872e-2fa0-4614-8d91-bed019be6e0d', '91d6dfca-64cf-4b19-bc47-b6c26bcdfabe', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7edb9db5-ae03-4e75-a82e-3f5d3d134eff', '91d6dfca-64cf-4b19-bc47-b6c26bcdfabe', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('be93fe13-cbba-4d59-a2b7-cb27601e68d9', '28e4e0f1-9b9e-43af-a67f-60081c25f7b4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e3f1df4e-256a-405d-b3e6-7e789a179555', '28e4e0f1-9b9e-43af-a67f-60081c25f7b4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('979250ff-a913-40f6-8422-1c0fbe2ad0c4', '28e4e0f1-9b9e-43af-a67f-60081c25f7b4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('028a6487-e5b2-4940-8d12-46d796592f8e', 'd4584e25-8f4c-4105-8ba6-a2af2642c476', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('19dd4f69-dee1-4d4a-9613-561d9a528738', 'd4584e25-8f4c-4105-8ba6-a2af2642c476', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4c0b192d-9f7c-4110-b78f-f3b79738de98', 'd4584e25-8f4c-4105-8ba6-a2af2642c476', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d4cd0ce4-1336-4ca2-9b4f-2e8ff262f75b', '6b63134d-91f4-4c34-8d05-6b21a2c0e150', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('dbf31c80-2d47-4885-a28e-dcf8ccea065d', '6b63134d-91f4-4c34-8d05-6b21a2c0e150', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b7e94030-eda9-4ed3-a476-e571bf60eda0', '6b63134d-91f4-4c34-8d05-6b21a2c0e150', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ac4e5050-d191-49fa-bd5e-a1042b8230a7', '5f4b7c3f-9c5c-4f43-a113-acb03eda0e39', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('51a59bc5-807e-43b1-b7f6-dd461b00d600', '5f4b7c3f-9c5c-4f43-a113-acb03eda0e39', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1ad235aa-149f-4a3b-bce1-f5b6f5b2830d', '5f4b7c3f-9c5c-4f43-a113-acb03eda0e39', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1fa37719-8a0d-4831-b293-f382506f71d5', '14310449-79c5-46cd-b1ab-5eb105de1ac4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d789d745-62a7-4de8-a231-ae01e0bdcd48', '14310449-79c5-46cd-b1ab-5eb105de1ac4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7d03d9a8-ecb8-4631-9b98-d1ee7a6a1b88', '14310449-79c5-46cd-b1ab-5eb105de1ac4', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e511d646-6f09-4560-b12f-afcf09bb2c13', '8e44acca-6a64-4732-89d2-3032b02366c4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2cb5d862-4759-4935-86aa-c90958d4b844', '8e44acca-6a64-4732-89d2-3032b02366c4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d5ba69a1-c5eb-4024-845e-5131cd73dcfc', '8e44acca-6a64-4732-89d2-3032b02366c4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('587a9ed2-32b5-4e2a-9ce7-c7856d5e0484', 'b7242c90-d4ac-43e5-974c-4b5f001e5b52', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('518c4770-8b2e-4453-b6e6-152d43c89edf', 'b7242c90-d4ac-43e5-974c-4b5f001e5b52', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bc273306-1ba3-4cec-9086-32bdd1734106', 'b7242c90-d4ac-43e5-974c-4b5f001e5b52', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cbc558d4-64b2-411d-98b0-5e5e8b4f6835', 'beb62132-ffad-4c77-b78f-46be76e70212', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('68e005b1-817c-4123-bdc6-64b727077e8c', 'beb62132-ffad-4c77-b78f-46be76e70212', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c9abe61d-400e-4bd8-84dc-dead6ee89d95', 'fa70347f-dfa8-4d99-990e-aecf207884b2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8619dc2f-168f-4c7b-8759-399c25e5a199', 'fa70347f-dfa8-4d99-990e-aecf207884b2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('071c5904-43fa-49ef-82a0-9da604e5d8c9', 'fa70347f-dfa8-4d99-990e-aecf207884b2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ea54196a-3d29-4a40-a760-15694365513c', '6a5f9bf6-77b8-4423-af5b-beb0fda87763', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('71efd181-c2e0-40dd-8197-307acb42c9d4', '6a5f9bf6-77b8-4423-af5b-beb0fda87763', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('70e15a42-f66a-4592-af62-cf16418e4a88', '6a5f9bf6-77b8-4423-af5b-beb0fda87763', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fe240ecb-3451-4115-9c57-fdf7ba031901', '91b4d85f-47b5-4bb1-b9e1-9c975f997059', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fe9f1fb4-1911-4357-9802-431399241cb9', '91b4d85f-47b5-4bb1-b9e1-9c975f997059', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('677b98d6-97ee-47b1-bf7c-26e121afa085', '91b4d85f-47b5-4bb1-b9e1-9c975f997059', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f738d42b-d9e6-488b-ab88-90cea75fc24b', '3120d694-7708-4863-b864-db8e0319de38', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2f1df11e-2c1b-4be6-8750-53c554feb69f', '3120d694-7708-4863-b864-db8e0319de38', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f30c55a4-003c-4cda-89c5-7415316a91c8', '3120d694-7708-4863-b864-db8e0319de38', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4d4d5521-64bb-4f30-9db1-c463f578a071', '6c4d2bc7-0aa6-443d-b8c1-5a86f4b0f0c7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4915cbbe-6439-4337-90cd-389e3488889b', '6c4d2bc7-0aa6-443d-b8c1-5a86f4b0f0c7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3f7e6bfe-30d0-4c1c-bc02-1866605c2575', '6c4d2bc7-0aa6-443d-b8c1-5a86f4b0f0c7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f86d17a2-c254-4f3f-af5f-9deeb82f7d6e', '6c4d2bc7-0aa6-443d-b8c1-5a86f4b0f0c7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('f5b56dc9-3ec2-4788-930d-b5e24ee404f5', '5647ea28-e5a5-4fba-8487-f7999590ddf6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ed8c90c7-ebc2-4dc1-84d2-2b2c38511672', '5647ea28-e5a5-4fba-8487-f7999590ddf6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('42f311b7-1d87-492c-b9b8-d20c3ea67369', '5647ea28-e5a5-4fba-8487-f7999590ddf6', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b6ee87c0-9c54-4a91-86f5-5af35a3c8517', '7a1f60f7-ca96-4a05-ba72-1001919a7381', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('304ced84-31cd-4cd6-8468-ed77e8f253c9', '7a1f60f7-ca96-4a05-ba72-1001919a7381', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('43034fe0-7c9d-4608-9ae1-9377f72bb6a4', '7a1f60f7-ca96-4a05-ba72-1001919a7381', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('26e0625b-fff9-4394-84a7-ddd26fa4af2d', '35da4804-12fa-48d4-ab53-92552139a372', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a3ff5295-94cf-4ce5-935e-a02290f58cbb', '35da4804-12fa-48d4-ab53-92552139a372', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('448cac3a-ec64-4da6-96aa-a59eb3a5d221', '35da4804-12fa-48d4-ab53-92552139a372', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0f86034d-e8bd-4274-a011-12ac58d6d6ae', '0dcdf1fb-e59e-449e-b740-f589b95eeb8d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2dc5fdf3-265c-4dca-be36-761f7521933d', '0dcdf1fb-e59e-449e-b740-f589b95eeb8d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('da8be9c1-116b-45df-9c5e-44ce01c66eab', '0dcdf1fb-e59e-449e-b740-f589b95eeb8d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('58cff41a-c556-44f3-96e7-714d6e5a0420', 'cc6f1d66-b52d-485f-bf4d-2b2feaaaedee', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f9cee834-6ad7-44d9-ae98-a6eed4d9459c', 'cc6f1d66-b52d-485f-bf4d-2b2feaaaedee', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('514c2cc3-9a22-44bd-96f5-4921092617cf', 'cc6f1d66-b52d-485f-bf4d-2b2feaaaedee', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c365a30a-6f62-4dbc-8b23-fcac0b7030f2', '9511bf04-9a0f-4be2-90cd-28277ed8ed06', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6231421b-99a4-4038-aa9c-907d178bbab7', '9511bf04-9a0f-4be2-90cd-28277ed8ed06', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8202bb3a-4f32-462e-9269-5f77a69e632d', '9511bf04-9a0f-4be2-90cd-28277ed8ed06', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c9cd4c55-8aff-45b1-949e-9abbe2c48b67', '44fd9bc1-1312-4733-a6bc-55e3894ea747', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9b9ee52f-c765-4f22-8e46-2d7ac6b43343', '44fd9bc1-1312-4733-a6bc-55e3894ea747', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fdc81b7c-c07a-4a6a-85a6-67033e2f59ec', '44fd9bc1-1312-4733-a6bc-55e3894ea747', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6070559d-e9ba-4f8d-a062-03d2b9486a91', '14c80b57-35a9-4d4f-b646-96a3b2d9eb4c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5814e78e-aff1-4285-a8d9-96854253b5b1', '14c80b57-35a9-4d4f-b646-96a3b2d9eb4c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('80b2a2c6-69b5-4f9c-94f4-a059c552f7d8', '14c80b57-35a9-4d4f-b646-96a3b2d9eb4c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2e6cf79c-6182-45d0-a380-5018e1f77199', 'a44346bf-7462-49e4-b192-fd9350f0157f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9fb01b45-525c-40fa-803b-9d3f0a0094ff', 'a44346bf-7462-49e4-b192-fd9350f0157f', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('68939b3b-bfc9-49b2-96ec-2178a7cbe812', 'a44346bf-7462-49e4-b192-fd9350f0157f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1f0f36b9-4abd-4e7c-9e50-ccb10d3a36dd', 'dd775c37-29e5-42f2-b6ce-2c77b401cf28', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('80107c22-c362-450a-9a65-99f4cf803e59', 'dd775c37-29e5-42f2-b6ce-2c77b401cf28', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f92cdc78-e3c9-409d-83b7-c4662961e570', 'dd775c37-29e5-42f2-b6ce-2c77b401cf28', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e1eb2024-583d-4db5-90f6-9359b42cc3f1', 'bc4ab38a-9b0f-4a67-988a-d6120bfff35e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('74d6664f-aac5-46c2-a614-007edfd7a8d3', 'bc4ab38a-9b0f-4a67-988a-d6120bfff35e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('171ace2e-7c93-4469-b205-6c1f5820165a', 'bc4ab38a-9b0f-4a67-988a-d6120bfff35e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('df04e422-51db-4145-aee4-bfa4e68437ad', '0e047dee-3f07-4a9b-9056-018b080d45a3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0b06c682-6b87-4f7d-9191-ca1523dcf024', '0e047dee-3f07-4a9b-9056-018b080d45a3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('911d87cc-838b-4c1f-9aac-8b95456cc93a', '0e047dee-3f07-4a9b-9056-018b080d45a3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('31fd3d6d-de3a-499f-aebb-01e8e377b3e2', '56ca57e7-82f7-44b6-8d62-c0f9190c2d7f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('82a14fb0-ef6e-4567-8d21-4fb2adcc3f36', '56ca57e7-82f7-44b6-8d62-c0f9190c2d7f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6b2ef9a9-781c-4f20-84b3-c027b04b2466', '56ca57e7-82f7-44b6-8d62-c0f9190c2d7f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bbd34de5-03bc-4e40-92af-228f81ed9b98', 'a78b6ead-d999-406a-b6e7-f352e8457ff4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4a424a56-b887-4079-9f88-a3e9b50497b9', 'a78b6ead-d999-406a-b6e7-f352e8457ff4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('99c2c6b8-626a-470b-b314-650883cbe2bd', 'a78b6ead-d999-406a-b6e7-f352e8457ff4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('582687f4-a8f6-4f63-acc8-a82cedd9ff39', '25612953-55e3-4949-93b8-c3f1e3520382', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e0709d21-4c51-43b7-8772-357ca31c4dde', '25612953-55e3-4949-93b8-c3f1e3520382', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('be55b5ce-7b2f-4cda-bde5-90eed664093d', '25612953-55e3-4949-93b8-c3f1e3520382', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c6a9cc05-4c72-445c-8990-bdb768de3708', 'a2142e65-25cf-46d3-a7e2-9c95d53e2071', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a00a0140-9958-4224-9aa9-ae664aa14245', 'a2142e65-25cf-46d3-a7e2-9c95d53e2071', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bfbde544-5866-4b97-94d2-c23dfe93ed18', 'bb1b1675-f8e1-4bc2-8bc6-5008150d0c78', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('049bf8e4-a187-44df-abcc-388dd211c14c', 'bb1b1675-f8e1-4bc2-8bc6-5008150d0c78', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('46264399-fde1-44b0-9d51-3ecda1f26af2', 'bb1b1675-f8e1-4bc2-8bc6-5008150d0c78', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d55e746a-8664-4f9b-bacf-2f6e92ff2515', 'e238960e-11ee-4ca3-a32f-f71b73c1d2e0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('85e9a93e-f3ee-4ca5-b960-9c5912d286ed', 'e238960e-11ee-4ca3-a32f-f71b73c1d2e0', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1bdd4d2a-7154-49e6-99ca-e28261924757', 'e238960e-11ee-4ca3-a32f-f71b73c1d2e0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('99d4c9bb-a7da-4b42-af86-021d6e1ad23b', '09fb7606-5167-4f97-9764-4946325f1a1e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f2bebbe3-8191-48e2-ade5-418c4ea5de21', '09fb7606-5167-4f97-9764-4946325f1a1e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('458ede91-72c4-421d-aa40-eeb3b3329f6c', '09fb7606-5167-4f97-9764-4946325f1a1e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b8ab0c90-4c3c-4a1f-b051-6ec30c01ae60', 'd81d82a9-cc1b-49e3-b27e-6f6bae5435c3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4ea86eae-ca7b-44d9-83e6-4efcf2ddcb81', 'd81d82a9-cc1b-49e3-b27e-6f6bae5435c3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('38744d0e-8fd6-4f9f-aa1e-dffad09a4e53', 'd81d82a9-cc1b-49e3-b27e-6f6bae5435c3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5cc2183c-5f49-4616-9d4e-fe77ee491ed2', 'd81d82a9-cc1b-49e3-b27e-6f6bae5435c3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('4f37b84a-744a-4f93-9295-a3b5c6ab84e6', '66f7bf28-6b6f-4792-a988-f961bacd4b36', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('939d7da4-9de5-42ea-9e72-2ed39c416c63', '66f7bf28-6b6f-4792-a988-f961bacd4b36', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('864d770b-e16a-44b8-a59e-bbd88dde73aa', '66f7bf28-6b6f-4792-a988-f961bacd4b36', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9819034c-ae84-4daf-93e3-5fbe48c89051', 'a4c345d0-eda9-4422-a96c-d924e78bd71b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('79b16d01-3718-4062-a824-a5d255a6de50', 'a4c345d0-eda9-4422-a96c-d924e78bd71b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('79c70d49-be71-4e72-82ff-c8caff1e98f0', 'a4c345d0-eda9-4422-a96c-d924e78bd71b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0e03df88-5e84-48f9-97b9-b791f822a8ef', '7691b4b9-e8bd-472f-87c4-d9d725458e53', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b4c8fff3-38db-49ca-89a2-00226e12cb65', '7691b4b9-e8bd-472f-87c4-d9d725458e53', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('80230596-ee61-421b-bdcd-9a3ea5cb4c0e', '7691b4b9-e8bd-472f-87c4-d9d725458e53', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1f26cfc6-c0fe-45da-aef5-22d397a036b3', '16d10fd7-c7e5-4942-b7b7-5b13d742395d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2cf6b6ec-399f-416e-8e54-41b793e08841', '16d10fd7-c7e5-4942-b7b7-5b13d742395d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b40fffcd-2f61-423e-a66b-e92cb2b5a990', '16d10fd7-c7e5-4942-b7b7-5b13d742395d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('da02ca6c-cd37-4ecc-851c-71c6dfc4d8e3', '998e9fda-9ebf-47dd-9a88-e4d741532110', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('69a84293-03e4-42b5-8d00-7e066fc0d0e9', '998e9fda-9ebf-47dd-9a88-e4d741532110', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7a1006e4-1255-4f33-8622-45d835b544bf', '998e9fda-9ebf-47dd-9a88-e4d741532110', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bad2271d-6de8-47ac-b683-4c821782b8ff', '3e494b9f-0000-4d9d-995e-ab609a4b62af', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('49dc7a39-30d2-415f-9b68-db74459f6937', '3e494b9f-0000-4d9d-995e-ab609a4b62af', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('50c7a22c-070f-4b6b-a96b-fcd82359bb2e', '3e494b9f-0000-4d9d-995e-ab609a4b62af', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a42584d6-26a1-445e-81ce-4254ff6f5aaa', '9d36cfcc-748d-4834-8a82-18559224a4ec', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a435190e-cbc3-4162-8097-107d2edff251', '9d36cfcc-748d-4834-8a82-18559224a4ec', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d62cca03-b3f2-4869-978f-0944501a82c4', '9d36cfcc-748d-4834-8a82-18559224a4ec', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('60f33e64-ab5e-483d-9ffc-78a02960a705', 'f31c4563-6b55-47b1-8a36-0b34172f3b7c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('51394812-567d-4d58-90e9-f5cb86ce430c', 'f31c4563-6b55-47b1-8a36-0b34172f3b7c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('de275c4a-970e-497f-b8e6-a1897fe8d094', 'f31c4563-6b55-47b1-8a36-0b34172f3b7c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d68a4e46-81c5-4e52-a0d9-41487a17aa74', '6a4aba41-27be-4ec2-ad32-28c204f00748', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c8b22ca2-c2ec-4620-990c-9b9bfd9b0320', '6a4aba41-27be-4ec2-ad32-28c204f00748', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9736b858-6879-495c-a476-c52b7ad869b8', '6a4aba41-27be-4ec2-ad32-28c204f00748', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('27a3f0f3-b729-4c2e-8aa0-367bf726ca3c', 'e43b77c6-41e9-4bff-b0af-b2ebf59b7419', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('854aa95a-961c-4ab7-bcc4-95251bd66520', 'e43b77c6-41e9-4bff-b0af-b2ebf59b7419', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d7f6b30e-3eb1-4f2c-9b71-287d438d8ba6', 'e43b77c6-41e9-4bff-b0af-b2ebf59b7419', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fee183e1-e1bc-433c-8ceb-be20f0753d50', '59898270-c707-4b25-9632-a391606f7457', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e31c1a8b-9aea-4741-92fc-233109a92b6e', '59898270-c707-4b25-9632-a391606f7457', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d8e8f0ef-1976-43fa-9adc-3d3f368236aa', '59898270-c707-4b25-9632-a391606f7457', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3354199d-f110-4172-a074-cd0d9b674579', 'd4d2eea4-b3c7-40e8-b67c-11b40d948b1e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('173a3663-c84a-452c-98df-f895e93a5c19', 'd4d2eea4-b3c7-40e8-b67c-11b40d948b1e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('44b8c66c-19e1-43b4-97a9-ae075b1e1e1d', 'd4d2eea4-b3c7-40e8-b67c-11b40d948b1e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('abf1750d-6281-4744-8408-13873e62643d', 'cde825ac-a907-4d20-a5a5-e744206c4555', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1cc46ad3-9f72-4834-9568-0cc82cec1a8e', 'cde825ac-a907-4d20-a5a5-e744206c4555', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('47ef663b-3595-40e3-9e2a-b2748d4de3ba', 'cde825ac-a907-4d20-a5a5-e744206c4555', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cd18d312-83aa-44d0-9428-41173637c165', '72ee09be-3d48-449d-a1de-eb7729c80f4e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4ec5b37b-425f-48be-bcba-19fe595481e3', '72ee09be-3d48-449d-a1de-eb7729c80f4e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('87d37f22-c469-4fe1-8e43-4bf4bdd7277e', '72ee09be-3d48-449d-a1de-eb7729c80f4e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('eacb84b1-8366-41f5-b0cf-2b742bac5f1e', 'bdbcea1b-553e-4c5f-9550-c1d1db2afa21', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d8c874ea-ddd4-4313-9fab-d119e24cedfd', 'bdbcea1b-553e-4c5f-9550-c1d1db2afa21', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d0ac7bf1-5edd-4004-80db-6e437b75a27b', 'bdbcea1b-553e-4c5f-9550-c1d1db2afa21', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c7835c8a-2e8f-47c9-9120-6ffe47b6e996', 'bcb926a8-7522-4c12-95e0-ec18cbd2c257', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cb0203ec-545f-42d2-a9ba-406acfe98751', 'bcb926a8-7522-4c12-95e0-ec18cbd2c257', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5a5eb6f5-6d5e-4f19-bd1a-5defc6eda767', 'bcb926a8-7522-4c12-95e0-ec18cbd2c257', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('390b60ea-704f-4c2b-a9bd-0a8a804ab2a0', '28e483fe-7b3f-4df4-b541-7bdaeae701e2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8df11e99-e693-4fee-9ffa-a798fe258c17', '28e483fe-7b3f-4df4-b541-7bdaeae701e2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d27e4294-fd85-47d3-82e4-fa9987079691', '65b03ed4-62f7-43d8-9b2d-cb360d81f9c6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('989bd09b-36f3-4649-9f76-f6375690abbb', '65b03ed4-62f7-43d8-9b2d-cb360d81f9c6', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b7663cb4-af5a-473f-b41b-4551c8f926b7', '65b03ed4-62f7-43d8-9b2d-cb360d81f9c6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6c0473da-2888-4eeb-a63f-cfe6e2619847', '0b5bbe80-44af-46c5-9f22-4cd42de544db', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f5a34a50-297c-40a2-bf1f-1e8100b1dbca', '0b5bbe80-44af-46c5-9f22-4cd42de544db', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('75ac7a28-6a63-4edd-8f98-7dda2be16000', '0b5bbe80-44af-46c5-9f22-4cd42de544db', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('edaede9e-18c2-41f9-9f1d-fb32038ddc36', '6bcc029d-7dc2-4da2-b843-f565f6978e29', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6a9e84ec-ead6-4ac1-8eac-7bd0ef100831', '6bcc029d-7dc2-4da2-b843-f565f6978e29', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('476484e1-cd37-41e9-9397-169e3c7ab92c', '6bcc029d-7dc2-4da2-b843-f565f6978e29', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e2289a14-8eec-47d2-9535-158836ad4ba5', '3e970179-77d6-438e-b1e2-b9fe5186f35c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bbe95938-e2cf-4c4d-a745-258fd1f8d01d', '3e970179-77d6-438e-b1e2-b9fe5186f35c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b1a5fbba-cb2a-4e2d-9e36-ecdb19c4a9da', '3e970179-77d6-438e-b1e2-b9fe5186f35c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('649ecd5b-a8ff-41a2-baa6-3a5e1de26a35', '3e970179-77d6-438e-b1e2-b9fe5186f35c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('9b32f93a-e397-4a9c-b06d-db70a5ee559a', '96d0ea5a-50e9-4913-b720-0ffdaca744db', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ec21398c-c23d-4c4d-800b-d9e7d2ffff80', '96d0ea5a-50e9-4913-b720-0ffdaca744db', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5ff87c55-5f25-45dd-a054-2ba39ff67842', '96d0ea5a-50e9-4913-b720-0ffdaca744db', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a614e4d6-141e-4ef0-bfeb-86ed6d6804e5', 'e58ee110-bbcd-4aa8-a937-9100f3317671', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('33bf439b-794d-43ae-841f-9f62c37b121e', 'e58ee110-bbcd-4aa8-a937-9100f3317671', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b3ea3bc3-8fc4-4c72-8586-417769a4ad22', 'e58ee110-bbcd-4aa8-a937-9100f3317671', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d95f869b-eda6-4ae4-9a57-06bb5e2bbb1e', 'cc6f36ff-3c0d-41ee-b9ef-c4856872a7b4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d8716435-883c-4fd8-b574-6b7d59ea7556', 'cc6f36ff-3c0d-41ee-b9ef-c4856872a7b4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bdb66d64-8b15-4adc-9006-704d849fc062', 'cc6f36ff-3c0d-41ee-b9ef-c4856872a7b4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('55eb69ad-a1a2-4b49-92d3-a82efb91d900', 'e63aed09-e985-4524-965e-994f4c809845', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a5722551-de6a-4e67-80ab-d7fb4910e98d', 'e63aed09-e985-4524-965e-994f4c809845', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3533eb97-c488-4d42-8a3c-60cfb2a58e30', 'e63aed09-e985-4524-965e-994f4c809845', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3be162f1-d7af-4ac2-b062-0f158138b22c', '973a35a4-8439-4321-8a51-3d4bc648ced8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4e50b2cc-0f14-47eb-9093-33f29875e613', '973a35a4-8439-4321-8a51-3d4bc648ced8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d4ef4529-0907-48b1-b449-63c44d5d55f4', '973a35a4-8439-4321-8a51-3d4bc648ced8', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('320fafdb-df48-4210-bf69-98245b894b78', '8dd3df63-84c7-4ad4-ae29-38ddcf4ac879', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1365a797-291a-40d0-bc08-543bd76eaae9', '8dd3df63-84c7-4ad4-ae29-38ddcf4ac879', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('467f6158-e03d-470c-a34f-91ca577d1183', '8dd3df63-84c7-4ad4-ae29-38ddcf4ac879', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('681ef809-1697-4d86-9d57-56bbcf1f8c1f', 'c2c743e5-9698-4f79-9692-021183298348', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('91cd86e2-7344-4eab-925d-0de1c6ce14d4', 'c2c743e5-9698-4f79-9692-021183298348', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('80cd9baa-bfe1-483c-be4d-bc4a868aec49', 'c2c743e5-9698-4f79-9692-021183298348', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('688fb118-6a0f-4909-b285-4fba78bd5395', '2eaf12e7-d4b2-4ed5-aae9-c5bdbf85bfbc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8f216006-5307-4d35-9539-7d415cc1b2ac', '2eaf12e7-d4b2-4ed5-aae9-c5bdbf85bfbc', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('906b6e48-0097-4390-bbe6-0e25f6894190', '2eaf12e7-d4b2-4ed5-aae9-c5bdbf85bfbc', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('27932973-7655-4d0f-9011-ea5cd541443e', '1aba759f-9827-49aa-a654-2c782836661c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('176c7845-3e55-463d-94fd-175613a7cdb9', '1aba759f-9827-49aa-a654-2c782836661c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8499a1a4-d019-45b0-9392-075480120207', '1aba759f-9827-49aa-a654-2c782836661c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('63355b71-2892-4e2b-ba82-e23922491d48', '4055eece-662a-481d-a4aa-1047e5567c02', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('91dba25e-d330-4fe6-8155-7d7492da5ce5', '4055eece-662a-481d-a4aa-1047e5567c02', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('65631e4c-0aa6-4dba-a426-8fd6f96cac1b', '4055eece-662a-481d-a4aa-1047e5567c02', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9d0ee8d7-caac-46c3-9b69-47732ff742cf', 'd24d1341-a56b-4f5b-b416-ac1b6809626e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d49cca59-b0b1-4223-9085-25978b1326d4', 'd24d1341-a56b-4f5b-b416-ac1b6809626e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e118a30b-4cd8-47f2-9b10-b276343cb6bd', 'd24d1341-a56b-4f5b-b416-ac1b6809626e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6cde20da-9527-430f-ba59-9fa7652daa79', 'e1222179-447f-4f33-b421-0af721af9e62', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5e047310-00e1-4532-a0e8-ceed59b34131', 'e1222179-447f-4f33-b421-0af721af9e62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('53f8b50a-26f0-477a-900b-266f17bc61bc', 'e1222179-447f-4f33-b421-0af721af9e62', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6ab122d9-e729-4990-8fbc-3c1644163524', '7e252708-764d-4579-b439-9b18ade74e39', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3b382a74-3e9d-47d0-a522-fa531296c54b', '7e252708-764d-4579-b439-9b18ade74e39', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3c1d43db-78e5-4f15-b516-33ce71a5a5f3', '7e252708-764d-4579-b439-9b18ade74e39', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fa4a97f4-51a5-45d6-bc0d-69e6fda34dd5', '44da2c9d-7fdc-42cc-aefd-7c499f5233c6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c7fd2ca6-2ad9-43fb-9098-ee67a467cd2b', '44da2c9d-7fdc-42cc-aefd-7c499f5233c6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9f582545-8d65-4c7f-9357-e821458c3d92', '44da2c9d-7fdc-42cc-aefd-7c499f5233c6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('52b235f0-4076-44d8-968f-5f1bbe1ab1f2', '6d19a615-efca-483e-8358-ac9c79748d38', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9f1ea137-cbb2-4a8a-96d1-37e06baeb18c', '6d19a615-efca-483e-8358-ac9c79748d38', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('552c7d09-f82e-4e8d-92d9-e4e3cf707632', '6d19a615-efca-483e-8358-ac9c79748d38', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3f8d450d-667c-4d69-a0ee-5a974c1e7c42', '777dce02-8896-4e77-819c-86c3c5ea27c1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('69352b96-e9a2-4c23-b1b4-e18c1f8ee9e4', '777dce02-8896-4e77-819c-86c3c5ea27c1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('970a5fa9-16de-41bf-98e3-2bac26218904', '777dce02-8896-4e77-819c-86c3c5ea27c1', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3359670a-569c-48b5-a296-1b37e42644d5', '1a6d8ea8-305c-4bce-bf5f-8fb6a65f328f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a80ece3a-b4e4-4412-be73-20593947b5c2', '1a6d8ea8-305c-4bce-bf5f-8fb6a65f328f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4b12f744-b17b-49fb-9284-1f0e38743be7', '4872b89f-973d-487d-8041-2d82a487d256', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('716c181f-454a-4926-9bef-1c26802f0830', '4872b89f-973d-487d-8041-2d82a487d256', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ba316b36-da73-4092-935e-133ae0c872b5', '4872b89f-973d-487d-8041-2d82a487d256', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2bee6bf6-fc03-4c85-aef7-9a3722f85f07', '18cb2ffd-a7b0-4899-af73-c66201fc4f82', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('68e92043-c06d-42ff-82d9-ba74a14d3c6d', '18cb2ffd-a7b0-4899-af73-c66201fc4f82', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('041103d7-0e5c-4dc4-89ca-38dc6cfe97a3', '18cb2ffd-a7b0-4899-af73-c66201fc4f82', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('16a1b110-df5f-454b-8290-6a9f14108e8f', 'c004d318-f4db-48c8-963a-91577a994043', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ef45489b-307f-4d15-9f6a-81911390ebfc', 'c004d318-f4db-48c8-963a-91577a994043', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8f11731f-d4d5-4f7b-b1c0-d3ab764a412a', 'c004d318-f4db-48c8-963a-91577a994043', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c15995e8-2d48-4ed4-a972-22624a03057c', 'e7e38322-fe5a-4c79-9280-f9158d7af380', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('271704fd-555f-4ffc-992a-cd58b1d6c07f', 'e7e38322-fe5a-4c79-9280-f9158d7af380', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c9d9c5f7-9839-4f7b-b70a-a66327d8f49c', 'e7e38322-fe5a-4c79-9280-f9158d7af380', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc513871-21bf-484d-b164-bb697dcfa0cc', 'f89ee160-d99d-4c3f-95fd-975c25523f69', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6c966ded-ba66-43b4-9861-da171ff6ee2b', 'f89ee160-d99d-4c3f-95fd-975c25523f69', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0c2eda2b-1705-4618-b38b-f4d552928912', 'f89ee160-d99d-4c3f-95fd-975c25523f69', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('62eae5fb-a01c-4e70-9b69-27ca6dd8c15c', '6c9f13da-a6f4-4498-aeaa-6107f0769cf4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6f88d27c-dc5f-422a-8904-725f221dcdcc', '6c9f13da-a6f4-4498-aeaa-6107f0769cf4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('31ca6687-ce71-4cff-a76e-3d9c25266963', '6c9f13da-a6f4-4498-aeaa-6107f0769cf4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('2c2706e4-1697-4bbd-aa33-ec55a507ced0', '113aa4c3-33b2-4208-b8ee-e040ad5e7fe7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('449fad47-40eb-42bd-80e7-df74cf262d85', '113aa4c3-33b2-4208-b8ee-e040ad5e7fe7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1b74e51d-8920-4c15-856a-9267670cdd9c', '113aa4c3-33b2-4208-b8ee-e040ad5e7fe7', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('98ff849d-f968-4528-9295-680939e543b6', '3f3814a1-9fd2-4b0c-a28d-3e2acfbb37a7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ee146019-2c64-4131-8e10-a2ff28de8c8f', '3f3814a1-9fd2-4b0c-a28d-3e2acfbb37a7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('062af242-fc4f-4e73-b7ba-6a3e3b6c0bba', '3f3814a1-9fd2-4b0c-a28d-3e2acfbb37a7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f1842e15-e0f2-4514-b9f3-444d77bc7d86', '0ca4a12b-937e-4243-8046-5196dc232c34', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('008dd54d-0ccf-42c8-b421-360f6dad5062', '0ca4a12b-937e-4243-8046-5196dc232c34', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c4867974-0577-4101-9a52-5af07129fb60', '0ca4a12b-937e-4243-8046-5196dc232c34', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bafcd25d-92ca-4553-8cf1-beadfa942a03', '7a9c8172-6815-4fe9-8383-6a90047c2122', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7a474450-c883-4878-81a4-6a73c758dfff', '7a9c8172-6815-4fe9-8383-6a90047c2122', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1f35fa8a-70f1-492d-b703-7d3cb466c7df', '7a9c8172-6815-4fe9-8383-6a90047c2122', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7fe37502-f5bd-4e3b-bbde-def3a1070117', 'e752dc2c-f5f4-4931-aa37-1e9de96b3964', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a7ca3acf-dfc5-44ec-8c2e-0d26a042cb85', 'e752dc2c-f5f4-4931-aa37-1e9de96b3964', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('12c06272-1a2a-475b-9ee2-589ea48e5a44', 'e752dc2c-f5f4-4931-aa37-1e9de96b3964', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('726e77fe-1a05-4082-b125-dd1e5efdabe3', '7382f6b0-a641-4358-8def-1c1049b21805', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ce5edb04-d480-468a-92a3-90b741f9ce27', '7382f6b0-a641-4358-8def-1c1049b21805', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('60b36218-6c4b-4e67-85e8-7bb83121d044', '7382f6b0-a641-4358-8def-1c1049b21805', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('076aea0a-76ac-4a27-9cb2-25225399adee', '7382f6b0-a641-4358-8def-1c1049b21805', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('ccb012a4-f851-415e-8ce6-669ff49ece05', 'a9c44ce7-8c1b-4e6f-b526-0269912c6e80', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('39572d5d-f75b-4654-8866-3815cd57e668', 'a9c44ce7-8c1b-4e6f-b526-0269912c6e80', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fe64d9b4-1942-4051-9744-292e8219e643', 'a9c44ce7-8c1b-4e6f-b526-0269912c6e80', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('aa2b696f-e5fb-4899-8e9a-fd2b7f345518', 'ba0efe64-bf35-491b-a633-a5c0ddd95179', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('673a622b-f456-4e7a-ba36-d389c698f8f8', 'ba0efe64-bf35-491b-a633-a5c0ddd95179', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('14e4a85c-bb1e-45d3-8388-19f31f9955f3', 'ba0efe64-bf35-491b-a633-a5c0ddd95179', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a13d59f2-3bb1-4284-a464-f7f244bd39b3', 'd87b314a-6e80-4358-b15b-a800cc5a16c8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bf9ea839-0254-41ea-b5ac-f55885f3a252', 'd87b314a-6e80-4358-b15b-a800cc5a16c8', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f0c9f969-dec7-4722-8992-536c09dc2647', 'd87b314a-6e80-4358-b15b-a800cc5a16c8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('189c7496-ec99-4f33-bdc1-3b7155a85b58', 'dace7e92-08d6-4b49-9f6d-526b2dfae7db', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('21b36590-cd24-47d6-b938-41bc07170967', 'dace7e92-08d6-4b49-9f6d-526b2dfae7db', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('25844fea-1aac-4e0a-b663-7b024d314356', 'dace7e92-08d6-4b49-9f6d-526b2dfae7db', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('47c81077-0019-4ce5-9eda-db1f46358272', 'e61fb6f3-d19a-47ea-9e1e-b60b16e3cbe3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('efa21a5a-1c68-434b-83d4-d923a2132f89', 'e61fb6f3-d19a-47ea-9e1e-b60b16e3cbe3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('55b3e525-c78b-487d-bf5f-990e97df08e7', 'e61fb6f3-d19a-47ea-9e1e-b60b16e3cbe3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('916ddee3-cff5-476e-b315-893f45ac9fcc', 'deb8af90-0a5e-4bdb-9f6f-182bb91820fd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f5269ea6-5082-4940-96ee-b1ad0b24a726', 'deb8af90-0a5e-4bdb-9f6f-182bb91820fd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0b920e48-10e7-4498-b6e0-90d873513988', 'deb8af90-0a5e-4bdb-9f6f-182bb91820fd', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('39729ba4-3051-4ab9-9f5f-d868e702de37', '879269b7-b680-49f1-9db2-784158045be7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1d016c89-eccd-4d71-be01-ad47e0c8808d', '879269b7-b680-49f1-9db2-784158045be7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('399d3a15-75b4-41fa-a10b-31e1dc766efb', '879269b7-b680-49f1-9db2-784158045be7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fac752b4-caeb-4cd4-8fd9-0e6e145efb5b', '4c348eb1-6f12-4bde-b749-19c2116b66a6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('910fb189-7867-4dcf-8bc4-feee0cbe1d91', '4c348eb1-6f12-4bde-b749-19c2116b66a6', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8b0f7c83-e536-4da5-94d1-71847cfa81a5', '4c348eb1-6f12-4bde-b749-19c2116b66a6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f89b1929-8b6a-4b55-a879-5ccd11eabc25', '1f8b3793-5440-4361-9e39-4e149189d64e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2d4926d0-cb3e-4d79-8b02-451e8a92961d', '1f8b3793-5440-4361-9e39-4e149189d64e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bc42f668-03b9-453f-a5aa-c9fefefeda7e', 'db0faad5-3664-4214-a741-5bf289213824', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('13f343dc-d878-4f94-bb14-a3aea86762ba', 'db0faad5-3664-4214-a741-5bf289213824', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e34159d0-6c66-4c84-afdc-7c970513ee21', 'db0faad5-3664-4214-a741-5bf289213824', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('87163c6c-adec-4550-9ae2-d9cabc64b9ca', '012bd02f-707f-4683-9d4f-5bf89cc66465', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('24ddb28d-ec53-456b-bf4a-6dc3b6f9f0e7', '012bd02f-707f-4683-9d4f-5bf89cc66465', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('24d4f574-70a7-4454-b03f-d7699c21f5f2', '012bd02f-707f-4683-9d4f-5bf89cc66465', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d23f9164-87a1-4624-9522-90e9467bd6af', 'bb6ed0dd-d612-4e1f-9b20-ac631af4038c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bd5cd9af-3476-4186-b259-70468b1b4b51', 'bb6ed0dd-d612-4e1f-9b20-ac631af4038c', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e2c782d1-bff1-4eab-98df-35981566dfc7', 'bb6ed0dd-d612-4e1f-9b20-ac631af4038c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7a5cdfa2-2463-45b4-b444-925c55e3d4cf', 'edd38637-62ac-414f-8f59-40ca119f733f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('16eba79a-9247-450a-88e7-68f9903e7204', 'edd38637-62ac-414f-8f59-40ca119f733f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('43e39f20-3fc8-4557-bef8-4e316030f891', 'edd38637-62ac-414f-8f59-40ca119f733f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0284c937-885d-4c10-a771-24c851cd8674', 'edd38637-62ac-414f-8f59-40ca119f733f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('10450b5c-651f-428f-97cd-9695988b40e4', '7a0b73b1-97c8-4cfb-900f-7a74d3ce4bc7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b231262f-c719-44f9-ba91-ec5f78708859', '7a0b73b1-97c8-4cfb-900f-7a74d3ce4bc7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('fc520410-ea83-4951-9415-ef03f929e933', '7a0b73b1-97c8-4cfb-900f-7a74d3ce4bc7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e7876b33-d597-4aad-806a-66db8b90f2d2', '07cbaa43-5fba-4e8c-a92a-e5bdf3ec3cfa', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('84cf688e-dc63-4b43-948e-0d5f95d785b3', '07cbaa43-5fba-4e8c-a92a-e5bdf3ec3cfa', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('df767b03-3901-42ad-972c-f45fb7aa83b7', '07cbaa43-5fba-4e8c-a92a-e5bdf3ec3cfa', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e0d5af05-ed2d-4d8b-bf3b-2964a26d5fe9', 'f331ff20-5c21-4063-a8d2-b671cdec8bb9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d98afdfe-ff8b-454e-bdfb-0d16c630ac0a', 'f331ff20-5c21-4063-a8d2-b671cdec8bb9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('53053dc6-bd1e-4a7a-9e5c-a0c6e3c3cab9', 'f331ff20-5c21-4063-a8d2-b671cdec8bb9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1ca69e76-c96c-40ac-bc50-e0f758055f26', '67821f01-f3fd-42bf-8d67-7809bc407b00', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a6fd8484-8f2e-4967-86ac-384b33957389', '67821f01-f3fd-42bf-8d67-7809bc407b00', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d2aa74a8-42fc-43b8-b654-c352482fb663', '67821f01-f3fd-42bf-8d67-7809bc407b00', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('86443dee-6481-4869-888d-84b45a94b7f7', 'a7bde365-df3b-4a03-bc3b-5ef59855b342', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f1f38f54-6978-48b4-8cda-81db61979ad0', 'a7bde365-df3b-4a03-bc3b-5ef59855b342', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('41178f4d-548f-4933-9ee2-1a946fd43f77', 'a7bde365-df3b-4a03-bc3b-5ef59855b342', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('460dde0e-84c6-488e-bbc9-cd89a2aa5a4a', '08ff5ec6-55d2-4fb2-99f5-58d783254aab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1f92412a-7206-4b7d-9936-6a8531b4862d', '08ff5ec6-55d2-4fb2-99f5-58d783254aab', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0314d09d-8847-4b3e-83aa-e16439aaf3b9', '08ff5ec6-55d2-4fb2-99f5-58d783254aab', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('17213711-5cf9-4e8b-9f01-80e86eb54d61', '97879638-3577-4c39-aa19-1aaad6091581', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c58c6977-853d-423d-9877-cffe8f5b69dd', '97879638-3577-4c39-aa19-1aaad6091581', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('671a045e-2f47-4b78-acc6-4b5dd7131a04', '97879638-3577-4c39-aa19-1aaad6091581', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fd684ee8-354c-48ef-8386-e414c4913375', '94ec808c-7f24-4944-8438-6349820c43c9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7d68b0d7-abea-4185-971b-b8465583422f', '94ec808c-7f24-4944-8438-6349820c43c9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e076ff92-a318-4ffa-806c-42b7111db39d', '94ec808c-7f24-4944-8438-6349820c43c9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7e39fd18-2507-4a26-b728-7b5b1c6b81b3', 'd8ea64cb-d04d-4fc3-aa22-316a14d1cdd5', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e63c39de-8edc-44b9-8291-031f04f24752', 'd8ea64cb-d04d-4fc3-aa22-316a14d1cdd5', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d579463b-e964-4eb6-ac92-fefdd23c13c3', 'd8ea64cb-d04d-4fc3-aa22-316a14d1cdd5', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8b136f51-1c62-41ad-a841-38a831ee8db0', '4643e0cb-f63f-4918-be7b-00448744cec6', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c3a36909-cc2f-4176-98df-c7b136572f08', '4643e0cb-f63f-4918-be7b-00448744cec6', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('dfb33cb2-129a-44e8-b6a8-6e00b79b1663', '4643e0cb-f63f-4918-be7b-00448744cec6', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('aa611092-2d73-437f-b59b-c8e7c18cc823', 'ffc7ef2e-5cc9-47aa-9388-ca2c5d4815fe', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('58b48d84-0540-42e4-b56e-98cab25fa928', 'ffc7ef2e-5cc9-47aa-9388-ca2c5d4815fe', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('895fa60b-bbb5-4e43-b41c-214f1fcd65d7', 'ffc7ef2e-5cc9-47aa-9388-ca2c5d4815fe', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('05ef35e2-17f1-406d-9c5c-76761cfe9b73', 'eb26872c-23c9-4859-9609-6044e50016ca', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5e49645d-2099-4313-b36e-115f13bb3bb4', 'eb26872c-23c9-4859-9609-6044e50016ca', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('10dbe135-ead3-4b77-aa61-718710df2059', 'eb26872c-23c9-4859-9609-6044e50016ca', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('8a7522a5-6f08-44a0-bcef-f9387f4b2ef0', '85b0742e-a14f-41be-904a-54a3fd569cd9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8ef6c1d4-0243-49a1-8acb-f07379fb25ab', '85b0742e-a14f-41be-904a-54a3fd569cd9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b7fd1aea-830f-4a81-95b4-690a34acc804', '85b0742e-a14f-41be-904a-54a3fd569cd9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c02135ac-3ad7-4f59-85c0-13f13604c5b8', 'd2652581-c54f-4a1c-9441-2e43cc9f0f52', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1f3e2509-616b-4b5e-bbed-a8ce69a37e13', 'd2652581-c54f-4a1c-9441-2e43cc9f0f52', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4e3dbc4f-c6b5-4388-a571-768628789936', 'd2652581-c54f-4a1c-9441-2e43cc9f0f52', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('38735fbf-7cd5-4abf-b5f1-14162a9f8815', '9ce5774e-7693-465a-9724-d28bc8ac0091', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('da5e6ed7-2385-416f-8460-3e51cdb8ff2f', '9ce5774e-7693-465a-9724-d28bc8ac0091', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2c55eb86-1a7e-47ab-b109-98317188485a', '9ce5774e-7693-465a-9724-d28bc8ac0091', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a9ba8d8d-248d-42d6-b5cf-e964ca0b6015', 'c0f20126-1d91-4395-92eb-06a2b09e1b1b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('478d265c-9d3b-41b7-a29e-9876afc60a99', 'c0f20126-1d91-4395-92eb-06a2b09e1b1b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('6197faf2-de70-4d07-a7b4-52c2613bdf74', 'c0f20126-1d91-4395-92eb-06a2b09e1b1b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('90f60fc6-8618-4a48-95a0-bc7c74c7e92e', 'd0d59095-200b-418b-b6a0-9b005cdd2876', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b03ebe64-8d32-4694-b5ec-f6bebca941a0', 'd0d59095-200b-418b-b6a0-9b005cdd2876', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f91a517a-5708-4f06-942a-83994f843a16', '1d43931c-b98c-4436-b36b-c586a8d45aef', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('da3b154b-0600-4356-9a2f-b40728895507', '1d43931c-b98c-4436-b36b-c586a8d45aef', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3b9e1e6d-fde3-4823-8777-20e6ae3a8caa', '1d43931c-b98c-4436-b36b-c586a8d45aef', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('29c8f33d-8263-4538-ad98-90512b219081', '3e4a4314-f6ad-4c60-8ceb-f6228dcfeb60', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9bf2f6ae-267d-4ee4-a129-ecd33ef98ebd', '3e4a4314-f6ad-4c60-8ceb-f6228dcfeb60', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4c1888c9-103e-4966-bbed-6b3cc9725418', '3e4a4314-f6ad-4c60-8ceb-f6228dcfeb60', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7565c517-7a7e-4420-bbd4-c086c1feb6c6', '7337da2c-94b0-4f24-aa7d-9e5122f22be0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('807005d1-a7e1-443c-bcba-1d581ce2cdc3', '7337da2c-94b0-4f24-aa7d-9e5122f22be0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a65158a2-8b01-4fc5-93cd-cf7908fc365a', '7337da2c-94b0-4f24-aa7d-9e5122f22be0', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('20fb032f-a61d-4a39-b2e8-422f2dca8746', '478ebe95-e903-4f94-8f9d-1b21961a4755', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('76f8d409-3c5e-4072-9c3c-22ec6b68e6fa', '478ebe95-e903-4f94-8f9d-1b21961a4755', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('2ca8796e-13c6-46b1-87e7-2777c07ac716', '478ebe95-e903-4f94-8f9d-1b21961a4755', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('52b984ae-ea3d-4dd4-bdfa-84fb1b4a1f8f', '478ebe95-e903-4f94-8f9d-1b21961a4755', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('7d6189e3-182d-4fde-80d8-e10ae774c6e6', 'edf44847-94e5-431c-bb9d-b1cdb2fb02da', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('afbbee5e-99c8-482d-8379-2dc3eae581e9', 'edf44847-94e5-431c-bb9d-b1cdb2fb02da', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1ea253a7-e95c-4f11-82b5-e8834023e694', 'edf44847-94e5-431c-bb9d-b1cdb2fb02da', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('76cb85b6-a763-4e56-a937-ed220280d5a7', '793de146-9c7f-49fd-b60d-6b1e1ca9f963', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4b494d40-0c0b-4456-aa01-11a0b44dbc94', '793de146-9c7f-49fd-b60d-6b1e1ca9f963', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('121fb406-fff1-4a29-8774-c2f9da414080', '793de146-9c7f-49fd-b60d-6b1e1ca9f963', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f449b3b1-7a88-463c-8822-b044dd8ebdf4', '14e09997-887d-478e-b8c9-1cc3bee84a03', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('63ba66c6-4ff8-4da1-9523-1d6abc322392', '14e09997-887d-478e-b8c9-1cc3bee84a03', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('9ad10fdd-062c-4c58-8dec-ee8fc8d8d789', '14e09997-887d-478e-b8c9-1cc3bee84a03', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f5e248ee-4087-4a04-b496-14cdb159cd4f', '14e09997-887d-478e-b8c9-1cc3bee84a03', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('a2d72d41-6a1b-4d39-ba6f-e00a5864088c', 'a0ad189f-a827-43e1-bc21-b247de1affe2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('463b14c4-f368-41ce-b4b2-82a7c619f6a0', 'a0ad189f-a827-43e1-bc21-b247de1affe2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('035b6e87-e4f4-4d10-a688-e89fedaac4f4', 'a0ad189f-a827-43e1-bc21-b247de1affe2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('531d2895-cb91-41fa-8334-0f72482ffd5c', 'a0ad189f-a827-43e1-bc21-b247de1affe2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('d7f9a8eb-93ab-4025-bd0b-091af9033597', 'a0ad189f-a827-43e1-bc21-b247de1affe2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('f66071ed-c002-4ad7-9f90-2df263c460dc', '8a685e9f-74f6-4885-ac75-09a512247366', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b2c51017-57f8-49f7-80aa-55004e84d4a6', '8a685e9f-74f6-4885-ac75-09a512247366', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e14a7c55-d020-4a32-b5e6-7f1b0fe59462', '8a685e9f-74f6-4885-ac75-09a512247366', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('47e55d43-175e-4e2f-9a63-1b7797dab848', 'f58d8619-9365-4a25-9f8a-87ec9dad6191', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2994f8bd-5abc-44ee-bafa-87788d207e87', 'f58d8619-9365-4a25-9f8a-87ec9dad6191', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0b14fdbb-187f-47a2-af5e-a73f5e21a5c4', 'f58d8619-9365-4a25-9f8a-87ec9dad6191', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cd6e6b87-edc7-43e3-90d6-9770ab7ec044', '9ce0f989-c570-440e-942b-f62fd3735318', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('04224c38-913a-4b06-90ef-00a58130ad64', '9ce0f989-c570-440e-942b-f62fd3735318', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('08d3d4d1-1209-43d5-b2a8-88512749ef22', '9ce0f989-c570-440e-942b-f62fd3735318', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ac6e978f-37c8-4362-ba9f-b6a635ce9f51', '592c9d12-a6a2-4196-b8bc-94864b93edb4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1d069176-5a15-4795-8917-144b5e8a62a0', '592c9d12-a6a2-4196-b8bc-94864b93edb4', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('756dcf26-1964-4f60-8b95-468690d5aeca', '592c9d12-a6a2-4196-b8bc-94864b93edb4', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c6a6611e-1cff-419d-ba66-e701db4a1498', '2525e37b-7f05-4683-b75e-5f410f9a3a6c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c8a37d4e-5f72-40d6-9b11-74391c9b47f0', '2525e37b-7f05-4683-b75e-5f410f9a3a6c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('479379d0-17c3-4b00-8c44-aad127d619fb', '2525e37b-7f05-4683-b75e-5f410f9a3a6c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('143b03a4-b094-4e8c-98d4-665d059a8b80', '07cb2271-5ed3-492b-b22f-df46f1a56c06', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5cc264e1-e45f-49d5-ab04-3e35f1a7eb06', '07cb2271-5ed3-492b-b22f-df46f1a56c06', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9238e015-53a5-4693-a183-0797aff101d3', '07cb2271-5ed3-492b-b22f-df46f1a56c06', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('78b3d99e-6e00-49ee-94d9-25fc04a53425', '3e8ef5f9-572f-4af1-a506-b21f777563ff', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('17e75513-6e84-48c9-bcc6-6ef8b6cd7b19', '3e8ef5f9-572f-4af1-a506-b21f777563ff', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('13d00246-8f78-47d8-a671-9064e7c17a67', '3e8ef5f9-572f-4af1-a506-b21f777563ff', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('3ea678af-198b-409f-8265-15bb41b3857d', '18061ba0-addb-49c2-b060-fa5c51e48750', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4fd91d65-8d0f-4eb9-9dc9-6e9ac05a7245', '18061ba0-addb-49c2-b060-fa5c51e48750', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('3cc84fd5-a479-4edc-8e94-f396a9bd86c0', '18061ba0-addb-49c2-b060-fa5c51e48750', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0d8c019f-0b1e-4c85-a84e-1b8a9122a07e', '18061ba0-addb-49c2-b060-fa5c51e48750', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('6fe88292-4540-4d43-88b0-59853583e083', 'e787d2f2-2273-4b66-9a56-385674ac0644', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b3f2cad3-4520-4c0e-b7d9-97ea3bdcfcf4', 'e787d2f2-2273-4b66-9a56-385674ac0644', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('5b5a5ee5-661b-423b-aaee-a9c9769c402f', 'e787d2f2-2273-4b66-9a56-385674ac0644', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('8bf3da14-9731-4586-a8ea-22e36ef3d7ef', 'e787d2f2-2273-4b66-9a56-385674ac0644', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('615aa038-6359-414e-993b-ab7a76b0db0b', 'e787d2f2-2273-4b66-9a56-385674ac0644', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('6eb03e9a-75be-4295-a60a-5543aa3be632', 'e8771095-5162-42f7-8d42-c2c2b97597e8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d162e8ba-7cb8-466e-8bd0-5f36b6fba81e', 'e8771095-5162-42f7-8d42-c2c2b97597e8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5b594be4-fa34-4fc8-8098-ecfd37c39d1b', 'e8771095-5162-42f7-8d42-c2c2b97597e8', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6fbad5cc-4af3-4ccc-abbe-d2bb25e1b670', '85c7582f-4257-4d14-8831-17cc32c1088f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('152646f6-bb5d-41ee-b759-99df5676a4ad', '85c7582f-4257-4d14-8831-17cc32c1088f', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1d3c7fc9-6667-4fcf-b61e-3b68c66e4adb', '85c7582f-4257-4d14-8831-17cc32c1088f', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('23365fe3-01d5-4426-a55e-7de3e00ed3cc', '4a59a879-610e-46b2-8def-62b942358e2d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('10db401d-743b-412a-b00c-404833fa66b3', '4a59a879-610e-46b2-8def-62b942358e2d', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b4a0928d-980b-4945-8e8a-0038facecb7b', '4a59a879-610e-46b2-8def-62b942358e2d', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('98fbc620-407a-4faf-979e-743fdd1adc4e', '7b727354-5d79-4ee1-b6a0-18483e492d23', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c66cfea1-5e9a-40de-b799-7b3822b7d644', '7b727354-5d79-4ee1-b6a0-18483e492d23', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7f4441fd-fb11-4f8b-9bb5-09719dd662b8', '496cfe15-6ded-415f-b4c8-989cfcc5d09a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('21758832-b526-4c8e-a679-6149cceef110', '496cfe15-6ded-415f-b4c8-989cfcc5d09a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d472f45e-99b3-4af2-9c2d-6d9ce3e63395', '496cfe15-6ded-415f-b4c8-989cfcc5d09a', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f8dbdf41-8ce1-4f59-88b4-59bc5fc6fd50', '7f777242-f8c6-4947-a8db-6f6980c145d4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5277003f-9056-46f0-aeac-097b61e4f573', '7f777242-f8c6-4947-a8db-6f6980c145d4', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ee90f877-29e2-4cbd-9aab-4183fd0fd991', '7f777242-f8c6-4947-a8db-6f6980c145d4', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c7de93c8-38fe-49d3-99f5-8f2f0ad0b5f0', '3777c158-2048-4fc6-9636-497af899d4ae', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('71bad1ed-ea67-48cf-8aa3-9e804d3e21d9', '3777c158-2048-4fc6-9636-497af899d4ae', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1fceb37e-95b4-4772-8275-b9a77ae79937', '3777c158-2048-4fc6-9636-497af899d4ae', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7c80d9d3-6887-4273-9bc7-d7421e188260', 'a64cb414-8834-47de-ac98-3669d0406edf', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('372dc165-add3-4c09-9cef-456a6ab6deeb', 'a64cb414-8834-47de-ac98-3669d0406edf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0ac93669-19b6-467b-b730-d9e66418eb49', 'a64cb414-8834-47de-ac98-3669d0406edf', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('69144548-1c0b-4ac4-b208-06ac787997c6', 'a64cb414-8834-47de-ac98-3669d0406edf', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('d61cdf4f-cc92-4a10-a138-39ba0ec3c4d0', 'b587cb04-c635-4fec-8cc6-51f942655c2e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('531fe0e3-0ac9-4f1e-bb77-c4dfa1de6450', 'b587cb04-c635-4fec-8cc6-51f942655c2e', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('28ed67c8-06fb-46c6-a6ba-12f494f2cfbb', 'b587cb04-c635-4fec-8cc6-51f942655c2e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('79bc424f-bcf2-444e-8201-a364a958e663', '3b6f7ae4-a39d-46c1-b83a-6cdd756cb5ad', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('583d1454-4535-4464-8ecc-27e9c7c4ca48', '3b6f7ae4-a39d-46c1-b83a-6cdd756cb5ad', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('c2b94ca9-8a21-44b5-9e4c-2a25494bd194', '3b6f7ae4-a39d-46c1-b83a-6cdd756cb5ad', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc63bca2-9bc9-475e-b353-a48e33a97346', '34d57fb8-79bc-489a-9e91-4361f13baa7a', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('377d63e4-8b6e-4bb7-9e67-7d01b13b1e11', '34d57fb8-79bc-489a-9e91-4361f13baa7a', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('1133fc73-f7d7-439f-8f04-942e82761797', '34d57fb8-79bc-489a-9e91-4361f13baa7a', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7d7d756d-296f-46ef-b7f7-7d2472eb8c5f', '34d57fb8-79bc-489a-9e91-4361f13baa7a', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('a880c4d3-e335-4c1c-959b-2e802e1f5e06', '38dd1071-f0ee-46ef-892e-7bfb9d45ad7c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('aeab22ef-7632-438f-9737-772f420c306d', '38dd1071-f0ee-46ef-892e-7bfb9d45ad7c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('99973f0f-f9dd-4623-b204-aabbeb1607ae', '38dd1071-f0ee-46ef-892e-7bfb9d45ad7c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('c7b5889d-0fe3-4a9e-b038-bba96a389369', '38dd1071-f0ee-46ef-892e-7bfb9d45ad7c', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('8e71e5e5-4e58-4b78-af1c-670b9efa48d1', '38dd1071-f0ee-46ef-892e-7bfb9d45ad7c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('42bfe6b4-5689-4b7f-8d4b-e32e56cca897', '7ca81808-ace3-4f80-98e4-169d1762d34e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c681243b-84fa-40e6-8b76-b5d5c325d9f0', '7ca81808-ace3-4f80-98e4-169d1762d34e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('53945701-888a-41c3-8dd9-5e29d7ba6fea', '7ca81808-ace3-4f80-98e4-169d1762d34e', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('bc2d5b63-7531-45cd-a0cb-862c16de374a', 'c16e47f8-98e5-48ef-abe7-7fd789e350b9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('43eaee7e-522a-491e-af1e-58a1651efecd', 'c16e47f8-98e5-48ef-abe7-7fd789e350b9', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ba10a180-8817-451e-b2cb-eb44a56faeab', 'c16e47f8-98e5-48ef-abe7-7fd789e350b9', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('c011354e-ffac-47b1-aff0-3d121f891ff3', '9d2c388c-978c-48cb-aadc-93dbdd0c7732', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6e1f547a-724b-407d-9128-edc4623ae1c6', '9d2c388c-978c-48cb-aadc-93dbdd0c7732', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('63137e86-78f2-43c5-9c11-a7c63b1ddbc7', '9d2c388c-978c-48cb-aadc-93dbdd0c7732', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a3de4592-eebc-4ece-92bb-5553f81dabeb', 'bf9cebc5-92a3-453b-9215-907869cfce8d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('793de001-40a7-4dda-bb31-1099b1de768d', 'bf9cebc5-92a3-453b-9215-907869cfce8d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3782cdc2-6bb6-4a5f-9838-d4875b694b58', 'bf9cebc5-92a3-453b-9215-907869cfce8d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1e29ea35-1606-4626-9307-7e468d4b8f07', '6a2f560f-a273-46e7-8af9-13550eb7e2b7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('92b432c4-4f47-44f4-adb0-801636b99193', '6a2f560f-a273-46e7-8af9-13550eb7e2b7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('a6844058-1a02-45de-9817-7c057a68d062', '6a2f560f-a273-46e7-8af9-13550eb7e2b7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ad5e113d-7f1c-4172-a53b-98b0c3391be8', '268b8a51-4e5b-40f6-b43e-4cd587c38a81', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c23b17dc-e207-4a2f-aa12-37ea20a28a47', '268b8a51-4e5b-40f6-b43e-4cd587c38a81', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('faee10ac-fddc-4263-9447-d5d96af915b7', '268b8a51-4e5b-40f6-b43e-4cd587c38a81', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0f90a0d8-0e9b-4a77-8aa5-7bc25d72edd8', '13f192c3-8297-473f-a116-638d6d838b20', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b1d9aa05-a4df-452e-ae02-6fd682b64190', '13f192c3-8297-473f-a116-638d6d838b20', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('8bcbc8ef-037e-4fc3-b8b9-55ca45bb8369', '13f192c3-8297-473f-a116-638d6d838b20', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f392676c-a87a-4da9-8447-a6cde2fa1f88', '13f192c3-8297-473f-a116-638d6d838b20', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('84ef3a76-9e62-4322-862c-6eda8e45e6de', 'e59aeb2d-b2f4-4872-87ab-6145a23ceab0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ebf58b95-fc32-4b1f-93f7-4daeccca3561', 'e59aeb2d-b2f4-4872-87ab-6145a23ceab0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4a8688ac-7335-4039-889c-aa414748199a', 'e59aeb2d-b2f4-4872-87ab-6145a23ceab0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a8290b8d-fcd5-49f6-af27-1f67ef97e83f', '21ea0277-d19a-486c-81c1-f6fb608a275b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5d3ff9a7-1a21-4d2e-aee2-dfd09420fb08', '21ea0277-d19a-486c-81c1-f6fb608a275b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('12fd448b-28f0-440d-b680-f47d9adca717', 'b40c987c-d079-493a-a8de-07c6851d8cdd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6ff0f56b-85e5-4241-abcc-7d62fa558516', 'b40c987c-d079-493a-a8de-07c6851d8cdd', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('0844bc16-59b0-425c-94c0-274a5b41bac2', 'b40c987c-d079-493a-a8de-07c6851d8cdd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b6446481-26bb-44a2-8a78-184a6967d45f', '92189734-7c5d-455d-a5fb-a5b7e2809b40', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1bc91ee9-e8ec-4b92-9e82-aee4818dc95f', '92189734-7c5d-455d-a5fb-a5b7e2809b40', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('15900bcb-b7ef-4f19-a9cd-592338bd8340', '92189734-7c5d-455d-a5fb-a5b7e2809b40', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4c243814-b9b9-4173-9250-409322e778b8', '0cd9b1f1-8d9c-42cd-bd4c-8bd7f0193ce0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e16e17a0-8dae-40af-a9a3-6521c0b0e3ad', '0cd9b1f1-8d9c-42cd-bd4c-8bd7f0193ce0', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4cf94cd3-75ed-487a-8dff-b14a725702b7', '0cd9b1f1-8d9c-42cd-bd4c-8bd7f0193ce0', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('30ca2f3e-5295-462e-8ee1-366ae108b77c', 'ef6c3738-fc0f-4586-b4e2-a772872fb17f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('942b43eb-a5e0-47bb-bdb4-668812604ff2', 'ef6c3738-fc0f-4586-b4e2-a772872fb17f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5e823c64-1637-4e80-a39c-9617d46388cf', 'ef6c3738-fc0f-4586-b4e2-a772872fb17f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4a901178-01fc-4787-92ee-46b324a3a928', '6762b6db-bf13-4806-a2be-a51c36eba281', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8d54880e-66b3-4f80-8e29-51555191b26a', '6762b6db-bf13-4806-a2be-a51c36eba281', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('4b85731f-1f75-4d26-8fc7-e74459ab7c59', '6762b6db-bf13-4806-a2be-a51c36eba281', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9a5a601d-44dc-42e7-891e-26200de774af', '6762b6db-bf13-4806-a2be-a51c36eba281', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('b78eed9a-28c6-4de9-811b-20b20989476e', 'e71497ba-011e-449d-b355-8dcd83aa86ce', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('e5fcf528-a59d-45c0-a689-91f9a3fb8fb0', 'e71497ba-011e-449d-b355-8dcd83aa86ce', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('481074ef-6890-48fd-8a8b-63dc30c34729', 'e71497ba-011e-449d-b355-8dcd83aa86ce', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('92559200-48f4-40c6-87a2-3b123e3ba3be', '64e54b51-3081-461a-8a52-3587fafe5e73', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0e491dc8-7aa9-437e-a0cf-c2372f004246', '64e54b51-3081-461a-8a52-3587fafe5e73', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('84a09209-98fa-4706-b151-34353fdb8cd2', '64e54b51-3081-461a-8a52-3587fafe5e73', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('de37e290-92ef-44dd-8020-008b87802f72', 'b5234d58-7c2e-447e-bed4-1e6aab8ee3b3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('eb4b85c2-f67c-48a2-9cf9-457ab5ae484e', 'b5234d58-7c2e-447e-bed4-1e6aab8ee3b3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bd095f75-a17b-4b06-a7a7-a36b69c67257', 'b5234d58-7c2e-447e-bed4-1e6aab8ee3b3', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0198a074-33af-465a-ab5d-af427d2629fc', '16b87422-b5fc-4935-8fec-a37c28019502', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5e818d76-b8ad-4c46-8bd9-69c3054515fa', '16b87422-b5fc-4935-8fec-a37c28019502', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f6772ef6-57c4-496a-9bc8-595c88b2841a', '16b87422-b5fc-4935-8fec-a37c28019502', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f690093b-514e-4171-9eed-ba18cbb45856', '53313af6-97ab-4f69-a74b-c0521a0b5a63', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1cfb297a-dad7-41a3-8f9f-2ca877975b15', '53313af6-97ab-4f69-a74b-c0521a0b5a63', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('9a5ae3b0-3402-4527-b3cd-eeda895784a9', '53313af6-97ab-4f69-a74b-c0521a0b5a63', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ac8b0010-2460-4d4c-a766-17d5b045e00a', '53313af6-97ab-4f69-a74b-c0521a0b5a63', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('1fc524ec-c515-42b3-baa3-957375989303', 'ddac1b7d-e7bf-40d7-91ec-1e7807586471', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('50d539ce-aabd-47cf-a1a9-db772e7f73d1', 'ddac1b7d-e7bf-40d7-91ec-1e7807586471', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('6fdf88e4-f2bb-4513-b612-8cee5242babb', 'ddac1b7d-e7bf-40d7-91ec-1e7807586471', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('6d711a73-8fde-4361-b307-4ae50b870be5', 'ddac1b7d-e7bf-40d7-91ec-1e7807586471', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('04aff2f2-7706-4fb4-bfe0-ace75e284f60', '58b29972-d0e3-4545-9ac8-b79f95025e33', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('1e4bdcb7-1f03-4199-9000-25a3fd4ff297', '58b29972-d0e3-4545-9ac8-b79f95025e33', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ae80c362-f07b-4bec-b4de-c9aa4caaab41', '58b29972-d0e3-4545-9ac8-b79f95025e33', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('5eff1af4-03fe-413f-9c13-fe72002febd9', 'f3bec57f-e561-4258-b619-adb9733d1fda', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d16662dd-45d6-4b0c-8fef-0dfed3e45cb4', 'f3bec57f-e561-4258-b619-adb9733d1fda', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('d4d29cf2-e122-4a19-807c-e135df031c3f', 'f3bec57f-e561-4258-b619-adb9733d1fda', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('75cc1ca9-d03c-4927-811b-e555670adb95', '0cb77654-89c4-452b-814e-08c3583e0f76', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a4c45559-c4a7-4aad-8413-f00a466114a6', '0cb77654-89c4-452b-814e-08c3583e0f76', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f9e6d64e-afcd-4b40-863c-8d360f3242f2', '0cb77654-89c4-452b-814e-08c3583e0f76', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cc6ce5bf-4293-4d11-a568-4bcce77e6e54', '305d5c70-a8fc-4a53-8f1e-0e72336876a2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a28aad59-be36-4a74-b56e-e1d1250c3d13', '305d5c70-a8fc-4a53-8f1e-0e72336876a2', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3448f57f-d410-4716-a8e3-cd1a3e340b72', '305d5c70-a8fc-4a53-8f1e-0e72336876a2', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4087cf11-c12a-4ad2-9bef-4af9c8d10e07', 'a152361d-d27e-4011-94ec-e5140f37712b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('b28d0204-b5dd-48f3-8ff9-50c67c9e9c12', 'a152361d-d27e-4011-94ec-e5140f37712b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('4d469b3f-01e1-4e73-a28d-e32cf75b6957', 'a152361d-d27e-4011-94ec-e5140f37712b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('2e68bcb3-85ca-46af-a5b2-710214746358', 'a152361d-d27e-4011-94ec-e5140f37712b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('c032cdde-686d-4756-801b-6fee096c1234', 'a152361d-d27e-4011-94ec-e5140f37712b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('cc8c92e2-b6eb-47de-9428-855f9b91ddde', '71a26f09-ae56-4d2c-974c-ad6122db9b13', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('9e07d2ae-b48c-4283-abab-1dd711601d8d', '71a26f09-ae56-4d2c-974c-ad6122db9b13', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b8c530d4-1209-4b7b-acab-383c87897e14', '71a26f09-ae56-4d2c-974c-ad6122db9b13', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('29d23f42-9c7e-47da-a656-fab82f1a86db', 'ae0e34f5-da4c-43cc-86a5-c156db1de0a0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('acac4cb2-940d-43e2-a9a0-f7dfe9812abf', 'ae0e34f5-da4c-43cc-86a5-c156db1de0a0', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('67cef6cb-dfb6-4424-b005-5ba1bfb1df4a', 'ae0e34f5-da4c-43cc-86a5-c156db1de0a0', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('4a72e9e8-17d8-4a27-a94d-6faf3b8448a4', '798d385e-7a8c-4adf-88fe-241caaaca860', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('5c0ff7d3-0d4e-446a-9ec7-306e525d5ddc', '798d385e-7a8c-4adf-88fe-241caaaca860', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('4e60b5cc-0369-42b2-8c72-f48d2b1fdda9', '798d385e-7a8c-4adf-88fe-241caaaca860', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e4d93a21-46a7-4d8f-ab91-fb88ce359d3c', '798d385e-7a8c-4adf-88fe-241caaaca860', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('6850fd54-cad7-44d6-836b-d618561667de', 'd1950a4b-a2d2-44fb-86f9-a1497f1fb6be', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fd6322e6-d82e-4c68-9303-79827144717f', 'd1950a4b-a2d2-44fb-86f9-a1497f1fb6be', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('62d63404-fc92-40cd-87c4-d34d72f67c8e', 'd1950a4b-a2d2-44fb-86f9-a1497f1fb6be', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b91d8c20-12d7-40c6-a9f8-9af1fcc39fac', 'd1950a4b-a2d2-44fb-86f9-a1497f1fb6be', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('3d8bf9ac-7cae-4fe2-a0b1-12610bd5547c', 'b355cca0-3283-423f-a4fc-c74ac1f37408', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('63af514a-45f2-49b2-8ea6-d28d2aa925c4', 'b355cca0-3283-423f-a4fc-c74ac1f37408', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('dfb26712-f1b0-48f3-bdc8-7d94cb3bd3e5', 'b355cca0-3283-423f-a4fc-c74ac1f37408', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('eec3d500-ac66-43ae-a5a4-e4f12fa460de', '51932a97-e92e-48d8-a97f-448b2687c330', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c11f68a2-5a4f-497d-aa59-66af25282e39', '51932a97-e92e-48d8-a97f-448b2687c330', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4c610b22-539d-4c20-82f7-dfbc032e800f', '51932a97-e92e-48d8-a97f-448b2687c330', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('18c07be7-112c-4d3c-a01a-d5200cefb2c9', '3be141c0-b955-46ab-bee8-475ed2ce8b38', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('19797695-d50d-464d-bc34-be8a305ff823', '3be141c0-b955-46ab-bee8-475ed2ce8b38', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4c3406f2-d09d-4a3d-8529-147cf79a71fc', '3be141c0-b955-46ab-bee8-475ed2ce8b38', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('64ad220e-b355-44a3-acae-d9ec1c637f61', 'ab4b8d72-c96a-47cb-a181-4891feebd130', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d114f415-d95f-4b45-9df3-c50e55887389', 'ab4b8d72-c96a-47cb-a181-4891feebd130', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e41913a0-35fe-466b-8483-67230eee731f', 'ab4b8d72-c96a-47cb-a181-4891feebd130', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a3add82c-df42-4a39-a6e9-e151429dab7e', '09ffde36-4380-42d8-af20-9682ac3fa1ca', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('09fece9a-6577-4edc-8502-6b6032fe016a', '09ffde36-4380-42d8-af20-9682ac3fa1ca', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('5c5c2a19-73f4-4690-a941-d7cca0535adf', 'd25a11ea-4067-4c18-a44b-77d11d891248', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('7e116442-8e4f-47b2-84d1-b3e97579f321', 'd25a11ea-4067-4c18-a44b-77d11d891248', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('e9a88540-b721-429c-aee0-6aeb8592694a', 'd25a11ea-4067-4c18-a44b-77d11d891248', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a0456055-b64d-4ae8-8f23-7d6ff9d1f89a', '642ca176-4a3c-4404-a9b0-4a5a2c0319f3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f8ea3292-2705-47b4-bca3-a7e782cf7807', '639370bb-be2a-446a-a5af-f03a5739f072', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0a7910c2-ed79-4f70-82b7-ec8b8c7705c5', '639370bb-be2a-446a-a5af-f03a5739f072', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('bbebe391-07b6-41fa-9bb0-5e1f95aebcba', '639370bb-be2a-446a-a5af-f03a5739f072', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('497c2bf4-c77f-400f-942d-cdbd0e5660c1', '86f5b779-5388-4492-b458-b5900398abba', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('08ab9c49-fb88-499b-a6c4-154db17207c1', '86f5b779-5388-4492-b458-b5900398abba', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f1741255-9f56-420c-85cb-aa135c87496c', '86f5b779-5388-4492-b458-b5900398abba', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('210538d7-b938-4153-97d6-7a623dfe513e', '5484dc0e-4461-4c27-b3c9-972fcabc98b7', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('4b905dce-1608-4a84-964c-25ae348b1a0b', '5484dc0e-4461-4c27-b3c9-972fcabc98b7', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('0c57983b-dbd1-4736-9f8f-1b9db434e2ee', '5484dc0e-4461-4c27-b3c9-972fcabc98b7', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('cbc6f6b4-9609-4e96-9370-9e7a755fede6', '5484dc0e-4461-4c27-b3c9-972fcabc98b7', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('6f5ca99a-76e4-4953-bc97-853e078f8fe7', 'f7c9c437-6199-488c-8c55-9dbe9a9b6f44', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8bad7191-ae60-45d9-b095-b13add59d470', 'f7c9c437-6199-488c-8c55-9dbe9a9b6f44', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('ddeed8c0-8ee8-480a-9c5e-0273e2bc33dc', 'f7c9c437-6199-488c-8c55-9dbe9a9b6f44', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('556794c6-2a10-4ead-8dcc-8a9573bc7521', 'f7c9c437-6199-488c-8c55-9dbe9a9b6f44', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('64e655b3-6716-43c6-b790-4ddbc011e4fc', 'e462143a-6a84-4865-970e-460a73f4a5c2', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('25672274-e1b8-4363-ac17-d05bcc7aa7da', 'e462143a-6a84-4865-970e-460a73f4a5c2', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ee0e88f3-6c85-405a-8a4d-2150b4f3deb4', 'e462143a-6a84-4865-970e-460a73f4a5c2', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('366c2b58-a372-4eb0-a956-efd4bc8079e1', 'bbfd1011-2b22-4aef-b7ec-e8e3e5f1d00f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('31a630bd-52c2-4ced-a5f0-ba95c060ae8c', 'bbfd1011-2b22-4aef-b7ec-e8e3e5f1d00f', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3fc6737e-438d-481a-9df9-64d087d7028b', 'bbfd1011-2b22-4aef-b7ec-e8e3e5f1d00f', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('972f7f5b-2f1f-48cb-9105-85353af5543c', '44429c43-58da-4701-8ad1-4e7dc7692352', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('42fd3a39-a526-48a4-9044-fdf0fcc0137f', '642ca176-4a3c-4404-a9b0-4a5a2c0319f3', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7505704c-495d-4b93-9caf-93a81c848b2a', '642ca176-4a3c-4404-a9b0-4a5a2c0319f3', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0fafd947-8020-47fe-8c86-61a3b5530482', 'af8ac415-6791-478a-a99b-486817414a62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d32155e6-fa02-43cc-821d-12b2e47f050b', 'af8ac415-6791-478a-a99b-486817414a62', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('22d1d06f-7674-4d5c-a661-14b240ce119b', 'af8ac415-6791-478a-a99b-486817414a62', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7c5692fc-defd-473d-98cd-74bcb5557200', '4abd1a87-5cdd-4ce4-b2d2-a8b43a62a6bd', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2f21d0d4-7bfa-4c9a-acbc-682d98701164', '4abd1a87-5cdd-4ce4-b2d2-a8b43a62a6bd', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4f236b8e-81c4-4fb0-a017-a54b3540fb4f', '4abd1a87-5cdd-4ce4-b2d2-a8b43a62a6bd', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e7e6f58b-d6fd-41ab-87be-0965c5edbaac', 'c28298bb-54b5-4a65-a0bc-cdd051fe2fc3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('a93ffa1b-aa2b-4873-a372-613e920c8501', 'c28298bb-54b5-4a65-a0bc-cdd051fe2fc3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8c759dfa-d142-4d38-9d50-2973ad1bf785', 'c28298bb-54b5-4a65-a0bc-cdd051fe2fc3', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('7b813c7f-52b8-48ad-a96c-2244d8aa9390', 'c28298bb-54b5-4a65-a0bc-cdd051fe2fc3', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('4a7ac724-0f2c-4ca5-958a-2175cfd9a5a2', '20a36447-ce8a-4712-9f1d-ae3bbebc10b1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('cb4bc162-52c9-4fbc-8dc3-9d6885cd248f', '20a36447-ce8a-4712-9f1d-ae3bbebc10b1', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('bb088d79-3f66-412b-9181-b3ea3df02532', '20a36447-ce8a-4712-9f1d-ae3bbebc10b1', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('e526a5b2-8573-42dc-a509-0c18a716811c', '20a36447-ce8a-4712-9f1d-ae3bbebc10b1', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('ef55151c-bebc-4980-a351-a19fb2dc7667', '20a36447-ce8a-4712-9f1d-ae3bbebc10b1', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('94e77945-3ac0-4944-be50-d2a34934f9a7', '0ce67a1f-f404-400c-ba2f-695d19798f80', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('bda93339-4c7e-4cd4-9a22-b90e9977369b', '0ce67a1f-f404-400c-ba2f-695d19798f80', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('1b1a09ed-436a-4dce-aba0-254482ca43b1', '0ce67a1f-f404-400c-ba2f-695d19798f80', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('80ef33bf-03d2-4dd9-b6d2-c48725853a81', '5297e86a-1f9e-48fc-8ed7-f6138312bdd8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('617d094e-223f-4ef2-8214-db8a9f7090cb', '5297e86a-1f9e-48fc-8ed7-f6138312bdd8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('86c331d6-e4d5-4a3d-b032-7f021dfc6f77', '5297e86a-1f9e-48fc-8ed7-f6138312bdd8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('609791b3-8486-41f3-a90e-252fbbbe2bc6', '1822c3a4-b573-45e4-a233-247d26c0f90d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('6b96d34c-8c91-453d-955f-0761ef738080', '1822c3a4-b573-45e4-a233-247d26c0f90d', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('4dbda604-0ce6-4781-9be1-da2c979a6916', '1822c3a4-b573-45e4-a233-247d26c0f90d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1bba6801-7cb5-4b9f-b1e6-20369d38c1f6', 'bb5a985f-e091-4409-87f2-c39f68def66b', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('99985e57-1e6c-4541-b6be-b427ad49c0ef', 'bb5a985f-e091-4409-87f2-c39f68def66b', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('292b79b0-becb-41f1-9b1d-e1243d9e79ab', 'bb5a985f-e091-4409-87f2-c39f68def66b', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('9acfadbe-d0ec-4d10-b4f2-e2fa53016a1d', 'bb5a985f-e091-4409-87f2-c39f68def66b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('34b4eebb-9a96-44a8-946f-3b6a3301073a', '9b6b981f-1b38-4ea1-9ac7-4564698f3994', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('22f9b10e-5c4f-4cf7-ab24-ff688eaf9b09', '9b6b981f-1b38-4ea1-9ac7-4564698f3994', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b6f7314b-4259-4d6b-95e5-8dc02b7e35f2', '9b6b981f-1b38-4ea1-9ac7-4564698f3994', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('efdf164d-d359-4802-ad7f-284c223c3164', '7b6d933a-6589-4b73-864f-2375ca4eb906', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0bc37f4a-4931-4c65-9d60-96601f570703', '7b6d933a-6589-4b73-864f-2375ca4eb906', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8bfc5e28-862b-41e1-bcd4-9c639c28d1fd', '7b6d933a-6589-4b73-864f-2375ca4eb906', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('24ae8576-fe69-4d07-8cd5-e00e63122638', '44429c43-58da-4701-8ad1-4e7dc7692352', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('40552c05-bb7b-4317-b6a8-913013a7a9ba', '44429c43-58da-4701-8ad1-4e7dc7692352', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('f6f6e615-34dc-46de-9219-df7fb07efd00', 'b784eb31-503d-4904-a184-ab26613a4040', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('d9b2d504-8656-4d51-b0d9-65e4c533d210', 'b784eb31-503d-4904-a184-ab26613a4040', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('77fcc3d0-9ff2-4eaa-ae53-7147d74e0b23', 'b784eb31-503d-4904-a184-ab26613a4040', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d3d0a9bf-9dba-4c56-8edd-abcb9478a192', 'b5e8a1f8-3b44-4e84-819e-ce247196a88d', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('c7b9c358-a730-48ef-b5b0-1b792c29a106', 'b5e8a1f8-3b44-4e84-819e-ce247196a88d', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b4a492f3-0c83-456b-af76-f3cc83d9d491', '8e4892f2-7131-42a7-98d4-fb4e0cc3a69e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('2ac643f5-8a68-446a-93f9-e06bd0d4961f', '8e4892f2-7131-42a7-98d4-fb4e0cc3a69e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('ecebd460-e015-4a79-8e5c-e595d79f0ceb', '8e4892f2-7131-42a7-98d4-fb4e0cc3a69e', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('a2e31a94-aaa9-4f7f-8be9-4920d89fcd01', 'cc56c71a-1c7a-4224-8bf8-b6a009663792', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('be951ca4-f0c0-41d7-bc2f-59290b831d05', 'cc56c71a-1c7a-4224-8bf8-b6a009663792', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7cf63328-8fde-4bd5-8b8d-083bed38ee35', 'cc56c71a-1c7a-4224-8bf8-b6a009663792', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('19293359-1f74-4459-a804-fd778233e389', '8ceeca33-4167-4c08-9356-5b9365ca9d90', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('3dbfe792-7763-46f3-a5be-777286efc10a', '8ceeca33-4167-4c08-9356-5b9365ca9d90', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8d12a8fe-9349-43cf-ab03-b4a6c8064b99', '8ceeca33-4167-4c08-9356-5b9365ca9d90', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('ddd31539-cb27-4727-bf0b-9eb75481d749', 'bdc6d42d-0bdd-4c97-b0f3-d3883699723c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('ab38d952-fe60-442d-87cd-806a2b6eac95', 'bdc6d42d-0bdd-4c97-b0f3-d3883699723c', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('12d4e927-c295-439d-bfa5-82b7abc02ef8', 'bdc6d42d-0bdd-4c97-b0f3-d3883699723c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('e63eb7fa-9704-407d-b43d-58db267e40ba', '771e9a5d-d008-46fa-ba74-d5853ca0fe4c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('053a49de-2fa2-448e-9d72-1343704d2b8a', '771e9a5d-d008-46fa-ba74-d5853ca0fe4c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('b83fbc26-c76f-43fc-ab77-703f17b7f98e', '771e9a5d-d008-46fa-ba74-d5853ca0fe4c', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('fd74a9fb-867a-4790-9472-eba04daf5666', '771e9a5d-d008-46fa-ba74-d5853ca0fe4c', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('4ec1020b-35b7-449d-a673-dffa3be99e02', '685d13d9-8fbb-4dbd-9049-ef68f5994a85', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('f66431e8-53e8-4dbc-922b-a684af72ec6c', '685d13d9-8fbb-4dbd-9049-ef68f5994a85', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('68f45565-3d5f-4575-8079-33c887ffda02', '685d13d9-8fbb-4dbd-9049-ef68f5994a85', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('b67c08e0-ee09-4198-9b37-5085ec0be1f9', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('42d8671f-9881-4633-98e7-73a1b827c2f5', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('8755387d-4094-4a32-947a-be7732773906', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 3);
INSERT INTO public.meal_event_detail VALUES ('4f6c5b50-f7c6-4846-a51e-8eb0377f197a', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);
INSERT INTO public.meal_event_detail VALUES ('5abeeddc-e8cb-4c8d-97ad-a7f50d6f42fc', 'cb565376-35cc-4b9d-a029-1a54c4fb40e8', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 5);
INSERT INTO public.meal_event_detail VALUES ('971ea884-4e59-469d-8c7f-062a8ece6c01', 'af727d71-7f00-4add-84cb-dc5bd631904e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('18804fe0-685a-4b45-b4bc-9968d4b64a85', 'af727d71-7f00-4add-84cb-dc5bd631904e', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('12657c0b-e1f5-4425-a4fc-ee2518207219', 'af727d71-7f00-4add-84cb-dc5bd631904e', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('0991eb74-010a-4a9f-8b76-d347b8cc9915', 'e1041696-59d4-4383-a7d9-32cbf8fe2cf9', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('fb0f3dc8-c8e9-4247-aab6-ea8d5dd8c554', 'e1041696-59d4-4383-a7d9-32cbf8fe2cf9', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('f442ac22-ea55-4c1c-b9f3-800f274623f2', 'e1041696-59d4-4383-a7d9-32cbf8fe2cf9', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('23e81b79-5563-4565-9eae-46f0f0dc72af', '5f4afee5-971c-4724-89a5-f7c0eca3c6ff', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('21e0f21e-d72c-45c8-a262-04d0850e6efd', '5f4afee5-971c-4724-89a5-f7c0eca3c6ff', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('7bf86c05-57ca-448b-859b-931ad667c3e9', '5f4afee5-971c-4724-89a5-f7c0eca3c6ff', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('dd7d2e5a-d04b-4b33-a1a9-15161bcbd0b0', '53ccaf1d-0382-4602-9cda-c1a7d5b9d886', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('11889eb5-9c20-4581-89bd-2608a35dac5e', '53ccaf1d-0382-4602-9cda-c1a7d5b9d886', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('24b1c79e-6465-4e13-9472-b137734ed92d', '53ccaf1d-0382-4602-9cda-c1a7d5b9d886', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('d59d4896-6e52-4d4a-aa27-582126ed9ea2', 'bade33e0-792e-496c-be21-48a73b707c73', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('0c192a50-62ec-4823-acc6-20abf11263b8', 'bade33e0-792e-496c-be21-48a73b707c73', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('3cd72230-dbfd-4978-9b4e-baef365efe70', 'bade33e0-792e-496c-be21-48a73b707c73', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('1e2ed02d-6705-4cf3-96bc-a5138ce9a352', 'bb8f3693-5e8e-4706-9c04-d6e17cf6528b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('17ba18d7-6a19-4b74-a0e8-d84b80c8f63a', 'bb8f3693-5e8e-4706-9c04-d6e17cf6528b', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 2);
INSERT INTO public.meal_event_detail VALUES ('8352385b-47f7-4ece-b1c6-146c29e6b47f', 'bb8f3693-5e8e-4706-9c04-d6e17cf6528b', 'cb5b451f-45e6-480d-9e34-3b04fc6c076f', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('94477b28-f989-4656-a2da-3611daa67e8d', 'b07183fe-8890-4f98-945e-bb772626b711', 'eebb7561-afec-41d8-bc3a-6e949a770acb', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 1);
INSERT INTO public.meal_event_detail VALUES ('8599633a-2b57-45df-8bfb-a971c5647fd5', 'b07183fe-8890-4f98-945e-bb772626b711', 'f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Main', 2);
INSERT INTO public.meal_event_detail VALUES ('7b7d990c-db6d-405c-a6cd-5670e0062a10', 'b07183fe-8890-4f98-945e-bb772626b711', '1d9ac977-ba52-470a-bbc4-6862beaa8de2', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 3);
INSERT INTO public.meal_event_detail VALUES ('40cb0867-67d8-4948-9cf8-ca5260a5e471', 'b07183fe-8890-4f98-945e-bb772626b711', '7959862a-1f7f-402d-9f82-0a8e1ee56200', false, 'Accepted', NULL, NULL, 0, NULL, NULL, false, 'Side', 4);


--
-- TOC entry 5291 (class 0 OID 32810)
-- Dependencies: 248
-- Data for Name: meal_event_header; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.meal_event_header VALUES ('5484dc0e-4461-4c27-b3c9-972fcabc98b7', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-13', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('f7c9c437-6199-488c-8c55-9dbe9a9b6f44', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-13', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('e462143a-6a84-4865-970e-460a73f4a5c2', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-13', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('bbfd1011-2b22-4aef-b7ec-e8e3e5f1d00f', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-14', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('44429c43-58da-4701-8ad1-4e7dc7692352', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-14', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('b784eb31-503d-4904-a184-ab26613a4040', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-14', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('b5e8a1f8-3b44-4e84-819e-ce247196a88d', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-15', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('8e4892f2-7131-42a7-98d4-fb4e0cc3a69e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-15', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('cc56c71a-1c7a-4224-8bf8-b6a009663792', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-15', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('8ceeca33-4167-4c08-9356-5b9365ca9d90', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-16', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('bdc6d42d-0bdd-4c97-b0f3-d3883699723c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-16', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('771e9a5d-d008-46fa-ba74-d5853ca0fe4c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-16', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('685d13d9-8fbb-4dbd-9049-ef68f5994a85', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-17', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('cb565376-35cc-4b9d-a029-1a54c4fb40e8', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-17', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('af727d71-7f00-4add-84cb-dc5bd631904e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-17', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('e1041696-59d4-4383-a7d9-32cbf8fe2cf9', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-18', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('5f4afee5-971c-4724-89a5-f7c0eca3c6ff', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-18', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('53ccaf1d-0382-4602-9cda-c1a7d5b9d886', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-18', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('bade33e0-792e-496c-be21-48a73b707c73', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-19', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('bb8f3693-5e8e-4706-9c04-d6e17cf6528b', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-19', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('b07183fe-8890-4f98-945e-bb772626b711', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-19', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('3d0b5832-f7e8-4a21-bc48-6c632e4d10ee', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-06', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('361ab7ab-b76c-4596-bc10-908d0e5977dc', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-06', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('03005c76-5533-4ee8-b7d5-6f52fb118077', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-06', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('a1e16b13-3878-4224-b711-6379641d3afe', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-07', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('1f99dd5a-6e27-4b5f-9921-69a71174ed05', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-07', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('247ea03f-cc1a-4cb6-ae18-6c97160c093c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-07', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('705874b7-7dd9-4bc7-91b8-bb7c140fbc86', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-08', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('5bf7c543-2d7c-47d3-80af-049eb2dd43ab', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-08', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('5927c122-bc55-4690-a831-d7f4a1fe9d86', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-08', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('5437ef6b-54b1-415c-ac64-b93530c6557e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-09', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('232032e2-b760-4111-a33a-e7bbbfeea64f', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-09', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('4066785a-2e99-44b4-a625-bd7f9ae8469b', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-09', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('6fbc0039-e261-4941-a129-ed9c163b81c8', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-10', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('03a11d42-8d40-4873-8e1b-c64c5c606100', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-10', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('955c5848-4979-4873-a233-01157f2cb5b7', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-10', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('07119274-a390-49ac-bba3-0292814d0ccf', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-11', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('fb28c188-9814-4cf3-9d6e-3d5e97d2b9a5', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-11', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('7475cd18-81c8-425f-a87b-06e4a3cbbfdf', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-11', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('e0850e47-3d4d-4f59-ae5e-5c5216e778ba', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-12', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('25645465-c92f-4b38-8374-45751b7061e2', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-12', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('9fae68e6-11ab-45b8-9f49-f63d710d867c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-12', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('03015ea6-a0ba-48c1-a4c7-7381799f9342', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-03-30', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('718d972c-6553-4ec5-ac88-28dd81e3ed2d', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-03-30', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('27160bd1-d41c-46ff-9737-5448c5cff098', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-03-30', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('c1ab2193-74ec-462b-8ae2-76a69d394102', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-03-31', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('00942178-64d4-4bfa-88d6-9879363c7f8c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-03-31', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('54542518-02a8-4dcd-942b-500c32601f8c', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-03-31', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('1e021341-b4ca-4173-98d2-2fbc879b7177', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-01', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('01cdf071-00c4-4850-87e4-142ab0363bd9', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-01', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('dbf8c1c6-976d-4094-8d4d-6dc21740a688', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-01', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('aa52f754-1f78-48e1-a64f-8a2885ec4dfc', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-02', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('33ade968-d13f-4a6d-a31c-571e26c07272', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-02', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('1901c785-6dea-4eac-a4a9-573eddcd2a84', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-02', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('5fd92fec-67a5-4922-9f3d-b4f8a25dc446', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-03', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('cb6353af-0e89-476a-a289-74d4f1869188', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-03', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('111d701c-9202-440a-b4a0-6fbf925005ea', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-03', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('1ec09257-e5c1-4afb-856b-04488c43d513', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-04', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('f424774c-0842-451f-93d3-62a42ec8ff19', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-04', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('de3a1aaf-e336-4544-8340-9dd14cc05501', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-04', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('e94b8fd6-0a07-4ab8-998d-15bcf09cfe05', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Breakfast', '2026-04-05', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('ed536348-ac58-4365-8a89-5dc34905e7a2', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Lunch', '2026-04-05', 1, 0, DEFAULT);
INSERT INTO public.meal_event_header VALUES ('0b05103e-50ef-4528-bd1c-7067fb90799e', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 'Dinner', '2026-04-05', 1, 0, DEFAULT);


--
-- TOC entry 5272 (class 0 OID 16473)
-- Dependencies: 227
-- Data for Name: price_input_buffer; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5268 (class 0 OID 16417)
-- Dependencies: 223
-- Data for Name: price_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.price_logs VALUES (435, NULL, 1277.00, '2026-03-13 13:28:21.272161', NULL);
INSERT INTO public.price_logs VALUES (437, 'STP-01', 1277.00, '2026-03-13 17:43:25.120082', 1);
INSERT INTO public.price_logs VALUES (438, 'STP-01', 1082.50, '2026-03-07 00:00:00', 1);
INSERT INTO public.price_logs VALUES (439, 'STP-01', 1115.00, '2026-03-08 00:00:00', 1);
INSERT INTO public.price_logs VALUES (440, 'STP-01', 1147.50, '2026-03-09 00:00:00', 1);
INSERT INTO public.price_logs VALUES (441, 'STP-01', 1180.00, '2026-03-10 00:00:00', 1);
INSERT INTO public.price_logs VALUES (442, 'STP-01', 1212.50, '2026-03-11 00:00:00', 1);
INSERT INTO public.price_logs VALUES (443, 'STP-01', 1245.00, '2026-03-12 00:00:00', 1);
INSERT INTO public.price_logs VALUES (444, 'STP-01', 1277.50, '2026-03-13 00:00:00', 1);


--
-- TOC entry 5270 (class 0 OID 16430)
-- Dependencies: 225
-- Data for Name: price_summaries_historical; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5284 (class 0 OID 16763)
-- Dependencies: 239
-- Data for Name: recipe_content_vault; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_content_vault VALUES ('cb5b451f-45e6-480d-9e34-3b04fc6c076f', '/assets/meals/chicken_curry.png', '/assets/meals/chicken_curry.png', 'Standard prep steps for Chicken Curry', NULL, NULL);
INSERT INTO public.recipe_content_vault VALUES ('f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', '/assets/meals/paneer_butter_masala.png', '/assets/meals/paneer_butter_masala.png', 'Standard prep steps for Classic Paneer Butter Masala', NULL, NULL);
INSERT INTO public.recipe_content_vault VALUES ('eebb7561-afec-41d8-bc3a-6e949a770acb', '/assets/meals/white_gravy_paneer.png', '/assets/meals/white_gravy_paneer.png', 'Standard prep steps for White Gravy Paneer', NULL, NULL);
INSERT INTO public.recipe_content_vault VALUES ('1d9ac977-ba52-470a-bbc4-6862beaa8de2', '/assets/meals/dal_tadka.png', '/assets/meals/dal_tadka.png', 'Standard prep steps for Homestyle Dal Tadka', NULL, NULL);
INSERT INTO public.recipe_content_vault VALUES ('7959862a-1f7f-402d-9f82-0a8e1ee56200', '/assets/meals/aloo_jeera.png', '/assets/meals/aloo_jeera.png', 'Standard prep steps for Aloo Jeera', NULL, NULL);


--
-- TOC entry 5283 (class 0 OID 16746)
-- Dependencies: 238
-- Data for Name: recipe_dna_master; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_dna_master VALUES ('7959862a-1f7f-402d-9f82-0a8e1ee56200', 'Aloo Jeera', NULL, 'Vegan', true, 'STP-06', NULL, true, 'Medium', 'ALO-JRA', true);
INSERT INTO public.recipe_dna_master VALUES ('cb5b451f-45e6-480d-9e34-3b04fc6c076f', 'Chicken Curry', NULL, 'Non-Veg', false, 'STP-17', NULL, true, 'Medium', 'CHK-CUR', false);
INSERT INTO public.recipe_dna_master VALUES ('f1c2bc95-0924-44bc-a5de-64e2b9bf6d35', 'Classic Paneer Butter Masala', NULL, 'Veg', true, 'STP-PNR', NULL, true, 'Medium', 'PNR-BUT', false);
INSERT INTO public.recipe_dna_master VALUES ('eebb7561-afec-41d8-bc3a-6e949a770acb', 'White Gravy Paneer', NULL, 'Veg', false, 'STP-PNR', NULL, true, 'Medium', 'PNR-WHT', false);
INSERT INTO public.recipe_dna_master VALUES ('1d9ac977-ba52-470a-bbc4-6862beaa8de2', 'Homestyle Dal Tadka', NULL, 'Vegan', true, 'STP-TDL', NULL, true, 'Medium', 'DAL-TDK', true);


--
-- TOC entry 5289 (class 0 OID 24576)
-- Dependencies: 245
-- Data for Name: recipe_gap_analysis; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.recipe_gap_analysis VALUES ('ba7dee9f-b8f9-4b1d-afc9-7b7e599003a8', 'Satvik Kerala Jackfruit Curry', 'User: Satvik/Kerala + Market: Stress', 'Kerala', 3, 1, '{"steps": ["Boil", "Grind"], "ingredients": ["Jackfruit", "Coconut"]}', 'PENDING', '2026-03-02 16:53:12.243353+05:30', '2026-03-02 16:53:12.243353+05:30');


--
-- TOC entry 5278 (class 0 OID 16521)
-- Dependencies: 233
-- Data for Name: seasonal_price_benchmarks; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5277 (class 0 OID 16515)
-- Dependencies: 232
-- Data for Name: seasons; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5281 (class 0 OID 16722)
-- Dependencies: 236
-- Data for Name: staple_master_registry; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.staple_master_registry VALUES ('STP-01', 'Tomato', 'Vegetable', 'High', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-02', 'Onion', 'Vegetable', 'High', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-03', 'Ginger', 'Garnish', 'High', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-04', 'Garlic', 'Garnish', 'High', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-05', 'Green Chili', 'Garnish', 'High', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-06', 'Potato', 'Vegetable', 'Medium', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-07', 'Coriander', 'Garnish', 'High', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-08', 'Rice (Basmati/Raw)', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-09', 'Atta (Wheat Flour)', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-10', 'Poha', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-11', 'Oats', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-12', 'Rava (Semolina)', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-13', 'Toor Dal', 'Protein', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-14', 'Moong Dal', 'Protein', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-16', 'Eggs', 'Protein', 'Medium', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-17', 'Chicken', 'Protein', 'High', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-18', 'Kabuli Chana', 'Protein', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-19', 'Milk', 'Dairy', 'Fixed', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-20', 'Curd', 'Dairy', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-21', 'Cooking Oil', 'Oil', 'Medium', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-22', 'Ghee', 'Oil', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-23', 'Butter', 'Dairy', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-24', 'Salt', 'Pantry', 'Fixed', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-25', 'Sugar', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-26', 'Turmeric Powder', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-27', 'Chili Powder', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-28', 'Mustard Seeds', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-29', 'Tamarind', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-30', 'Tea/Coffee Powder', 'Pantry', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-TDL', 'Toor Dal', 'Protein', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-RCE', 'Rice', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-ATA', 'Atta', 'Grain', 'Low', true, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-MSH', 'Mushrooms', 'Vegetable', 'High', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-ONN', 'Onion', 'Vegetable', 'Medium', false, 0.00);
INSERT INTO public.staple_master_registry VALUES ('STP-15', 'Paneer', 'Protein', 'Medium', true, 1200.00);
INSERT INTO public.staple_master_registry VALUES ('STP-PNR', 'Paneer', 'Dairy', 'Medium', true, 1200.00);


--
-- TOC entry 5273 (class 0 OID 16492)
-- Dependencies: 228
-- Data for Name: system_alerts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.system_alerts VALUES ('PEAK_ALERT', 'ta', ' உச்ச விலை (Wave 5 Peak)');
INSERT INTO public.system_alerts VALUES ('BUY_SIGNAL', 'ta', ' குறைந்த விலை (Buying Zone)');
INSERT INTO public.system_alerts VALUES ('STABLE', 'ta', ' சாதாரண விலை (Neutral)');


--
-- TOC entry 5300 (class 0 OID 90281)
-- Dependencies: 258
-- Data for Name: user_intelligence_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.user_intelligence_profile VALUES ('0cd2ca13-2014-4687-88f5-3579a3250a1d', '8b4f002f-b78e-478a-8f75-81b427f03786', 0, 4, NULL, 2, 3, '{}', '{}', NULL, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');
INSERT INTO public.user_intelligence_profile VALUES ('a2a005b7-e145-468f-81ce-382cc3d1b7d7', '733b3f63-0fb4-4170-877c-eb2a70f29ccb', 0, 4, NULL, 2, 3, '{}', '{}', NULL, '2026-04-14 11:47:02.575629', '2026-04-14 11:47:02.575629');


--
-- TOC entry 5287 (class 0 OID 16851)
-- Dependencies: 243
-- Data for Name: weekly_planning_session; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5298 (class 0 OID 90230)
-- Dependencies: 256
-- Data for Name: weekly_questionnaire; Type: TABLE DATA; Schema: public; Owner: postgres
--



--
-- TOC entry 5334 (class 0 OID 0)
-- Dependencies: 218
-- Name: ingredient_master_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingredient_master_id_seq', 30, true);


--
-- TOC entry 5335 (class 0 OID 0)
-- Dependencies: 229
-- Name: market_locations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.market_locations_id_seq', 1, false);


--
-- TOC entry 5336 (class 0 OID 0)
-- Dependencies: 226
-- Name: price_input_buffer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_input_buffer_id_seq', 1, false);


--
-- TOC entry 5337 (class 0 OID 0)
-- Dependencies: 222
-- Name: price_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_logs_id_seq', 444, true);


--
-- TOC entry 5338 (class 0 OID 0)
-- Dependencies: 224
-- Name: price_summaries_historical_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.price_summaries_historical_id_seq', 1, false);


--
-- TOC entry 5339 (class 0 OID 0)
-- Dependencies: 231
-- Name: seasons_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.seasons_id_seq', 1, false);


-- Completed on 2026-04-17 13:26:15

--
-- PostgreSQL database dump complete
--

\unrestrict JYOMQAAC6138T7s3EWhRijSXr7x01TBw8RI9JTwFbpAdYC3ZlPArH7TeiO3MWXv

