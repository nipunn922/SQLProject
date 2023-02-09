USE pizza_data

-- Open  all dataset

SELECT * FROM order_details
SELECT * FROM orders
SELECT * FROM pizzas
SELECT * FROM pizza_types

-- Which order Id had the highest number of orders

SELECT order_id, SUM(quantity) AS total_orders
FROM order_details
GROUP BY order_id
ORDER BY total_orders DESC


-- What is the most frequent number of orders given by customers ordering pizza

WITH total AS (SELECT order_id, SUM(quantity) AS total_orders
FROM order_details
GROUP BY order_id)

SELECT total_orders, COUNT(total_orders) AS frequency
FROM total
GROUP BY total_orders
ORDER BY frequency DESC


-- Top 5 pizza which was ordered the most in terms of quantity orders?

SELECT name, SUM(quantity) AS total_quantity
FROM order_details AS od
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY name
ORDER BY total_quantity DESC
LIMIT 5;


-- What size was ordered more repetitively?

SELECT size, COUNT(*) AS count_size
FROM order_details AS od
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY size
ORDER BY count_size DESC


-- What was the total revenue with ranks from each pizza?

WITH pizza_table AS 
(SELECT 
    order_id, 
    name, 
    size, 
    category, 
    ingredients, 
    quantity,
    price
FROM
order_details AS od
LEFT JOIN pizzas AS pz 
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt 
ON pz.pizza_type_id = pt.pizza_type_id)

SELECT name, ROUND(SUM(quantity*price), 2) AS revenue,
RANK() OVER (ORDER BY ROUND(SUM(quantity*price), 2) DESC) AS revenue_rank
FROM pizza_table
GROUP BY name
ORDER BY name 


-- What is the sales from only pizza with ingredients having chicken?

WITH pizza_table AS 
(SELECT order_id, 
	name, 
    	size,  
    	category, 
    	ingredients, 
    	quantity, 
    	price
FROM order_details AS od
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id)

SELECT name, ROUND(SUM(quantity*price), 2) AS revenue
FROM pizza_table
WHERE ingredients LIKE '%chicken%'
GROUP BY name
ORDER BY revenue


-- How many customers ordered pizza that did not contained 'Tomatoes' or 'Mushrooms'?

SELECT COUNT(*) AS customer_count
FROM order_details AS od
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
WHERE ingredients NOT LIKE '%tomatoes%' 
AND ingredients NOT LIKE '%mushroom%' 


-- Ranking the sales of each type of pizza partitioned by category

 WITH pizza_table AS (
 SELECT category, 
	 name,
	 ROUND(SUM(quantity*price), 2) AS revenue
FROM order_details AS od
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY category, name)

SELECT category, name, 
RANK() OVER (PARTITION BY category
	     ORDER BY revenue DESC) AS rank_n
FROM pizza_table
ORDER BY category, rank_n;


-- In which month was the highest number of orders in terms of quantity?

SELECT MONTHNAME(date) AS month, SUM(quantity) AS orders
FROM order_details AS os
LEFT JOIN orders AS ors 
ON os.order_id = ors.order_id
GROUP BY month
ORDER BY orders DESC


-- What days dominates the most number of orders in terms of revenue?

SELECT 
DAYNAME(date) AS day, ROUND(SUM(quantity*price), 2) AS pizza_sales
FROM order_details AS od
LEFT JOIN orders AS ors 
ON od.order_id = ors.order_id
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN  pizza_types AS pt 
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY day
ORDER BY pizza_sales DESC

-- Which week had the highest number of sales?

SELECT 
WEEKOFYEAR(date) AS week_number,
ROUND(SUM(quantity * price), 3) AS total_sales
FROM order_details AS od
LEFT JOIN orders AS ors 
ON od.order_id = ors.order_id
LEFT JOIN pizzas AS pz 
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt 
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY week_number
ORDER BY total_sales DESC;

-- Which category has the highest sales on a monthly basis?

WITH all_orders AS (
SELECT EXTRACT(month FROM date) AS month, 
	category,  
        ROUND(SUM(quantity*price), 2) AS revenue
FROM order_details AS od
LEFT JOIN orders AS ors
ON od.order_id = ors.order_id
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY month, category)

SELECT month, category, revenue,
RANK() OVER(PARTITION BY month 
		ORDER BY revenue DESC) AS rank_n
FROM all_orders
ORDER BY month, rank_n


-- Which order_ids had the highest quantity sold given the pizza size is Medium?

SELECT order_id, SUM(quantity) AS total_quantity
FROM order_details, (SELECT pizza_id
FROM pizzas 
WHERE SIZE = 'M') AS sub

WHERE order_details.pizza_id = sub.pizza_id
GROUP BY order_id
ORDER BY total_quantity DESC


-- In which hour there was the highest number of sales ?

SELECT 
EXTRACT(hour from time) AS hour, ROUND(SUM(quantity*price), 2) AS pizza_sales
FROM order_details AS od
LEFT JOIN orders AS ors 
ON od.order_id = ors.order_id
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN  pizza_types AS pt 
ON pz.pizza_type_id = pt.pizza_type_id
GROUP BY hour
ORDER BY pizza_sales DESC


 -- What was the running total sales in the month of july ?
 
WITH all_orders AS (
SELECT date, time,  ROUND(SUM(quantity*price), 2) AS revenue
FROM order_details AS od
LEFT JOIN orders AS ors
ON od.order_id = ors.order_id
LEFT JOIN pizzas AS pz
ON od.pizza_id = pz.pizza_id
LEFT JOIN pizza_types AS pt
ON pz.pizza_type_id = pt.pizza_type_id
WHERE MONTHNAME(date) = 'July'
GROUP BY time, date
ORDER BY date, time )

SELECT date, time, revenue,
ROUND(SUM(revenue) OVER (ORDER BY date, time), 2) AS running_revenue
FROM all_orders

