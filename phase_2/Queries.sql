-- -----------------------------------------------------
--      Querie 1
-- -----------------------------------------------------


-- Version A: 
SELECT a.airport_id, 
       a.name, 
       COUNT(f.flight_id) AS total_flights
FROM AIRPORT a
JOIN ROUTE r ON a.airport_id = r.origin_airport_id
JOIN FLIGHT f ON r.route_id = f.route_id
WHERE EXTRACT(MONTH FROM f.departure_time) = 5 
  AND EXTRACT(YEAR FROM f.departure_time) = 2024
GROUP BY a.airport_id, a.name
ORDER BY total_flights DESC;


-- Version B: 
SELECT a.airport_id, 
       a.name, 
       sub.flight_count AS total_flights
FROM AIRPORT a
JOIN (
    SELECT r.origin_airport_id, COUNT(*) AS flight_count
    FROM FLIGHT f
    JOIN ROUTE r ON f.route_id = r.route_id
    WHERE EXTRACT(MONTH FROM f.departure_time) = 5
      AND EXTRACT(YEAR FROM f.departure_time) = 2024
    GROUP BY r.origin_airport_id
) sub ON a.airport_id = sub.origin_airport_id
ORDER BY total_flights DESC;




-- -----------------------------------------------------
--      Querie 2
-- -----------------------------------------------------


-- Version A: Standard Joins with Subquery in HAVING
SELECT 
    a.airport_id, 
    a.name AS airport_name, 
    a.city, 
    SUM(ac.capacity) AS total_departure_capacity,
    COUNT(f.flight_id) AS flight_count
FROM AIRPORT a
JOIN ROUTE r ON a.airport_id = r.origin_airport_id
JOIN FLIGHT f ON r.route_id = f.route_id
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
WHERE a.region = 'Region 1'
GROUP BY a.airport_id, a.name, a.city
HAVING SUM(ac.capacity) > (
    -- Subquery calculating the average total capacity per airport across the whole system
    SELECT AVG(airport_total_cap)
    FROM (
        SELECT r2.origin_airport_id, SUM(ac2.capacity) AS airport_total_cap
        FROM FLIGHT f2
        JOIN ROUTE r2 ON f2.route_id = r2.route_id
        JOIN AIRCRAFT ac2 ON f2.aircraft_id = ac2.aircraft_id
        GROUP BY r2.origin_airport_id
    ) system_averages
)
ORDER BY total_departure_capacity DESC;


-- Version B: Using CTE (WITH clause) --
WITH SystemCapacities AS (
    -- Pre-calculate the total capacity for every airport
    SELECT r2.origin_airport_id, SUM(ac2.capacity) AS airport_sum
    FROM FLIGHT f2
    JOIN ROUTE r2 ON f2.route_id = r2.route_id
    JOIN AIRCRAFT ac2 ON f2.aircraft_id = ac2.aircraft_id
    GROUP BY r2.origin_airport_id
),
GlobalAverage AS (
    -- Calculate the single average value from the pre-calculated sums
    SELECT AVG(airport_sum) AS avg_val FROM SystemCapacities
)
SELECT 
    a.airport_id, 
    a.name, 
    a.city, 
    SUM(ac.capacity) AS total_departure_capacity
FROM AIRPORT a
JOIN ROUTE r ON a.airport_id = r.origin_airport_id
JOIN FLIGHT f ON r.route_id = f.route_id
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
CROSS JOIN GlobalAverage
WHERE a.region = 'Region 1'
GROUP BY a.airport_id, a.name, a.city, GlobalAverage.avg_val
HAVING SUM(ac.capacity) > GlobalAverage.avg_val
ORDER BY total_departure_capacity DESC;




-- -----------------------------------------------------
--      Querie 3
-- -----------------------------------------------------


-- Version A: Standard Multiple Joins
SELECT 
    f.flight_number, 
    f.departure_time, 
    ac.model AS aircraft_model, 
    a.name AS origin_airport, 
    a.country
FROM FLIGHT f
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
JOIN ROUTE r ON f.route_id = r.route_id
JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
WHERE ac.manufacturer = 'Airbus' 
  AND a.country = 'Country 5'
ORDER BY f.departure_time ASC;


-- Version B: Using IN with Subqueries
SELECT 
    f.flight_number, 
    f.departure_time,
    (SELECT model FROM AIRCRAFT WHERE aircraft_id = f.aircraft_id) AS aircraft_model,
    (SELECT name FROM AIRPORT WHERE airport_id = (SELECT origin_airport_id FROM ROUTE WHERE route_id = f.route_id)) AS origin_airport
FROM FLIGHT f
WHERE f.aircraft_id IN (
    SELECT aircraft_id FROM AIRCRAFT WHERE manufacturer = 'Airbus'
)
AND f.route_id IN (
    SELECT route_id FROM ROUTE 
    WHERE origin_airport_id IN (SELECT airport_id FROM AIRPORT WHERE country = 'Country 5')
)
ORDER BY f.departure_time ASC;





-- -----------------------------------------------------
--      Querie 4
-- -----------------------------------------------------


-- Version A: Using JOIN and DISTINCT to ensure unique rows
SELECT DISTINCT 
    ac.manufacturer, 
    ac.model, 
    ac.capacity
FROM AIRCRAFT ac
JOIN FLIGHT f ON ac.aircraft_id = f.aircraft_id
JOIN ROUTE r ON f.route_id = r.route_id
JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
WHERE a.country = 'Country 10'
ORDER BY ac.manufacturer, ac.model;


-- Version B: Using EXISTS (Avoids duplicates by design)
SELECT 
    ac.manufacturer, 
    ac.model, 
    ac.capacity
FROM AIRCRAFT ac
WHERE EXISTS (
    -- Check if this aircraft has at least one flight departing from Country 10
    SELECT 1 
    FROM FLIGHT f
    JOIN ROUTE r ON f.route_id = r.route_id
    JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
    WHERE f.aircraft_id = ac.aircraft_id
    AND a.country = 'Country 10'
)
ORDER BY ac.manufacturer, ac.model;




-- -----------------------------------------------------
--      Querie 5
-- -----------------------------------------------------


SELECT 
    a.region AS airport_region,
    EXTRACT(MONTH FROM f.departure_time) AS flight_month,
    EXTRACT(YEAR FROM f.departure_time) AS flight_year,
    COUNT(f.flight_id) AS total_delayed_flights,
    ROUND(AVG(ac.capacity), 0) AS avg_capacity_delayed_planes
FROM FLIGHT f
JOIN ROUTE r ON f.route_id = r.route_id
JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
WHERE f.status = 'Delayed'
GROUP BY a.region, flight_year, flight_month
HAVING COUNT(f.flight_id) > 0
ORDER BY flight_year DESC, flight_month DESC, total_delayed_flights DESC;




-- -----------------------------------------------------
--      Querie 6
-- -----------------------------------------------------


SELECT 
    a.name AS airport_name,
    t.terminal_name,
    EXTRACT(DOW FROM f.departure_time) AS day_numeric, -- 0 for Sunday, 1 for Monday...
    TO_CHAR(f.departure_time, 'Day') AS day_name,     -- Full name of the day
    SUM(ac.capacity) AS total_passenger_capacity,
    COUNT(f.flight_id) AS number_of_flights,
    ROUND(AVG(ac.capacity), 2) AS avg_passengers_per_flight
FROM FLIGHT f
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
JOIN ROUTE r ON f.route_id = r.route_id
JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
JOIN TERMINAL t ON a.airport_id = t.airport_id
WHERE f.departure_time >= '2024-01-01'
GROUP BY a.airport_id, a.name, t.terminal_id, t.terminal_name, day_numeric, day_name
HAVING SUM(ac.capacity) > 500 -- Only showing busy terminal days
ORDER BY a.name, day_numeric ASC;




-- -----------------------------------------------------
--      Querie 7
-- -----------------------------------------------------


SELECT 
    a.name AS airport_name,
    EXTRACT(MONTH FROM f.departure_time) AS flight_month,
    CASE 
        WHEN EXTRACT(HOUR FROM f.departure_time) BETWEEN 5 AND 11 THEN 'Morning Shift (05:00-12:00)'
        WHEN EXTRACT(HOUR FROM f.departure_time) BETWEEN 12 AND 17 THEN 'Afternoon Shift (12:00-18:00)'
        WHEN EXTRACT(HOUR FROM f.departure_time) BETWEEN 18 AND 23 THEN 'Evening Shift (18:00-00:00)'
        ELSE 'Night Shift (00:00-05:00)'
    END AS shift_category,
    COUNT(f.flight_id) AS flight_count
FROM FLIGHT f
JOIN ROUTE r ON f.route_id = r.route_id
JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
WHERE a.region = 'Region 1'
GROUP BY a.name, flight_month, shift_category
ORDER BY flight_month, a.name, shift_category;




-- -----------------------------------------------------
--      Querie 8
-- -----------------------------------------------------


SELECT 
    a.country,
    COUNT(f.flight_id) AS num_delayed_flights,
    SUM(ac.capacity) AS total_impacted_seats,
    ROUND(AVG(ac.capacity), 2) AS avg_seats_per_delayed_flight
FROM AIRPORT a
JOIN ROUTE r ON a.airport_id = r.origin_airport_id
JOIN FLIGHT f ON r.route_id = f.route_id
JOIN AIRCRAFT ac ON f.aircraft_id = ac.aircraft_id
WHERE f.status = 'Delayed'
GROUP BY a.country
HAVING COUNT(f.flight_id) > 5 -- Only showing countries with significant delay issues
ORDER BY total_impacted_seats DESC;




-- -----------------------------------------------------
--      Querie DELETE 1
-- -----------------------------------------------------


-- Delete Query 1: Infrastructure Consolidation
-- Deleting maintenance gates in low-capacity terminals
DELETE FROM GATE
WHERE status = 'Maintenance'
AND terminal_id IN (
    -- Subquery: Find IDs of terminals with capacity below 5500
    SELECT terminal_id 
    FROM TERMINAL 
    WHERE capacity < 5500
);




-- -----------------------------------------------------
--      Querie DELETE 2
-- -----------------------------------------------------


-- Delete Query 2: Fleet Modernization
-- Deleting flights assigned to small Embraer aircraft (Capacity 120)
DELETE FROM FLIGHT
WHERE aircraft_id IN (
    -- Subquery: Find IDs of all Embraer aircraft based on their fixed capacity
    SELECT aircraft_id 
    FROM AIRCRAFT 
    WHERE capacity = 120 
    AND manufacturer = 'Embraer'
);




-- -----------------------------------------------------
--      Querie DELETE 3
-- -----------------------------------------------------


-- Delete Query 3: Security Lockdown
-- Deleting scheduled 'On Time' flights departing from Region 1
DELETE FROM FLIGHT
WHERE status = 'On Time'
AND route_id IN (
    -- Subquery: Find routes starting from any airport in Region 1
    SELECT route_id 
    FROM ROUTE 
    WHERE origin_airport_id IN (
        SELECT airport_id 
        FROM AIRPORT 
        WHERE region = 'Region 1'
    )
);





-- -----------------------------------------------------
--      Querie UPDATE 1
-- -----------------------------------------------------


-- Update Query 1: Safety Regulation Capacity Adjustment
-- Updates aircraft capacity based on departure country
UPDATE AIRCRAFT
SET capacity = ROUND(capacity * 0.9)
WHERE aircraft_id IN (
    -- Subquery: Find all aircraft IDs that are currently assigned to flights
    -- departing from airports in 'Country 1'
    SELECT f.aircraft_id
    FROM FLIGHT f
    JOIN ROUTE r ON f.route_id = r.route_id
    JOIN AIRPORT a ON r.origin_airport_id = a.airport_id
    WHERE a.country = 'Country 1'
);




-- -----------------------------------------------------
--      Querie UPDATE 2
-- -----------------------------------------------------


-- Update Query 2: Regional Strike Impact
-- Mass update of flight status and arrival times in a specific region
UPDATE FLIGHT
SET status = 'Delayed',
    arrival_time = arrival_time + INTERVAL '3 hours'
WHERE status = 'On Time'
AND route_id IN (
    -- Subquery: Find routes starting from airports in Region 5
    SELECT route_id 
    FROM ROUTE 
    WHERE origin_airport_id IN (
        SELECT airport_id 
        FROM AIRPORT 
        WHERE region = 'Region 5'
    )
);




-- -----------------------------------------------------
--      Querie UPDATE 3
-- -----------------------------------------------------


-- Update Query 3: Terminal Software Upgrade
-- Closing all open gates for maintenance in specific named terminals
UPDATE GATE
SET status = 'Maintenance'
WHERE status = 'Open'
AND terminal_id IN (
    -- Subquery: Find IDs of all terminals named 'Terminal C'
    SELECT terminal_id 
    FROM TERMINAL 
    WHERE terminal_name = 'Terminal C'
);
