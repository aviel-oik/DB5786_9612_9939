-- =============================================================================
-- init-data.sql
-- Description: Population de la base de données avec 20,000 avions/vols 
--              et 500 aéroports/routes/terminaux/portes.
-- =============================================================================

-- 1. Nettoyage et réinitialisation des compteurs d'ID
TRUNCATE TABLE GATE, TERMINAL, FLIGHT, ROUTE, AIRCRAFT, AIRPORT RESTART IDENTITY CASCADE;

DO $$
DECLARE
    i INT;
    v_manufacturer TEXT;
    v_model TEXT;
    v_capacity INT;
BEGIN
    -- -----------------------------------------------------
    -- A. INSERTION DE 500 AÉROPORTS
    -- -----------------------------------------------------
    FOR i IN 1..500 LOOP
        INSERT INTO AIRPORT (name, city, region, country, iata_code, timezone)
        VALUES (
            'International Airport ' || i,
            'City ' || ((i % 150) + 1),
            'Region ' || ((i % 50) + 1),
            'Country ' || ((i % 70) + 1),
            -- Génération d'un code IATA unique de 3 lettres (AAA, AAB, etc.)
            CHR(65 + (i / 676 % 26)) || CHR(65 + (i / 26 % 26)) || CHR(65 + (i % 26)),
            'UTC' || CASE WHEN i % 2 = 0 THEN '+' ELSE '-' END || (i % 13)
        );
    END LOOP;

    -- -----------------------------------------------------
    -- B. INSERTION DE 500 ROUTES
    -- -----------------------------------------------------
    -- On connecte l'aéroport i à l'aéroport i+1 de manière circulaire
    FOR i IN 1..500 LOOP
        INSERT INTO ROUTE (origin_airport_id, destination_airport_id)
        VALUES (i, (i % 500) + 1);
    END LOOP;

    -- -----------------------------------------------------
    -- C. INSERTION DE 500 TERMINAUX
    -- -----------------------------------------------------
    -- 1 terminal par aéroport
    FOR i IN 1..500 LOOP
        INSERT INTO TERMINAL (terminal_name, terminal_number, capacity, airport_id)
        VALUES ('Terminal ' || CHR(65 + (i % 6)), (i % 5) + 1, 5000 + (i % 1000), i);
    END LOOP;

    -- -----------------------------------------------------
    -- D. INSERTION DE 500 PORTES (GATES)
    -- -----------------------------------------------------
    -- 1 porte par terminal pour respecter le quota de 500
    FOR i IN 1..500 LOOP
        INSERT INTO GATE (gate_number, status, max_passengers, terminal_id)
        VALUES ('Gate-' || i, CASE WHEN i % 5 = 0 THEN 'Maintenance' ELSE 'Open' END, 300, i);
    END LOOP;

    -- -----------------------------------------------------
    -- E. INSERTION DE 20,000 AVIONS (AIRCRAFT)
    -- -----------------------------------------------------
    FOR i IN 1..20000 LOOP
        -- Logique de fabricant réaliste
        IF i % 4 = 0 THEN 
            v_manufacturer := 'Boeing'; v_model := '737-MAX'; v_capacity := 180;
        ELSIF i % 4 = 1 THEN 
            v_manufacturer := 'Airbus'; v_model := 'A320neo'; v_capacity := 190;
        ELSIF i % 4 = 2 THEN 
            v_manufacturer := 'Embraer'; v_model := 'E195-E2'; v_capacity := 120;
        ELSE 
            v_manufacturer := 'Airbus'; v_model := 'A350-900'; v_capacity := 350;
        END IF;

        INSERT INTO AIRCRAFT (model, manufacturer, capacity, status)
        VALUES (v_model || ' (#' || i || ')', v_manufacturer, v_capacity, 'Active');
    END LOOP;

    -- -----------------------------------------------------
    -- F. INSERTION DE 20,000 VOLS (FLIGHT)
    -- -----------------------------------------------------
    FOR i IN 1..20000 LOOP
        INSERT INTO FLIGHT (flight_number, departure_time, arrival_time, status, route_id, aircraft_id)
        VALUES (
            'FL-' || i,
            -- Dates étalées sur l'année 2024
            TIMESTAMP '2024-01-01 00:00:00' + (i * INTERVAL '25 minutes'),
            TIMESTAMP '2024-01-01 03:00:00' + (i * INTERVAL '25 minutes'),
            CASE WHEN i % 20 = 0 THEN 'Delayed' ELSE 'On Time' END,
            (i % 500) + 1, -- Répartit sur les 500 routes existantes
            i              -- Utilise les 20,000 avions créés
        );
    END LOOP;

END $$;

-- -----------------------------------------------------
-- VÉRIFICATION FINALE
-- -----------------------------------------------------
SELECT 'AIRPORT' as table_name, COUNT(*) FROM AIRPORT
UNION ALL SELECT 'ROUTE', COUNT(*) FROM ROUTE
UNION ALL SELECT 'TERMINAL', COUNT(*) FROM TERMINAL
UNION ALL SELECT 'GATE', COUNT(*) FROM GATE
UNION ALL SELECT 'AIRCRAFT', COUNT(*) FROM AIRCRAFT
UNION ALL SELECT 'FLIGHT', COUNT(*) FROM FLIGHT;