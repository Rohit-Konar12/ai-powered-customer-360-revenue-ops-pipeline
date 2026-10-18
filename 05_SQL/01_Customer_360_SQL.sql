CREATE DATABASE customer_360;
use customer_360;
CREATE TABLE customers_raw (
customer_id CHAR(36) NOT NULL,
first_name VARCHAR(50),
last_name VARCHAR(50),
email VARCHAR(100) NULL,
phone_number VARCHAR(30),
gender CHAR(1),
dob DATE,
signup_date DATE,
address VARCHAR(100),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(100),
device_ids VARCHAR(255),
source VARCHAR(20)
);
SELECT COUNT(*) FROM customers_raw;                        
SELECT COUNT(*) FROM customers_raw WHERE email IS NULL;    
SELECT COUNT(DISTINCT customer_id) FROM customers_raw;     
-- New table with the same structure
CREATE TABLE customers LIKE customers_raw;
INSERT INTO customers
SELECT customer_id, first_name, last_name, email, phone_number, gender, dob, signup_date, address, city, state, country, device_ids, source
FROM (SELECT c.*, ROW_NUMBER() OVER ( PARTITION BY customer_id ORDER BY (email LIKE CONCAT(first_name, '.', last_name, '%')) DESC, CHAR_LENGTH(first_name) + CHAR_LENGTH(last_name) ASC ) AS rn
FROM customers_raw c
) t
WHERE rn = 1;
ALTER TABLE customers ADD PRIMARY KEY (customer_id);
SELECT COUNT(*) FROM customers;                      
SELECT COUNT(DISTINCT customer_id) FROM customers;   
SELECT COUNT(*) FROM customers WHERE email IS NULL; 
UPDATE customers
SET first_name = REPLACE(first_name, ' ', ''), last_name  = REPLACE(last_name, ' ', '')
WHERE customer_id IS NOT NULL;
SET SQL_SAFE_UPDATES = 0;
SET SQL_SAFE_UPDATES = 1;
SELECT COUNT(*) FROM customers
WHERE first_name LIKE '% %' OR last_name LIKE '% %';  
SELECT COUNT(*) FROM customers
WHERE first_name REGEXP '^(.)\\1(.)\\2' OR last_name REGEXP '^(.)\\1(.)\\2';
SHOW KEYS FROM customers WHERE Key_name = 'PRIMARY';
CREATE TABLE orders (
order_id VARCHAR(50),
customer_id VARCHAR(50),
product_id VARCHAR(50),
order_amount DECIMAL(12, 2),
order_date DATE,
payment_method VARCHAR(50),
status VARCHAR(50),
quantity DECIMAL(12 ,2)
);
SELECT COUNT(*) FROM orders;
CREATE TABLE products (
product_id VARCHAR(50),
product_name VARCHAR(50),
category VARCHAR(50),
price DECIMAL(12, 2)
);
SELECT COUNT(*) FROM products;
CREATE TABLE support_tickets (
ticket_id VARCHAR(50),
customer_id VARCHAR(50),
issue_type VARCHAR(50),
ticket_created DATETIME,
ticket_resolved DATETIME,
resolution_time_hours DECIMAL(12, 2),
sentiment VARCHAR(50),
support_agent VARCHAR(100)
);
SELECT COUNT(*) FROM support_tickets;
CREATE TABLE clickstream (
event_id VARCHAR(100),
session_id VARCHAR(100),
customer_id VARCHAR(50),
event_type VARCHAR(50),
page_url VARCHAR(500),
device_ids VARCHAR(255),
timestamp DATETIME,
ingest_run_id VARCHAR(100)
);
SELECT COUNT(*) FROM clickstream;

SELECT 'orders' AS table_name, COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS unique_ids,SUM(order_id IS NULL) AS null_ids FROM orders UNION ALL SELECT 'products', COUNT(*), COUNT(DISTINCT product_id), SUM(product_id IS NULL) FROM products UNION ALL SELECT 'support_tickets', COUNT(*), COUNT(DISTINCT ticket_id), SUM(ticket_id IS NULL) FROM support_tickets UNION ALL SELECT 'clickstream', COUNT(*), COUNT(DISTINCT event_id), SUM(event_id IS NULL) FROM clickstream; 

ALTER TABLE orders ADD PRIMARY KEY (order_id);
ALTER TABLE products ADD PRIMARY KEY (product_id);
ALTER TABLE support_tickets ADD PRIMARY KEY (ticket_id);
ALTER TABLE clickstream ADD PRIMARY KEY (event_id);
-- Keys & Relationships, Establish and verify the relatiional model.
SELECT 'orders' AS table_name, COUNT(*) AS invalid_customer_ids FROM orders o LEFT JOIN customers c ON o.customer_id = c.customer_id WHERE o.customer_id IS NOT NULL AND c.customer_id IS NULL UNION ALL SELECT 'support_tickets', COUNT(*) FROM support_tickets s LEFT JOIN customers c ON s.customer_id = c.customer_id WHERE s.customer_id IS NOT NULL AND c.customer_id IS NULL UNION ALL SELECT 'clickstream', COUNT(*) FROM clickstream cs LEFT JOIN customers c ON cs.customer_id = c.customer_id WHERE cs.customer_id IS NOT NULL AND c.customer_id IS NULL;
-- orders -> products relation.
SELECT COUNT(*) AS invalid_product_ids FROM orders o LEFT JOIN products p ON o.product_id = p.product_id WHERE o.product_id IS NOT NULL AND p.product_id IS NULL;
-- Create foreign-keys.
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE orders ADD CONSTRAINT fk_orders_products FOREIGN KEY (product_id) REFERENCES products(product_id);
ALTER TABLE support_tickets ADD CONSTRAINT fk_support_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
ALTER TABLE clickstream ADD CONSTRAINT fk_clickstream_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id);
-- Relational structure after creating foreign keys.
-- customers
-- │
-- ├──< orders >── products
-- │
-- ├──< support_tickets
-- │
-- └──< clickstream

-- SQL data quality checks.
-- Final row count.
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers UNION ALL SELECT 'orders', COUNT(*) FROM orders UNION ALL SELECT 'products', COUNT(*) FROM products UNION ALL SELECT 'support_tickets', COUNT(*) FROM support_tickets UNION ALL SELECT 'clickstream', COUNT(*) FROM clickstream;
-- NULL checks in important key columns.
SELECT 'orders.customer_id' AS column_name, COUNT(*) AS null_count FROM orders WHERE customer_id IS NULL UNION ALL SELECT 'orders.product_id', COUNT(*) FROM orders WHERE product_id IS NULL UNION ALL SELECT 'support_tickets.customer_id', COUNT(*) FROM support_tickets WHERE customer_id IS NULL UNION ALL SELECT 'clickstream.customer_id', COUNT(*) FROM clickstream WHERE customer_id IS NULL;
-- Business Questions
-- For each customers, how many days passed between their consecutive purches?
WITH customer_orders AS ( SELECT customer_id, order_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id) AS previous_order_date FROM orders WHERE order_date IS NOT NULL) SELECT customer_id, order_id, order_date, previous_order_date, DATEDIFF(order_date, previous_order_date) AS days_since_previous_order FROM customer_orders WHERE previous_order_date IS NOT NULL ORDER BY customer_id, order_date, order_id LIMIT 20;
-- For each customer, how frequently do they return to purchase, and how variable are their purchase gaps?
WITH purches_intervals AS (SELECT customer_id, order_date, LAG(order_date) OVER(PARTITION BY customer_id ORDER BY order_date, order_id) AS previous_order_date FROM orders WHERE order_date IS NOT NULL), customer_gaps AS(SELECT customer_id, DATEDIFF(order_date, previous_order_date) AS days_between_orders FROM purches_intervals WHERE previous_order_date IS NOT NULL) SELECT customer_id, COUNT(*) AS purches_intervals, ROUND(AVG(days_between_orders), 1) AS average_days_between_orders, MIN(days_between_orders) AS shortest_gap, MAX(days_between_orders) AS longest_gap FROM customer_gaps GROUP BY customer_id ORDER BY average_days_between_orders LIMIT 20;

WITH purchase_intervals AS (SELECT customer_id, order_date, LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date, order_id ) AS previous_order_date FROM orders WHERE order_date IS NOT NULL), customer_gaps AS (SELECT customer_id, DATEDIFF(order_date, previous_order_date) AS days_between_orders FROM purchase_intervals WHERE previous_order_date IS NOT NULL) SELECT CASE WHEN days_between_orders = 0 THEN 'Same day' WHEN days_between_orders BETWEEN 1 AND 7 THEN '1-7 days' WHEN days_between_orders BETWEEN 8 AND 30 THEN '8-30 days' WHEN days_between_orders BETWEEN 31 AND 90 THEN '31-90 days' WHEN days_between_orders BETWEEN 91 AND 180 THEN '91-180 days' ELSE '181+ days' END AS purchase_gap_group, COUNT(*) AS interval_count FROM customer_gaps GROUP BY purchase_gap_group ORDER BY CASE purchase_gap_group WHEN 'Same day' THEN 1 WHEN '1-7 days' THEN 2 WHEN '8-30 days' THEN 3 WHEN '31-90 days' THEN 4 WHEN '91-180 days' THEN 5 ELSE 6 END;
-- How long have customers been active, and how recently did they purchase?
SELECT customer_id, MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date, DATEDIFF( MAX(order_date), MIN(order_date)) AS customer_lifetime_days, DATEDIFF( (SELECT MAX(order_date) FROM orders), MAX(order_date) ) AS days_since_last_order FROM orders WHERE order_date IS NOT NULL GROUP BY customer_id ORDER BY customer_lifetime_days DESC LIMIT 20;
-- How the customer base is distributed by observed lifetime
WITH customer_lifecycle AS ( SELECT customer_id, MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date, DATEDIFF(MAX(order_date), MIN(order_date)) AS customer_lifetime_days, DATEDIFF((SELECT MAX(order_date) FROM orders), MAX(order_date) ) AS days_since_last_order FROM orders WHERE order_date IS NOT NULL GROUP BY customer_id) SELECT CASE WHEN customer_lifetime_days = 0 THEN '0 days' WHEN customer_lifetime_days BETWEEN 1 AND 30 THEN '1-30 days' WHEN customer_lifetime_days BETWEEN 31 AND 90 THEN '31-90 days' WHEN customer_lifetime_days BETWEEN 91 AND 180 THEN '91-180 days' WHEN customer_lifetime_days BETWEEN 181 AND 365 THEN '181-365 days' ELSE '366+ days' END AS lifecycle_group, COUNT(*) AS customer_count FROM customer_lifecycle GROUP BY lifecycle_group ORDER BY CASE lifecycle_group WHEN '0 days' THEN 1 WHEN '1-30 days' THEN 2 WHEN '31-90 days' THEN 3 WHEN '91-180 days' THEN 4 WHEN '181-365 days' THEN 5 ELSE 6 END;
-- Recency
WITH customer_lifecycle AS ( SELECT customer_id, MAX(order_date) AS last_order_date, DATEDIFF( (SELECT MAX(order_date) FROM orders), MAX(order_date) ) AS days_since_last_order FROM orders WHERE order_date IS NOT NULL GROUP BY customer_id ) SELECT CASE WHEN days_since_last_order = 0 THEN '0 days' WHEN days_since_last_order BETWEEN 1 AND 30 THEN '1-30 days' WHEN days_since_last_order BETWEEN 31 AND 90 THEN '31-90 days' WHEN days_since_last_order BETWEEN 91 AND 180 THEN '91-180 days' ELSE '181+ days' END AS recency_group, COUNT(*) AS customer_count FROM customer_lifecycle GROUP BY recency_group ORDER BY CASE recency_group WHEN '0 days' THEN 1 WHEN '1-30 days' THEN 2 WHEN '31-90 days' THEN 3 WHEN '91-180 days' THEN 4 ELSE 5 END;
-- Who are the highest-revenue customers within each country?
WITH customer_revenue AS ( SELECT c.customer_id, c.country, SUM(o.order_amount) AS total_revenue FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_amount IS NOT NULL GROUP BY c.customer_id, c.country) SELECT customer_id, country, ROUND(total_revenue, 2) AS total_revenue, RANK() OVER ( PARTITION BY country ORDER BY total_revenue DESC) AS country_rank FROM customer_revenue ORDER BY country, country_rank LIMIT 30;
-- Top 3 revenue-generating customers within every country.
WITH customer_revenue AS ( SELECT c.customer_id, c.country, SUM(o.order_amount) AS total_revenue FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_amount IS NOT NULL GROUP BY c.customer_id, c.country), ranked_customers AS ( SELECT customer_id, country, total_revenue, RANK() OVer ( PARTITION BY country ORDER BY total_revenue DESC ) AS country_rank FROM customer_revenue) SELECT customer_id, country, ROUND(total_revenue, 2) AS total_revenue, country_rank FROM ranked_customers WHERE country_rank <= 3 ORDER BY country, country_rank;
-- Which customers generate substantially more revenue than the average customer in their country?
WITH customer_revenue AS (SELECT c.customer_id, c.country, SUM(o.order_amount) AS total_revenue FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_amount IS NOT NULL GROUP BY c.customer_id, c.country), country_analysis AS(SELECT customer_id, country, total_revenue, AVG(total_revenue) OVER (PARTITION BY country) AS country_avg_revenue FROM customer_revenue) SELECT customer_id, country, ROUND(total_revenue, 2) AS total_revenue, ROUND(country_avg_revenue, 2) AS country_avg_revenue, ROUND(total_revenue - country_avg_revenue, 2) AS difference_from_country_avg FROM country_analysis WHERE total_revenue > country_avg_revenue ORDER BY difference_from_country_avg DESC LIMIT 20;
-- How much of total revenue does each customer contribute, and how quickly does cumulative revenue build as we move from the highest-revenue customers downward?
WITH customer_revenue AS ( SELECT customer_id, SUM(order_amount) AS total_revenue FROM orders WHERE order_amount IS NOT NULL GROUP BY customer_id), revenue_contribution AS (SELECT customer_id, total_revenue, SUM(total_revenue) OVER() AS total_company_revenue, SUM(total_revenue) OVER( ORDER BY total_revenue DESC ROWS UNBOUNDED PRECEDING) AS cumulative_revenue FROM customer_revenue) SELECT customer_id, ROUND(total_revenue, 2) AS total_revenue, ROUND( total_revenue / total_company_revenue * 100, 4 ) AS revenue_contribution_pct, ROUND( cumulative_revenue / total_company_revenue * 100, 4 ) AS cumulative_revenue_pct FROM revenue_contribution ORDER BY total_revenue DESC LIMIT 20;
-- Which product generates the highest revenue within each product category?
WITH product_revenue AS ( SELECT p.product_id, p.product_name, p.category, SUM(o.order_amount) AS total_revenue FROM products p JOIN orders o ON p.product_id = o.product_id WHERE o.order_amount IS NOT NULL GROUP BY p.product_id, p.product_name, p.category ), ranked_products AS ( SELECT product_id, product_name, category, total_revenue, ROW_NUMBER() OVER ( PARTITION BY category ORDER BY total_revenue DESC ) AS category_rank FROM product_revenue ) SELECT product_id, product_name, category, ROUND(total_revenue, 2) AS total_revenue, category_rank FROM ranked_products WHERE category_rank = 1 ORDER BY category;
-- Which customers purchased less in their latest observed month compared with the previous month?
WITH monthly_customer_orders AS ( SELECT customer_id, DATE_FORMAT(order_date, '%Y-%m') AS order_month, COUNT(DISTINCT order_id) AS monthly_orders FROM orders WHERE order_date IS NOT NULL GROUP BY customer_id, DATE_FORMAT(order_date, '%Y-%m') ), monthly_comparison AS ( SELECT customer_id, order_month, monthly_orders, LAG(monthly_orders) OVER ( PARTITION BY customer_id ORDER BY order_month ) AS previous_month_orders, LAG(order_month) OVER ( PARTITION BY customer_id ORDER BY order_month ) AS previous_order_month FROM monthly_customer_orders ) SELECT customer_id, previous_order_month, order_month AS latest_order_month, previous_month_orders, monthly_orders AS latest_month_orders, previous_month_orders - monthly_orders AS order_decline FROM monthly_comparison WHERE previous_order_month = DATE_FORMAT( DATE_SUB( STR_TO_DATE(CONCAT(order_month, '-01'), '%Y-%m-%d'), INTERVAL 1 MONTH ), '%Y-%m' ) AND monthly_orders < previous_month_orders ORDER BY order_decline DESC LIMIT 20;
-- Which customers have purchased from the company but have never contacted support?
SELECT o.customer_id, COUNT(DISTINCT o.order_id) AS total_orders, ROUND(SUM(o.order_amount), 2) AS total_revenue FROM orders o LEFT JOIN support_tickets s ON o.customer_id = s.customer_id WHERE o.order_amount IS NOT NULL AND s.customer_id IS NULL GROUP BY o.customer_id ORDER BY total_revenue DESC LIMIT 20;
-- Which customers show relatively high digital engagement but relatively low order activity?
WITH customer_engagement AS ( SELECT customer_id, COUNT(*) AS engagement_events FROM clickstream WHERE customer_id IS NOT NULL GROUP BY customer_id ), customer_orders AS ( SELECT customer_id, COUNT(DISTINCT order_id) AS total_orders FROM orders GROUP BY customer_id ), customer_behavior AS ( SELECT e.customer_id, e.engagement_events, COALESCE(o.total_orders, 0) AS total_orders FROM customer_engagement e LEFT JOIN customer_orders o ON e.customer_id = o.customer_id ) SELECT customer_id, engagement_events, total_orders FROM customer_behavior WHERE engagement_events >= ( SELECT AVG(engagement_events) FROM customer_engagement ) AND total_orders < ( SELECT AVG(total_orders) FROM customer_orders ) ORDER BY engagement_events DESC LIMIT 20;
-- Which high-value customers also have relatively high support activity?
WITH customer_revenue AS ( SELECT customer_id, SUM(order_amount) AS total_revenue FROM orders WHERE order_amount IS NOT NULL GROUP BY customer_id), customer_support AS ( SELECT customer_id, COUNT(*) AS support_tickets, ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_time, SUM( CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END ) AS positive_tickets, SUM( CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END ) AS negative_tickets, SUM( CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END ) AS neutral_tickets FROM support_tickets GROUP BY customer_id), customer_analysis AS ( SELECT r.customer_id, r.total_revenue, s.support_tickets, s.avg_resolution_time, s.positive_tickets, s.negative_tickets, s.neutral_tickets FROM customer_revenue r JOIN customer_support s ON r.customer_id = s.customer_id ) SELECT customer_id, ROUND(total_revenue, 2) AS total_revenue, support_tickets, avg_resolution_time, positive_tickets, negative_tickets, neutral_tickets FROM customer_analysis WHERE total_revenue >= ( SELECT AVG(total_revenue) FROM customer_revenue ) AND support_tickets >= ( SELECT AVG(support_tickets) FROM customer_support ) ORDER BY total_revenue DESC LIMIT 20;

-- Customer 360 analytical layer. Customer order metrics.
CREATE OR REPLACE VIEW vw_customer_order_metrics AS SELECT customer_id, MIN(order_date) AS first_order_date, MAX(order_date) AS last_order_date, COUNT(DISTINCT order_id) AS total_orders ,ROUND(SUM(order_amount), 2) AS total_revenue, SUM(quantity) AS total_quantity, ROUND( AVG( order_amount), 2) AS avg_order_value, DATEDIFF( MAX(order_date), MIN(order_date)) AS customer_lifetime_days, DATEDIFF( (SELECT MAX(order_date) FROM orders), MAX(order_date)) AS days_since_last_order FROM orders WHERE order_amount IS NOT NULL GROUP BY customer_id;
SELECT * FROM vw_customer_order_metrics LIMIT 10;
-- Customer-level support view.
CREATE OR REPLACE VIEW vw_customer_support_metrics AS SELECT customer_id, COUNT(*) AS support_tickets, ROUND(AVG(resolution_time_hours), 2) AS avg_resolution_time, SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_tickets, SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_tickets, SUM(CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_tickets FROM support_tickets GROUP BY customer_id;
SELECT * FROM vw_customer_support_metrics LIMIT 10;
-- customer-level clickstream metric.
CREATE OR REPLACE VIEW vw_customer_engagement_metrics AS SELECT customer_id, COUNT(*) AS engagement_events FROM clickstream WHERE customer_id IS NOT NULL GROUP BY customer_id;
SELECT * FROM vw_customer_engagement_metrics LIMIT 10;

CREATE OR REPLACE VIEW vw_customer_360 AS
SELECT
c.customer_id,

-- Customer profile
c.first_name,
c.last_name,
c.gender,
c.city,
c.state,
c.country,
c.source,

-- Order metrics
o.first_order_date,
o.last_order_date,
o.customer_lifetime_days,
o.total_orders,
o.total_revenue,
o.total_quantity,
o.avg_order_value,
o.days_since_last_order,

-- Engagement
COALESCE(e.engagement_events, 0) AS engagement_events,

-- Support
COALESCE(s.support_tickets, 0) AS support_tickets,
s.avg_resolution_time,
COALESCE(s.positive_tickets, 0) AS positive_tickets,
COALESCE(s.negative_tickets, 0) AS negative_tickets,
COALESCE(s.neutral_tickets, 0) AS neutral_tickets

FROM customers c

LEFT JOIN vw_customer_order_metrics o
ON c.customer_id = o.customer_id

LEFT JOIN vw_customer_engagement_metrics e
ON c.customer_id = e.customer_id

LEFT JOIN vw_customer_support_metrics s
ON c.customer_id = s.customer_id;
    
SELECT *
FROM vw_customer_360
LIMIT 10;

SELECT
COUNT(*) AS customer_360_rows,
COUNT(DISTINCT customer_id) AS unique_customers
FROM vw_customer_360;
-- Customer 360 segmentation.
CREATE OR REPLACE VIEW vw_customer_360_segmented AS SELECT c360.*,
CASE
    WHEN total_orders BETWEEN 1 AND 2 THEN '1-2 Orders'
    WHEN total_orders BETWEEN 3 AND 5 THEN '3-5 Orders'
    WHEN total_orders BETWEEN 6 AND 10 THEN '6-10 Orders'
    WHEN total_orders >= 11 THEN '11+ Orders'
    ELSE 'No Orders'
END AS purchase_frequency_segment,

CASE
    WHEN engagement_events <= 5 THEN 'Low'
    WHEN engagement_events <= 10 THEN 'Medium'
    ELSE 'High'
END AS engagement_segment,

CASE
    WHEN support_tickets = 0 THEN 'No Tickets'
    WHEN support_tickets BETWEEN 1 AND 2 THEN '1-2 Tickets'
    WHEN support_tickets BETWEEN 3 AND 5 THEN '3-5 Tickets'
    ELSE '6+ Tickets'
END AS support_segment

FROM vw_customer_360 c360;

SELECT
customer_id,
total_orders,
engagement_events,
support_tickets,
purchase_frequency_segment,
engagement_segment,
support_segment
FROM vw_customer_360_segmented
LIMIT 10;
-- Validation segment count.
SELECT purchase_frequency_segment, COUNT(*) AS customer_count
FROM vw_customer_360_segmented
GROUP BY purchase_frequency_segment
ORDER BY customer_count DESC;


-- Reusable SQL views.
-- Monthly revenue trend.
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS ym,
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    ROUND(SUM(order_amount), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
WHERE order_date IS NOT NULL
  AND order_amount IS NOT NULL
GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    DATE_FORMAT(order_date, '%Y-%m');
    
SELECT *
FROM vw_monthly_revenue
ORDER BY ym;
-- Products performance view.
CREATE OR REPLACE VIEW vw_product_performance AS
SELECT
    p.product_id,
    p.product_name,
    p.category,
    p.price,

    COUNT(DISTINCT o.order_id) AS total_orders,
    COALESCE(SUM(o.quantity), 0) AS total_quantity,
    ROUND(COALESCE(SUM(o.order_amount), 0), 2) AS total_revenue

FROM products p
LEFT JOIN orders o
    ON p.product_id = o.product_id
   AND o.order_amount IS NOT NULL

GROUP BY
    p.product_id,
    p.product_name,
    p.category,
    p.price;

SELECT *
FROM vw_product_performance
LIMIT 10;
-- SQL views final validation.
SELECT
    TABLE_NAME
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = 'customer_360'
  AND TABLE_NAME IN (
      'vw_customer_order_metrics',
      'vw_customer_support_metrics',
      'vw_customer_engagement_metrics',
      'vw_customer_360',
      'vw_customer_360_segmented',
      'vw_monthly_revenue',
      'vw_product_performance'
  )
ORDER BY TABLE_NAME;

-- SQL validation.
-- Customer 360 integrity
SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT customer_id) AS unique_customers,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_ids,
ROUND(SUM(total_revenue), 2) AS customer_360_revenue
FROM vw_customer_360;
     
SELECT
    (SELECT COUNT(*) FROM products) AS products,
    (SELECT COUNT(*) FROM vw_product_performance) AS product_view,
    (SELECT COUNT(*) FROM vw_monthly_revenue) AS monthly_revenue_rows;