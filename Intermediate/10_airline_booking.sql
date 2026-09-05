-- =====================================================================
-- PROJECT (INTERMEDIATE): AIRLINE BOOKING SYSTEM
-- Skills demonstrated: multi-table JOINs, subqueries, GROUP BY + HAVING,
--                       CASE, date/time functions, self-referencing
--                       logic via route pairs
-- =====================================================================

DROP DATABASE IF EXISTS airline_booking;
CREATE DATABASE airline_booking;
USE airline_booking;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE airports (
    airport_code  CHAR(3) PRIMARY KEY,
    airport_name  VARCHAR(100) NOT NULL,
    city          VARCHAR(50) NOT NULL
);

CREATE TABLE flights (
    flight_id      INT PRIMARY KEY AUTO_INCREMENT,
    flight_number  VARCHAR(10) NOT NULL,
    origin         CHAR(3) NOT NULL,
    destination    CHAR(3) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time   DATETIME NOT NULL,
    base_price     DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (origin) REFERENCES airports(airport_code),
    FOREIGN KEY (destination) REFERENCES airports(airport_code)
);

CREATE TABLE passengers (
    passenger_id  INT PRIMARY KEY AUTO_INCREMENT,
    full_name     VARCHAR(100) NOT NULL,
    frequent_flyer_tier VARCHAR(20) NOT NULL DEFAULT 'Standard'
);

CREATE TABLE bookings (
    booking_id    INT PRIMARY KEY AUTO_INCREMENT,
    flight_id     INT NOT NULL,
    passenger_id  INT NOT NULL,
    booking_date  DATE NOT NULL,
    seat_class    VARCHAR(20) NOT NULL,     -- 'Economy', 'Business', 'First'
    fare_paid     DECIMAL(8,2) NOT NULL,
    status        VARCHAR(20) NOT NULL DEFAULT 'confirmed',
    FOREIGN KEY (flight_id) REFERENCES flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengers(passenger_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO airports (airport_code, airport_name, city) VALUES
('JFK', 'John F. Kennedy Intl', 'New York'),
('LAX', 'Los Angeles Intl',     'Los Angeles'),
('ORD', 'O''Hare Intl',         'Chicago'),
('ATL', 'Hartsfield-Jackson',   'Atlanta'),
('SFO', 'San Francisco Intl',   'San Francisco'),
('MIA', 'Miami Intl',           'Miami');

INSERT INTO flights (flight_number, origin, destination, departure_time, arrival_time, base_price) VALUES
('AL101', 'JFK', 'LAX', '2024-07-01 08:00:00', '2024-07-01 11:15:00', 320.00),
('AL102', 'LAX', 'JFK', '2024-07-05 13:00:00', '2024-07-05 21:10:00', 340.00),
('AL201', 'ORD', 'ATL', '2024-07-02 09:30:00', '2024-07-02 12:00:00', 180.00),
('AL202', 'ATL', 'ORD', '2024-07-06 15:00:00', '2024-07-06 16:45:00', 175.00),
('AL301', 'SFO', 'MIA', '2024-07-03 07:00:00', '2024-07-03 15:20:00', 410.00),
('AL302', 'MIA', 'SFO', '2024-07-08 17:00:00', '2024-07-08 20:10:00', 425.00),
('AL401', 'JFK', 'ORD', '2024-07-04 10:00:00', '2024-07-04 11:45:00', 150.00),
('AL501', 'LAX', 'SFO', '2024-07-04 18:00:00', '2024-07-04 19:20:00', 95.00);

INSERT INTO passengers (full_name, frequent_flyer_tier) VALUES
('Alicia Fontaine', 'Gold'),
('Brian Kowalski',  'Standard'),
('Camille Dupont',  'Silver'),
('Derek Osei',      'Standard'),
('Elyse Whitfield', 'Gold'),
('Farhan Iqbal',    'Standard'),
('Giulia Romano',   'Silver'),
('Hassan Ali',      'Standard');

INSERT INTO bookings (flight_id, passenger_id, booking_date, seat_class, fare_paid, status) VALUES
(1, 1, '2024-06-01', 'Business', 780.00, 'confirmed'),
(1, 2, '2024-06-02', 'Economy',  320.00, 'confirmed'),
(1, 3, '2024-06-05', 'Economy',  320.00, 'confirmed'),
(2, 1, '2024-06-01', 'Business', 820.00, 'confirmed'),
(2, 4, '2024-06-10', 'Economy',  340.00, 'cancelled'),
(3, 5, '2024-06-03', 'First',    540.00, 'confirmed'),
(3, 6, '2024-06-12', 'Economy',  180.00, 'confirmed'),
(4, 5, '2024-06-03', 'First',    530.00, 'confirmed'),
(4, 7, '2024-06-15', 'Economy',  175.00, 'confirmed'),
(5, 2, '2024-06-06', 'Economy',  410.00, 'confirmed'),
(5, 8, '2024-06-18', 'Business', 920.00, 'confirmed'),
(6, 3, '2024-06-08', 'Economy',  425.00, 'cancelled'),
(7, 4, '2024-06-11', 'Economy',  150.00, 'confirmed'),
(7, 6, '2024-06-20', 'Economy',  150.00, 'confirmed'),
(8, 1, '2024-06-04', 'Economy',   95.00, 'confirmed'),
(8, 7, '2024-06-22', 'Economy',   95.00, 'confirmed'),
(1, 8, '2024-06-25', 'Economy',  320.00, 'confirmed'),
(3, 2, '2024-06-27', 'Economy',  180.00, 'confirmed');

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. All flights with their full origin/destination city names (two joins to the same table)
SELECT f.flight_number,
       orig.city AS origin_city,
       dest.city AS destination_city,
       f.departure_time,
       f.base_price
FROM flights f
JOIN airports orig ON orig.airport_code = f.origin
JOIN airports dest ON dest.airport_code = f.destination
ORDER BY f.departure_time;

-- 2. Total revenue per flight (confirmed bookings only)
SELECT f.flight_number,
       ROUND(SUM(b.fare_paid), 2) AS total_revenue,
       COUNT(b.booking_id) AS seats_sold
FROM flights f
JOIN bookings b ON b.flight_id = f.flight_id AND b.status = 'confirmed'
GROUP BY f.flight_number
ORDER BY total_revenue DESC;

-- 3. Passengers who have booked more than 2 confirmed flights
SELECT p.full_name, COUNT(b.booking_id) AS confirmed_bookings
FROM passengers p
JOIN bookings b ON b.passenger_id = p.passenger_id AND b.status = 'confirmed'
GROUP BY p.passenger_id, p.full_name
HAVING confirmed_bookings > 2;

-- 4. Revenue by seat class, with a CASE-based markup label
SELECT seat_class,
       ROUND(SUM(fare_paid), 2) AS total_revenue,
       CASE
           WHEN seat_class = 'First' THEN 'Premium cabin'
           WHEN seat_class = 'Business' THEN 'Premium cabin'
           ELSE 'Standard cabin'
       END AS cabin_group
FROM bookings
WHERE status = 'confirmed'
GROUP BY seat_class
ORDER BY total_revenue DESC;

-- 5. Flights with a cancellation rate above the network average
SELECT f.flight_number,
       COUNT(*) AS total_bookings,
       SUM(CASE WHEN b.status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
       ROUND(100.0 * SUM(CASE WHEN b.status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*), 1) AS cancel_rate_pct
FROM flights f
JOIN bookings b ON b.flight_id = f.flight_id
GROUP BY f.flight_number
HAVING cancel_rate_pct > (
    SELECT 100.0 * SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) / COUNT(*)
    FROM bookings
);

-- 6. Average fare paid per frequent flyer tier
SELECT p.frequent_flyer_tier, ROUND(AVG(b.fare_paid), 2) AS avg_fare_paid
FROM passengers p
JOIN bookings b ON b.passenger_id = p.passenger_id AND b.status = 'confirmed'
GROUP BY p.frequent_flyer_tier
ORDER BY avg_fare_paid DESC;

-- 7. Flights departing within the next 3 days of the latest booking date in the data
--    (relative date logic, useful for "upcoming departures" dashboards)
SELECT flight_number, departure_time
FROM flights
WHERE departure_time BETWEEN
    (SELECT MAX(booking_date) FROM bookings)
    AND DATE_ADD((SELECT MAX(booking_date) FROM bookings), INTERVAL 3 DAY)
ORDER BY departure_time;

-- 8. Round-trip pairs: routes where a return flight exists (origin/destination reversed)
SELECT f1.flight_number AS outbound, f2.flight_number AS return_flight,
       f1.origin, f1.destination
FROM flights f1
JOIN flights f2 ON f2.origin = f1.destination AND f2.destination = f1.origin
WHERE f1.origin < f1.destination;   -- avoid duplicate reversed pairs
