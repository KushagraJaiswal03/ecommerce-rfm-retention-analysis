-- E-Commerce Customer Analytics
-- Cohort & Retention Analysis (PostgreSQL)

-- Step 1: Identify each customer's first purchase month (their cohort)
CREATE TABLE customer_cohort AS
SELECT
    c.customer_unique_id,
    DATE_TRUNC('month', MIN(o.order_purchase_timestamp))::date AS cohort_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_unique_id;

-- Step 2: Map every order to the customer's cohort month
CREATE TABLE order_activity AS
SELECT
    c.customer_unique_id,
    cc.cohort_month,
    DATE_TRUNC('month', o.order_purchase_timestamp)::date AS order_month
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN customer_cohort cc ON c.customer_unique_id = cc.customer_unique_id
WHERE o.order_status = 'delivered';

-- Step 3: Calculate months since first purchase, and active customers per cohort/month
CREATE TABLE cohort_retention AS
SELECT
    cohort_month,
    order_month,
    (DATE_PART('year', order_month) - DATE_PART('year', cohort_month)) * 12 +
    (DATE_PART('month', order_month) - DATE_PART('month', cohort_month)) AS months_since_first_purchase,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM order_activity
GROUP BY cohort_month, order_month
ORDER BY cohort_month, order_month;

-- Step 4: Get total cohort size per starting month
CREATE TABLE cohort_size AS
SELECT cohort_month, COUNT(DISTINCT customer_unique_id) AS cohort_customers
FROM customer_cohort
GROUP BY cohort_month;

-- Step 5: Blended retention curve across all cohorts (months 0-6)
SELECT
    cr.months_since_first_purchase,
    SUM(cr.active_customers) AS total_active,
    SUM(cs.cohort_customers) AS total_cohort_base,
    ROUND(SUM(cr.active_customers)::numeric / SUM(cs.cohort_customers) * 100, 2) AS avg_retention_pct
FROM cohort_retention cr
JOIN cohort_size cs ON cr.cohort_month = cs.cohort_month
WHERE cr.months_since_first_purchase BETWEEN 0 AND 6
GROUP BY cr.months_since_first_purchase
ORDER BY cr.months_since_first_purchase;
