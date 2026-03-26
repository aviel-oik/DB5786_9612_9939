-- =============================================================================
-- DATA POPULATION SCRIPT (100 ROWS PER TABLE)
-- Database: PostgreSQL
-- =============================================================================

-- -----------------------------------------------------
-- 1. INSERTING DATA INTO: AIRPORT
-- -----------------------------------------------------
-- Logic: 100 Unique Airports with unique 3-letter IATA codes
INSERT INTO AIRPORT (name, city, region, country, iata_code, timezone) VALUES
('Ben Gurion International', 'Tel Aviv', 'Central', 'Israel', 'TLV', 'UTC+2'),
('Heathrow Airport', 'London', 'Greater London', 'United Kingdom', 'LHR', 'UTC+0'),
('John F. Kennedy Intl', 'New York', 'New York', 'USA', 'JFK', 'UTC-5'),
('Charles de Gaulle', 'Paris', 'Ile-de-France', 'France', 'CDG', 'UTC+1'),
('Dubai International', 'Dubai', 'Dubai', 'UAE', 'DXB', 'UTC+4'),
('Haneda Airport', 'Tokyo', 'Kanto', 'Japan', 'HND', 'UTC+9'),
('Singapore Changi', 'Singapore', 'East', 'Singapore', 'SIN', 'UTC+8'),
('Los Angeles Intl', 'Los Angeles', 'California', 'USA', 'LAX', 'UTC-8'),
('Frankfurt Airport', 'Frankfurt', 'Hesse', 'Germany', 'FRA', 'UTC+1'),
('Hong Kong Intl', 'Hong Kong', 'Lantau', 'China', 'HKG', 'UTC+8');

-- Generating the remaining 90 airports with a systematic pattern for uniqueness
INSERT INTO AIRPORT (name, city, region, country, iata_code, timezone)
SELECT 
    'Airport ' || i, 
    'City ' || i, 
    'Region ' || (i % 5), 
    'Country ' || (i % 10),
    -- Generates unique strings like 'A11', 'A12'...
    CHR(65 + (i / 26)) || CHR(65 + (i % 26)) || CHR(48 + (i % 10)),
    'UTC+' || (i % 12)
FROM generate_series(11, 100) AS i;


-- -----------------------------------------------------
-- 2. INSERTING DATA INTO: ROUTE
-- -----------------------------------------------------
-- Logic: Creating 100 routes connecting Airport(i) to Airport(i+1)
INSERT INTO ROUTE (origin_airport_id, destination_airport_id)
SELECT i, (i % 100) + 1 
FROM generate_series(1, 100) AS i;


-- -----------------------------------------------------
-- 3. INSERTING DATA INTO: AIRCRAFT
-- -----------------------------------------------------
-- Logic: 100 Aircraft alternating between Boeing and Airbus models
INSERT INTO AIRCRAFT (model, manufacturer, capacity, status)
SELECT 
    CASE WHEN i % 2 = 0 THEN '737 MAX ' || i ELSE 'A320neo ' || i END,
    CASE WHEN i % 2 = 0 THEN 'Boeing' ELSE 'Airbus' END,
    150 + (i % 200),
    CASE WHEN i % 10 = 0 THEN 'Maintenance' ELSE 'Active' END
FROM generate_series(1, 100) AS i;


-- -----------------------------------------------------
-- 4. INSERTING DATA INTO: FLIGHT
-- -----------------------------------------------------
-- Logic: 100 Flights with unique flight numbers and logical arrival times
INSERT INTO FLIGHT (flight_number, departure_time, arrival_time, status, route_id, aircraft_id)
SELECT 
    'XY' || (1000 + i), -- Unique Flight Number
    NOW() + (i || ' hours')::interval, -- Departure: Now + i hours
    NOW() + ((i + 3) || ' hours')::interval, -- Arrival: Departure + 3 hours
    'Scheduled',
    i, -- Matches Route ID
    i  -- Matches Aircraft ID
FROM generate_series(1, 100) AS i;


-- -----------------------------------------------------
-- 5. INSERTING DATA INTO: TERMINAL
-- -----------------------------------------------------
-- Logic: One terminal assigned to each of the 100 airports
INSERT INTO TERMINAL (terminal_name, terminal_number, capacity, airport_id)
SELECT 
    'Terminal ' || CASE WHEN i % 2 = 0 THEN 'A' ELSE 'B' END,
    (i % 5) + 1,
    2000 + (i * 10),
    i -- Matches Airport ID
FROM generate_series(1, 100) AS i;


-- -----------------------------------------------------
-- 6. INSERTING DATA INTO: GATE
-- -----------------------------------------------------
-- Logic: One gate assigned to each of the 100 terminals
INSERT INTO GATE (gate_number, status, max_passengers, terminal_id)
SELECT 
    'G' || i,
    'Available',
    200,
    i -- Matches Terminal ID
FROM generate_series(1, 100) AS i;

-- -----------------------------------------------------
-- VERIFICATION
-- -----------------------------------------------------
SELECT 'AIRPORT' as table, count(*) from AIRPORT
UNION ALL SELECT 'ROUTE', count(*) from ROUTE
UNION ALL SELECT 'AIRCRAFT', count(*) from AIRCRAFT
UNION ALL SELECT 'FLIGHT', count(*) from FLIGHT
UNION ALL SELECT 'TERMINAL', count(*) from TERMINAL
UNION ALL SELECT 'GATE', count(*) from GATE;