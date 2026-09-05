-- =====================================================================
-- PROJECT 4 (INTERMEDIATE): HR / EMPLOYEE MANAGEMENT SYSTEM
-- Skills demonstrated: self-joins, multi-table joins, GROUP BY + HAVING,
--                       views, date functions
-- =====================================================================

DROP DATABASE IF EXISTS hr_management;
CREATE DATABASE hr_management;
USE hr_management;

-- ---------------------------------------------------------------------
-- SCHEMA
-- ---------------------------------------------------------------------

CREATE TABLE departments (
    department_id    INT PRIMARY KEY AUTO_INCREMENT,
    department_name  VARCHAR(50) NOT NULL,
    budget            DECIMAL(12,2) NOT NULL
);

CREATE TABLE employees (
    employee_id    INT PRIMARY KEY AUTO_INCREMENT,
    first_name     VARCHAR(50) NOT NULL,
    last_name      VARCHAR(50) NOT NULL,
    department_id  INT NOT NULL,
    manager_id     INT NULL,                       -- self-referencing FK
    salary         DECIMAL(10,2) NOT NULL,
    hire_date      DATE NOT NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- ---------------------------------------------------------------------
-- SAMPLE DATA
-- ---------------------------------------------------------------------

INSERT INTO departments (department_name, budget) VALUES
('Engineering', 1200000.00),
('Sales',        600000.00),
('Marketing',    350000.00),
('Finance',      400000.00),
('Human Resources', 200000.00);

-- Top-level managers first (manager_id NULL), then their reports
INSERT INTO employees (first_name, last_name, department_id, manager_id, salary, hire_date) VALUES
('Rachel',  'Kim',       1, NULL, 145000, '2018-01-10'),  -- 1 Eng director
('Victor',  'Adeyemi',   2, NULL, 130000, '2018-03-15'),  -- 2 Sales director
('Priya',   'Desai',     3, NULL, 110000, '2019-02-01'),  -- 3 Marketing director
('Simon',   'Blake',     4, NULL, 125000, '2018-06-20'),  -- 4 Finance director
('Denise',  'Ford',      5, NULL, 105000, '2019-05-11'),  -- 5 HR director

('Alex',    'Nguyen',    1, 1, 98000,  '2019-04-01'),      -- 6
('Bianca',  'Rossi',     1, 1, 102000, '2019-07-15'),      -- 7
('Carlos',  'Mendes',    1, 1, 95000,  '2020-01-20'),      -- 8
('Deepa',   'Iyer',      1, 6, 87000,  '2021-03-10'),      -- 9  reports to Alex
('Ewan',    'MacLeod',   1, 6, 91000,  '2021-06-01'),      -- 10 reports to Alex
('Farah',   'Haddad',    1, 7, 152000, '2020-09-05'),      -- 11 reports to Bianca, earns MORE than manager

('Grace',   'Oduya',     2, 2, 78000,  '2019-08-12'),      -- 12
('Hugo',    'Alvarez',   2, 2, 82000,  '2020-02-18'),      -- 13
('Ines',    'Costa',     2, 12,88000,  '2021-01-11'),      -- 14 reports to Grace, earns MORE than manager
('Jonas',   'Weber',     2, 12,74000,  '2021-11-02'),      -- 15

('Karin',   'Svensson',  3, 3, 68000,  '2020-05-06'),      -- 16
('Leon',    'Fischer',   3, 3, 71000,  '2020-08-19'),      -- 17

('Maya',    'Chowdhury', 4, 4, 84000,  '2019-10-01'),      -- 18
('Noah',    'Peterson',  4, 4, 89000,  '2020-04-14'),      -- 19

('Olga',    'Ivanova',   5, 5, 61000,  '2021-02-08'),      -- 20
('Paulo',   'Sousa',     5, 5, 63000,  '2022-01-17');      -- 21

-- ---------------------------------------------------------------------
-- QUERIES
-- ---------------------------------------------------------------------

-- 1. Employees who earn more than their manager (self-join)
SELECT e.first_name AS employee_first, e.last_name AS employee_last, e.salary AS employee_salary,
       m.first_name AS manager_first, m.last_name AS manager_last, m.salary AS manager_salary
FROM employees e
JOIN employees m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;

-- 2. Departments with above-average headcount
SELECT d.department_name, COUNT(e.employee_id) AS headcount
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
HAVING headcount > (
    SELECT AVG(dept_count) FROM (
        SELECT COUNT(*) AS dept_count
        FROM employees
        GROUP BY department_id
    ) AS sub
);

-- 3. Create a view summarizing department budget vs. actual salary spend
CREATE OR REPLACE VIEW department_budget_summary AS
SELECT d.department_id,
       d.department_name,
       d.budget,
       SUM(e.salary) AS total_salaries,
       d.budget - SUM(e.salary) AS remaining_budget
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_id, d.department_name, d.budget;

-- Usage:
SELECT * FROM department_budget_summary ORDER BY remaining_budget DESC;

-- 4. Average salary per department
SELECT d.department_name, ROUND(AVG(e.salary), 2) AS avg_salary
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY avg_salary DESC;

-- 5. Employees hired in the last 3 years (relative to most recent hire date in the data)
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date >= (SELECT DATE_SUB(MAX(hire_date), INTERVAL 3 YEAR) FROM employees)
ORDER BY hire_date DESC;

-- 6. Longest-tenured employee in each department
SELECT e.department_id, d.department_name, e.first_name, e.last_name, e.hire_date
FROM employees e
JOIN departments d ON d.department_id = e.department_id
WHERE e.hire_date = (
    SELECT MIN(e2.hire_date)
    FROM employees e2
    WHERE e2.department_id = e.department_id
);

-- 7. Managers and their direct report count
SELECT m.first_name, m.last_name, COUNT(e.employee_id) AS direct_reports
FROM employees m
JOIN employees e ON e.manager_id = m.employee_id
GROUP BY m.employee_id, m.first_name, m.last_name
ORDER BY direct_reports DESC;

-- 8. Salary spread (max - min) within each department
SELECT d.department_name, MAX(e.salary) - MIN(e.salary) AS salary_spread
FROM departments d
JOIN employees e ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY salary_spread DESC;
