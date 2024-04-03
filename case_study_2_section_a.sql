-- A. Pizza Metrics
-- How many pizzas were ordered?
SELECT COUNT(*) as order_pizzas
FROM customer_orders;

-- How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id) as unique_orders
FROM customer_orders;

-- How many successful orders were delivered by each runner?
SELECT 
runner_id, 
COUNT(*) as successful_orders
FROM runner_orders
WHERE pickup_time<>'null'
GROUP BY runner_id;

-- How many of each type of pizza was delivered?
SELECT 
pizza_name,
COUNT(*) as delivered_pizzas
FROM runner_orders as RO
INNER JOIN customer_orders as CO on RO.order_id = CO.order_id
INNER JOIN pizza_names as PN on PN.pizza_id = CO.pizza_id
WHERE pickup_time<>'null'
GROUP BY pizza_name;

-- How many Vegetarian and Meatlovers were ordered by each customer?
WITH CTE AS (
SELECT 
pizza_name,
customer_id,
COUNT(*) as ordered_pizzas
FROM runner_orders as RO
INNER JOIN customer_orders as CO on RO.order_id = CO.order_id
INNER JOIN pizza_names as PN on PN.pizza_id = CO.pizza_id
GROUP BY pizza_name,
customer_id
)
SELECT 
customer_id,
COALESCE("'Meatlovers'",0) as meatlovers,
COALESCE("'Vegetarian'",0) as vegetarian,
COALESCE("'Meatlovers'",0) + COALESCE("'Vegetarian'",0) as total
FROM CTE
PIVOT (SUM(ordered_pizzas) FOR pizza_name IN ( 'Meatlovers','Vegetarian'));

-- What was the maximum number of pizzas delivered in a single order?
SELECT 
RO.order_id, 
COUNT(pizza_id) as pizzas
FROM runner_orders as RO
INNER JOIN customer_orders as CO on RO.order_id = CO.order_id
WHERE pickup_time<>'null'
GROUP BY RO.order_id
ORDER BY COUNT(pizza_id) DESC
LIMIT 1;

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH CHANGES AS (
SELECT 
order_id,
pizza_id,
(CASE 
WHEN exclusions='null' THEN 0
WHEN exclusions='' THEN 0
WHEN exclusions IS NULL THEN 0
ELSE 1
END) +
(CASE 
WHEN extras='null' THEN 0
WHEN extras='' THEN 0
WHEN extras IS NULL THEN 0
ELSE 1
END ) as changes
FROM customer_orders
)
SELECT 
CASE 
WHEN changes>0 THEN 'change'
ELSE 'no changes'
END as change,
COUNT(*) as delivered_pizzas
FROM CHANGES
INNER JOIN runner_orders as RO ON RO.order_id = CHANGES.order_id
WHERE pickup_time<>'null'
GROUP BY 1;

-- How many pizzas were delivered that had both exclusions and extras?
WITH CHANGES AS (
SELECT 
order_id,
pizza_id,
(CASE 
WHEN exclusions='null' THEN 0
WHEN exclusions='' THEN 0
WHEN exclusions IS NULL THEN 0
ELSE 1
END) as exclusions,
(CASE 
WHEN extras='null' THEN 0
WHEN extras='' THEN 0
WHEN extras IS NULL THEN 0
ELSE 1
END ) as extras
FROM customer_orders
)
SELECT COUNT(*) as pizzas_delivered
FROM CHANGES
INNER JOIN runner_orders as RO on RO.order_id = CHANGES.order_id
WHERE exclusions = 1
AND extras = 1
AND pickup_time<>'null';

-- What was the total volume of pizzas ordered for each hour of the day?
SELECT 
DATE_PART('hour',order_time) as hour,
COUNT(*) as pizza_volume
FROM customer_orders
GROUP BY DATE_PART('hour',order_time);


-- What was the volume of orders for each day of the week?
SELECT 
DAYNAME(order_time) as day,
COUNT(*) as pizza_volume
FROM customer_orders
GROUP BY DAYNAME(order_time);