-- DATA ANALYTICS MODULE-END ASSIGNMENT 3


CREATE DATABASE elearning_platform;
USE elearning_platform;



CREATE TABLE learners (
  learner_id INT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  country VARCHAR(60) NOT NULL
);

CREATE TABLE courses (
  course_id INT PRIMARY KEY,
  course_name VARCHAR(120) NOT NULL,
  category VARCHAR(60) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0)
);

CREATE TABLE purchases (
  purchase_id INT PRIMARY KEY,
  learner_id INT NOT NULL,
  course_id INT NOT NULL,
  quantity INT NOT NULL CHECK (quantity > 0),
  purchase_date DATE NOT NULL,
  CONSTRAINT fk_purchase_learner FOREIGN KEY (learner_id) REFERENCES learners(learner_id),
  CONSTRAINT fk_purchase_course FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

INSERT INTO learners VALUES
(1, 'Ananya Rao', 'India'),
(2, 'Ben Carter', 'USA'),
(3, 'Chen Wei', 'Singapore'),
(4, 'Divya Kumar', 'India'),
(5, 'Ethan Brown', 'UK');

INSERT INTO courses VALUES
(101, 'SQL Basics', 'Data Analytics', 4999.00),
(102, 'Python for Data Science', 'Data Science', 5999.00),
(103, 'Excel for Business', 'Business', 2999.00),
(104, 'UI UX Design Fundamentals', 'Design', 3999.00),
(105, 'Cloud Computing with AWS', 'Cloud', 6999.00);

INSERT INTO purchases VALUES
(1001, 1, 101, 1, '2026-01-05'),
(1002, 1, 102, 1, '2026-01-08'),
(1003, 2, 101, 2, '2026-01-10'),
(1004, 2, 103, 1, '2026-01-12'),
(1005, 3, 102, 1, '2026-01-15'),
(1006, 4, 104, 1, '2026-01-18'),
(1007, 4, 101, 1, '2026-01-20'),
(1008, 2, 103, 1, '2026-01-22');

-- DATA EXPLORATION: INNER JOIN (all matched purchase details)
SELECT l.learner_id, l.full_name AS learner_name, c.course_name, c.category,
       p.quantity, FORMAT(p.quantity * c.unit_price, 2) AS total_amount, p.purchase_date
FROM purchases p
INNER JOIN learners l ON p.learner_id = l.learner_id
INNER JOIN courses c ON p.course_id = c.course_id
ORDER BY p.purchase_date, l.full_name;

-- LEFT JOIN: keep every learner, including learners with no purchases
SELECT l.learner_id, l.full_name AS learner_name, c.course_name, c.category,
       p.quantity, FORMAT(COALESCE(p.quantity * c.unit_price, 0), 2) AS total_amount,
       p.purchase_date
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses c ON p.course_id = c.course_id
ORDER BY l.full_name, p.purchase_date;

-- RIGHT JOIN: keep every course, including courses never purchased
SELECT c.course_id, c.course_name, c.category, l.full_name AS learner_name,
       p.quantity, FORMAT(COALESCE(p.quantity * c.unit_price, 0), 2) AS total_amount,
       p.purchase_date
FROM purchases p
RIGHT JOIN courses c ON p.course_id = c.course_id
LEFT JOIN learners l ON p.learner_id = l.learner_id
ORDER BY c.course_id, p.purchase_date;

-- Each learner's total spending and country
SELECT l.learner_id, l.full_name AS learner_name, l.country,
       FORMAT(COALESCE(SUM(p.quantity * c.unit_price), 0), 2) AS total_spent
FROM learners l
LEFT JOIN purchases p ON l.learner_id = p.learner_id
LEFT JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name, l.country
ORDER BY COALESCE(SUM(p.quantity * c.unit_price), 0) DESC;

--  Top 3 courses by total quantity sold
SELECT c.course_id, c.course_name, SUM(p.quantity) AS total_quantity_sold
FROM courses c
INNER JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.course_id, c.course_name
ORDER BY total_quantity_sold DESC, c.course_name
LIMIT 3;

-- Revenue and unique learners by category
SELECT c.category, FORMAT(SUM(p.quantity * c.unit_price), 2) AS total_revenue,
       COUNT(DISTINCT p.learner_id) AS unique_learners
FROM courses c
INNER JOIN purchases p ON c.course_id = p.course_id
GROUP BY c.category
ORDER BY SUM(p.quantity * c.unit_price) DESC;

-- learners who purchased from more than one category
SELECT l.learner_id, l.full_name AS learner_name,
       COUNT(DISTINCT c.category) AS categories_purchased
FROM learners l
INNER JOIN purchases p ON l.learner_id = p.learner_id
INNER JOIN courses c ON p.course_id = c.course_id
GROUP BY l.learner_id, l.full_name
HAVING COUNT(DISTINCT c.category) > 1
ORDER BY categories_purchased DESC, l.full_name;

-- courses that have never been purchased
SELECT c.course_id, c.course_name, c.category, FORMAT(c.unit_price, 2) AS unit_price
FROM courses c
LEFT JOIN purchases p ON c.course_id = p.course_id
WHERE p.purchase_id IS NULL
ORDER BY c.course_name;
