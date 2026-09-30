-- RAPID E-COMMERCE DATA ANALYSIS PROJECT
-- PostgreSQL + Power BI



-- 1. TABLE CREATION

DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPRICE NUMERIC(5,2),
    availableQuantity INTEGER,
    discountSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,
    quantity INTEGER
);


-- Rename columns

ALTER TABLE zepto
RENAME COLUMN discountPRICE TO discountPercent;

ALTER TABLE zepto
RENAME COLUMN discountSellingPrice TO discountedSellingPrice;



-- 2. DATA EXPLORATION

-- Count total number of products

SELECT COUNT(*) AS total_products
FROM zepto;


-- View sample data

SELECT *
FROM zepto
LIMIT 10;


-- Check for NULL values

SELECT *
FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;


-- Find different product categories

SELECT DISTINCT category
FROM zepto
ORDER BY category;


-- Products in stock vs out of stock

SELECT
    outOfStock,
    COUNT(sku_id) AS product_count
FROM zepto
GROUP BY outOfStock;


-- Product names appearing multiple times

SELECT
    name,
    COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;



-- 3. DATA CLEANING

-- Find products with zero price

SELECT *
FROM zepto
WHERE mrp = 0
   OR discountedSellingPrice = 0;


-- Remove products with zero MRP

DELETE FROM zepto
WHERE mrp = 0;


-- Convert prices from paise to rupees

UPDATE zepto
SET
    mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;



-- 4. BUSINESS ANALYSIS



-- Q1. Top 10 products with the highest discount percentage

SELECT
    name,
    mrp,
    discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;


-- Business Insight:
-- Identifies products receiving the highest discounts,
-- helping businesses evaluate promotional strategies and
-- understand which products are heavily discounted.




-- Q2. High-MRP products that are currently out of stock

SELECT DISTINCT
    name AS "Out Of Stock Products",
    mrp
FROM zepto
WHERE outOfStock = TRUE
  AND mrp > 300
ORDER BY mrp DESC;


-- Business Insight:
-- Highlights high-value products that are unavailable,
-- helping businesses prioritize inventory replenishment
-- and reduce potential lost sales.


-- Q3. Estimated inventory value by category

SELECT
    category,
    ROUND(
        SUM(discountedSellingPrice * availableQuantity),
        2
    ) AS estimated_inventory_value
FROM zepto
GROUP BY category
ORDER BY estimated_inventory_value DESC;


-- Business Insight:
-- Identifies categories holding the highest estimated
-- inventory value, helping businesses understand where
-- most of their inventory capital is concentrated.




-- Q4. Products with MRP greater than Rs. 500
-- and discount percentage below 10%

SELECT DISTINCT
    name,
    mrp,
    discountPercent
FROM zepto
WHERE mrp > 500
  AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Business Insight:
-- Identifies relatively expensive products with limited
-- discounts, helping businesses evaluate pricing strategies
-- and customers identify products offering fewer discounts.




-- Q5. Top 5 categories with the highest average discount

SELECT
    category,
    ROUND(AVG(discountPercent), 2) AS average_discount
FROM zepto
GROUP BY category
ORDER BY average_discount DESC
LIMIT 5;


-- Business Insight:
-- Shows which categories rely more heavily on discounts,
-- helping businesses evaluate category-level promotional
-- strategies and discount patterns.



-- Q6. Price per gram for products weighing at least 100 grams

SELECT DISTINCT
    name,
    weightInGms,
    discountedSellingPrice,
    ROUND(
        discountedSellingPrice / weightInGms,
        2
    ) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
  AND weightInGms > 0
ORDER BY price_per_gram;


-- Business Insight:
-- Enables comparison of products based on price per gram,
-- helping identify relatively cost-effective products and
-- supporting pricing and product-value analysis.




-- Q7. Classify products based on weight

SELECT DISTINCT
    name,
    weightInGms,
    CASE
        WHEN weightInGms < 1000 THEN 'Low'
        WHEN weightInGms < 5000 THEN 'Medium'
        ELSE 'Bulk'
    END AS weight_category
FROM zepto
ORDER BY weightInGms;

-- Business Insight:
-- Groups products into Low, Medium and Bulk weight segments,
-- helping businesses understand product mix and potentially
-- plan packaging, storage and inventory handling strategies.



-- Q8. Total inventory weight by category

SELECT
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;


-- Business Insight:
-- Identifies categories with the largest physical inventory
-- weight, helping businesses plan warehouse capacity,
-- storage requirements and inventory management.

