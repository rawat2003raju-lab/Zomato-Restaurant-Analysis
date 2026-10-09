# Zomato Restaurant Analysis using SQL (MySQL)

An SQL project that answers business questions about 9,551 restaurants across 15 countries, using MySQL. It covers importing data, data quality checks, aggregation, subqueries, CTEs and window functions, and building summary tables.

- **Author:** Raju Rawat | [LinkedIn](https://www.linkedin.com/in/raju-rawat-4a6233251/)
- **Dataset:** Zomato restaurants dataset, 9,551 rows, 21 columns, 141 cities. Source: `<add dataset link here>`
- **Tools:** MySQL 8, MySQL Workbench, Python (pandas) for data preparation

## Business problem

A restaurant-discovery platform wants to understand its listings. For example:
- Where are the restaurants, and how is the data spread across cities?
- Does a higher price mean a better rating?
- Do online delivery and table booking go with better ratings or more votes?
- Do big chains rate better than independent restaurants?
- Which restaurants give the best value (high rating, low cost, many votes)?

## SQL skills demonstrated

| Skill | Where it is used |
|---|---|
| `SELECT`, `WHERE`, `AND`/`OR`, `LIKE`, `ORDER BY`, `LIMIT` | `sql/03_basic_queries.sql` |
| `GROUP BY`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX` | `sql/04_aggregation_queries.sql` |
| `HAVING` (vs `WHERE`), `SUM(condition)` for percentages | `sql/04_aggregation_queries.sql` |
| Subqueries (in `WHERE` and `HAVING`) | `sql/04_...`, `sql/05_...` |
| `CASE WHEN`, `UNION ALL`, `LEFT JOIN`, CTE (`WITH`) | `sql/05_advanced_queries.sql` |
| Window functions: `RANK()`, `AVG() OVER`, `SUM() OVER` | `sql/05_advanced_queries.sql` |
| `CREATE TABLE ... AS SELECT`, `ALTER TABLE`, `UPDATE` | `sql/06_create_summary_tables.sql` |
| Data quality checks and handling `NULL` values | `sql/02_data_quality_checks.sql` |
| Table design and `LOAD DATA` import | `sql/01_create_table_and_import.sql` |

## Project structure

```
data/
  raw/Zomato_Restaurant_Dataset.csv   original file
  zomato_sql_ready.csv                cleaned file with simple column names (loaded into MySQL)
python/
  01_data_cleaning.py                 fixes found in the raw data (see below)
  02_make_sql_ready.py                renames columns for MySQL
sql/
  01_create_table_and_import.sql      create the table, import the CSV, check the import
  02_data_quality_checks.sql          10 checks on the loaded data
  03_basic_queries.sql                10 basic queries
  04_aggregation_queries.sql          15 GROUP BY / HAVING queries
  05_advanced_queries.sql             10 queries with CASE, CTE, subqueries, window functions
  06_create_summary_tables.sql        new tables built from queries
```

## How to run

1. Open MySQL Workbench and run `sql/01_create_table_and_import.sql`. It creates the `zomato` table. Import `data/zomato_sql_ready.csv` using the Table Data Import Wizard, or the `LOAD DATA` statement in the file (change the file path first).
2. Check the import: the table should have **9,551** rows, **2,148** missing `rating_clean`, **18** missing `cost_clean`.
3. Run the other files in order. Run queries one at a time and read the output.

The `python/` scripts are optional. They rebuild `zomato_sql_ready.csv` from the raw file (run from the project root, with `pip install pandas`). The window-function queries and CTEs need MySQL 8.0 or later.

## Data preparation

The raw file needed some cleaning before analysis. The original columns are kept and the cleaned values are in new `..._clean` columns.

| Issue | Rows | Handling |
|---|---|---|
| Rating 0 means "Not rated", not a bad score | 2,148 | `rating_clean` is `NULL` |
| Latitude and longitude of 0 (location missing) | about 498 | set to `NULL` |
| Average cost for two = 0 | 18 | `cost_clean` is `NULL` |
| Philippines labelled with the wrong currency (Botswana Pula) | 22 | relabelled Philippine Peso |
| Garbled characters in 3 city names and the pound sign | 54 + 80 | fixed by hand |
| Missing cuisines | 9 | filled with `Unknown` |
| `Switch to order menu` is "No" in every row | all | column dropped |
| Costs in 12 currencies | all | cost questions are filtered to India |

No duplicate rows or duplicate restaurant IDs were found (checks DQ2 and DQ3).

## Key findings

All findings are for India unless stated, and each one comes from a query in the `sql/` folder.

**1. The data is mostly Delhi NCR.** India has 8,652 of the 9,551 restaurants. New Delhi (63.3%), Gurgaon (12.9%), Noida (12.5%) and Faridabad (2.9%) together make up 91.6% of the Indian rows (query V5). Every other city has about 20 restaurants or fewer.

**2. Higher price range goes with better ratings.** Average rating is 3.20, 3.31, 3.68 and 3.73 for price ranges 1 to 4 (A8). Among rated restaurants, about 31% in range 4 are "Very Good" or "Excellent", against under 4% in range 1 (V1).

**3. Table booking goes with higher ratings and much higher cost.** Restaurants with booking average a 3.55 rating and about ₹1,570 for two, against 3.31 and ₹485 without it (A10).

**4. Online delivery goes with more votes, not better ratings.** Average rating is about the same (3.37 vs 3.34), but restaurants with delivery average 209 votes against 109 (A9). 28% of Indian restaurants offer delivery.

**5. Chains rate slightly lower than independent restaurants.** 1,375 restaurants belong to chains (names with 5+ outlets) and average 3.23, against 3.38 for 7,277 independents (V7). Cafe Coffee Day (83 outlets, 3.00) and Domino's Pizza (79 outlets, 2.93) are among the lowest, while Barbeque Nation (25 outlets, 4.35) is a clear exception (V6).

**6. Italian and Cafe restaurants rate higher than the most common cuisines.** Italian averages 3.71 and Cafe 3.63, against 3.29 for North Indian and 3.27 for Chinese (A13).

**7. Most restaurants are rated "Average".** 39.1% fall in that band, 22.5% are not rated, and only 3.2% are "Excellent" (A5).

## Limitations

- About 90% of the Indian data is Delhi NCR. Results for other cities rest on about 20 restaurants each, so they are not comparable with New Delhi, and city rankings should be read with care.
- Costs are in local currencies, so cost comparisons only make sense within one country.
- 22.5% of restaurants have no rating, and unrated restaurants are more common among cheaper ones. The rating averages for cheap restaurants rest on fewer places than the group size suggests.
- `price_range` bands overlap in rupee terms (check DQ9), so `cost_clean` is used when the real price matters.
- This is a snapshot, so the findings show association, not cause. For example, delivery restaurants having more votes does not show that delivery causes more votes.

## Next steps

- Build a dashboard (Power BI or Tableau) from the `city_summary` table
- Split the comma-separated `cuisines` column into its own table to analyse single cuisines properly
- Convert costs to one currency to compare countries
