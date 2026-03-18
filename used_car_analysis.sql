-- ============================================================
-- Used Car Market Analysis
-- Author: Steve Myette
-- Dataset: 7,253 used car listings across 11 Indian cities
-- Purpose: Identify pricing drivers and market trends to
--          support data-driven inventory and acquisition decisions
-- ============================================================


-- ============================================================
-- SECTION 1: MARKET OVERVIEW
-- ============================================================

-- 1A. Overall market summary
-- High-level snapshot of the dataset
SELECT
    COUNT(*)                        AS total_listings,
    COUNT(DISTINCT SUBSTR(Name, 1, INSTR(Name, ' ') - 1))
                                    AS unique_brands,
    COUNT(DISTINCT Location)        AS cities,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price,
    ROUND(MIN(CAST(Price AS FLOAT)), 2)     AS min_price,
    ROUND(MAX(CAST(Price AS FLOAT)), 2)     AS max_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != '';


-- 1B. Listings by city
-- Understand where inventory is concentrated
SELECT
    Location,
    COUNT(*)                                AS total_listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY Location
ORDER BY total_listings DESC;


-- 1C. Listings by fuel type
-- Market share and pricing by fuel type
SELECT
    Fuel_Type,
    COUNT(*)                                AS total_listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price,
    ROUND(MIN(CAST(Price AS FLOAT)), 2)     AS min_price,
    ROUND(MAX(CAST(Price AS FLOAT)), 2)     AS max_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY Fuel_Type
ORDER BY total_listings DESC;


-- ============================================================
-- SECTION 2: BRAND & MODEL ANALYSIS
-- ============================================================

-- 2A. Average price by brand
-- Extract brand from the Name field and rank by average price
SELECT
    SUBSTR(Name, 1, INSTR(Name, ' ') - 1)  AS brand,
    COUNT(*)                                AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price,
    ROUND(MIN(CAST(Price AS FLOAT)), 2)     AS min_price,
    ROUND(MAX(CAST(Price AS FLOAT)), 2)     AS max_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY brand
HAVING COUNT(*) >= 10
ORDER BY avg_price DESC;


-- 2B. Best value brands
-- Brands with the highest ratio of listings under 10 lakh
-- Useful for budget inventory acquisition
SELECT
    SUBSTR(Name, 1, INSTR(Name, ' ') - 1)  AS brand,
    COUNT(*)                                AS total_listings,
    SUM(CASE WHEN CAST(Price AS FLOAT) < 10 THEN 1 ELSE 0 END)
                                            AS budget_listings,
    ROUND(
        100.0 * SUM(CASE WHEN CAST(Price AS FLOAT) < 10 THEN 1 ELSE 0 END) / COUNT(*),
        1
    )                                       AS pct_budget
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY brand
HAVING COUNT(*) >= 10
ORDER BY pct_budget DESC;


-- ============================================================
-- SECTION 3: DEPRECIATION & VALUE RETENTION
-- ============================================================

-- 3A. Average price by vehicle age
-- How does age affect price across the market?
SELECT
    (2025 - CAST(Year AS INT))              AS age_years,
    COUNT(*)                                AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY age_years
HAVING COUNT(*) >= 5
ORDER BY age_years ASC;


-- 3B. Price retention by transmission type
-- Do automatic or manual cars hold value better?
SELECT
    Transmission,
    COUNT(*)                                AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price,
    ROUND(AVG(CAST(Kilometers_Driven AS FLOAT)), 0)
                                            AS avg_km_driven
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY Transmission
ORDER BY avg_price DESC;


-- 3C. Impact of ownership history on price
-- First owner vs second vs third — how much does it matter?
SELECT
    Owner_Type,
    COUNT(*)                                AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price,
    ROUND(AVG(CAST(Kilometers_Driven AS FLOAT)), 0)
                                            AS avg_km_driven
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
GROUP BY Owner_Type
ORDER BY avg_price DESC;


-- ============================================================
-- SECTION 4: MILEAGE & USAGE ANALYSIS
-- ============================================================

-- 4A. Price by kilometers driven bucket
-- Segment vehicles into usage tiers and compare pricing
SELECT
    CASE
        WHEN CAST(Kilometers_Driven AS INT) < 20000  THEN '0–20K km'
        WHEN CAST(Kilometers_Driven AS INT) < 50000  THEN '20K–50K km'
        WHEN CAST(Kilometers_Driven AS INT) < 100000 THEN '50K–100K km'
        WHEN CAST(Kilometers_Driven AS INT) < 150000 THEN '100K–150K km'
        ELSE '150K+ km'
    END                                             AS usage_tier,
    COUNT(*)                                        AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)             AS avg_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
  AND Kilometers_Driven IS NOT NULL AND Kilometers_Driven != ''
GROUP BY usage_tier
ORDER BY avg_price DESC;


-- 4B. Fuel efficiency vs price
-- Do more fuel-efficient cars command a premium?
SELECT
    CASE
        WHEN CAST(REPLACE(Mileage, ' kmpl', '') AS FLOAT) < 10  THEN 'Under 10 kmpl'
        WHEN CAST(REPLACE(Mileage, ' kmpl', '') AS FLOAT) < 15  THEN '10–15 kmpl'
        WHEN CAST(REPLACE(Mileage, ' kmpl', '') AS FLOAT) < 20  THEN '15–20 kmpl'
        WHEN CAST(REPLACE(Mileage, ' kmpl', '') AS FLOAT) < 25  THEN '20–25 kmpl'
        ELSE '25+ kmpl'
    END                                             AS efficiency_tier,
    COUNT(*)                                        AS listings,
    ROUND(AVG(CAST(Price AS FLOAT)), 2)             AS avg_price
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
  AND Mileage IS NOT NULL AND Mileage != ''
GROUP BY efficiency_tier
ORDER BY avg_price DESC;


-- ============================================================
-- SECTION 5: PRICING OPPORTUNITY ANALYSIS
-- ============================================================

-- 5A. Potential underpriced listings
-- Cars where price is significantly below the average
-- for their brand, year, and fuel type combination
-- Useful for identifying acquisition targets
SELECT
    used_cars.Name,
    used_cars.Location,
    used_cars.Year,
    used_cars.Kilometers_Driven,
    used_cars.Fuel_Type,
    used_cars.Transmission,
    CAST(used_cars.Price AS FLOAT)          AS listing_price,
    ROUND(brand_avg.avg_price, 2)           AS brand_avg_price,
    ROUND(brand_avg.avg_price - CAST(used_cars.Price AS FLOAT), 2)
                                            AS discount_vs_avg
FROM used_cars
JOIN (
    SELECT
        SUBSTR(Name, 1, INSTR(Name, ' ') - 1)  AS brand,
        Fuel_Type,
        ROUND(AVG(CAST(Price AS FLOAT)), 2)     AS avg_price
    FROM used_cars
    WHERE Price IS NOT NULL AND Price != ''
    GROUP BY brand, Fuel_Type
    HAVING COUNT(*) >= 5
) brand_avg
ON SUBSTR(used_cars.Name, 1, INSTR(used_cars.Name, ' ') - 1) = brand_avg.brand
AND used_cars.Fuel_Type = brand_avg.Fuel_Type
WHERE used_cars.Price IS NOT NULL AND used_cars.Price != ''
  AND (brand_avg.avg_price - CAST(used_cars.Price AS FLOAT)) > 5
ORDER BY discount_vs_avg DESC
LIMIT 20;


-- 5B. Price per kilometer — value efficiency metric
-- Which listings offer the most car per rupee per km?
SELECT
    Name,
    Location,
    Year,
    Kilometers_Driven,
    CAST(Price AS FLOAT)                    AS price,
    ROUND(
        CAST(Price AS FLOAT) /
        NULLIF(CAST(Kilometers_Driven AS FLOAT), 0) * 100000,
        4
    )                                       AS price_per_100k_km
FROM used_cars
WHERE Price IS NOT NULL AND Price != ''
  AND Kilometers_Driven IS NOT NULL
  AND CAST(Kilometers_Driven AS INT) > 0
ORDER BY price_per_100k_km ASC
LIMIT 20;
