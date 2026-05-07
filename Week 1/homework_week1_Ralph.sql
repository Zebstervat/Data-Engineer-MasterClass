
               --12 Thursday Questions



--Q1. List all orders with status shipped ordered by purchase date descending

select * 
from olist_orders_dataset ood 
where order_status = 'delivered'
order by order_purchase_timestamp DESC 


--Q2. Find all customers from the state of RJ

Select ocd.customer_id 
from olist_customers_dataset ocd 
where ocd.customer_state = 'RJ'


--Q3. Show the top 10 most expensive products with their order IDs

Select top 10 
order_id,
price
from olist_order_items_dataset ooid 
ORDER BY  price desc

--Q4. Find all customers from cities containing the word rio

Select * 
from olist_customers_dataset ocd 
where ocd.customer_city LIKE '%rio%'

--Q5. Count the total number of orders per customer state, ordered by count descending

select ocd.customer_state,
	COUNT(*) AS total_orders 
	from olist_orders_dataset ood 
JOIN olist_customers_dataset ocd on ood.customer_id = ocd.customer_id
GROUP BY ocd.customer_state 
order BY total_orders desc


--Q6.  Find the average, min and max price of items per order. Show only orders with more than 3 items

SELECT 
order_id, 
AVG(price) as average_price,
MIN(price) as min_price,
MAX(price) as max_price
from olist_order_items_dataset
where order_item_id > 3
group by order_id 


--Q7. Show total revenue per payment type

SELECT oopd.payment_type, SUM(oopd.payment_value ) 
from olist_order_payments_dataset oopd 
GROUP  by oopd.payment_type 


--Q8. Join orders and customers. Show order ID, status, customer city and state for SP customers only

SELECT ood.order_id, 
ood.order_status, 
ocd.customer_city, 
ocd.customer_state 
from olist_orders_dataset ood 
JOIN olist_customers_dataset ocd ON ood.customer_id = ocd.customer_id 
where ocd.customer_state ='SP'


--Q9. Join order items and products. Show product category name and price for items over 300 reais

SELECT opd.product_category_name, 
ooid.price  
FROM olist_order_items_dataset ooid 
JOIN olist_products_dataset opd  ON ooid.product_id = opd.product_id 
where ooid.price > 300

--Q10. Which sellers have sold more than 100 items? Show seller ID and item count

select * 
from 
(select ooid.seller_id, 
COUNT(*) as item_count  
from olist_order_items_dataset ooid 
GROUP BY ooid.seller_id) a
where a.item_count > 100

--Q11. Show the top 5 product categories by total revenue for delivered orders only

SELECT top 5 opd.product_category_name, 
SUM(ooid.price) as total_revenue  
from olist_order_items_dataset ooid 
JOIN olist_products_dataset opd on ooid.product_id = opd.product_id 
JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id
where ood.order_status = 'delivered'
group BY opd.product_category_name 
ORDER BY total_revenue desc


--Q12. Using a LEFT JOIN, find all orders that have no payment record

select * 
from olist_order_items_dataset ooid 
left join olist_order_payments_dataset oopd on ooid.order_id = oopd.order_id
where oopd.payment_value is null







     --12 Wednesday Questions

--Q1. Show all orders along with the customer city and state. Only show orders that have a status of delivered.

SELECT ood.order_id, 
ocd.customer_city, 
ocd.customer_state,
ood.order_status 
from olist_orders_dataset ood 
JOIN olist_customers_dataset ocd on ood.customer_id = ocd.customer_id 
where ood.order_status = 'delivered'


--Q2. Find all order items with their product category name. Only show items priced above 300 reais, ordered by price descending.

select ooid.order_id,
opd.product_category_name,ooid.price  
from olist_order_items_dataset ooid 
JOIN olist_products_dataset opd on ooid.product_id = opd.product_id 
where ooid.price > 300
ORDER BY ooid.price DESC 


--Q3. Which orders have no review at all? Show the order ID and order status.

SELECT ood.order_id,
ood.order_status 
from olist_orders_dataset ood 
LEFT JOIN olist_order_reviews_dataset oord on ood.order_id = oord.order_id 
where oord.review_id is null


--Q4. Find all customers who placed an order in 2017. Use a subquery. Show their city and state.

          --I am not sure why a subquary would be necessary here?

SELECT ood.customer_id, 
ocd.customer_city,
ocd.customer_state 
from olist_orders_dataset ood
JOIN olist_customers_dataset ocd on ood.customer_id = ocd.customer_id 
WHERE ood.order_purchase_timestamp LIKE '%2017%'


--Q5. Who sold the single most expensive item on the platform? Use a subquery to find them.     
 
SELECT top 1 a.seller_id 
from 
(select top 1 * from olist_order_items_dataset ooid 
ORDER by price desc) a


--Q6. Label every order as High Value, Medium Value, or Low Value based on payment amount. High is over 500 reais, Medium is 100 to 500, Low is under 100. 

select ooid.order_id,
case 
	when ooid.price > 500 then 'High'
	when ooid.price >= 100 then 'Medium'
	else 'Low'
end as ranked_order
from olist_order_items_dataset ooid 


--Q7. For each state show how many orders were delivered, canceled, and shipped as separate columns.

SELECT ocd.customer_state,
    SUM(case when ood.order_status = 'delivered' then 1 else 00 END ) AS delivered,
    SUM(case when ood.order_status = 'canceled' then 1 else 00 END ) AS canceled,
    SUM(case when ood.order_status = 'shipped' then 1 else 00 END ) AS shipped
   from olist_orders_dataset ood 
   JOIN olist_customers_dataset ocd on ood.customer_id = ocd.customer_id 
  GROUP BY ocd.customer_state 
  
 
  --Q8. Rank all sellers by total revenue using RANK. Show seller ID, total revenue, and their rank. Top 20 only.

 SELECT top 20
   ooid.seller_id,
   SUM(ooid.price) as total_price,
   RANK() OVER (order by SUM(ooid.price) DESC ) as sellers_ranked   
   from olist_order_items_dataset ooid
   GROUP BY ooid.seller_id 
   
   
   --Q9. Show monthly revenue for 2017 and 2018. Add a column showing the change from the previous month using LAG.
   
SELECT ood.order_purchase_timestamp,
    ooid.price,
    lag(ooid.price) OVER (order by ood.order_purchase_timestamp) as prev_revenue    
    from olist_orders_dataset ood
    join olist_order_items_dataset ooid on ood.order_id = ooid.order_id 
    WHERE YEAR(ood.order_purchase_timestamp) = 2017 or YEAR(ood.order_purchase_timestamp) = 2018
    ORDER BY YEAR(ood.order_purchase_timestamp) ASC , MONTH(ood.order_purchase_timestamp) ASC


    --Q10. Within each product category rank sellers by total items sold using ROW_NUMBER with PARTITION BY. Show only the number one ranked seller in each category.

  WITH rankedSellers AS (
    	SELECT  
    		opd.product_category_name,
    		ooid.seller_id,
    		ooid.product_id,
    		row_number() over (
    			partition by opd.product_category_name
    			order by ooid.product_id desc
    		) as seller_rank
    	from olist_order_items_dataset ooid    
    	JOIN olist_products_dataset opd on ooid.product_id = opd.product_id
    	 --GROUP by opd.product_category_name, ooid.seller_id
    )
    SELECT 
    	product_category_name,
    	seller_id,
    	product_id
	FROM rankedSellers
	WHERE seller_rank = 1
	
	--Q11. Write a CTE that calculates total revenue and total orders per state. In the main query calculate revenue per order for each state and only show states where revenue per order is above 150 reais. Order by revenue per order descending.











































                        --Additional Interview Questions - Solve them when you get a chance - Very Important to Practice



--Q7. Find the running total of revenue by state and show each state's percentage contribution to the overall total.

Select a.customer_state,a.total_revenue, 
(a.total_revenue  * 100.0) / SUM(a.total_revenue) OVER () as percent_contribution 
from (SELECT 
ocd.customer_state as customer_state, 
SUM(ooid.price ) as total_revenue 
--(ooid.price * 100.0) / SUM(ooid.price) OVER () as percent_contribution 
from olist_orders_dataset ood 
JOIN olist_customers_dataset ocd on ood.customer_id = ocd.customer_id  
JOIN olist_order_items_dataset ooid on ood.order_id = ooid.order_id 
GROUP BY ocd.customer_state) a 


--Q8. For each seller find their best month — the month where they made the most revenue.

select seller_id, a.[year], a.[month], MAX(a.total_sales) AS best_month 
FROM (SELECT
    ooid.seller_id,
    YEAR(ood.order_purchase_timestamp) as year,
    MONTH(ood.order_purchase_timestamp) as month,
    SUM(ooid.price) as total_sales
    from olist_orders_dataset ood
    join olist_order_items_dataset ooid on ood.order_id = ooid.order_id 
    GROUP BY ooid.seller_id, YEAR(ood.order_purchase_timestamp), MONTH(ood.order_purchase_timestamp)) a
    GROUP BY seller_id, a.[year], a.[month]
    ORDER BY a.[year], a.[month] DESC 
    
    
--Q9. Divide all customers into 4 equal spending quartiles and show how many customers are in each quartile.


WITH CustomerQuartiles as (
     SELECT 
         ocd.customer_id,
         price,
         NTILE(4) OVER  (ORDER BY price DESC ) AS spending_quartile
         FROM olist_customers_dataset ocd 
         JOIN olist_orders_dataset ood on ocd.customer_id = ood.customer_id 
         join olist_order_items_dataset ooid on ood.order_id = ooid.order_id 
)


SELECT 
     spending_quartile,
     COUNT(customer_id) as customer_count
     FROM CustomerQuartiles
     GROUP BY spending_quartile
     order BY spending_quartile


--Q10. 











































