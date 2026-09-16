-- 76. Find customers who never placed an order.

SELECT erp_customers.customer_id , order_id
FROM erp_customers LEFT JOIN erp_orders ON
     erp_customers.customer_id =  erp_orders.customer_id
WHERE order_id IS NULL
ORDER BY erp_customers.customer_id ASC;

-- 77. Find customers with at least 10 orders.

WITH customer_order AS (SELECT customer_id , COUNT(order_id) AS no_of_orders
FROM erp_orders
GROUP BY customer_id)

SELECT customer_id,no_of_orders
FROM customer_order
WHERE no_of_orders >= 10
ORDER BY no_of_orders ASC;

--78. Calculate each customer's first order date.


SELECT customer_id,MIN(order_date) AS first_order_of_customer
FROM erp_orders
GROUP BY customer_id
ORDER BY customer_id;

--79. Calculate each customer's latest order date.

SELECT customer_id , MAX(order_date) AS latest_order
FROM erp_orders
GROUP BY customer_id
ORDER BY customer_id ;

--80. Calculate days since latest order using 2026-07-31.

SELECT customer_id , MAX(order_date) AS last_order_date , DATE'2026-07-31'-MAX(order_date) AS day_from_last_order
FROM erp_orders
GROUP BY customer_id
ORDER BY day_from_last_order DESC;

--81. Find customers inactive for more than 180 days.


WITH order_history AS (SELECT customer_id,MAX(order_date) AS last_order_date , DATE'2026-07-31'-MAX(order_date) AS day_from_last_order
FROM erp_orders
GROUP BY customer_id
ORDER BY day_from_last_order)

SELECT customer_id,last_order_date,day_from_last_order
FROM order_history
WHERE day_from_last_order > 180
ORDER BY day_from_last_order DESC;

--82. Calculate revenue per customer.


SELECT customer_id , SUM(invoice_total) AS customer_revenue 
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY customer_id
ORDER BY customer_revenue DESC;


--83. Calculate average order value per customer.

SELECT customer_id , ROUND(AVG(invoice_total),2) AS avg_customer_order
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY customer_id 
ORDER BY avg_customer_order DESC;


--84. Rank customers by revenue within each region.


WITH customer_data AS (SELECT region , finance_invoices.customer_id , SUM(invoice_total) AS customer_revenue  
FROM finance_invoices LEFT JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY region , finance_invoices.customer_id
ORDER BY region , customer_revenue DESC)

SELECT region, customer_id,customer_revenue,
       RANK() OVER ( PARTITION BY region ORDER BY customer_revenue DESC) AS revenue_rank
FROM customer_data
ORDER BY region,customer_revenue DESC;

--85. Find top 5 customers in every region.

WITH customer_data AS (SELECT region , finance_invoices.customer_id , SUM(invoice_total) AS customer_revenue  
FROM finance_invoices LEFT JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY region , finance_invoices.customer_id),

ranking AS (SELECT region, customer_id,customer_revenue,
       RANK() OVER ( PARTITION BY region ORDER BY customer_revenue DESC ) AS revenue_rank
FROM customer_data)

SELECT *
FROM ranking
WHERE revenue_rank <= 5
ORDER BY region , revenue_rank;

--86. Calculate each customer's percentage contribution to total revenue.


WITH customer_data AS (SELECT customer_id, SUM(invoice_total) AS customer_revenue 
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY customer_id)

SELECT customer_id , customer_revenue , SUM(customer_revenue) OVER () AS total , 
      (customer_revenue/(SUM(customer_revenue) OVER ()))*100 as per
FROM customer_data
ORDER BY customer_revenue DESC;


--87. Find customers responsible for the top 80% of revenue.

WITH customer_data AS (SELECT customer_id , SUM(invoice_total) AS customer_revenue 
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY customer_id),

per AS (SELECT customer_id , customer_revenue , SUM(customer_revenue) OVER() AS total , 
       (customer_revenue/(SUM(customer_revenue) OVER()))*100 AS percentage
FROM customer_data),

cumil AS (SELECT customer_id , customer_revenue , total , percentage,
       SUM(percentage) OVER (
       ORDER BY customer_revenue DESC
	   ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
	   ) AS cumilitive
FROM per),

final_tal AS (SELECT *,
       LAG(cumilitive,1,0) OVER ( ORDER BY customer_revenue DESC) AS lag_cumil
FROM cumil)

SELECT *
FROM final_tal
WHERE lag_cumil < 80
ORDER BY customer_revenue DESC;

-- 88. Compare Large + Enterprise revenue with all other customers.

WITH customer_comp AS (SELECT customer_size , SUM(invoice_total) AS customer_sizewise_revenue
FROM finance_invoices LEFT JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY customer_size)

SELECT CASE WHEN customer_size IN ('Large','Enterprise') THEN 'Large + Enterprise'
             ELSE 'all other customers'
			 END AS grouping_col, SUM(customer_sizewise_revenue) AS group_revenue
FROM customer_comp
GROUP BY grouping_col
ORDER BY grouping_col DESC;

--89. Calculate repeat-customer rate by year.

SELECT *
FROM finance_invoices;

WITH order_by_year AS (SELECT EXTRACT(YEAR FROM invoice_date) AS invoice_year , customer_id, COUNT(order_id) AS no_of_order
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_year,customer_id),

cal AS (SELECT invoice_year ,COUNT(no_of_order) AS total_unique_cust , 
      SUM(CASE WHEN no_of_order > 1 THEN 1 ELSE 0 END) AS repeat_cust
FROM order_by_year
GROUP BY invoice_year)

SELECT invoice_year,total_unique_cust,repeat_cust , ROUND((repeat_cust::NUMERIC/total_unique_cust)*100,2) AS repeat_per
FROM cal
ORDER BY repeat_per DESC;

--90. Find customers whose 2026 revenue declined versus 2025.


WITH data AS (SELECT customer_id , EXTRACT(YEAR FROM invoice_date) AS invoice_year , SUM(invoice_total) AS cust_year_revenue
FROM finance_invoices
WHERE invoice_status = 'Posted' AND EXTRACT(YEAR FROM invoice_date) IN (2025,2026)
GROUP BY customer_id,invoice_year
ORDER BY customer_id,invoice_year DESC),

year_sort AS (SELECT customer_id , SUM(CASE WHEN invoice_year = 2025 THEN cust_year_revenue ElSE 0 END) AS revenue_2025,
                     SUM(CASE WHEN invoice_year = 2026 THEN cust_year_revenue ElSE 0 END) AS revenue_2026
FROM data 
GROUP BY customer_id)

SELECT customer_id , revenue_2025 , revenue_2026 , 
       CASE WHEN revenue_2025 > revenue_2026 THEN '2026 revenue is declinig'
	        WHEN revenue_2025 < revenue_2026 THEN '2026 revenue is increasing'
			ELSE '2025 and 2026 revenue is same' END
			AS compa_year_revenue
FROM year_sort
WHERE CASE WHEN revenue_2025 > revenue_2026 THEN '2026 revenue is declinig'
	        WHEN revenue_2025 < revenue_2026 THEN '2026 revenue is increasing'
			ELSE '2025 and 2026 revenue is same' END = '2026 revenue is declinig'
ORDER BY customer_id;

CREATE TABLE erp_returns(
return_id VARCHAR(20) PRIMARY KEY,
invoice_id VARCHAR(20),
order_id VARCHAR(20),
order_item_id VARCHAR(20),
product_id VARCHAR(20),
customer_id VARCHAR(20),
return_date DATE,
return_qty INTEGER,
return_reason VARCHAR(50)
)

SELECT *
FROM erp_returns;