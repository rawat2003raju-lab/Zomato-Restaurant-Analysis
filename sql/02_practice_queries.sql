-- ==========================================================
-- ZOMATO SQL PRACTICE  (table name: zomato)
-- Level 1: Basics | Level 2: GROUP BY | Level 3: Intermediate
-- Run the queries one at a time and read the output.
-- ==========================================================


-- ---------- CHECK THE DATA LOADED CORRECTLY ----------

-- Q0: Should return 9551 rows
SELECT COUNT(*) AS total_rows FROM zomato;

-- Q0b: Should return 2148 (the 'Not rated' restaurants have an EMPTY rating_clean)
-- If this shows 0, your import turned empty values into 0 - see the note in chat.
SELECT COUNT(*) AS not_rated FROM zomato WHERE rating_clean IS NULL;


-- ==========================================================
-- LEVEL 1: BASICS  (SELECT, WHERE, ORDER BY, LIMIT)
-- ==========================================================

-- Q1: Look at the first 10 rows
SELECT * FROM zomato LIMIT 10;

-- Q2: How many restaurants are in India?
SELECT COUNT(*) AS india_restaurants
FROM zomato
WHERE country = 'India';

-- Q3: How many different cities are in India?
SELECT COUNT(DISTINCT city) AS india_cities
FROM zomato
WHERE country = 'India';

-- Q4: Top 10 highest rated Indian restaurants (at least 100 votes)
SELECT restaurant_name, city, rating_clean, votes
FROM zomato
WHERE country = 'India' AND votes >= 100
ORDER BY rating_clean DESC, votes DESC
LIMIT 10;

-- Q5: Cheap restaurants in New Delhi with online delivery and rating 4 or more
SELECT restaurant_name, locality, cost_clean, rating_clean
FROM zomato
WHERE city = 'New Delhi'
  AND has_online_delivery = 'Yes'
  AND cost_clean <= 500
  AND rating_clean >= 4
ORDER BY rating_clean DESC
LIMIT 10;


-- ==========================================================
-- LEVEL 2: GROUP BY  (COUNT, AVG, HAVING)
-- ==========================================================

-- Q6: Number of restaurants in each country
SELECT country, COUNT(*) AS restaurants
FROM zomato
GROUP BY country
ORDER BY restaurants DESC;

-- Q7: Top 10 Indian cities by number of restaurants
SELECT city, COUNT(*) AS restaurants
FROM zomato
WHERE country = 'India'
GROUP BY city
ORDER BY restaurants DESC
LIMIT 10;

-- Q8: Average rating for each price range (India)
-- AVG() ignores the empty (NULL) ratings automatically
SELECT price_range,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
GROUP BY price_range
ORDER BY price_range;

-- Q9: Does online delivery change the rating and votes? (India)
SELECT has_online_delivery,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating,
       ROUND(AVG(votes), 1) AS avg_votes
FROM zomato
WHERE country = 'India'
GROUP BY has_online_delivery;

-- Q10: Does table booking change the rating and cost? (India)
SELECT has_table_booking,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating,
       ROUND(AVG(cost_clean), 0) AS avg_cost
FROM zomato
WHERE country = 'India'
GROUP BY has_table_booking;

-- Q11: Best rated cities with at least 20 restaurants
-- WHERE filters rows BEFORE grouping, HAVING filters groups AFTER grouping
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC
LIMIT 10;


-- ==========================================================
-- LEVEL 3: INTERMEDIATE  (CASE WHEN, subquery, LIKE, window function)
-- ==========================================================

-- Q12: Group restaurants into rating categories (CASE WHEN = if / else)
SELECT
    CASE
        WHEN rating_clean IS NULL THEN 'Not rated'
        WHEN rating_clean >= 4.5 THEN 'Excellent'
        WHEN rating_clean >= 4.0 THEN 'Very Good'
        WHEN rating_clean >= 3.0 THEN 'Average'
        ELSE 'Poor'
    END AS rating_category,
    COUNT(*) AS restaurants
FROM zomato
WHERE country = 'India'
GROUP BY rating_category
ORDER BY restaurants DESC;

-- Q13: Restaurants rated ABOVE the India average (subquery)
-- The query inside the brackets runs first and gives one number
SELECT restaurant_name, city, rating_clean
FROM zomato
WHERE country = 'India'
  AND rating_clean > (SELECT AVG(rating_clean)
                      FROM zomato
                      WHERE country = 'India')
ORDER BY rating_clean DESC, votes DESC
LIMIT 10;

-- Q14: Biggest chains in India (same name, many outlets)
SELECT restaurant_name,
       COUNT(*) AS outlets,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
GROUP BY restaurant_name
HAVING COUNT(*) >= 5
ORDER BY outlets DESC
LIMIT 10;

-- Q15: How many restaurants serve North Indian food? (LIKE with %)
-- Cuisines are stored like 'North Indian, Chinese', so we search inside the text
SELECT COUNT(*) AS north_indian_restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
  AND cuisines LIKE '%North Indian%';

-- Q16: Hidden gems = high rating, low cost, many votes
SELECT restaurant_name, city, cuisines, cost_clean, rating_clean, votes
FROM zomato
WHERE country = 'India'
  AND rating_clean >= 4.0
  AND cost_clean <= 500
  AND votes >= 200
ORDER BY rating_clean DESC, votes DESC
LIMIT 10;

-- Q17 (Challenge): Top 3 most voted restaurants in each of the 4 biggest cities
-- RANK() OVER (PARTITION BY ...) numbers the rows inside each city
SELECT city, restaurant_name, votes, rank_in_city
FROM (
    SELECT city, restaurant_name, votes,
           RANK() OVER (PARTITION BY city ORDER BY votes DESC) AS rank_in_city
    FROM zomato
    WHERE city IN ('New Delhi', 'Gurgaon', 'Noida', 'Faridabad')
) AS ranked
WHERE rank_in_city <= 3
ORDER BY city, rank_in_city;
