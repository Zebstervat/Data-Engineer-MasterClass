-- ============================================================
-- WEEK 1: COMPLETE SQL QUERY BANK
-- All queries run against the Olist Brazilian E-Commerce dataset
-- ============================================================


-- ============================================================
-- MONDAY: SQL FOUNDATIONS
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 1. SELECT BASICS — Retrieving data
-- ────────────────────────────────────────────────────────────

-- Get everything from the orders table (first 10 rows)
SELECT TOP 10 * FROM olist_orders_dataset;

-- Select specific columns only
SELECT order_id, customer_id, order_status
FROM olist_orders_dataset;

-- Select specific columns with a friendly alias
SELECT
    order_id AS "Order ID",
    order_status AS "Status",
    order_purchase_timestamp AS "Purchased At"
FROM olist_orders_dataset;

-- Select unique/distinct values — what order statuses exist?
SELECT DISTINCT order_status
FROM olist_orders_dataset;

-- Count how many rows are in the table
SELECT COUNT(*) AS total_orders
FROM olist_orders_dataset;

-- Select top 20 most recent orders
SELECT TOP 20
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
ORDER BY order_purchase_timestamp DESC;


-- ────────────────────────────────────────────────────────────
-- 2. WHERE — Filtering rows
-- ────────────────────────────────────────────────────────────

-- Equality: only delivered orders
SELECT order_id, order_status
FROM olist_orders_dataset
WHERE order_status = 'delivered';

-- Not equal: everything except delivered
SELECT order_id, order_status
FROM olist_orders_dataset
WHERE order_status != 'delivered';

-- Greater than: expensive items (price over 500 reais)
SELECT order_id, product_id, price
FROM olist_order_items_dataset
WHERE price > 500
ORDER BY price DESC;

-- Less than: cheap shipping (freight under 10)
SELECT order_id, product_id, price, freight_value
FROM olist_order_items_dataset
WHERE freight_value < 10;

-- BETWEEN: items priced between 100 and 200
SELECT product_id, price
FROM olist_order_items_dataset
WHERE price BETWEEN 100 AND 200
ORDER BY price;

-- LIKE: cities starting with 'sao'
SELECT DISTINCT customer_city
FROM olist_customers_dataset
WHERE customer_city LIKE 'sao%';

-- LIKE: cities containing 'paulo'
SELECT DISTINCT customer_city
FROM olist_customers_dataset
WHERE customer_city LIKE '%paulo%';

-- IN: customers from three specific states
SELECT customer_id, customer_city, customer_state
FROM olist_customers_dataset
WHERE customer_state IN ('SP', 'RJ', 'MG');

-- AND: expensive items with cheap shipping
SELECT order_id, price, freight_value
FROM olist_order_items_dataset
WHERE price > 200
  AND freight_value < 15;

-- OR: canceled or unavailable orders
SELECT order_id, order_status
FROM olist_orders_dataset
WHERE order_status = 'canceled'
   OR order_status = 'unavailable';

-- IS NULL: orders that were never delivered
SELECT order_id, order_status, order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NULL;

-- IS NOT NULL: orders that were delivered
SELECT order_id, order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL;

-- Combining multiple conditions
SELECT order_id, order_status, order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp < '2018-04-01';


-- ────────────────────────────────────────────────────────────
-- 3. ORDER BY — Sorting results
-- ────────────────────────────────────────────────────────────

-- Sort by price ascending (cheapest first)
SELECT product_id, price
FROM olist_order_items_dataset
ORDER BY price ASC;

-- Sort by price descending (most expensive first)
SELECT TOP 20 product_id, price
FROM olist_order_items_dataset
ORDER BY price DESC;

-- Sort by multiple columns
SELECT customer_state, customer_city
FROM olist_customers_dataset
ORDER BY customer_state ASC, customer_city ASC;

-- Top 10 highest freight costs
SELECT TOP 10 order_id, product_id, freight_value
FROM olist_order_items_dataset
ORDER BY freight_value DESC;


-- ────────────────────────────────────────────────────────────
-- 4. GROUP BY + AGGREGATION — Summarizing data
-- ────────────────────────────────────────────────────────────

-- COUNT: how many orders per status?
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;

-- COUNT: how many customers per state?
SELECT
    customer_state,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;

-- SUM: total revenue per seller
SELECT TOP 20
    seller_id,
    SUM(price) AS total_revenue,
    COUNT(*) AS items_sold
FROM olist_order_items_dataset
GROUP BY seller_id
ORDER BY total_revenue DESC;

-- AVG: average price per product category
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS avg_price,
    COUNT(*) AS items_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY avg_price DESC;

-- MIN and MAX: price range per category
SELECT
    p.product_category_name,
    MIN(oi.price) AS cheapest,
    MAX(oi.price) AS most_expensive,
    MAX(oi.price) - MIN(oi.price) AS price_range
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY price_range DESC;

-- All five aggregate functions in one query
SELECT
    customer_state,
    COUNT(*) AS total_orders,
    ROUND(AVG(payment_value), 2) AS avg_payment,
    ROUND(SUM(payment_value), 2) AS total_revenue,
    MIN(payment_value) AS smallest_payment,
    MAX(payment_value) AS biggest_payment
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY customer_state
ORDER BY total_revenue DESC;

-- HAVING: only states with more than 1000 orders
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) > 1000
ORDER BY total_revenue DESC;

-- HAVING with AVG: categories where average price > 200
SELECT
    p.product_category_name,
    ROUND(AVG(oi.price), 2) AS avg_price,
    COUNT(*) AS items_sold
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
HAVING AVG(oi.price) > 200
ORDER BY avg_price DESC;

-- COUNT DISTINCT: how many unique customers per state?
SELECT
    customer_state,
    COUNT(DISTINCT customer_city) AS unique_cities,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY unique_cities DESC;

-- Group by month: orders over time
SELECT
    FORMAT(order_purchase_timestamp, 'yyyy-MM') AS order_month,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
GROUP BY FORMAT(order_purchase_timestamp, 'yyyy-MM')
ORDER BY order_month;


-- ────────────────────────────────────────────────────────────
-- 5. JOINs — Connecting tables
-- ────────────────────────────────────────────────────────────

-- INNER JOIN: orders with their items
SELECT
    o.order_id,
    o.order_status,
    oi.product_id,
    oi.price
FROM olist_orders_dataset o
INNER JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
ORDER BY oi.price DESC;

-- INNER JOIN: orders with customer info
SELECT
    o.order_id,
    c.customer_city,
    c.customer_state,
    o.order_status
FROM olist_orders_dataset o
INNER JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
WHERE c.customer_state = 'SP';

-- INNER JOIN: orders with payment details
SELECT
    o.order_id,
    o.order_status,
    p.payment_type,
    p.payment_value
FROM olist_orders_dataset o
INNER JOIN olist_order_payments_dataset p
    ON o.order_id = p.order_id
ORDER BY p.payment_value DESC;

-- What payment types are most popular?
SELECT
    p.payment_type,
    COUNT(*) AS times_used,
    ROUND(AVG(p.payment_value), 2) AS avg_amount
FROM olist_order_payments_dataset p
GROUP BY p.payment_type
ORDER BY times_used DESC;

-- Multi-table JOIN: order + customer + item + product (4 tables!)
SELECT TOP 50
    o.order_id,
    c.customer_city,
    c.customer_state,
    p.product_category_name,
    oi.price
FROM olist_orders_dataset o
INNER JOIN olist_customers_dataset c
    ON o.customer_id = c.customer_id
INNER JOIN olist_order_items_dataset oi
    ON o.order_id = oi.order_id
INNER JOIN olist_products_dataset p
    ON oi.product_id = p.product_id
WHERE c.customer_state = 'SP'
ORDER BY oi.price DESC;

-- LEFT JOIN vs INNER JOIN: see the difference
-- INNER: only orders WITH reviews
SELECT COUNT(*) AS orders_with_reviews
FROM olist_orders_dataset o
INNER JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id;

-- LEFT: ALL orders, even without reviews
SELECT COUNT(*) AS all_orders_incl_no_reviews
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id;

-- LEFT JOIN: find orders WITHOUT reviews (NULLs)
SELECT TOP 20
    o.order_id,
    o.order_status,
    r.review_score
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r
    ON o.order_id = r.order_id
WHERE r.review_score IS NULL;

-- JOIN with aggregation: average review score per state
SELECT
    c.customer_state,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review,
    COUNT(*) AS total_reviews
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
GROUP BY c.customer_state
HAVING COUNT(*) > 100
ORDER BY avg_review DESC;

-- Revenue by product category (3-table JOIN + GROUP BY)
SELECT TOP 15
    p.product_category_name,
    COUNT(*) AS items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN olist_orders_dataset o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;


-- ============================================================
-- WEDNESDAY: ADVANCED SQL
-- ============================================================


-- ────────────────────────────────────────────────────────────
-- 6. SUBQUERIES — Queries inside queries
-- ────────────────────────────────────────────────────────────

-- Scalar subquery: items priced above average
SELECT order_id, product_id, price
FROM olist_order_items_dataset
WHERE price > (
    SELECT AVG(price) FROM olist_order_items_dataset
)
ORDER BY price DESC;

-- Subquery in WHERE: customers who placed orders in 2018
SELECT DISTINCT customer_id, customer_city, customer_state
FROM olist_customers_dataset
WHERE customer_id IN (
    SELECT customer_id
    FROM olist_orders_dataset
    WHERE order_purchase_timestamp >= '2018-01-01'
);

-- Subquery: sellers who sold the most expensive item
SELECT seller_id, price
FROM olist_order_items_dataset
WHERE price = (
    SELECT MAX(price) FROM olist_order_items_dataset
);

-- Subquery with NOT IN: states with NO canceled orders
SELECT DISTINCT customer_state
FROM olist_customers_dataset
WHERE customer_state NOT IN (
    SELECT DISTINCT c.customer_state
    FROM olist_customers_dataset c
    JOIN olist_orders_dataset o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'canceled'
);


-- ────────────────────────────────────────────────────────────
-- 7. CASE WHEN — Conditional logic
-- ────────────────────────────────────────────────────────────

-- Categorize items by price tier
SELECT
    order_id,
    product_id,
    price,
    CASE
        WHEN price > 500 THEN 'Premium'
        WHEN price > 100 THEN 'Standard'
        WHEN price > 30  THEN 'Budget'
        ELSE 'Bargain'
    END AS price_tier
FROM olist_order_items_dataset
ORDER BY price DESC;

-- Categorize review scores
SELECT
    review_score,
    CASE
        WHEN review_score >= 4 THEN 'Positive'
        WHEN review_score = 3 THEN 'Neutral'
        ELSE 'Negative'
    END AS sentiment,
    COUNT(*) AS total
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score DESC;

-- CASE with aggregation: count orders by delivery speed
SELECT
    CASE
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 7 THEN 'Fast (1 week)'
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 14 THEN 'Normal (2 weeks)'
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 30 THEN 'Slow (1 month)'
        ELSE 'Very slow (1+ month)'
    END AS delivery_speed,
    COUNT(*) AS total_orders
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
GROUP BY
    CASE
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 7 THEN 'Fast (1 week)'
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 14 THEN 'Normal (2 weeks)'
        WHEN DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date) <= 30 THEN 'Slow (1 month)'
        ELSE 'Very slow (1+ month)'
    END
ORDER BY total_orders DESC;

-- CASE inside SUM: pivot-style counting
SELECT
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN o.order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN o.order_status = 'canceled' THEN 1 ELSE 0 END) AS canceled,
    SUM(CASE WHEN o.order_status = 'shipped' THEN 1 ELSE 0 END) AS shipped
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- ────────────────────────────────────────────────────────────
-- 8. WINDOW FUNCTIONS — Compute without collapsing rows
-- ────────────────────────────────────────────────────────────

-- ROW_NUMBER: rank items by price within each order
SELECT
    order_id,
    product_id,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY order_id
        ORDER BY price DESC
    ) AS item_rank
FROM olist_order_items_dataset;

-- RANK: rank sellers by total revenue
SELECT
    seller_id,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM (
    SELECT
        seller_id,
        ROUND(SUM(price), 2) AS total_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
) AS seller_stats;

-- DENSE_RANK: rank states by order count (no gaps)
SELECT
    customer_state,
    order_count,
    DENSE_RANK() OVER (ORDER BY order_count DESC) AS state_rank
FROM (
    SELECT
        c.customer_state,
        COUNT(*) AS order_count
    FROM olist_orders_dataset o
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
) AS state_orders;

-- Running total: cumulative revenue by month
SELECT
    order_month,
    monthly_revenue,
    SUM(monthly_revenue) OVER (ORDER BY order_month) AS running_total
FROM (
    SELECT
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        ROUND(SUM(p.payment_value), 2) AS monthly_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
) AS monthly;

-- LAG: compare each month's revenue to the previous month
SELECT
    order_month,
    monthly_revenue,
    LAG(monthly_revenue, 1) OVER (ORDER BY order_month) AS prev_month_revenue,
    ROUND(monthly_revenue - LAG(monthly_revenue, 1) OVER (ORDER BY order_month), 2) AS month_over_month_change
FROM (
    SELECT
        FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS order_month,
        ROUND(SUM(p.payment_value), 2) AS monthly_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
) AS monthly
ORDER BY order_month;

-- NTILE: divide customers into 4 spending quartiles
SELECT
    customer_id,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spending_quartile
FROM (
    SELECT
        o.customer_id,
        ROUND(SUM(p.payment_value), 2) AS total_spent
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    GROUP BY o.customer_id
) AS customer_spending;


-- ────────────────────────────────────────────────────────────
-- 9. CTEs — Common Table Expressions
-- ────────────────────────────────────────────────────────────

-- Simple CTE: top 10 states by revenue
WITH state_revenue AS (
    SELECT
        c.customer_state,
        ROUND(SUM(p.payment_value), 2) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
)
SELECT *
FROM state_revenue
WHERE total_revenue > 100000
ORDER BY total_revenue DESC;

-- CTE with calculation: revenue per order by state
WITH state_stats AS (
    SELECT
        c.customer_state,
        COUNT(DISTINCT o.order_id) AS total_orders,
        ROUND(SUM(p.payment_value), 2) AS total_revenue
    FROM olist_orders_dataset o
    JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
    JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    total_orders,
    total_revenue,
    ROUND(total_revenue / total_orders, 2) AS revenue_per_order
FROM state_stats
ORDER BY revenue_per_order DESC;

-- Multiple CTEs: compare category performance
WITH category_sales AS (
    SELECT
        p.product_category_name,
        COUNT(*) AS items_sold,
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
),
category_reviews AS (
    SELECT
        p.product_category_name,
        ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    JOIN olist_order_reviews_dataset r ON oi.order_id = r.order_id
    GROUP BY p.product_category_name
)
SELECT
    s.product_category_name,
    s.items_sold,
    s.total_revenue,
    r.avg_review
FROM category_sales s
JOIN category_reviews r ON s.product_category_name = r.product_category_name
WHERE s.items_sold > 100
ORDER BY s.total_revenue DESC;

-- CTE + window function: rank categories by revenue
WITH category_revenue AS (
    SELECT
        p.product_category_name,
        ROUND(SUM(oi.price), 2) AS total_revenue
    FROM olist_order_items_dataset oi
    JOIN olist_products_dataset p ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT
    product_category_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM category_revenue
ORDER BY revenue_rank;


-- ────────────────────────────────────────────────────────────
-- 10. BONUS: Real business questions
-- ────────────────────────────────────────────────────────────

-- What is the average delivery time by state?
SELECT
    c.customer_state,
    ROUND(AVG(DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date)), 1) AS avg_delivery_days,
    COUNT(*) AS total_delivered
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) > 100
ORDER BY avg_delivery_days;

-- Which product categories have the worst reviews?
SELECT
    p.product_category_name,
    ROUND(AVG(CAST(r.review_score AS FLOAT)), 2) AS avg_review,
    COUNT(*) AS total_reviews
FROM olist_order_items_dataset oi
JOIN olist_products_dataset p ON oi.product_id = p.product_id
JOIN olist_order_reviews_dataset r ON oi.order_id = r.order_id
GROUP BY p.product_category_name
HAVING COUNT(*) > 50
ORDER BY avg_review ASC;

-- Monthly revenue trend
SELECT
    FORMAT(o.order_purchase_timestamp, 'yyyy-MM') AS month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(p.payment_value), 2) AS revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
WHERE o.order_status = 'delivered'
GROUP BY FORMAT(o.order_purchase_timestamp, 'yyyy-MM')
ORDER BY month;

-- Top 10 cities by revenue
SELECT TOP 10
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(p.payment_value), 2) AS total_revenue
FROM olist_orders_dataset o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_payments_dataset p ON o.order_id = p.order_id
GROUP BY c.customer_city, c.customer_state
ORDER BY total_revenue DESC;

-- Late deliveries: which orders arrived after the estimated date?
SELECT TOP 20
    o.order_id,
    o.order_estimated_delivery_date,
    o.order_delivered_customer_date,
    DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date) AS days_late
FROM olist_orders_dataset o
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
ORDER BY days_late DESC;
