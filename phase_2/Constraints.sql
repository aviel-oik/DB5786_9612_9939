-- =============================================================================
-- Constraints.sql
-- הוספת אילוצים (Constraints) לבסיס הנתונים ובדיקת תקינותם
-- =============================================================================

-- -----------------------------------------------------
-- 1. אילוץ על טבלת AIRCRAFT: הגבלת קיבולת מקסימלית
-- תיאור: הוספת אילוץ המבטיח שקיבולת המטוס לא תעלה על 1000 נוסעים (גבול עליון ריאלי).
-- -----------------------------------------------------

-- א. הוספת האילוץ
ALTER TABLE AIRCRAFT 
ADD CONSTRAINT check_max_capacity CHECK (capacity <= 1000);

-- ב. ניסיון הכנסה שסותר את האילוץ (צפוי להיכשל)
-- שגיאה צפויה: new row for relation "aircraft" violates check constraint "check_max_capacity"
INSERT INTO AIRCRAFT (model, manufacturer, capacity, status) 
VALUES ('Super Plane', 'FutureJet', 1500, 'Active');


-- -----------------------------------------------------
-- 2. אילוץ על טבלת AIRPORT: תקינות קוד IATA
-- תיאור: הוספת אילוץ המבטיח שקוד ה-IATA יכיל בדיוק 3 אותיות גדולות בלבד (A-Z).
-- -----------------------------------------------------

-- א. הוספת האילוץ
ALTER TABLE AIRPORT 
ADD CONSTRAINT check_iata_format CHECK (iata_code ~ '^[A-Z]{3}$');

-- ב. ניסיון הכנסה שסותר את האילוץ (צפוי להיכשל - מכיל מספרים)
-- שגיאה צפויה: new row for relation "airport" violates check constraint "check_iata_format"
INSERT INTO AIRPORT (name, city, region, country, iata_code, timezone) 
VALUES ('Test Airport', 'Test City', 'Test Region', 'Test Country', '123', 'UTC+2');


-- -----------------------------------------------------
-- 3. אילוץ על טבלת FLIGHT: הגבלת ערכי סטטוס
-- תיאור: הוספת אילוץ המגביל את שדה הסטטוס לערכים מוגדרים מראש בלבד.
-- -----------------------------------------------------

-- א. הוספת האילוץ
ALTER TABLE FLIGHT 
ADD CONSTRAINT check_flight_status_values 
CHECK (status IN ('Scheduled', 'On Time', 'Delayed', 'Cancelled', 'Arrived'));

-- ב. ניסיון הכנסה שסותר את האילוץ (צפוי להיכשל - סטטוס לא חוקי)
-- שגיאה צפויה: new row for relation "flight" violates check constraint "check_flight_status_values"
INSERT INTO FLIGHT (flight_number, departure_time, arrival_time, status, route_id, aircraft_id) 
VALUES ('XX-999', NOW(), NOW() + INTERVAL '2 hours', 'In-The-Air', 1, 1);


-- -----------------------------------------------------
-- 4. אילוץ על טבלת GATE: מינימום נוסעים בשער
-- תיאור: הוספת אילוץ המבטיח שקיבולת השער (max_passengers) חייבת להיות גדולה מ-0.
-- -----------------------------------------------------

-- א. הוספת האילוץ
ALTER TABLE GATE 
ADD CONSTRAINT check_positive_passengers CHECK (max_passengers > 0);

-- ב. ניסיון הכנסה שסותר את האילוץ (צפוי להיכשל - ערך שלילי)
-- שגיאה צפויה: new row for relation "gate" violates check constraint "check_positive_passengers"
INSERT INTO GATE (gate_number, status, max_passengers, terminal_id) 
VALUES ('Gate-Error', 'Open', -50, 1);


-- -----------------------------------------------------
-- 5. אילוץ על טבלת TERMINAL: קיבולת טרמינל מינימלית
-- תיאור: הבטחה שטרמינל לא יוקם עם קיבולת נמוכה מ-100 איש.
-- -----------------------------------------------------

-- א. הוספת האילוץ
ALTER TABLE TERMINAL 
ADD CONSTRAINT check_terminal_min_capacity CHECK (capacity >= 100);

-- ב. ניסיון הכנסה שסותר את האילוץ (צפוי להיכשל)
-- שגיאה צפויה: new row for relation "terminal" violates check constraint "check_terminal_min_capacity"
INSERT INTO TERMINAL (terminal_name, terminal_number, capacity, airport_id) 
VALUES ('Tiny Terminal', '99', 50, 1);