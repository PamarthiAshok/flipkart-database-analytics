/*
Flipkart Database Project – SQL Portfolio  
Author: VENKATA ASHOK KUMAR PAMARTHI  
Date: July 2025  
Description: This file contains 15 analytical SQL queries built using PostgreSQL across five datasets:  
             customers, products, sales, shippings, and payments.  
Purpose: To explore customer behavior, product performance, logistics, and revenue insights.
*/

--1.Retrieve all products along with their total sales revenue from completed orders?
select p.product_id,p.product_name , sum(s.quantity * s.price_per_unit)as total_sales
from products p 
join 
	sales s on p.product_id=s.product_id
where 
	s.order_status='Completed'
group by p.product_id,p.product_name
order by total_sales desc;

--2.List all customers and the products they have purchased, showing only those who have ordered more than two products.
select c.customer_id,c.customer_name,p.product_name
from customers c 
join 
	sales s  on c.customer_id=s.customer_id 
join
	products p on s.product_id=p.product_id
where 
	s.order_status='Completed' 
	and c.customer_id in (select customer_id 
						  from sales 
						  where order_status='Completed' 
						  group by customer_id 
						  having count(distinct product_id)>2)
order by c.customer_id;

--3.Find the total amount spent by customers in 'Gujarat' who have ordered products priced greater than 10,000.
select c.customer_name,c.customer_id,sum(s.quantity * s.price_per_unit) as total_amount_spent_by_customers
from customers c 
join
	sales s  on c.customer_id = s.customer_id 
join 
	products p on s.product_id=p.product_id
where
	c.state='Gujarat' and p.price>10000 and s.order_status='Completed'
group by c.customer_name,c.customer_id ;

--4.Retrieve the list of all orders that have not yet been shipped?
select s.order_id,s.order_date,s.order_status,s.product_id,s.customer_id
from sales s 
left join 
	shippings sh on s.order_id=sh.order_id
where sh.order_id is null and s.order_status='Completed';

--5.Find the average order value per customer for orders with a quantity of more than 5?
select c.customer_id,c.customer_name,avg(s.quantity*s.price_per_unit) as average_order_value
from customers c 
join 
	sales s on c.customer_id=s.customer_id
where 
	s.quantity>5 and s.order_status='Completed'
group by c.customer_id,c.customer_name;

--6.Get the top 5 customers by total spending on 'Accessories'?
select c.customer_id,c.customer_name ,sum(s.quantity * s.price_per_unit) as total_spending
from customers c 
join 
	sales s on c.customer_id=s.customer_id
join 
	products p on s.product_id=p.product_id
where 
	p.category='Accessories' and s.order_status='Completed'
group by c.customer_id,c.customer_name
order by total_spending desc
limit 5;

--7.Retrieve a list of customers who have not made any payment for their orders?
select c.customer_id,c.customer_name 
from customers c 
join 
	sales s on c.customer_id=s.customer_id 
left join 
	payments p on s.order_id=p.order_id 
where 
	p.order_id is null and s.order_status='Completed'
group by c.customer_id,c.customer_name;

--8.Find the most popular product based on total quantity sold in 2023?

--model : 1
select p.product_id,p.product_name ,sum(s.quantity) as Total_Quantity
from products p 
join 
	sales s on p.product_id =s.product_id 
join 
	payments pay on s.order_id=pay.order_id
where 
	(pay.payment_date between '2023-01-01' and '2023-12-31') 
	and s.order_status='Completed'
group by p.product_name,p.product_id
order by Total_Quantity desc 
limit 1;

--model : 2
select  p.product_id, p.product_name, sum(s.quantity) AS total_quantity_sold
from products p
join
    sales s on p.product_id = s.product_id
join
    payments pay on s.order_id = pay.order_id
where
    EXTRACT(YEAR FROM pay.payment_date) = 2023
    AND s.order_status = 'Completed'
group by  
    p.product_id, p.product_name
order by  
    total_quantity_sold DESC
LIMIT 1;

--9.List all orders that were cancelled and the reason for cancellation (if available)?
select s.order_id,s.order_date,s.customer_id,s.order_status,s.quantity
from sales s
where s.order_status='Cancelled';

--10.Retrieve the total quantity of products sold by category in 2023?
select p.category,sum(s.quantity) as Total_Quantity
from products p 
join
	sales s on p.product_id=s.product_id 
join 
	payments pay on s.order_id=pay.order_id
where 
	EXTRACT(YEAR FROM pay.payment_date)=2023
group by p.category;

--11.Get the count of returned orders by shipping provider in 2023?
select count(*) as Returned_Orders,sh.shipping_providers
from sales s 
join 
	shippings sh on s.order_id=sh.order_id 
where 
	s.order_status='Returned' and Extract(year from sh.shipping_date)=2023
group by sh.shipping_providers
order by Returned_Orders desc ;

--12.Show the total revenue generated per month for the year 2023?

select to_char(sh.shipping_date,'YYYY-MM')AS Month,sum(s.quantity * s.price_per_unit) as Total_Revenue 
from sales s 
join 
	shippings sh on s.order_id=sh.order_id
where 
	EXTRACT(YEAR FROM sh.shipping_date)=2023
group by to_char(sh.shipping_date,'YYYY-MM')
order by month;


--13.Find the customers who have made the most purchases in a single month?
select c.customer_id,to_char(s.order_date,'YYYY-MM') AS Month,count(*) as Order_Count
from customers c 
join 
	sales s on c.customer_id=s.customer_id
group by to_char(s.order_date,'YYYY-MM'),c.customer_id
order by Order_Count desc 
limit 1;

--14.Retrieve the number of orders made per product category in 2023 and order by total quantity sold?
select p.category,count(*) as Number_of_Orders,
	   sum(s.quantity) as total_quantity_sold
from products p
join 
	sales s on p.product_id=s.product_id
where 
	EXTRACT(YEAR FROM s.order_date)=2023
group by p.category
order by total_quantity_sold desc;


--15.List the products that have never been ordered (use LEFT JOIN between products and sales)?

select p.product_id,p.product_name
from products p 
left join 
	sales s on p.product_id=s.product_id 
where s.product_id is null;





