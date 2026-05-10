                                          -- PIZZA SALES - SQL --

-- Q1. Retrieve the total number of orders placed.


SELECT 
    COUNT(order_id) AS Total_Order
FROM
    orders;
    
    
    
-- Q2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(od.quantity * p.price)) AS total_rev
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id;    
    
    
-- Q3. Identify the highest-priced pizza.

SELECT 
    p.pizza_type_id, size, name, price
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY price DESC
LIMIT 1;



-- Q4. Identify the most common pizza size ordered.

SELECT 
    p.size, SUM(od.quantity) AS total_quantity
FROM
    pizzas p
        JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;




-- Q5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity) AS quantity
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY quantity DESC
LIMIT 5;



-- Q6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pt.category, SUM(od.quantity) AS total_quantity
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.category
ORDER BY total_quantity DESC;



-- Q7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS order_count
FROM
    orders
GROUP BY hours;


-- Q8. Join relevant tables to find the category-wise distribution of pizzas.


SELECT 
    pt.category, COUNT(p.pizza_id) AS no_of_pizzas
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.category;


-- Q9. Group the orders by date and calculate the average number of pizzas ordered per day.


SELECT 
    ROUND(AVG(orders)) AS average_order
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS orders
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;
    
    
-- Q10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    pt.name, SUM(od.quantity * p.price) AS rev
FROM
    order_details od
        JOIN
    pizzas p ON od.pizza_id = p.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY pt.name
ORDER BY rev DESC
LIMIT 3;



-- Q11. Calculate the percentage contribution of each pizza type to total revenue.

select category, round((rev/sum(rev) over())*100) as revenue_percentage
from
(select pt.category, sum(p.price * od.quantity) as rev
from pizzas p join order_details od
on p.pizza_id = od.pizza_id
join pizza_types pt on pt.pizza_type_id = p.pizza_type_id
group by pt.category) as a;



SELECT 
    pt.category,
    ROUND((SUM(od.quantity * p.price) / (SELECT 
                    ROUND(SUM(od.quantity * p.price)) AS total_sales
                FROM
                    order_details od
                        JOIN
                    pizzas p ON p.pizza_id = od.pizza_id)) * 100) AS revenue
FROM
    pizza_types pt
        JOIN
    pizzas p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
;


-- Q12. Analyze the cumulative revenue generated over time.

select order_date, sum(revenue) over(order by order_date) as cumu_rev
from 
(select o.order_date, round(sum(od.quantity * p.price)) as revenue
from order_details od join pizzas p
on od.pizza_id = p.pizza_id join orders o 
on o.order_id = od.order_id
group by o.order_date) as a;

-- Q13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.



select category, name, revenue 
from 
(select category , name , revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pt.category, pt.name, sum(od.quantity * p.price) as revenue
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join order_details od
on od.pizza_id = p.pizza_id
group by pt.category, pt.name) as a) as b
where rn <=3;

