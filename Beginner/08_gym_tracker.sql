-- =====================================================================
-- PROJECT (BEGINNER): GYM MEMBERSHIP TRACKER
-- Skills demonstrated: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT,
--                       aggregates, basic JOINs, CASE (simple)
-- =====================================================================

DROP DATABASE IF EXISTS gym_tracker;
CREATE DATABASE gym_tracker;
USE gym_tracker;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE members (
    member_id     INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    plan_type     VARCHAR(20) NOT NULL,     -- 'Basic', 'Premium', 'VIP'
    signup_date   DATE NOT NULL
);

CREATE TABLE classes (
    class_id      INT PRIMARY KEY AUTO_INCREMENT,
    class_name    VARCHAR(50) NOT NULL,
    instructor    VARCHAR(50) NOT NULL,
    capacity      INT NOT NULL
);

CREATE TABLE attendance (
    attendance_id INT PRIMARY KEY AUTO_INCREMENT,
    member_id     INT NOT NULL,
    class_id      INT NOT NULL,
    attended_on   DATE NOT NULL,
    FOREIGN KEY (member_id) REFERENCES members(member_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO members (first_name, last_name, plan_type, signup_date) VALUES
('Tara',  'Brennan',  'Premium', '2023-01-05'),
('Sam',   'Ilyas',    'Basic',   '2023-02-12'),
('Wren',  'Castillo', 'VIP',     '2023-03-01'),
('Nia',   'Achebe',   'Basic',   '2023-04-18'),
('Omar',  'Farouk',   'Premium', '2023-05-02'),
('Piper', 'Lindqvist','VIP',     '2023-05-20'),
('Ravi',  'Menon',    'Basic',   '2023-06-15'),
('Sasha', 'Volkov',   'Premium', '2023-07-01');

INSERT INTO classes (class_name, instructor, capacity) VALUES
('Morning Yoga',      'Bea Thompson', 20),
('HIIT Blast',        'Marco Diaz',   15),
('Spin Cycle',        'Lena Kruger',  18),
('Strength Basics',   'Marco Diaz',   12),
('Evening Pilates',   'Bea Thompson', 20);

INSERT INTO attendance (member_id, class_id, attended_on) VALUES
(1, 1, '2024-06-03'), (1, 1, '2024-06-05'), (1, 5, '2024-06-10'),
(2, 2, '2024-06-04'), (2, 2, '2024-06-11'),
(3, 3, '2024-06-01'), (3, 3, '2024-06-08'), (3, 2, '2024-06-15'), (3, 4, '2024-06-18'),
(4, 1, '2024-06-06'),
(5, 2, '2024-06-07'), (5, 4, '2024-06-14'),
(6, 3, '2024-06-02'), (6, 3, '2024-06-09'), (6, 3, '2024-06-16'), (6, 5, '2024-06-20'),
(7, 1, '2024-06-12'),
(8, 4, '2024-06-13'), (8, 2, '2024-06-19');

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. All members on the 'VIP' plan
SELECT first_name, last_name, signup_date
FROM members
WHERE plan_type = 'VIP';

-- 2. Distinct plan types offered
SELECT DISTINCT plan_type FROM members;

-- 3. Members sorted by signup date, most recent first
SELECT first_name, last_name, signup_date
FROM members
ORDER BY signup_date DESC;

-- 4. Number of members per plan type
SELECT plan_type, COUNT(*) AS member_count
FROM members
GROUP BY plan_type
ORDER BY member_count DESC;

-- 5. Most popular classes by attendance count
SELECT c.class_name, COUNT(a.attendance_id) AS total_attendance
FROM classes c
JOIN attendance a ON a.class_id = c.class_id
GROUP BY c.class_name
ORDER BY total_attendance DESC;

-- 6. Members who have attended more than 3 classes total
SELECT m.first_name, m.last_name, COUNT(a.attendance_id) AS classes_attended
FROM members m
JOIN attendance a ON a.member_id = m.member_id
GROUP BY m.member_id, m.first_name, m.last_name
HAVING classes_attended > 3;

-- 7. Classes taught by each instructor
SELECT instructor, COUNT(*) AS classes_taught
FROM classes
GROUP BY instructor;

-- 8. Members who have never attended a class (LEFT JOIN)
SELECT m.first_name, m.last_name
FROM members m
LEFT JOIN attendance a ON a.member_id = m.member_id
WHERE a.attendance_id IS NULL;

-- 9. Top 3 most recent class attendances overall
SELECT m.first_name, m.last_name, c.class_name, a.attended_on
FROM attendance a
JOIN members m ON m.member_id = a.member_id
JOIN classes c ON c.class_id = a.class_id
ORDER BY a.attended_on DESC
LIMIT 3;
