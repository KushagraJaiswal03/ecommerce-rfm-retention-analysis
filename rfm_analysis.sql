-- E-Commerce Customer Analytics
-- RFM Segmentation (PostgreSQL)

-- Step 1: Build per-customer Recency, Frequency, Monetary base metrics
WITH reference_date AS (
    SELECT MAX(order_purchase_timestamp) + INTERVAL '1 day' AS ref_date
    FROM orders
),
customer_orders AS (
    SELECT
        c.customer_unique_id,
        o.order_id,
        o.order_purchase_timestamp
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
customer_value AS (
    SELECT
        co.customer_unique_id,
        co.order_id,
        SUM(oi.price + oi.freight_value) AS order_value
    FROM customer_orders co
    JOIN order_items oi ON co.order_id = oi.order_id
    GROUP BY co.customer_unique_id, co.order_id
)
SELECT
    co.customer_unique_id,
    (SELECT ref_date FROM reference_date)::date - MAX(co.order_purchase_timestamp)::date AS recency_days,
    COUNT(DISTINCT co.order_id) AS frequency,
    ROUND(SUM(cv.order_value), 2) AS monetary
INTO rfm_base
FROM customer_orders co
JOIN customer_value cv ON co.order_id = cv.order_id
GROUP BY co.customer_unique_id;

-- Step 2: Score each customer on R/F/M using quintiles
CREATE TABLE rfm_scored AS
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_base;

-- Step 3: Combine scores into business-readable segments
SELECT
    customer_unique_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,
    (r_score + f_score + m_score) AS rfm_total,
    CASE
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 4 AND m_score >= 4 THEN 'At Risk (High Value)'
        WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
        ELSE 'Regular'
    END AS segment
INTO rfm_segments
FROM rfm_scored;

-- Step 4: Segment-level revenue summary
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(monetary), 2) AS avg_spend,
    ROUND(SUM(monetary), 2) AS total_revenue,
    ROUND(SUM(monetary) / (SELECT SUM(monetary) FROM rfm_segments) * 100, 2) AS pct_of_total_revenue
FROM rfm_segments
GROUP BY segment
ORDER BY total_revenue DESC;
