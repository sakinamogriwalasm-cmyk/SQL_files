-- =====================================================================
-- PROJECT (BEGINNER): LIBRARY MANAGEMENT SYSTEM
-- Skills demonstrated: SELECT, WHERE, ORDER BY, LIMIT, DISTINCT,
--                       basic aggregates, simple JOINs, date filtering
-- =====================================================================

DROP DATABASE IF EXISTS library_management;
CREATE DATABASE library_management;
USE library_management;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE authors (
    author_id     INT PRIMARY KEY AUTO_INCREMENT,
    author_name   VARCHAR(100) NOT NULL,
    country       VARCHAR(50)
);

CREATE TABLE books (
    book_id       INT PRIMARY KEY AUTO_INCREMENT,
    title         VARCHAR(150) NOT NULL,
    author_id     INT NOT NULL,
    genre         VARCHAR(50),
    published_year YEAR,
    copies_owned  INT NOT NULL DEFAULT 1,
    FOREIGN KEY (author_id) REFERENCES authors(author_id)
);

CREATE TABLE members (
    member_id     INT PRIMARY KEY AUTO_INCREMENT,
    first_name    VARCHAR(50) NOT NULL,
    last_name     VARCHAR(50) NOT NULL,
    join_date     DATE NOT NULL
);

CREATE TABLE loans (
    loan_id       INT PRIMARY KEY AUTO_INCREMENT,
    book_id       INT NOT NULL,
    member_id     INT NOT NULL,
    loan_date     DATE NOT NULL,
    due_date      DATE NOT NULL,
    return_date   DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO authors (author_name, country) VALUES
('Haruki Murakami',   'Japan'),
('Chimamanda Adichie','Nigeria'),
('George Orwell',     'UK'),
('Isabel Allende',    'Chile'),
('Yuval Noah Harari', 'Israel'),
('Toni Morrison',     'USA');

INSERT INTO books (title, author_id, genre, published_year, copies_owned) VALUES
('Norwegian Wood',            1, 'Fiction',    1987, 3),
('Kafka on the Shore',        1, 'Fiction',    2002, 2),
('Half of a Yellow Sun',      2, 'Fiction',    2006, 4),
('Americanah',                2, 'Fiction',    2013, 3),
('1984',                      3, 'Dystopian',  1949, 5),
('Animal Farm',                3, 'Satire',     1945, 4),
('The House of the Spirits',  4, 'Fiction',    1982, 2),
('Sapiens',                   5, 'Non-fiction',2011, 6),
('Homo Deus',                 5, 'Non-fiction',2015, 3),
('Beloved',                   6, 'Fiction',    1987, 2);

INSERT INTO members (first_name, last_name, join_date) VALUES
('Anya',   'Petrov',   '2022-01-10'),
('Ben',    'Nakamura', '2022-03-22'),
('Carmen', 'Diaz',     '2022-05-14'),
('Derek',  'Ola',      '2022-07-01'),
('Emi',    'Suzuki',   '2022-09-19'),
('Farid',  'Hossain',  '2023-01-05'),
('Gina',   'Marchetti','2023-02-28'),
('Hank',   'Osei',     '2023-04-11');

INSERT INTO loans (book_id, member_id, loan_date, due_date, return_date) VALUES
(1, 1, '2024-05-01', '2024-05-15', '2024-05-14'),
(5, 1, '2024-06-01', '2024-06-15', '2024-06-20'),   -- returned late
(3, 2, '2024-05-03', '2024-05-17', '2024-05-16'),
(8, 2, '2024-06-10', '2024-06-24', NULL),            -- still out
(5, 3, '2024-05-05', '2024-05-19', '2024-05-18'),
(9, 3, '2024-07-01', '2024-07-15', NULL),             -- still out, overdue if today > due
(2, 4, '2024-05-08', '2024-05-22', '2024-05-21'),
(6, 4, '2024-06-12', '2024-06-26', '2024-07-01'),     -- returned late
(4, 5, '2024-05-10', '2024-05-24', '2024-05-23'),
(5, 5, '2024-06-15', '2024-06-29', '2024-06-28'),
(7, 6, '2024-05-12', '2024-05-26', '2024-05-25'),
(1, 6, '2024-07-02', '2024-07-16', NULL),
(8, 7, '2024-05-14', '2024-05-28', '2024-05-27'),
(10,7, '2024-06-18', '2024-07-02', '2024-07-05'),     -- returned late
(5, 8, '2024-05-16', '2024-05-30', '2024-05-29'),
(3, 8, '2024-06-20', '2024-07-04', NULL);

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. All books, alphabetically by title
SELECT title, genre, published_year
FROM books
ORDER BY title;

-- 2. Books in the "Fiction" genre
SELECT title, published_year
FROM books
WHERE genre = 'Fiction';

-- 3. Distinct genres in the catalog
SELECT DISTINCT genre FROM books;

-- 4. Books published before 1990
SELECT title, published_year
FROM books
WHERE published_year < 1990
ORDER BY published_year;

-- 5. Top 5 most-loaned books
SELECT b.title, COUNT(l.loan_id) AS times_loaned
FROM books b
JOIN loans l ON l.book_id = b.book_id
GROUP BY b.title
ORDER BY times_loaned DESC
LIMIT 5;

-- 6. Members who currently have a book checked out (not yet returned)
SELECT m.first_name, m.last_name, b.title, l.due_date
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b ON b.book_id = l.book_id
WHERE l.return_date IS NULL;

-- 7. Loans that were returned late
SELECT m.first_name, m.last_name, b.title, l.due_date, l.return_date,
       DATEDIFF(l.return_date, l.due_date) AS days_late
FROM loans l
JOIN members m ON m.member_id = l.member_id
JOIN books b ON b.book_id = l.book_id
WHERE l.return_date > l.due_date;

-- 8. Number of books written by each author
SELECT a.author_name, COUNT(b.book_id) AS book_count
FROM authors a
JOIN books b ON b.author_id = a.author_id
GROUP BY a.author_name
ORDER BY book_count DESC;

-- 9. Average number of copies owned per genre
SELECT genre, AVG(copies_owned) AS avg_copies
FROM books
GROUP BY genre
ORDER BY avg_copies DESC;

-- 10. Members who joined in 2023
SELECT first_name, last_name, join_date
FROM members
WHERE join_date >= '2023-01-01'
ORDER BY join_date;
