-- =====================================================================
-- PROJECT (INTERMEDIATE): FOOD DELIVERY APP
-- Skills demonstrated: multi-table JOINs, subqueries, GROUP BY + HAVING,
--                       CASE, date functions, LEFT JOIN anti-pattern,
--                       correlated subqueries
-- =====================================================================

DROP DATABASE IF EXISTS food_delivery;
CREATE DATABASE food_delivery;
USE food_delivery;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE restaurants (
    restaurant_id   INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_name VARCHAR(100) NOT NULL,
    cuisine         VARCHAR(50) NOT NULL,
    city            VARCHAR(50) NOT NULL
);

CREATE TABLE menu_items (
    item_id       INT PRIMARY KEY AUTO_INCREMENT,
    restaurant_id INT NOT NULL,
    item_name     VARCHAR(100) NOT NULL,
    price         DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id)
);

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    city          VARCHAR(50) NOT NULL
);

CREATE TABLE drivers (
    driver_id     INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    vehicle_type  VARCHAR(20) NOT NULL
);

CREATE TABLE orders (
    order_id       INT PRIMARY KEY AUTO_INCREMENT,
    customer_id    INT NOT NULL,
    restaurant_id  INT NOT NULL,
    driver_id      INT,
    order_time     DATETIME NOT NULL,
    delivered_time DATETIME,
    status         VARCHAR(20) NOT NULL DEFAULT 'delivered',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (restaurant_id) REFERENCES restaurants(restaurant_id),
    FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);

CREATE TABLE order_items (
    order_item_id  INT PRIMARY KEY AUTO_INCREMENT,
    order_id       INT NOT NULL,
    item_id        INT NOT NULL,
    quantity       INT NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (item_id) REFERENCES menu_items(item_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO restaurants (restaurant_name, cuisine, city) VALUES
('Golden Wok',        'Chinese',  'Austin'),
('La Trattoria',      'Italian',  'Austin'),
('Spice Route',       'Indian',   'Austin'),
('Taco Fiesta',       'Mexican',  'Dallas'),
('Sushi Haven',       'Japanese', 'Dallas'),
('Burger Junction',   'American', 'Dallas');

INSERT INTO menu_items (restaurant_id, item_name, price) VALUES
(1, 'Kung Pao Chicken', 12.99),
(1, 'Vegetable Fried Rice', 9.50),
(1, 'Spring Rolls', 6.00),
(2, 'Margherita Pizza', 13.50),
(2, 'Fettuccine Alfredo', 14.99),
(2, 'Tiramisu', 7.00),
(3, 'Butter Chicken', 13.99),
(3, 'Garlic Naan', 3.50),
(3, 'Vegetable Samosa', 5.00),
(4, 'Street Tacos (3)', 10.50),
(4, 'Burrito Bowl', 11.00),
(5, 'Salmon Nigiri Set', 16.99),
(5, 'California Roll', 8.99),
(6, 'Classic Cheeseburger', 9.99),
(6, 'Loaded Fries', 6.50);

INSERT INTO customers (full_name, city) VALUES
('Jordan Reyes', 'Austin'),
('Kayla Simmons', 'Austin'),
('Liam Foster', 'Austin'),
('Monica Reyes', 'Dallas'),
('Noel Park', 'Dallas'),
('Olivia Grant', 'Dallas'),
('Pedro Alvez', 'Austin'),
('Quinn Baker', 'Dallas');

INSERT INTO drivers (full_name, vehicle_type) VALUES
('Adam Ruiz', 'bike'),
('Beth Chan', 'car'),
('Carlos Nunez', 'scooter'),
('Dana White', 'car');

INSERT INTO orders (customer_id, restaurant_id, driver_id, order_time, delivered_time, status) VALUES
(1, 1, 1, '2024-06-01 12:05:00', '2024-06-01 12:40:00', 'delivered'),
(1, 3, 2, '2024-06-05 19:10:00', '2024-06-05 19:55:00', 'delivered'),
(2, 2, 1, '2024-06-02 18:30:00', '2024-06-02 19:05:00', 'delivered'),
(2, 1, 1, '2024-06-10 12:15:00', '2024-06-10 12:50:00', 'delivered'),
(3, 3, 2, '2024-06-03 13:00:00', '2024-06-03 13:45:00', 'delivered'),
(3, 2, NULL, '2024-06-15 20:00:00', NULL, 'cancelled'),
(4, 4, 3, '2024-06-04 12:20:00', '2024-06-04 12:50:00', 'delivered'),
(4, 5, 3, '2024-06-12 19:00:00', '2024-06-12 19:50:00', 'delivered'),
(5, 6, 4, '2024-06-06 13:10:00', '2024-06-06 13:35:00', 'delivered'),
(5, 4, 3, '2024-06-18 12:00:00', '2024-06-18 12:30:00', 'delivered'),
(6, 5, 4, '2024-06-07 18:45:00', '2024-06-07 19:40:00', 'delivered'),
(7, 1, 2, '2024-06-08 12:30:00', '2024-06-08 13:00:00', 'delivered'),
(7, 3, 2, '2024-06-20 19:20:00', '2024-06-20 20:05:00', 'delivered'),
(8, 6, 4, '2024-06-09 12:50:00', '2024-06-09 13:15:00', 'delivered'),
(8, 5, NULL, '2024-06-22 18:00:00', NULL, 'cancelled'),
(1, 2, 1, '2024-06-25 19:30:00', '2024-06-25 20:10:00', 'delivered'),
(2, 3, 2, '2024-06-27 12:40:00', '2024-06-27 13:20:00', 'delivered'),
(6, 6, 4, '2024-06-28 13:00:00', '2024-06-28 13:25:00', 'delivered');

INSERT INTO order_items (order_id, item_id, quantity) VALUES
(1, 1, 1), (1, 3, 2),
(2, 7, 1), (2, 8, 2),
(3, 4, 1), (3, 6, 1),
(4, 2, 1), (4, 1, 1),
(5, 7, 1), (5, 9, 3),
(6, 5, 1),
(7, 10, 2),
(8, 12, 1), (8, 13, 2),
(9, 14, 1), (9, 15, 1),
(10, 11, 1),
(11, 12, 2),
(12, 1, 1), (12, 3, 1),
(13, 7, 1), (13, 8, 3),
(14, 14, 2),
(15, 13, 1),
(16, 4, 2),
(17, 7, 1), (17, 9, 2),
(18, 14, 1), (18, 15, 2);

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. Average delivery time (in minutes) per restaurant, delivered orders only
SELECT r.restaurant_name,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, o.order_time, o.delivered_time)), 1) AS avg_delivery_minutes
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'delivered'
GROUP BY r.restaurant_name
ORDER BY avg_delivery_minutes;

-- 2. Total revenue per restaurant (delivered orders only)
SELECT r.restaurant_name,
       ROUND(SUM(mi.price * oi.quantity), 2) AS total_revenue
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
JOIN order_items oi ON oi.order_id = o.order_id
JOIN menu_items mi ON mi.item_id = oi.item_id
WHERE o.status = 'delivered'
GROUP BY r.restaurant_name
ORDER BY total_revenue DESC;

-- 3. Menu items that have never been ordered (LEFT JOIN anti-pattern)
SELECT mi.restaurant_id, mi.item_name
FROM menu_items mi
LEFT JOIN order_items oi ON oi.item_id = mi.item_id
WHERE oi.order_item_id IS NULL;

-- 4. Customers categorized into spend tiers using CASE
SELECT c.full_name,
       ROUND(SUM(mi.price * oi.quantity), 2) AS total_spend,
       CASE
           WHEN SUM(mi.price * oi.quantity) >= 60 THEN 'Frequent Diner'
           WHEN SUM(mi.price * oi.quantity) >= 30 THEN 'Regular'
           ELSE 'Occasional'
       END AS customer_tier
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id AND o.status = 'delivered'
JOIN order_items oi ON oi.order_id = o.order_id
JOIN menu_items mi ON mi.item_id = oi.item_id
GROUP BY c.customer_id, c.full_name
ORDER BY total_spend DESC;

-- 5. Each driver's delivered order count and cancellation-adjacent order count
--    (orders assigned to no driver because they were cancelled, shown separately)
SELECT d.full_name,
       COUNT(o.order_id) AS delivered_orders
FROM drivers d
JOIN orders o ON o.driver_id = d.driver_id AND o.status = 'delivered'
GROUP BY d.full_name
ORDER BY delivered_orders DESC;

-- 6. Orders that took longer than the restaurant's own average delivery time
--    (correlated subquery)
SELECT o.order_id, r.restaurant_name,
       TIMESTAMPDIFF(MINUTE, o.order_time, o.delivered_time) AS delivery_minutes
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
WHERE o.status = 'delivered'
  AND TIMESTAMPDIFF(MINUTE, o.order_time, o.delivered_time) > (
      SELECT AVG(TIMESTAMPDIFF(MINUTE, o2.order_time, o2.delivered_time))
      FROM orders o2
      WHERE o2.restaurant_id = o.restaurant_id
        AND o2.status = 'delivered'
  )
ORDER BY r.restaurant_name;

-- 7. Cuisines with above-average total order count
SELECT r.cuisine, COUNT(o.order_id) AS order_count
FROM restaurants r
JOIN orders o ON o.restaurant_id = r.restaurant_id
GROUP BY r.cuisine
HAVING order_count > (
    SELECT AVG(cnt) FROM (
        SELECT COUNT(*) AS cnt
        FROM orders o2
        JOIN restaurants r2 ON r2.restaurant_id = o2.restaurant_id
        GROUP BY r2.cuisine
    ) AS sub
);

-- 8. Cancellation rate per restaurant
SELECT r.restaurant_name,
       COUNT(*) AS total_orders,
       SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled_orders,
       ROUND(100.0 * SUM(CASE WHEN o.status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancellation_rate_pct
FROM orders o
JOIN restaurants r ON r.restaurant_id = o.restaurant_id
GROUP BY r.restaurant_name
ORDER BY cancellation_rate_pct DESC;
