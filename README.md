# MySQL Projects

## Contents

### Beginner

| # | File | Domain | Focus |
|---|------|--------|-------|
| 1 | `01_retail_sales_beginner.sql` | Retail sales | `SELECT`, `WHERE`, `ORDER BY`, `LIMIT`, `DISTINCT`, basic aggregates |
| 2 | `02_movie_rental_beginner.sql` | Movie rental | Filtering, simple joins, `GROUP BY`, date filtering |
| 3 | `07_library_management_beginner.sql` | Library management | Filtering, joins, aggregates, `DATEDIFF` |
| 4 | `08_gym_tracker_beginner.sql` | Gym membership | Filtering, `GROUP BY`, `HAVING`, `LEFT JOIN` anti-pattern |

### Intermediate

| # | File | Domain | Focus |
|---|------|--------|-------|
| 5 | `03_ecommerce_intermediate.sql` | E-commerce | Multi-table `JOIN`s, subqueries, `HAVING`, `CASE`, date functions |
| 6 | `04_hr_management_intermediate.sql` | HR / employee management | Self-joins, views, `HAVING` |
| 7 | `09_food_delivery_intermediate.sql` | Food delivery app | Correlated subqueries, `CASE`, `TIMESTAMPDIFF`, cancellation-rate analysis |
| 8 | `10_airline_booking_intermediate.sql` | Airline booking | Double self-joins (route pairs), `CASE`, `HAVING` vs. subquery average |

## Beginner projects

### 1. Retail Sales Database

A small retail store: customers, products, and the orders linking them.

**Schema:** `customers` — `orders` — `products` (each order links one
customer to one product with a quantity and date).

**Sample data:** 12 customers across 9 countries, 10 products across 4
categories, 25 orders.

**Query highlights:** products priced above the average price (subquery),
top 10 customers by order count, total orders per month, revenue across a
join with no `GROUP BY`.

### 2. Movie Rental Analysis

A simplified video rental system: stores, films, customers,
and rentals.

**Schema:** `stores` — `customers` — `rentals` — `films`.

**Sample data:** 2 stores, 10 films across 6 categories, 10 customers, 20
rentals.

**Query highlights:** most rented films, revenue per store, customers
inactive for 90+ days, currently outstanding (unreturned) rentals.

### 3. Library Management System

Authors, books, members, and book loans.

**Schema:** `authors` — `books` — `loans` — `members`.

**Sample data:** 6 authors, 10 books, 8 members, 16 loans.

**Query highlights:** most-loaned books, members currently holding a book,
loans returned late (`DATEDIFF` between due date and return date), books
per author.

### 4. Gym Membership Tracker

Members, fitness classes, and class attendance.

**Schema:** `members` — `attendance` — `classes`.

**Sample data:** 8 members across 3 plan tiers, 5 classes, 18 attendance
records.

**Query highlights:** most popular classes, members attending more than 3
classes, members who have never attended a class (`LEFT JOIN` anti-pattern).

---

## Intermediate projects

### 5. E-commerce Analytics

Customers, categories, products, orders, and order line items.

**Schema:** `customers` — `orders` — `order_items` — `products` — `categories`.

**Sample data:** 10 customers, 5 categories, 15 products, 20 orders, ~28
order items.

**Query highlights:** monthly revenue trend, products never ordered
(`LEFT JOIN` anti-pattern), customer spend tiers via `CASE`, second-highest
order value per customer (correlated subquery), categories with
above-average revenue.

### 6. HR / Employee Management System

Departments and employees, including a manager hierarchy.

**Schema:** `departments` — `employees` (self-referencing `manager_id`).

**Sample data:** 5 departments, 21 employees.

**Query highlights:** employees earning more than their manager (self-join),
departments with above-average headcount, a `VIEW` summarizing department
budget vs. salary spend, longest-tenured employee per department.

### 7. Food Delivery App

Restaurants, menu items, customers, drivers, orders, and order items.

**Schema:** `restaurants` — `menu_items`; `customers` — `orders` —
`order_items`; `drivers` — `orders`.

**Sample data:** 6 restaurants, 15 menu items, 8 customers, 4 drivers, 18
orders.

**Query highlights:** average delivery time per restaurant, orders slower
than their own restaurant's average (correlated subquery), customer spend
tiers, cancellation rate per restaurant.

### 8. Airline Booking System

Airports, flights, passengers, and bookings.

**Schema:** `airports` — `flights` (origin/destination both reference
`airports`) — `bookings` — `passengers`.

**Sample data:** 6 airports, 8 flights, 8 passengers, 18 bookings.

**Query highlights:** flights joined twice to `airports` for origin and
destination city names, flights with above-average cancellation rate,
revenue by seat class, round-trip route pairs (self-join).

---
