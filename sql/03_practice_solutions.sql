-- ==========================================================
-- ZOMATO SQL - PRACTICE QUESTIONS AND SOLUTIONS  (table: zomato)
-- Needs MySQL 8.0+ for the window functions (Q15-Q16, Q18-Q19)
-- For cost questions we filter to India, because other countries
-- use other currencies.
-- ==========================================================


-- ---------- BASIC ----------

-- Q1: The 10 cheapest restaurants in New Delhi
SELECT restaurant_name, locality, price_range, cost_clean
FROM zomato
WHERE city = 'New Delhi'
  AND cost_clean IS NOT NULL
ORDER BY cost_clean ASC, restaurant_name
LIMIT 10;

-- Q2: The 10 most expensive restaurants in New Delhi
SELECT restaurant_name, locality, price_range, cost_clean
FROM zomato
WHERE city = 'New Delhi'
  AND cost_clean IS NOT NULL
ORDER BY cost_clean DESC, restaurant_name
LIMIT 10;

-- Q3: Restaurants with BOTH table booking and online delivery
SELECT restaurant_name, city, has_table_booking, has_online_delivery
FROM zomato
WHERE has_table_booking = 'Yes'
  AND has_online_delivery = 'Yes';

-- Q4: Connaught Place restaurants rated above 4
SELECT restaurant_name, city, locality, rating_clean
FROM zomato
WHERE rating_clean > 4
  AND locality = 'Connaught Place'
ORDER BY rating_clean DESC;

-- Q5: How many restaurants have 0 votes?
SELECT COUNT(*) AS zero_vote_restaurants
FROM zomato
WHERE votes = 0;

-- Q6: Restaurants serving BOTH Chinese and North Indian food
-- LIKE '%word%' looks for the word anywhere inside the text
SELECT restaurant_name, city, cuisines
FROM zomato
WHERE cuisines LIKE '%Chinese%'
  AND cuisines LIKE '%North Indian%';


-- ---------- GROUP BY ----------

-- Q7: Average cost for two in each Indian city
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(AVG(cost_clean), 0) AS avg_cost
FROM zomato
WHERE country = 'India'
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY avg_cost DESC;

-- Q8: Total votes in each city, and votes per restaurant
SELECT city,
       COUNT(*) AS restaurants,
       SUM(votes) AS total_votes,
       ROUND(AVG(votes), 1) AS avg_votes_per_restaurant
FROM zomato
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY total_votes DESC;

-- Q9: Number and percentage of restaurants for each rating_text
SELECT rating_text,
       COUNT(*) AS restaurant_count,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM zomato), 1) AS pct
FROM zomato
GROUP BY rating_text
ORDER BY restaurant_count DESC;

-- Q10: New Delhi localities with at least 30 restaurants, best rated first
-- HAVING (not WHERE) is used because COUNT(*) is calculated AFTER grouping
SELECT locality,
       COUNT(*) AS total_restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE city = 'New Delhi'
GROUP BY locality
HAVING COUNT(*) >= 30
ORDER BY avg_rating DESC;

-- Q11: Minimum, maximum and average cost in each price range (India)
SELECT price_range,
       COUNT(*) AS restaurants,
       MIN(cost_clean) AS minimum,
       MAX(cost_clean) AS maximum,
       ROUND(AVG(cost_clean), 2) AS avg_cost
FROM zomato
WHERE country = 'India'
GROUP BY price_range
ORDER BY price_range;

-- Q12: Percentage of restaurants with online delivery in each Indian city
-- SUM(condition) counts the rows where the condition is true
SELECT city,
       COUNT(*) AS restaurants,
       SUM(has_online_delivery = 'Yes') AS with_delivery,
       ROUND(100.0 * SUM(has_online_delivery = 'Yes') / COUNT(*), 1) AS pct_delivery
FROM zomato
WHERE country = 'India'
GROUP BY city
HAVING COUNT(*) >= 20
ORDER BY pct_delivery DESC;

-- Q13: Average rating of cuisine combinations (India, at least 20 restaurants)
SELECT cuisines,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
GROUP BY cuisines
HAVING COUNT(*) >= 20
ORDER BY avg_rating DESC;

-- Q14: Compare single cuisines (UNION ALL stacks several queries)
SELECT 'Italian' AS cuisine, COUNT(*) AS restaurants, ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato WHERE country = 'India' AND cuisines LIKE '%Italian%'
UNION ALL
SELECT 'Cafe', COUNT(*), ROUND(AVG(rating_clean), 2)
FROM zomato WHERE country = 'India' AND cuisines LIKE '%Cafe%'
UNION ALL
SELECT 'Chinese', COUNT(*), ROUND(AVG(rating_clean), 2)
FROM zomato WHERE country = 'India' AND cuisines LIKE '%Chinese%'
UNION ALL
SELECT 'North Indian', COUNT(*), ROUND(AVG(rating_clean), 2)
FROM zomato WHERE country = 'India' AND cuisines LIKE '%North Indian%'
ORDER BY avg_rating DESC;


-- ---------- INTERMEDIATE ----------

-- Q15: How do the rating categories split across the price ranges? (India)
-- Percentages are out of RATED restaurants only
SELECT price_range,
       ROUND(100.0 * SUM(rating_text = 'Excellent') / SUM(rating_text <> 'Not rated'), 1) AS pct_excellent,
       ROUND(100.0 * SUM(rating_text = 'Very Good') / SUM(rating_text <> 'Not rated'), 1) AS pct_very_good,
       ROUND(100.0 * SUM(rating_text = 'Good')      / SUM(rating_text <> 'Not rated'), 1) AS pct_good,
       ROUND(100.0 * SUM(rating_text = 'Average')   / SUM(rating_text <> 'Not rated'), 1) AS pct_average,
       ROUND(100.0 * SUM(rating_text = 'Poor')      / SUM(rating_text <> 'Not rated'), 1) AS pct_poor
FROM zomato
WHERE country = 'India'
GROUP BY price_range
ORDER BY price_range;

-- Q16: Cities whose average rating is above the India average (subquery)
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating
FROM zomato
WHERE country = 'India'
GROUP BY city
HAVING COUNT(*) >= 20
   AND AVG(rating_clean) > (SELECT AVG(rating_clean)
                            FROM zomato
                            WHERE country = 'India')
ORDER BY avg_rating DESC;

-- Q17: Restaurants costing more than the India average (subquery)
SELECT restaurant_name, city, cost_clean
FROM zomato
WHERE country = 'India'
  AND cost_clean > (SELECT AVG(cost_clean)
                    FROM zomato
                    WHERE country = 'India')
ORDER BY cost_clean DESC;

-- Q18: Restaurants costing more than the average of THEIR OWN city (window function)
SELECT restaurant_name, city, cost_clean, ROUND(city_avg_cost, 0) AS city_avg_cost
FROM (
    SELECT restaurant_name, city, cost_clean,
           AVG(cost_clean) OVER (PARTITION BY city) AS city_avg_cost
    FROM zomato
    WHERE country = 'India'
) AS t
WHERE cost_clean > city_avg_cost
ORDER BY cost_clean DESC;

-- Q19: What share of all Indian restaurants is in each city?
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_india
FROM zomato
WHERE country = 'India'
GROUP BY city
ORDER BY restaurants DESC;

-- Q20: Top 3 rated restaurants in each locality (localities with 30+ rated restaurants)
SELECT city, locality, restaurant_name, rating_clean, votes, rank_in_locality
FROM (
    SELECT city, locality, restaurant_name, rating_clean, votes,
           COUNT(*) OVER (PARTITION BY city, locality) AS restaurants_in_locality,
           RANK() OVER (PARTITION BY city, locality
                        ORDER BY rating_clean DESC, votes DESC) AS rank_in_locality
    FROM zomato
    WHERE country = 'India'
      AND rating_clean IS NOT NULL
) AS ranked
WHERE rank_in_locality <= 3
  AND restaurants_in_locality >= 30
ORDER BY city, locality, rank_in_locality;


-- ---------- CREATING NEW TABLES ----------

-- Q21: An India-only table with a rating category column
DROP TABLE IF EXISTS zomato_india;

CREATE TABLE zomato_india AS
SELECT restaurant_id, restaurant_name, city, locality, cuisines,
       price_range, has_table_booking, has_online_delivery,
       cost_clean, rating_clean, votes,
       CASE
           WHEN rating_clean IS NULL THEN 'Not rated'
           WHEN rating_clean >= 4.5 THEN 'Excellent'
           WHEN rating_clean >= 4.0 THEN 'Very Good'
           WHEN rating_clean >= 3.0 THEN 'Average'
           ELSE 'Poor'
       END AS rating_category
FROM zomato
WHERE country = 'India';

-- Q22: A city summary table (one row per city)
DROP TABLE IF EXISTS city_summary;

CREATE TABLE city_summary AS
SELECT city,
       COUNT(*) AS restaurants,
       ROUND(AVG(rating_clean), 2) AS avg_rating,
       ROUND(AVG(cost_clean), 0) AS avg_cost,
       SUM(votes) AS total_votes
FROM zomato_india
GROUP BY city;
