-- =====================================================================
-- PROJECT 2 (BEGINNER): MOVIE RENTAL ANALYSIS
-- Skills demonstrated: single-table filtering, JOIN basics, GROUP BY,
--                       COUNT, SUM, AVG, date filtering
-- =====================================================================

DROP DATABASE IF EXISTS movie_rental;
CREATE DATABASE movie_rental;
USE movie_rental;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE stores (
    store_id     INT PRIMARY KEY AUTO_INCREMENT,
    store_name   VARCHAR(100) NOT NULL,
    city         VARCHAR(50)
);

CREATE TABLE films (
    film_id       INT PRIMARY KEY AUTO_INCREMENT,
    title         VARCHAR(150) NOT NULL,
    category      VARCHAR(50),
    release_year  YEAR,
    rental_rate   DECIMAL(5,2) NOT NULL
);

CREATE TABLE customers (
    customer_id   INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    store_id      INT NOT NULL,
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
);

CREATE TABLE rentals (
    rental_id     INT PRIMARY KEY AUTO_INCREMENT,
    film_id       INT NOT NULL,
    customer_id   INT NOT NULL,
    rental_date   DATE NOT NULL,
    return_date   DATE,
    FOREIGN KEY (film_id) REFERENCES films(film_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO stores (store_name, city) VALUES
('Downtown Video',  'Austin'),
('Riverside Rentals','Portland');

INSERT INTO films (title, category, release_year, rental_rate) VALUES
('The Last Signal',      'Sci-Fi',    2019, 3.99),
('Autumn in Paris',      'Romance',   2018, 2.99),
('Midnight Heist',       'Action',    2021, 4.99),
('Whispering Pines',     'Drama',     2017, 2.99),
('Comedy Night Live',    'Comedy',    2020, 2.49),
('The Silent Detective', 'Mystery',   2016, 3.49),
('Galactic Frontier',    'Sci-Fi',    2022, 4.99),
('Laugh Out Loud',       'Comedy',    2019, 2.49),
('Ocean Deep',           'Documentary', 2015, 1.99),
('Fast Lane',            'Action',    2020, 4.49);

INSERT INTO customers (first_name, last_name, store_id) VALUES
('Grace',   'Turner',   1),
('Owen',    'Baker',    1),
('Isla',    'Foster',   1),
('Mason',   'Reed',     2),
('Zoe',     'Bennett',  2),
('Leo',     'Coleman',  2),
('Ruby',    'Hayes',    1),
('Felix',   'Morgan',   2),
('Nina',    'Ward',     1),
('Theo',    'Simmons',  2);

INSERT INTO rentals (film_id, customer_id, rental_date, return_date) VALUES
(1, 1, '2024-05-01', '2024-05-04'),
(3, 1, '2024-06-10', '2024-06-13'),
(3, 2, '2024-05-02', '2024-05-05'),
(5, 3, '2024-05-03', '2024-05-06'),
(7, 4, '2024-05-05', '2024-05-08'),
(3, 5, '2024-05-06', '2024-05-09'),
(9, 6, '2024-02-01', '2024-02-04'),
(2, 7, '2024-05-08', '2024-05-11'),
(5, 8, '2024-05-09', '2024-05-12'),
(10,9, '2024-05-10', '2024-05-13'),
(3, 10,'2024-05-11', '2024-05-14'),
(7, 2, '2024-06-01', '2024-06-05'),
(1, 4, '2024-06-02', '2024-06-06'),
(5, 6, '2024-06-03', NULL),
(6, 3, '2024-01-15', '2024-01-18'),
(3, 7, '2024-06-15', '2024-06-18'),
(4, 8, '2024-06-16', '2024-06-19'),
(8, 9, '2024-06-17', NULL),
(2, 10,'2024-06-18', '2024-06-21'),
(9, 1, '2024-06-20', '2024-06-23');

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. All films in the "Sci-Fi" category
SELECT title, release_year, rental_rate
FROM films
WHERE category = 'Sci-Fi';

-- 2. Most rented films (rental count, descending)
SELECT f.title, COUNT(r.rental_id) AS times_rented
FROM films f
JOIN rentals r ON r.film_id = f.film_id
GROUP BY f.title
ORDER BY times_rented DESC;

-- 3. Revenue per store (sum of rental_rate for every rental made by that store's customers)
SELECT s.store_name, SUM(f.rental_rate) AS total_revenue
FROM rentals r
JOIN customers c ON c.customer_id = r.customer_id
JOIN stores s ON s.store_id = c.store_id
JOIN films f ON f.film_id = r.film_id
GROUP BY s.store_name
ORDER BY total_revenue DESC;

-- 4. Customers who haven't rented anything in the last 90 days
--    (relative to the most recent rental date in the data, for reproducibility)
SELECT c.customer_id, c.first_name, c.last_name, MAX(r.rental_date) AS last_rental
FROM customers c
JOIN rentals r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MAX(r.rental_date) < (SELECT DATE_SUB(MAX(rental_date), INTERVAL 90 DAY) FROM rentals);

-- 5. Average rental rate by film category
SELECT category, ROUND(AVG(rental_rate), 2) AS avg_rate
FROM films
GROUP BY category
ORDER BY avg_rate DESC;

-- 6. Number of rentals per customer
SELECT c.first_name, c.last_name, COUNT(r.rental_id) AS rental_count
FROM customers c
LEFT JOIN rentals r ON r.customer_id = c.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY rental_count DESC;

-- 7. Currently outstanding (not yet returned) rentals
SELECT r.rental_id, f.title, c.first_name, c.last_name, r.rental_date
FROM rentals r
JOIN films f ON f.film_id = r.film_id
JOIN customers c ON c.customer_id = r.customer_id
WHERE r.return_date IS NULL;

-- 8. Top 3 most expensive films by rental rate
SELECT title, rental_rate
FROM films
ORDER BY rental_rate DESC
LIMIT 3;
