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








-- -----------------------------------------------------
--      Querie 5
-- -----------------------------------------------------







-- -----------------------------------------------------
--      Querie 6
-- -----------------------------------------------------









-- -----------------------------------------------------
--      Querie 7
-- -----------------------------------------------------










-- -----------------------------------------------------
--      Querie 8
-- -----------------------------------------------------