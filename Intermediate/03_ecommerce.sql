-- =====================================================================
-- PROJECT 3 (INTERMEDIATE): E-COMMERCE ANALYTICS
-- Skills demonstrated: multi-table JOINs, subqueries (correlated &
--                       non-correlated), GROUP BY + HAVING, CASE,
--                       date functions, LEFT JOIN anti-pattern
-- =====================================================================

DROP DATABASE IF EXISTS ecommerce_analytics;
CREATE DATABASE ecommerce_analytics;
USE ecommerce_analytics;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    email         VARCHAR(100) UNIQUE,
    signup_date   DATE
);

CREATE TABLE categories (
    category_id    INT PRIMARY KEY AUTO_INCREMENT,
    category_name  VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id    INT PRIMARY KEY AUTO_INCREMENT,
    product_name  VARCHAR(100) NOT NULL,
    category_id   INT NOT NULL,
    price         DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id      INT PRIMARY KEY AUTO_INCREMENT,
    customer_id   INT NOT NULL,
    order_date    DATE NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'completed',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY AUTO_INCREMENT,
    order_id       INT NOT NULL,
    product_id     INT NOT NULL,
    quantity       INT NOT NULL,
    unit_price     DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO customers (full_name, email, signup_date) VALUES
('Hannah Lee',       'hannah.lee@mail.com',     '2022-11-01'),
('Marcus Webb',      'marcus.webb@mail.com',    '2022-12-15'),
('Yuki Tanaka',      'yuki.tanaka@mail.com',    '2023-01-10'),
('Chloe Martin',     'chloe.martin@mail.com',   '2023-01-22'),
('Diego Fernandez',  'diego.fernandez@mail.com','2023-02-05'),
('Aisha Rahman',     'aisha.rahman@mail.com',   '2023-02-18'),
('Tom O''Brien',     'tom.obrien@mail.com',     '2023-03-01'),
('Ingrid Larsen',    'ingrid.larsen@mail.com',  '2023-03-20'),
('Samuel Osei',      'samuel.osei@mail.com',    '2023-04-02'),
('Lena Novak',       'lena.novak@mail.com',     '2023-04-25');

INSERT INTO categories (category_name) VALUES
('Electronics'), ('Home & Kitchen'), ('Books'), ('Fitness'), ('Beauty');

INSERT INTO products (product_name, category_id, price) VALUES
('Bluetooth Earbuds',       1, 49.99),
('4K Monitor',              1, 249.99),
('Smart Plug',              1, 14.99),
('Non-Stick Pan Set',       2, 59.99),
('Electric Kettle',         2, 27.99),
('Cutting Board',           2, 15.50),
('Atomic Habits (Book)',    3, 12.99),
('The Pragmatic Programmer',3, 34.99),
('Resistance Bands',        4, 18.99),
('Adjustable Dumbbells',    4, 129.99),
('Yoga Block Set',          4, 21.99),
('Vitamin C Serum',         5, 22.50),
('Facial Cleanser',         5, 13.99),
('Bamboo Toothbrush Pack',  5, 8.99),
('Wireless Charger',        1, 24.99);

INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2023-05-01', 'completed'),
(1, '2023-06-12', 'completed'),
(1, '2023-08-03', 'completed'),
(2, '2023-05-04', 'completed'),
(2, '2023-07-19', 'completed'),
(3, '2023-05-10', 'completed'),
(3, '2023-09-02', 'completed'),
(4, '2023-05-15', 'completed'),
(5, '2023-06-01', 'completed'),
(5, '2023-06-25', 'completed'),
(5, '2023-09-14', 'completed'),
(6, '2023-06-05', 'completed'),
(7, '2023-06-18', 'completed'),
(7, '2023-08-22', 'completed'),
(8, '2023-07-01', 'completed'),
(9, '2023-07-10', 'completed'),
(9, '2023-07-28', 'completed'),
(10, '2023-08-01', 'completed'),
(10, '2023-08-15', 'cancelled'),
(2, '2023-09-30', 'completed');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 49.99),
(1, 5, 1, 27.99),
(2, 7, 2, 12.99),
(3, 2, 1, 249.99),
(4, 4, 1, 59.99),
(4, 6, 2, 15.50),
(5, 10, 1, 129.99),
(6, 12, 2, 22.50),
(6, 13, 1, 13.99),
(7, 15, 1, 24.99),
(8, 9, 1, 18.99),
(9, 1, 2, 49.99),
(9, 3, 3, 14.99),
(10, 8, 1, 34.99),
(11, 2, 1, 249.99),
(11, 15, 1, 24.99),
(12, 14, 3, 8.99),
(13, 11, 1, 21.99),
(14, 10, 1, 129.99),
(14, 9, 1, 18.99),
(15, 6, 1, 15.50),
(16, 7, 1, 12.99),
(17, 1, 1, 49.99),
(17, 12, 1, 22.50),
(18, 4, 1, 59.99),
(19, 5, 1, 27.99),
(20, 2, 1, 249.99),
(20, 15, 2, 24.99);

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. Monthly revenue trend (completed orders only)
SELECT DATE_FORMAT(o.order_date, '%Y-%m') AS month,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
WHERE o.status = 'completed'
GROUP BY month
ORDER BY month;

-- 2. Products that have never been ordered (LEFT JOIN anti-join pattern)
SELECT p.product_id, p.product_name
FROM products p
LEFT JOIN order_items oi ON oi.product_id = p.product_id
WHERE oi.order_item_id IS NULL;

-- 3. Total spend per customer, categorized into tiers with CASE
SELECT c.customer_id,
       c.full_name,
       ROUND(SUM(oi.quantity * oi.unit_price), 2) AS total_spend,
       CASE
           WHEN SUM(oi.quantity * oi.unit_price) >= 200 THEN 'Gold'
           WHEN SUM(oi.quantity * oi.unit_price) >= 80  THEN 'Silver'
           ELSE 'Bronze'
       END AS spend_tier
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'completed'
JOIN order_items oi ON oi.order_id = o.order_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spend DESC;

-- 4. Order value per order, and each order's rank vs. that customer's other orders
--    -- Second-highest order value per customer using a correlated subquery
SELECT o.customer_id, o.order_id, order_totals.order_value
FROM orders o
JOIN (
    SELECT order_id, SUM(quantity * unit_price) AS order_value
    FROM order_items
    GROUP BY order_id
) AS order_totals ON order_totals.order_id = o.order_id
WHERE (
    SELECT COUNT(*)
    FROM orders o2
    JOIN (
        SELECT order_id, SUM(quantity * unit_price) AS order_value
        FROM order_items
        GROUP BY order_id
    ) AS ot2 ON ot2.order_id = o2.order_id
    WHERE o2.customer_id = o.customer_id
      AND ot2.order_value > order_totals.order_value
) = 1;  -- exactly one order beats this one => this is the 2nd highest

-- 5. Customers who have placed orders in at least 3 distinct months
--    (a practical stand-in for "every quarter" that adapts to any date range)
SELECT c.customer_id, c.full_name, COUNT(DISTINCT DATE_FORMAT(o.order_date, '%Y-%m')) AS active_months
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name
HAVING active_months >= 3;

-- 6. Categories with above-average total revenue
SELECT cat.category_name, ROUND(SUM(oi.quantity * oi.unit_price), 2) AS category_revenue
FROM categories cat
JOIN products p ON p.category_id = cat.category_id
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY cat.category_name
HAVING category_revenue > (
    SELECT AVG(cat_rev) FROM (
        SELECT SUM(oi2.quantity * oi2.unit_price) AS cat_rev
        FROM products p2
        JOIN order_items oi2 ON oi2.product_id = p2.product_id
        GROUP BY p2.category_id
    ) AS sub
)
ORDER BY category_revenue DESC;

-- 7. Best-selling product by quantity within each category
SELECT p.category_id, p.product_name, SUM(oi.quantity) AS units_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
GROUP BY p.category_id, p.product_name
ORDER BY p.category_id, units_sold DESC;

-- 8. Customers who have never had a cancelled order
SELECT c.customer_id, c.full_name
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT customer_id FROM orders WHERE status = 'cancelled'
);
