-- ============================================================
-- Schema v7 — Lookup tables: cuisine_regions, cities
-- Run after: food_momentum_schema_v6_auth.sql
-- ============================================================

-- ── 1. cuisine_regions ───────────────────────────────────────
-- Drives home region selection: State → Region → Sub-region
-- Used for cuisine preference, recipe filtering

CREATE TABLE IF NOT EXISTS cuisine_regions (
    id          SERIAL PRIMARY KEY,
    state       VARCHAR(100) NOT NULL,
    region      VARCHAR(100) NOT NULL,
    sub_region  VARCHAR(100) NOT NULL,
    is_active   BOOLEAN DEFAULT TRUE,
    sort_order  INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_cuisine_regions_state ON cuisine_regions(state);
CREATE INDEX IF NOT EXISTS idx_cuisine_regions_state_region ON cuisine_regions(state, region);

-- ── 2. cities ────────────────────────────────────────────────
-- Drives current city selection: State → City
-- agmarknet_name: exact AGMARKNET district/market name for price API lookup
-- display_name: modern official city name shown in UI

CREATE TABLE IF NOT EXISTS cities (
    id              SERIAL PRIMARY KEY,
    state           VARCHAR(100) NOT NULL,
    display_name    VARCHAR(150) NOT NULL,
    agmarknet_name  VARCHAR(150),           -- exact AGMARKNET spelling for API calls
    is_active       BOOLEAN DEFAULT TRUE,
    sort_order      INTEGER DEFAULT 0
);

CREATE INDEX IF NOT EXISTS idx_cities_state ON cities(state);

-- ============================================================
-- SEED DATA — cuisine_regions
-- ============================================================

INSERT INTO cuisine_regions (state, region, sub_region, sort_order) VALUES

-- Tamil Nadu
('Tamil Nadu', 'North Tamil Nadu',    'Chennai Brahmin (Iyer)',        1),
('Tamil Nadu', 'North Tamil Nadu',    'Chennai Brahmin (Iyengar)',     2),
('Tamil Nadu', 'North Tamil Nadu',    'North Arcot',                   3),
('Tamil Nadu', 'North Tamil Nadu',    'Vellore',                       4),

('Tamil Nadu', 'Central Tamil Nadu',  'Chettinad',                     5),
('Tamil Nadu', 'Central Tamil Nadu',  'Kongu Nadu',                    6),
('Tamil Nadu', 'Central Tamil Nadu',  'Salem',                         7),
('Tamil Nadu', 'Central Tamil Nadu',  'Erode',                         8),
('Tamil Nadu', 'Central Tamil Nadu',  'Trichy',                        9),

('Tamil Nadu', 'South Tamil Nadu',    'Madurai',                       10),
('Tamil Nadu', 'South Tamil Nadu',    'Tirunelveli',                   11),
('Tamil Nadu', 'South Tamil Nadu',    'Nagercoil / Kanyakumari',       12),
('Tamil Nadu', 'South Tamil Nadu',    'Thoothukudi',                   13),

('Tamil Nadu', 'Coastal Tamil Nadu',  'Thanjavur (Brahmin)',           14),
('Tamil Nadu', 'Coastal Tamil Nadu',  'Thanjavur (Non-Brahmin)',       15),
('Tamil Nadu', 'Coastal Tamil Nadu',  'Nagapattinam',                  16),
('Tamil Nadu', 'Coastal Tamil Nadu',  'Rameswaram / Pamban',           17),

-- Kerala
('Kerala', 'North Kerala',            'Malabar (Kozhikode)',           20),
('Kerala', 'North Kerala',            'Malabar (Kannur)',              21),
('Kerala', 'North Kerala',            'Kasaragod',                     22),
('Kerala', 'North Kerala',            'Wayanad',                       23),

('Kerala', 'Central Kerala',          'Thrissur',                      24),
('Kerala', 'Central Kerala',          'Palakkad (Palakkad Iyer)',      25),
('Kerala', 'Central Kerala',          'Ernakulam / Kochi',             26),
('Kerala', 'Central Kerala',          'Syrian Christian (Kottayam)',   27),
('Kerala', 'Central Kerala',          'Idukki',                        28),

('Kerala', 'South Kerala',            'Thiruvananthapuram',            29),
('Kerala', 'South Kerala',            'Kollam',                        30),
('Kerala', 'South Kerala',            'Nair Cuisine',                  31),
('Kerala', 'South Kerala',            'Kerala Brahmin (Namboothiri)',  32),

-- Karnataka
('Karnataka', 'South Karnataka',      'Udupi Brahmin',                 40),
('Karnataka', 'South Karnataka',      'Mangalorean Catholic',          41),
('Karnataka', 'South Karnataka',      'Tulu Nadu',                     42),
('Karnataka', 'South Karnataka',      'Kodagu (Coorg)',                43),
('Karnataka', 'South Karnataka',      'Mysuru',                        44),

('Karnataka', 'North Karnataka',      'Dharwad / Hubli',               45),
('Karnataka', 'North Karnataka',      'Belagavi',                      46),
('Karnataka', 'North Karnataka',      'Uttara Kannada',                47),

('Karnataka', 'Central Karnataka',    'Bengaluru',                     48),
('Karnataka', 'Central Karnataka',    'Davangere',                     49),
('Karnataka', 'Central Karnataka',    'Chitradurga',                   50),

-- Andhra Pradesh
('Andhra Pradesh', 'Coastal Andhra',  'Godavari',                      60),
('Andhra Pradesh', 'Coastal Andhra',  'Krishna',                       61),
('Andhra Pradesh', 'Coastal Andhra',  'Guntur',                        62),
('Andhra Pradesh', 'Coastal Andhra',  'Visakhapatnam',                 63),

('Andhra Pradesh', 'Rayalaseema',     'Kurnool',                       64),
('Andhra Pradesh', 'Rayalaseema',     'Kadapa',                        65),
('Andhra Pradesh', 'Rayalaseema',     'Anantapur',                     66),
('Andhra Pradesh', 'Rayalaseema',     'Chittoor',                      67),

-- Telangana
('Telangana', 'Hyderabad Region',     'Hyderabadi (Muslim)',           70),
('Telangana', 'Hyderabad Region',     'Hyderabadi (Hindu)',            71),
('Telangana', 'Hyderabad Region',     'Telangana Brahmin',             72),

('Telangana', 'North Telangana',      'Nizamabad',                     73),
('Telangana', 'North Telangana',      'Karimnagar',                    74),
('Telangana', 'North Telangana',      'Adilabad',                      75),

('Telangana', 'South Telangana',      'Nalgonda',                      76),
('Telangana', 'South Telangana',      'Mahbubnagar',                   77),

-- Other states — top level only for now
('Maharashtra', 'Maharashtra',        'Maharashtra (General)',         80),
('Goa',         'Goa',               'Goan (General)',                81),
('Other',       'Other',             'Other',                         99);

-- ============================================================
-- SEED DATA — cities (AGMARKNET-aligned names)
-- ============================================================

INSERT INTO cities (state, display_name, agmarknet_name, sort_order) VALUES

-- Karnataka
('Karnataka', 'Bengaluru',        'Bangalore',                    1),
('Karnataka', 'Mysuru',           'Mysore',                       2),
('Karnataka', 'Mangaluru',        'Mangalore(Dakshin Kannad)',     3),
('Karnataka', 'Hubballi',         'Dharwad',                      4),
('Karnataka', 'Belagavi',         'Belgaum',                      5),
('Karnataka', 'Davangere',        'Davangere',                    6),
('Karnataka', 'Ballari',          'Bellary',                      7),
('Karnataka', 'Vijayapura',       'Bijapur',                      8),
('Karnataka', 'Shivamogga',       'Shimoga',                      9),
('Karnataka', 'Tumakuru',         'Tumkur',                       10),
('Karnataka', 'Raichur',          'Raichur',                      11),
('Karnataka', 'Kalaburagi',       'Gulbarga',                     12),
('Karnataka', 'Hassan',           'Hassan',                       13),
('Karnataka', 'Mandya',           'Mandya',                       14),
('Karnataka', 'Udupi',            'Udupi',                        15),
('Karnataka', 'Madikeri',         'Madikeri(Kodagu)',              16),
('Karnataka', 'Kolar',            'Kolar',                        17),
('Karnataka', 'Chikkamagaluru',   'Chikmagalur',                  18),
('Karnataka', 'Bagalkot',         'Bagalkot',                     19),
('Karnataka', 'Koppal',           'Koppal',                       20),
('Karnataka', 'Gadag',            'Gadag',                        21),
('Karnataka', 'Ramanagara',       'Ramanagar',                    22),
('Karnataka', 'Chamarajanagar',   'Chamrajnagar',                 23),
('Karnataka', 'Bidar',            'Bidar',                        24),
('Karnataka', 'Yadgir',           'Yadgir',                       25),

-- Tamil Nadu
('Tamil Nadu', 'Chennai',         'Chennai',                      1),
('Tamil Nadu', 'Coimbatore',      'Coimbatore',                   2),
('Tamil Nadu', 'Madurai',         'Madurai',                      3),
('Tamil Nadu', 'Tiruchirappalli', 'Trichy',                       4),
('Tamil Nadu', 'Salem',           'Salem',                        5),
('Tamil Nadu', 'Tirunelveli',     'Tirunelveli',                  6),
('Tamil Nadu', 'Erode',           'Erode',                        7),
('Tamil Nadu', 'Vellore',         'Vellore',                      8),
('Tamil Nadu', 'Thoothukudi',     'Tuticorin',                    9),
('Tamil Nadu', 'Thanjavur',       'Thanjavur',                    10),
('Tamil Nadu', 'Dindigul',        'Dindigul',                     11),
('Tamil Nadu', 'Tiruppur',        'Tiruppur',                     12),
('Tamil Nadu', 'Karur',           'Karur',                        13),
('Tamil Nadu', 'Nagapattinam',    'Nagapattinam',                 14),
('Tamil Nadu', 'Kancheepuram',    'Kanchipuram',                  15),
('Tamil Nadu', 'Namakkal',        'Namakkal',                     16),
('Tamil Nadu', 'Cuddalore',       'Cuddalore',                    17),
('Tamil Nadu', 'Krishnagiri',     'Krishnagiri',                  18),
('Tamil Nadu', 'Villupuram',      'Villupuram',                   19),
('Tamil Nadu', 'Ramanathapuram',  'Ramanathapuram',               20),
('Tamil Nadu', 'Virudhunagar',    'Virudhunagar',                 21),
('Tamil Nadu', 'Sivaganga',       'Sivaganga',                    22),
('Tamil Nadu', 'Pudukkottai',     'Pudukkottai',                  23),
('Tamil Nadu', 'The Nilgiris (Ooty)', 'Ooty',                    24),
('Tamil Nadu', 'Hosur',           'Hosur',                        25),

-- Kerala
('Kerala', 'Thiruvananthapuram',  'Thiruvananthapuram',           1),
('Kerala', 'Kochi',               'Ernakulam',                    2),
('Kerala', 'Kozhikode',           'Kozhikode',                    3),
('Kerala', 'Thrissur',            'Thrissur',                     4),
('Kerala', 'Kollam',              'Kollam',                       5),
('Kerala', 'Palakkad',            'Palakkad',                     6),
('Kerala', 'Alappuzha',           'Alappuzha',                    7),
('Kerala', 'Kottayam',            'Kottayam',                     8),
('Kerala', 'Kannur',              'Kannur',                       9),
('Kerala', 'Kasaragod',           'Kasaragod',                    10),
('Kerala', 'Malappuram',          'Malappuram',                   11),
('Kerala', 'Pathanamthitta',      'Pathanamthitta',               12),
('Kerala', 'Idukki',              'Idukki',                       13),
('Kerala', 'Wayanad',             'Wayanad',                      14),

-- Andhra Pradesh
('Andhra Pradesh', 'Visakhapatnam',   'Visakhapatnam',            1),
('Andhra Pradesh', 'Vijayawada',      'Vijayawada',               2),
('Andhra Pradesh', 'Guntur',          'Guntur',                   3),
('Andhra Pradesh', 'Tirupati',        'Tirupati',                 4),
('Andhra Pradesh', 'Kurnool',         'Kurnool',                  5),
('Andhra Pradesh', 'Rajahmundry',     'Rajahmundry',              6),
('Andhra Pradesh', 'Nellore',         'Nellore',                  7),
('Andhra Pradesh', 'Kadapa',          'Kadapa',                   8),
('Andhra Pradesh', 'Anantapur',       'Anantapur',                9),
('Andhra Pradesh', 'Eluru',           'Eluru',                    10),
('Andhra Pradesh', 'Ongole',          'Ongole',                   11),
('Andhra Pradesh', 'Chittoor',        'Chittoor',                 12),

-- Telangana
('Telangana', 'Hyderabad',        'Hyderabad',                    1),
('Telangana', 'Warangal',         'Warangal',                     2),
('Telangana', 'Nizamabad',        'Nizamabad',                    3),
('Telangana', 'Karimnagar',       'Karimnagar',                   4),
('Telangana', 'Khammam',          'Khammam',                      5),
('Telangana', 'Nalgonda',         'Nalgonda',                     6),
('Telangana', 'Mahbubnagar',      'Mahbubnagar',                  7),
('Telangana', 'Adilabad',         'Adilabad',                     8),
('Telangana', 'Siddipet',         'Siddipet',                     9),
('Telangana', 'Suryapet',         'Suryapet',                     10),

-- Maharashtra
('Maharashtra', 'Mumbai',         'Mumbai',                       1),
('Maharashtra', 'Pune',           'Pune',                         2),
('Maharashtra', 'Nagpur',         'Nagpur',                       3),
('Maharashtra', 'Nashik',         'Nashik',                       4),
('Maharashtra', 'Aurangabad',     'Aurangabad',                   5),
('Maharashtra', 'Solapur',        'Solapur',                      6),
('Maharashtra', 'Kolhapur',       'Kolhapur',                     7),

-- Goa
('Goa', 'Panaji',                 'Panaji',                       1),
('Goa', 'Margao',                 'Margao',                       2),
('Goa', 'Vasco da Gama',          'Vasco',                        3),

-- Delhi NCR
('Delhi', 'New Delhi',            'Delhi',                        1),
('Delhi', 'Noida',                'Noida',                        2),
('Delhi', 'Gurgaon',              'Gurgaon',                      3),

-- Other major metros
('West Bengal',   'Kolkata',      'Kolkata',                      1),
('Gujarat',       'Ahmedabad',    'Ahmedabad',                    1),
('Gujarat',       'Surat',        'Surat',                        2),
('Rajasthan',     'Jaipur',       'Jaipur',                       1),
('Madhya Pradesh','Bhopal',       'Bhopal',                       1),
('Madhya Pradesh','Indore',       'Indore',                       2),
('Uttar Pradesh', 'Lucknow',      'Lucknow',                      1),
('Uttar Pradesh', 'Kanpur',       'Kanpur',                       2),
('Tamil Nadu',    'Puducherry',   'Pondicherry',                  26);
