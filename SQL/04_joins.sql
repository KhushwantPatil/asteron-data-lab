--61. Join orders with customers to show order_id, order_date, customer_name, city, region.



SELECT erp_orders.order_id, order_date , customer_name , city, region
FROM erp_orders LEFT JOIN
     erp_customers ON 
	 erp_orders.customer_id = erp_customers.customer_id;

--62. Join order_items with products to show product_name and category.

SELECT order_item_id , order_id,erp_order_items.product_id,product_name , category
FROM erp_order_items LEFT JOIN
     erp_products ON 
	 erp_order_items.product_id = erp_products.product_id;

--63. Join orders, order_items, and products.

SELECT *
FROM erp_order_items  LEFT JOIN erp_products ON
	 erp_order_items.product_id = erp_products.product_id
	 LEFT JOIN erp_orders ON
	 erp_order_items.order_id = erp_orders.order_id;
	 

-- 64. Calculate total order value per order.

WITH aggregation AS (SELECT order_id,quantity,unit_price,
       (quantity*unit_price) AS order_value
FROM erp_order_items)

SELECT order_id,
       SUM(order_value) AS order_com_value
FROM aggregation
GROUP BY order_id
ORDER BY order_id ASC;
;


-- 65. Calculate total order value per customer.


SELECT customer_id , SUM(quantity*unit_price) AS order_value
FROM erp_order_items JOIN erp_orders ON
     erp_order_items.order_id = erp_orders.order_id
GROUP BY customer_id
ORDER BY order_value DESC;    


-- 66. Find top 20 customers by order value.


SELECT erp_orders.customer_id,erp_customers.customer_name ,SUM(quantity*unit_price) AS order_value
FROM erp_order_items JOIN erp_orders ON
     erp_order_items.order_id = erp_orders.order_id
	 JOIN erp_customers ON
	 erp_orders.customer_id = erp_customers.customer_id
GROUP BY erp_orders.customer_id,erp_customers.customer_name
ORDER BY order_value DESC
LIMIT 20;

--67. Calculate invoiced revenue by region.


SELECT region , SUM(invoice_total) AS region_wise_invoice_total
FROM finance_invoices JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY region
ORDER BY region_wise_invoice_total DESC;

-- 68. Calculate invoiced revenue by state.

SELECT erp_customers.state , SUM(invoice_total) AS state_wise_total_invoice_value
FROM finance_invoices JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY erp_customers.state
ORDER BY state_wise_total_invoice_value DESC;

-- 69. Calculate invoiced revenue by city.


SELECT city , SUM(invoice_total) AS city_wise_invoice_total
FROM finance_invoices JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY city
ORDER BY city_wise_invoice_total DESC;

--70. Calculate invoiced revenue by industry.

SELECT industry , SUM(invoice_total) AS invoice_revenue_per_industry
FROM finance_invoices JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY industry
ORDER BY invoice_revenue_per_industry DESC;

-- 71. Calculate invoiced revenue by customer_size.

SELECT customer_size , SUM(invoice_total) AS customer_size_wise_invoice_total
FROM finance_invoices JOIN erp_customers ON
     finance_invoices.customer_id = erp_customers.customer_id
WHERE invoice_status = 'Posted'
GROUP BY customer_size
ORDER BY customer_size_wise_invoice_total DESC;


--72. Calculate invoiced revenue by salesperson.

SELECT erp_orders.sales_rep_id, SUM(invoice_total) AS invoice_total_for_salesman
FROM finance_invoices JOIN erp_orders ON
     finance_invoices.order_id = erp_orders.order_id
     WHERE invoice_status = 'Posted'
GROUP BY erp_orders.sales_rep_id
ORDER BY invoice_total_for_salesman DESC;

--73. Calculate gross profit by product category.


SELECT category , SUM(quantity*(unit_price-unit_cost_at_order)) AS Gross_Profit
FROM erp_order_items JOIN finance_invoices ON
     erp_order_items.order_id = finance_invoices.order_id
	 JOIN erp_products ON
	 erp_order_items.product_id = erp_products.product_id
WHERE invoice_status = 'Posted'
GROUP BY category 
ORDER BY Gross_Profit DESC;


-- 74. Calculate gross margin percentage by product category.

WITH calculation AS (SELECT category , SUM(quantity*unit_price) AS revenue , SUM(quantity*(unit_price-unit_cost_at_order)) AS profit
FROM erp_order_items JOIN finance_invoices ON
     erp_order_items.order_id = finance_invoices.order_id
	 JOIN erp_products ON
	 erp_order_items.product_id = erp_products.product_id
WHERE invoice_status = 'Posted'
GROUP BY category
ORDER BY revenue)

SELECT category,revenue,profit , ROUND(((profit/revenue)*100),2) AS gross_margin_percentage
FROM calculation
ORDER BY gross_margin_percentage DESC;

--75. Find the 20 products generating highest gross profit.

SELECT erp_products.product_id,product_name ,  SUM(quantity*(unit_price-unit_cost_at_order)) AS profit
FROM erp_order_items JOIN finance_invoices ON
     erp_order_items.order_id = finance_invoices.order_id
	 JOIN erp_products ON
	 erp_order_items.product_id = erp_products.product_id
WHERE invoice_status = 'Posted'
GROUP BY erp_products.product_id, product_name
ORDER BY profit DESC
LIMIT 20 ;




