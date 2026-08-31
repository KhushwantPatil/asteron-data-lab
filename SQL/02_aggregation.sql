SELECT *
FROM erp_customers;

SELECT * 
FROM erp_customers
WHERE customer_name IS Null;

-- 21. Count total customers.

SELECT Count(DISTINCT customer_name) as NoOfCusotmer
FROM erp_customers ;

-- Answer 
SELECT Count(*)
FROM erp_customers ;

-- 22. Count customers by region.

SELECT region , Count(*) as region_cust_count
FROM erp_customers
GROUP BY region 
ORDER BY region_cust_count DESC;

--23. Count customers by industry.

SELECT industry , Count(*) as industry_cust_count
FROM erp_customers
GROUP BY industry
ORDER BY industry_cust_count DESC;


--24. Count customers by customer_size.

SELECT customer_size , Count(*) AS customer_size_wise_cust_no
FROM erp_customers
GROUP BY customer_size
ORDER BY customer_size_wise_cust_no DESC;


--25. Calculate average credit_days.

SELECT ROUND(AVG(credit_days),2) as average_credit_days
FROM erp_customers;

--26. Calculate average credit_days by customer_size.


SELECT customer_size , ROUND(AVG(credit_days),2) as avg_credit_days
FROM erp_customers
GROUP BY customer_size 
ORDER BY avg_credit_days DESC;

-- 27. Find minimum, maximum, and average product list_price.

SELECT MIN(list_price) AS min_list_price , MAX(list_price) AS max_list_price , ROUND(AVG(list_price),2) AS avg_list_price
FROM erp_products;

--28. Calculate average product price by category.

SELECT category , ROUND(AVG(list_price),2) AS category_avg_list_price
FROM erp_products
GROUP BY category
ORDER BY category_avg_list_price DESC ;

-- 29. Count products by category.

SELECT category, COUNT(*) as category_count
FROM erp_products
GROUP BY category
ORDER BY category_count DESC;

--30. Count suppliers by country.
--Creating the table 
CREATE TABLE erp_suppliers (
supplier_id VARCHAR(20) PRIMARY KEY,
supplier_name VARCHAR(50),
country VARCHAR(50),
contract_lead_days INTEGER,
historical_fill_rate NUMERIC
);

SELECT country , COUNT(*) AS country_wise_total_supplier
FROM erp_suppliers
GROUP BY country
ORDER BY country_wise_total_supplier DESC;

-- 31. Count orders by order_status.


CREATE TABLE erp_orders (
order_id VARCHAR(20) PRIMARY KEY,
customer_id VARCHAR(20),
order_date DATE ,
order_status VARCHAR(20),
order_channel VARCHAR(20),
sales_rep_id VARCHAR(20),
warehouse_id VARCHAR(20),
priority VARCHAR(20),
demand_factor NUMERIC
);

SELECT order_status, Count(*) as no_of_orders
FROM erp_orders
GROUP BY order_status
ORDER BY no_of_orders DESC;

-- 32. Count orders by order_channel.

SELECT order_channel , Count(*) AS order_count
FROM erp_orders
GROUP BY order_channel
ORDER BY order_count DESC;

-- 33. Count orders by year.

SELECT EXTRACT(YEAR FROM order_date) AS year_of_order , COUNT(*) AS orders_in_year
FROM erp_orders
GROUP BY year_of_order
ORDER BY year_of_order ASC;

-- 34. Count orders by month.

SELECT EXTRACT(MONTH FROM order_date) AS month_of_order , COUNT(*) AS orders_in_month
FROM erp_orders
GROUP BY month_of_order
ORDER BY orders_in_month ASC;

-- 35. Calculate total quantity ordered.

CREATE TABLE erp_order_items (
order_item_id VARCHAR(20) PRIMARY KEY,
order_id VARCHAR(20),
product_id VARCHAR(20),
quantity INTEGER ,
unit_price NUMERIC , 
unit_cost_at_order NUMERIC ,
discount_pct NUMERIC ,
uom VARCHAR(20)
)

SELECT SUM(quantity) as total_qtt_ordered
FROM erp_order_items;

-- 36. Calculate gross sales value using quantity * unit_price.

SELECT sum(quantity*unit_price) AS gross_sales
FROM erp_order_items;

--37. Calculate gross profit per line using quantity * (unit_price - unit_cost_at_order).

SELECT (quantity*(unit_price-unit_cost_at_order)) AS gross_profit_per_line
FROM erp_order_items;

-- 38. Calculate total gross profit.

SELECT SUM(quantity * (unit_price - unit_cost_at_order)) AS total_gross_profit
FROM erp_order_items;


-- 39. Calculate average discount_pct.

SELECT ROUND(AVG(discount_pct), 4) AS average_discount_pct
FROM erp_order_items;

-- 40. Find the 10 categories with the highest average list_price.

SELECT category, ROUND(AVG(list_price),2) AS avg_list_price
FROM erp_products
GROUP BY category
ORDER BY avg_list_price DESC
Limit 10;