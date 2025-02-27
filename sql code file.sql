create database pizzahut;

select * from pizzas;

select * from pizza_types;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id)); 

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_details_id)); 

select * from order_details;

-- Retrieve the total number of orders placed

select * from orders;

SELECT COUNT(*) FROM orders;

-- The total number of orders are 21350

-- Calculate the total revenue generated from pizza sales.

select * from pizzas;

select SUM(o.quantity*p.price) As total_revenue
from pizzas As p
JOIN order_details AS o
ON p.pizza_id=o.pizza_id;

-- the total revenue generated from pizza sales is 817860.049999993

-- Identify the highest-priced pizza.

select * from pizzas;

SELECT pt.name,p.price
FROM pizzas AS p
JOIN pizza_types AS pt
ON p.pizza_type_id=pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- The highest price pizza is : The Greek Pizza	35.95

-- Identify the most common pizza size ordered.

SELECT p.size, COUNT(order_details_id) AS total
FROM pizzas AS p
JOIN order_details AS o
ON p.pizza_id=o.pizza_id
GROUP BY p.size
ORDER BY total DESC
LIMIT 1;

-- The most common pizza size ordered is: L	18526

-- List the top 5 most ordered pizza types along with their quantities.

SELECT pt.name, sum(o.quantity) AS quantity
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details AS o
ON p.pizza_id=o.pizza_id
group by pt.name
ORDER BY quantity DESC
LIMIT 5;

-- The most ordered pizza types are: The Classic Deluxe Pizza	2453
-- The Barbecue Chicken Pizza	2432
-- The Hawaiian Pizza	2422
-- The Pepperoni Pizza	2418
-- The Thai Chicken Pizza	2371
-- Use ctrl+/ to comment multiple lines at once

-- Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT category, sum(o.quantity) AS total_ordered
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details AS o
ON p.pizza_id=o.pizza_id
GROUP BY category
ORDER BY total_ordered DESC;

-- the total quantity of each pizza category ordered is: 
-- Classic	14888
-- Supreme	11987
-- Veggie	11649
-- Chicken	11050

-- Determine the distribution of orders by hour of the day.

WITH cte AS(SELECT *, EXTRACT(DAY FROM order_date) AS date,EXTRACT( HOUR FROM order_time) AS hour
FROM orders)
SELECT hour,COUNT(order_id)
FROM cte
GROUP BY hour
ORDER BY hour;

-- the distribution of orders by hour of the day is:
-- 9	1
-- 10	8
-- 11	1231
-- 12	2520
-- 13	2455
-- 14	1472
-- 15	1468
-- 16	1920
-- 17	2336
-- 18	2399
-- 19	2009
-- 20	1642
-- 21	1198
-- 22	663
-- 23	28

-- Join relevant tables to find the category-wise distribution of pizzas.

SELECT category, COUNT(name) AS total
FROM pizza_types
GROUP BY category
ORDER BY total DESC;

--  the category-wise distribution of pizzas is:
-- Supreme	9
-- Veggie	9
-- Classic	8
-- Chicken	6

-- Group the orders by date and calculate the average number of pizzas ordered per day.

WITH cte AS(
SELECT o.order_date, SUM(od.quantity) AS total
FROM orders AS o
JOIN order_details AS od
ON o.order_id=od.order_id
GROUP BY o.order_date)
SELECT AVG(total) AS avg_order_per_day
FROM cte;

-- the average number of pizzas ordered per day is 138.4749

-- Determine the top 3 most ordered pizza types based on revenue.

SELECT pt.name,SUM(p.price*o.quantity) AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details AS o
ON p.pizza_id=o.pizza_id
GROUP BY pt.name
ORDER BY revenue DESC
LIMIT 3;

-- the top 3 most ordered pizza types based on revenue

-- The Thai Chicken Pizza	43434.25
-- The Barbecue Chicken Pizza	42768
-- The California Chicken Pizza	41409.5

-- Calculate the percentage contribution of each pizza type to total revenue.

SELECT pt.category, (SUM(p.price*o.quantity)/(SELECT SUM(p.price*o.quantity) AS total_sales
FROM order_details AS o
JOIN pizzas AS p
ON p.pizza_id=o.pizza_id))*100 AS revenue
FROM pizza_types AS pt
JOIN pizzas AS p
ON pt.pizza_type_id=p.pizza_type_id
JOIN order_details AS o
ON p.pizza_id=o.pizza_id
GROUP BY pt.category
ORDER BY revenue DESC;

-- the percentage contribution of each pizza type to total revenue
-- Classic	26.905960255669903
-- Supreme	25.45631126009884
-- Chicken	23.955137556847493
-- Veggie	23.682590927384783

-- Analyze the cumulative revenue generated over time.

SELECT order_date, SUM(revenue) OVER(ORDER BY order_date) AS cum_revenue
FROM
(SELECT o.order_date,SUM(p.price*od.quantity) AS revenue
FROM orders AS o
JOIN order_details AS od
ON o.order_id=od.order_id
JOIN pizzas AS p
ON p.pizza_id=od.pizza_id
GROUP BY o.order_date) AS sales;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
SELECT name,revenue
FROM
(SELECT category,name,revenue,RANK() OVER(partition by category ORDER BY revenue DESC) AS rn
FROM
(SELECT pt.category, pt.name,SUM(p.price*o.quantity) AS revenue
FROM pizzas AS p
JOIN pizza_types AS pt
ON p.pizza_type_id=pt.pizza_type_id
JOIN order_details AS o
ON o.pizza_id=p.pizza_id
GROUP BY pt.category,pt.name) AS a) AS b
WHERE rn<=3;

