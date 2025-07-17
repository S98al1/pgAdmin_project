SET search_path TO portfolio;

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


select * from customers;

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

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
	ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY c.customer_id, customer_name
ORDER BY total_spent DESC
;

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    ROUND(SUM(oi.quantity * oi.unit_price)::numeric, 2) AS total_spent
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
GROUP BY DATE_TRUNC('month', o.order_date)
ORDER BY month;