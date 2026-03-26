-- -----------------------------------------------------
--      Querie 1
-- -----------------------------------------------------

-- Method A: Using JOIN and GROUP BY
-- Efficiency: High. PostgreSQL optimizes joins using Hash Joins or Merge Joins.
SELECT 
    a.name AS airport_name, 
    a.city, 
    EXTRACT(MONTH FROM f.departure_time) AS flight_month,
    COUNT(f.flight_id) AS total_departures
FROM AIRPORT a
JOIN ROUTE r ON a.airport_id = r.origin_airport_id
JOIN FLIGHT f ON r.route_id = f.route_id
WHERE EXTRACT(YEAR FROM f.departure_time) = 2024
GROUP BY a.airport_id, a.name, a.city, flight_month
ORDER BY total_departures DESC;

-- Method B: Correlated Subquery in SELECT (just for mai)
-- Efficiency: Lower. Executes the subquery for every single row in the AIRPORT table.
SELECT 
    a.name, 
    (SELECT COUNT(*) 
     FROM FLIGHT f 
     JOIN ROUTE r ON f.route_id = r.route_id 
     WHERE r.origin_airport_id = a.airport_id 
     AND EXTRACT(MONTH FROM f.departure_time) = 5) AS may_flights
FROM AIRPORT a
ORDER BY may_flights DESC;



-- -----------------------------------------------------
--      Querie 2
-- -----------------------------------------------------







-- -----------------------------------------------------
--      Querie 3
-- -----------------------------------------------------








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