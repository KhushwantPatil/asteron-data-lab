--Built an Empty table for erp_customers.

CREATE TABLE erp_customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    customer_name VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    region VARCHAR(50),
    industry VARCHAR(100),
    customer_size VARCHAR(50),
    segment VARCHAR(20),
    credit_days INTEGER,
    sales_rep_id VARCHAR(20),
    created_date DATE,
    credit_limit_lakh NUMERIC
);


-- 1. Show all rows and columns from erp_customers.

SELECT *
From erp_customers ;

--2. Show only customer_id, customer_name, city, state, and region.

SELECT customer_id,customer_name, city, state, region
from erp_customers ;

--3. Return the first 20 customers.

SELECT *
FROM erp_customers
LIMIT 20;

--4. List all unique regions.

SELECT DISTINCT region
FROM erp_customers ;

--5. List all unique industries.

SELECT DISTINCT industry
FROM erp_customers ;

--6. Find all customers located in Pune.

SELECT *
FROM erp_customers
WHERE city = 'Pune' ;

--7. Find all customers in Maharashtra.

SELECT *
FROM erp_customers
WHERE state = 'Maharashtra' ;

--8. Find all customers in either Pune or Mumbai.

SELECT *
FROM erp_customers 
WHERE city = 'Pune' or city = 'Mumbai' ;

--9. Find all customers not in Maharashtra.

SELECT * 
FROM erp_customers
WHERE state <> 'Maharashtra' ;

--10. Find customers whose customer_size is Large or Enterprise.

SELECT customer_name,customer_size
FROM erp_customers
WHERE customer_size = 'Large' OR customer_size = 'Enterprise' ; 

-- 11. Find customers whose credit_days are greater than 45.

SELECT customer_name,credit_days 
FROM erp_customers
WHERE credit_days > 45;

--12. Find customers with credit_days between 30 and 60.

SELECT customer_name,credit_days 
FROM erp_customers
WHERE credit_days BETWEEN 30 AND 60 ;

-- 13. Find customers whose name starts with A.

SELECT *
FROM erp_customers
WHERE customer_name LIKE 'A%' ;

--14. Find customers whose name contains Engineering.

SELECT *
FROM erp_customers
WHERE customer_name LIKE '%Engineering%' ;

-- 15. Find customers created after 2025-01-01.

SELECT *
FROM erp_customers
WHERE created_date > '2025-01-01'
ORDER BY created_date ASC ;

-- 16. Sort customers by credit_limit_lakh descending.

SELECT customer_name , credit_limit_lakh
FROM erp_customers
ORDER BY credit_limit_lakh DESC ;

-- 17. Return the 25 customers with the highest credit limits.

SELECT customer_name , credit_limit_lakh
FROM erp_customers
ORDER BY credit_limit_lakh DESC
LIMIT 25;

-- 18. Show products where list_price is greater than 500.

CREATE TABLE erp_products (
product_id VARCHAR(20) PRIMARY KEY,
product_name VARCHAR(255),
category VARCHAR(20),
material VARCHAR(20),
diameter_mm INTEGER,
length_mm INTEGER,
primary_supplier_id VARCHAR(20),
standard_cost NUMERIC,
list_price NUMERIC,
uom VARCHAR(20)
);

ALTER TABLE erp_products
ALTER COLUMN category TYPE VARCHAR(50);

SELECT *
FROM erp_products;

--Solution 

SELECT product_id , product_name , list_price 
FROM erp_products
WHERE list_price > 500 ;

SELECT product_id , product_name , list_price 
FROM erp_products
ORDER BY list_price DESC ;


--  Result: 0 products found.
-- Validation: Highest list_price in the dataset is 101.58.

-- 19. Show products where material is SS304 or SS316.

SELECT * 
FROM erp_products
WHERE material IN ('SS304','SS316') 
ORDER BY material DESC;

-- 20. Find Hex Bolts and sort by list_price descending.

SELECT *
FROM erp_products
WHERE product_name LIKE 'Hex Bolts%'
ORDER BY list_price DESC ;

SELECT *
FROM erp_products
WHERE category = 'Hex Bolts'
ORDER BY list_price DESC ;
