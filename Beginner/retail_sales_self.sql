-- =====================================================================
-- PROJECT 1 (BEGINNER): RETAIL SALES DATABASE
-- Skills demonstrated: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT,
--                       basic aggregates (COUNT, SUM, AVG), GROUP BY
-- =====================================================================

DROP DATABASE IF EXISTS retail_sales;
CREATE DATABASE retail_sales;
USE retail_sales;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    country       VARCHAR(50),
    signup_date   DATE
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(50),
    price         DECIMAL(10,2) NOT NULL
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL,
    order_date    DATE NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO customers (first_name, last_name, email, country, signup_date) VALUES
('Ava',     'Reyes',     'ava.reyes@mail.com',     'USA',        '2023-01-15'),
('Liam',    'Chen',      'liam.chen@mail.com',     'Canada',     '2023-02-02'),
('Noor',    'Khan',      'noor.khan@mail.com',     'India',      '2023-02-20'),
('Sofia',   'Rossi',     'sofia.rossi@mail.com',   'Italy',      '2023-03-05'),
('Ethan',   'Brooks',    'ethan.brooks@mail.com',  'USA',        '2023-03-18'),
('Mia',     'Dubois',    'mia.dubois@mail.com',    'France',     '2023-04-01'),
('Kenji',   'Sato',      'kenji.sato@mail.com',    'Japan',      '2023-04-22'),
('Amara',   'Okafor',    'amara.okafor@mail.com',  'Nigeria',    '2023-05-10'),
('Lucas',   'Silva',     'lucas.silva@mail.com',   'Brazil',     '2023-05-29'),
('Priya',   'Nair',      'priya.nair@mail.com',    'India',      '2023-06-14'),
('Jack',    'Wilson',    'jack.wilson@mail.com',   'USA',        '2023-07-02'),
('Elena',   'Petrova',   'elena.petrova@mail.com', 'Russia',     '2023-07-19');

INSERT INTO products (product_name, category, price) VALUES
('Wireless Mouse',       'Electronics', 19.99),
('Mechanical Keyboard',  'Electronics', 79.99),
('USB-C Hub',            'Electronics', 34.50),
('Yoga Mat',             'Fitness',     24.00),
('Dumbbell Set 20kg',    'Fitness',     89.99),
('Running Shoes',        'Fitness',     64.50),
('Ceramic Mug Set',      'Home',        18.25),
('Table Lamp',           'Home',        42.00),
('Throw Blanket',        'Home',        29.99),
('Notebook Pack (3)',    'Office',      9.99);

INSERT INTO orders (customer_id, product_id, quantity, order_date) VALUES
(1, 1, 2, '2023-08-01'),
(1, 4, 1, '2023-08-15'),
(2, 2, 1, '2023-08-02'),
(3, 5, 1, '2023-08-03'),
(3, 6, 2, '2023-09-01'),
(4, 7, 3, '2023-08-05'),
(5, 8, 1, '2023-08-06'),
(5, 9, 2, '2023-09-10'),
(6, 10, 5, '2023-08-08'),
(7, 1, 1, '2023-08-09'),
(7, 3, 1, '2023-09-15'),
(8, 6, 1, '2023-08-11'),
(9, 2, 1, '2023-08-12'),
(9, 4, 2, '2023-09-20'),
(10, 5, 1, '2023-08-14'),
(10, 7, 1, '2023-08-14'),
(11, 8, 2, '2023-08-16'),
(11, 9, 1, '2023-09-22'),
(12, 10, 4, '2023-08-19'),
(1, 3, 1, '2023-10-01'),
(2, 6, 1, '2023-10-02'),
(3, 1, 3, '2023-10-05'),
(4, 2, 1, '2023-10-08'),
(5, 5, 1, '2023-10-12'),
(6, 4, 2, '2023-10-15');

SELECT * FROM customers;
SELECT * FROM orders;
SELECT * FROM products;

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. All customers, alphabetically by last name
SELECT customer_id, first_name, last_name, country
FROM customers
ORDER BY last_name;

-- 2. Customers from a specific country
SELECT first_name, last_name, email
FROM customers
WHERE country = 'India';

-- 3. Distinct countries represented in the customer base
SELECT DISTINCT country
FROM customers
ORDER BY country;

-- 4. Products priced above the average product price
SELECT product_name, price
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- 5. Top 5 most recent orders
SELECT order_id, customer_id, product_id, order_date
FROM orders
ORDER BY order_date DESC
LIMIT 5;

-- 6. Top 10 customers by number of orders placed
SELECT c.customer_id, c.first_name, c.last_name, COUNT(o.order_id) AS Total_Orders
   FROM customers c JOIN orders o 
ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY Total_Orders DESC
LIMIT 10;

-- 7. Total orders placed per month
SELECT SUBSTRING(order_date, 1, 7) AS order_month, COUNT(*) AS total_orders
FROM orders
GROUP BY order_month
ORDER BY order_month;

-- 8. Number of customers per country
SELECT COUNT(customer_id) AS total_customers, country
FROM customers
GROUP BY country
ORDER BY total_customers DESC;

-- 9. Total revenue generated (quantity * price) across all orders
SELECT SUM(o.quantity * p.price) AS total_revenue
FROM orders o JOIN products p 
ON o.product_id = p.product_id;

-- 10. Average order quantity per product category
SELECT AVG(o.quantity) AS avg_quantity_order, p.category 
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY p.category
ORDER BY avg_quantity_order DESC;








