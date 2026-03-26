-- -----------------------------------------------------
--      Querie 1
-- -----------------------------------------------------

-- Method A: 
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

-- Method B: 
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