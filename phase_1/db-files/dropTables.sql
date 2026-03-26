-- ==========================================
-- dropTables.sql
-- מחיקת הטבלאות בסדר הפוך להגדרתן
-- כדי למנוע שגיאות של Foreign Key constraints
-- ==========================================

-- 1. מחיקת טבלאות ה"ילד" (אלו שיש להן מפתחות זרים לאחרות)
DROP TABLE IF EXISTS GATE;
DROP TABLE IF EXISTS FLIGHT;

-- 2. מחיקת טבלאות הביניים
DROP TABLE IF EXISTS TERMINAL;
DROP TABLE IF EXISTS ROUTE;

-- 3. מחיקת טבלאות ה"אב" (אלו שלא תלויות באף טבלה אחרת)
DROP TABLE IF EXISTS AIRCRAFT;
DROP TABLE IF EXISTS AIRPORT;

-- הערה: השימוש ב-IF EXISTS מונע שגיאה במידה והטבלה כבר נמחקה או לא קיימת.