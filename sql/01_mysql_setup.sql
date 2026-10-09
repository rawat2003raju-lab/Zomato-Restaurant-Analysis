-- ==========================================================
-- ZOMATO - MySQL setup (matches zomato_sql_ready.csv)
-- Step 1: create table | Step 2: import | Step 3: check
-- ==========================================================

-- ---------- STEP 1: Create the table ----------
-- Column names match the CSV header exactly (no spaces),
-- so the queries in zomato_sql_queries.sql work without changes.
DROP TABLE IF EXISTS zomato;

CREATE TABLE zomato (
    restaurant_id       INT PRIMARY KEY,
    restaurant_name     VARCHAR(150),
    country_code        INT,
    city                VARCHAR(60),
    address             VARCHAR(255),
    locality            VARCHAR(150),
    locality_verbose    VARCHAR(255),
    longitude           DOUBLE,
    latitude            DOUBLE,
    cuisines            VARCHAR(255),
    avg_cost_for_two    INT,
    currency            VARCHAR(50),
    has_table_booking   VARCHAR(10),
    has_online_delivery VARCHAR(10),
    is_delivering_now   VARCHAR(10),
    price_range         INT,
    aggregate_rating    DECIMAL(2,1),
    rating_color        VARCHAR(50),
    rating_text         VARCHAR(50),
    votes               INT,
    country             VARCHAR(50),
    rating_clean        DECIMAL(2,1) NULL,   -- empty = Not rated
    cost_clean          DOUBLE NULL,         -- empty = cost was 0
    latitude_clean      DOUBLE NULL,         -- empty = location missing
    longitude_clean     DOUBLE NULL
) CHARACTER SET utf8mb4;


-- ---------- STEP 2: Import the CSV ----------
-- OPTION A (easiest): Table Data Import Wizard
--   Right-click the table "zomato" > Table Data Import Wizard > pick
--   zomato_sql_ready.csv > "Use existing table" > encoding utf-8.
--   Columns match by name, so just click Next until it finishes.
--
-- OPTION B (use this if Option A shows an error about empty/incorrect values):
--   Change the file path below, then run the statement.
--   NULLIF(@x, '') turns empty text into a real NULL.
--   If you get "local_infile" error, first run:  SET GLOBAL local_infile = 1;
--   and turn on "Allow local infile" in your connection settings.

LOAD DATA LOCAL INFILE 'C:/path/to/zomato_sql_ready.csv'
INTO TABLE zomato
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'          -- if rows look glued together, use '\r\n'
IGNORE 1 LINES
(restaurant_id, restaurant_name, country_code, city, address, locality,
 locality_verbose, longitude, latitude, cuisines, avg_cost_for_two, currency,
 has_table_booking, has_online_delivery, is_delivering_now, price_range,
 aggregate_rating, rating_color, rating_text, votes, country,
 @rating_clean, @cost_clean, @latitude_clean, @longitude_clean)
SET rating_clean    = NULLIF(@rating_clean, ''),
    cost_clean      = NULLIF(@cost_clean, ''),
    latitude_clean  = NULLIF(@latitude_clean, ''),
    longitude_clean = NULLIF(@longitude_clean, '');


-- ---------- STEP 3: Check the import ----------
-- Expected: 9551
SELECT COUNT(*) AS total_rows FROM zomato;

-- Expected: rating_clean 2148 | cost_clean 18 | latitude_clean 498
SELECT SUM(rating_clean   IS NULL) AS missing_rating,
       SUM(cost_clean     IS NULL) AS missing_cost,
       SUM(latitude_clean IS NULL) AS missing_latitude
FROM zomato;

-- If the numbers above show 0 instead, empty values became 0. Fix with:
-- UPDATE zomato SET rating_clean   = NULL WHERE rating_clean   = 0;
-- UPDATE zomato SET cost_clean     = NULL WHERE cost_clean     = 0;
-- UPDATE zomato SET latitude_clean = NULL, longitude_clean = NULL WHERE latitude_clean = 0;
