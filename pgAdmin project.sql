SET search_path TO portfolio;

-- table creation

Create table customers(
customer_id INT,
first_name TEXT,
last_name TEXT,
email VARCHAR(100),
phone VARCHAR(100),
address VARCHAR(100),
city TEXT
);

Create table order_items(
order_item_id INT PRIMARY KEY,
order_id INTEGER,
product_id INTEGER,
quantity INTEGER,
unit_price INTEGER
);

Create table orders(
order_id INT PRIMARY KEY,
customer_id INTEGER,
order_date DATE
);

Create table payments(
payment_id INT PRIMARY KEY,
order_id INTEGER,
payment_date DATE,
amount INTEGER,
payment_method TEXT
);


Create table products(
product_id INT PRIMARY KEY,
product_name TEXT,
category TEXT,
price INTEGER,
stock_quantity INTEGER
);


-- data cleaning

Alter table customers
Add primary key (customer_id);

alter table order_items
alter column unit_price type float(2)
;

alter table payments
alter column amount type float(2)
;

alter table products
alter column price type float(2)
;


-- rank of customers by amount spent

WITH customer_spending AS (
    SELECT 
        c.customer_id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS total_spent
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY c.customer_id, customer_name
)
SELECT 
    customer_name,
    total_spent,
    RANK() OVER (ORDER BY total_spent DESC) AS spend_rank
FROM customer_spending
ORDER BY spend_rank;



-- total and average of all sales

SELECT
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS total_sales,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id;


-- avg order value by customer ranked descending

SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS total_sales,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, customer_name
ORDER BY avg_order_value DESC;

-- MoM Sales

WITH monthly_totals AS (
    SELECT
        TO_CHAR(DATE_TRUNC('month', o.order_date), 'YYYY-MM') AS month,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price)::numeric AS total_sales,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY DATE_TRUNC('month', o.order_date)
),
ranked_months AS (
    SELECT *,
           RANK() OVER (ORDER BY month DESC) AS month_rank
    FROM monthly_totals
)
SELECT 
    month,
    total_orders,
    total_sales,
    avg_order_value
FROM ranked_months
ORDER BY month DESC;

-- YoY Sales Totals

WITH yearly_totals AS (
    SELECT
        TO_CHAR(DATE_TRUNC('year', o.order_date), 'YYYY') AS year,
        COUNT(DISTINCT o.order_id) AS total_orders,
        SUM(oi.quantity * oi.unit_price)::numeric AS total_sales,
        ROUND(SUM(oi.quantity * oi.unit_price)::numeric / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY DATE_TRUNC('year', o.order_date)
),
ranked_years AS (
    SELECT *,
           RANK() OVER (ORDER BY year DESC) AS year_rank
    FROM yearly_totals
)
SELECT 
    year,
    total_orders,
    total_sales,
    avg_order_value
FROM ranked_years
ORDER BY year DESC;

-- top products by revenue

SELECT 
    p.product_id,
    p.product_name,
    SUM(oi.quantity * oi.unit_price) AS total_revenue,
    RANK() OVER (ORDER BY SUM(oi.quantity * oi.unit_price) DESC) AS revenue_rank
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name
ORDER BY revenue_rank;