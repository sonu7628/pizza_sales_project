
Create Database Pizza_project;

Use Pizza_project;
--Basic:
--Retrieve the total number of orders placed.
--Calculate the total revenue generated from pizza sales.
--Identify the highest-priced pizza.
--Identify the most common pizza size ordered.
--List the top 5 most ordered pizza types along with their quantities.

select * from orders;

select order_id,count(order_id) as total_number_of_orders 
from orders
group by order_id
having count(order_id)>1;

select count(order_id) as total_number_of_orders from orders;
--Answer 1
select count(distinct order_id) as total_number_of_orders from orders;

--Answer 2.
--Calculate the total revenue generated from pizza sales.

--Use to list all tables in the database**********
SELECT * FROM INFORMATION_SCHEMA.TABLES;

select * from pizzas;

select * from pizza_types;
select * from orders;

select * from order_details;

select * from INFORMATION_SCHEMA.TABLES;

--******** To change the datatype of a column
ALTER TABLE pizzas
ALTER COLUMN price float;

select cast(sum(pizzas.price*order_details.quantity)as decimal(10,2)) as Total_revenue
from pizzas
inner join 
order_details on pizzas.pizza_id = order_details.pizza_id
;



--Identify the highest-priced pizza.

select * from pizzas
order by price desc;

select * from(
select *,
row_number() over(order by price desc) as row_num
from pizzas) as a
where row_num = 1;

select * from pizza_types
where pizza_type_id like 'the_greek' ;

--Alternate
select top 1 pizza_types.name as 'Pizza Name', cast(pizzas.price as decimal(10,2)) as 'Price'
from pizzas 
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by price desc;

--Identify the most common pizza size ordered.

select * from order_details;

select * from pizzas;

select top 1 pizzas.size, count(distinct order_details.order_id) as 'No of orders', sum(quantity) as 'Total Quantity ordered'
 from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
group by pizzas.size
order by count(distinct order_id) desc;

--List the top 5 most ordered pizza types along with their quantities.

select * from INFORMATION_SCHEMA.TABLES;

select * from pizza_types;

select * from order_details;


select top 5 pizza_types.name as 'Pizzas', sum(quantity) as 'Total_orders'
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by sum(quantity) desc;

/*Intermediate:
Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).
Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).
Find the category-wise distribution of pizzas (to understand customer behaviour).
Group the orders by date and calculate the average number of pizzas ordered per day.
Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)
*/

select * from order_details;

--Find the total quantity of each pizza category ordered (this will help us to understand the category which customers prefer the most).

select * from INFORMATION_SCHEMA.TABLES;

select top 5 pizza_types.name as 'Pizza', sum(order_details.quantity) as 'Quantity'
from pizzas
join order_details on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by sum(order_details.quantity) desc
;

--Determine the distribution of orders by hour of the day (at which time the orders are maximum (for inventory management and resource allocation).

select * from INFORMATION_SCHEMA.TABLES;

--************ to find the datatypes of the column
SELECT *, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders';

select * from order_details;
select * from orders;

SELECT DATEPART(hour, time) AS hour_only,count(distinct order_id) as 'No of Orders'
FROM orders
group by DATEPART(hour,time)
order by hour_only desc
;

--Find the category-wise distribution of pizzas (to understand customer behaviour).

select category, count(distinct pizza_type_id) as [No of pizzas]
from pizza_types
group by category
order by [No of pizzas]
;

--Group the orders by date and calculate the average number of pizzas ordered per day.

with cte as
(
select orders.date as 'Date', SUM(order_details.quantity) as 'T_P_O_T_D'
from orders 
join order_details on orders.order_id = order_details.order_id
Group by orders.date
--order by orders.date asc
)
select AVG([T_P_O_T_D]) as [avg_pizza] from cte

--Alternate 

select Avg(Total_Pizza_Today) as 'Avg_Total_Pizza'
from
(
select orders.date, Sum(order_details.quantity) as 'Total_Pizza_Today'
from orders
join 
order_details on orders.order_id=order_details.order_id
Group by orders.date
--order by orders.date asc
) as pizza_ordered
;
--Determine the top 3 most ordered pizza types based on revenue (let's see the revenue wise pizza orders to understand from sales perspective which pizza is the best selling)

select top 3 pizza_types.name,  Sum(pizzas.price*order_details.quantity) as 'Total_Selling'
from pizzas
join order_details on pizzas.pizza_id= order_details.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
Group by pizza_types.name
order by Total_Selling desc

/*Advanced:
Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)
Analyze the cumulative revenue generated over time.
Determine the top 3 most ordered pizza types based on revenue for each pizza category (In each category which pizza is the most selling)*/

--Calculate the percentage contribution of each pizza type to total revenue (to understand % of contribution of each pizza in the total revenue)

select * from INFORMATION_SCHEMA.TABLES;

	Select pizza_types.category,
CONCAT(cast((sum(order_details.quantity*pizzas.price)/
(select Sum(order_details.quantity*pizzas.price)
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
))*100 as decimal(10,2)),'%')
as 'Revenue Contribution from Pizza'
from order_details
join pizzas on pizzas.pizza_id=order_details.pizza_id
join pizza_types on pizzas.pizza_type_id=pizza_types.pizza_type_id
group by pizza_types.category;

--Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)

with cte as (
select date as 'Date', cast(sum(quantity*price) as decimal(10,2)) as 'Revenue'
from order_details
join orders on order_details.order_id=orders.order_id
join pizzas on pizzas.pizza_id=order_details.pizza_id
group by date
)
Select Date, Revenue, sum(Revenue) over (order by date) as 'Cumulative Sum'
from cte
group by date, Revenue;

-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
-- order by category, name, Revenue desc
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue