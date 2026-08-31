-- 41. Calculate monthly order count.

SELECT
    order_date,
    DATE_TRUNC('month', order_date)::DATE
FROM erp_orders
LIMIT 10;

SELECT DATE_TRUNC('month',order_date)::DATE AS order_month , COUNT(*) AS no_of_orders
FROM erp_orders
GROUP BY order_month
ORDER BY order_month DESC; 

--42. Calculate monthly invoice count.

CREATE TABLE finance_invoices(
invoice_id VARCHAR(20) PRIMARY KEY,
order_id VARCHAR(20),
customer_id VARCHAR(20),
invoice_date DATE,
subtotal NUMERIC,
tax_amount NUMERIC,
invoice_total NUMERIC,
invoice_status VARCHAR(20)
);

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month, COUNT(*) as monthly_invoice
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;

-- 43. Calculate monthly invoice subtotal.

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month, SUM(subtotal) as monthly_subtotal
FROM finance_invoices
where invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;

-- 44. Calculate monthly invoice_total.

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month , SUM(invoice_total) AS sum_of_invoice_total
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;

--45. Compare subtotal versus invoice_total by month.


SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month ,
     SUM(subtotal) AS monthly_subtotal ,
	 SUM(invoice_total) AS monthly_invoice_total
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;


-- 46. Calculate annual invoice subtotal.

SELECT DATE_TRUNC('year',invoice_date)::DATE AS annual_invoices ,
       SUM(subtotal) AS annual_subtotal
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY annual_invoices
ORDER BY annual_invoices ASC;

SELECT EXTRACT(YEAR from invoice_date) AS invoice_year ,
       SUM(subtotal) AS annual_subtotal
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_year
ORDER BY invoice_year ASC;

-- 47. Calculate year-over-year revenue growth.

CREATE TABLE finance_payments (
payment_id VARCHAR(20) PRIMARY KEY,
invoice_id VARCHAR(20),
customer_id VARCHAR(20),
payment_date DATE,
amount_paid NUMERIC,
payment_method VARCHAR(50)
);


WITH yearly AS (
    SELECT EXTRACT(YEAR FROM invoice_date) AS invoice_year,
           SUM(invoice_total) AS total_yearly_revenue
    FROM finance_invoices
    WHERE invoice_status = 'Posted'
    GROUP BY invoice_year
),

yearly_with_previous AS (
    SELECT invoice_year,
           total_yearly_revenue,
           LAG(total_yearly_revenue) OVER (ORDER BY invoice_year)
               AS previous_year_revenue
    FROM yearly
)

SELECT invoice_year,
       total_yearly_revenue,
       previous_year_revenue,
       ROUND(
           ((total_yearly_revenue - previous_year_revenue)
           / previous_year_revenue) * 100,
           2
       ) AS yoy_revenue_growth_pct
FROM yearly_with_previous
ORDER BY invoice_year;

-- 48. Find the month with highest invoiced revenue.

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month, SUM(invoice_total) AS monthly_invoice 
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY monthly_invoice DESC
LIMIT 1;

--49. Find the month with lowest revenue after 2022.

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month , SUM(invoice_total) AS monthly_invoice
FROM finance_invoices
WHERE invoice_status = 'Posted' AND DATE_TRUNC('month',invoice_date)::DATE > '2022-12-01'
GROUP BY invoice_month
ORDER BY monthly_invoice ASC
LIMIT 1;

-- 50. Calculate monthly average invoice value.


SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month, ROUND(AVG(invoice_total),2) AS avg_monthly_invoice
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;


-- 51. Calculate quarterly revenue.

SELECT DATE_TRUNC('quarter',invoice_date)::DATE AS invoice_quarter, ROUND(SUM(invoice_total),2) AS quarterly_invoice
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_quarter
ORDER BY invoice_quarter ASC;

-- 52. Calculate revenue by year and quarter.


SELECT EXTRACT(YEAR FROM invoice_date) AS invoice_year,
       EXTRACT(QUARTER FROM invoice_date) AS invoice_quarter,
	   SUM(invoice_total) AS quarterly_revenue
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_year , invoice_quarter
ORDER BY invoice_year ASC, invoice_quarter ASC;

--53. Compare each month of 2025 with the same month of 2024. 

WITH Comparison AS ( SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
                           SUM(invoice_total) AS monthly_revenue,
	                       LAG(SUM(invoice_total),12) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE) AS monthly_revenue_24 
                    FROM finance_invoices
                    WHERE invoice_status = 'Posted' AND  invoice_date BETWEEN '2024-01-01' AND '2025-12-31' 
                    GROUP BY invoice_month
                    ORDER BY invoice_month ASC )

SELECT invoice_month, monthly_revenue , monthly_revenue_24 , (monthly_revenue-monthly_revenue_24) AS monthly_comparison
FROM Comparison
WHERE invoice_month >= '2025-01-01';

-- 54. Calculate a 3-month rolling average of monthly revenue.

WITH Month_revenue AS (SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
       SUM(invoice_total) AS monthly_revenue,
	   LAG(SUM(invoice_total),1) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE) AS previous_month_revenue,
	   LAG(SUM(invoice_total),2) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE) AS last_to_last_month_revenue
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC)

SELECT invoice_month, monthly_revenue ,previous_month_revenue, last_to_last_month_revenue,
       ROUND(((monthly_revenue+previous_month_revenue+last_to_last_month_revenue)/3),2) AS running_avg_3_months
FROM Month_revenue
WHERE last_to_last_month_revenue is NOT NULL ;

-- Solution no 2

SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
       SUM(invoice_total) AS monthly_revenue,
	   ROUND(AVG(SUM(invoice_total)) OVER 
	   (ORDER BY DATE_TRUNC('month',invoice_date)::DATE 
	   ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_3_month_avg
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC;

-- 55. Calculate cumulative revenue over time.
SELECT *
FROM finance_invoices;


SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
       SUM(invoice_total) AS monthly_invoice,
	   ROUND(SUM(SUM(invoice_total)) OVER 
	   ( ORDER BY DATE_TRUNC('month',invoice_date)::DATE ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),2) AS cumulative_revenue
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month;

-- 56. Find months where revenue fell more than 10% from previous month.


WITH revenue_details AS (SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
       SUM(invoice_total) AS monthly_revenue,
	   LAG(SUM(invoice_total)) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE) AS previous_month_revenue,
	   ROUND(((SUM(invoice_total)-LAG(SUM(invoice_total)) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE))/LAG(SUM(invoice_total)) OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE))*100,2) AS revenue_per
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC)

SELECT invoice_month, monthly_revenue , previous_month_revenue , revenue_per
FROM revenue_details
WHERE revenue_per < -10
ORDER BY revenue_per ASC;

-- 57. Find every month that set a new all-time revenue high.

WITH month_max AS (SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
       SUM(invoice_total) AS monthly_revenue,
	   MAX(SUM(invoice_total)) 
	   OVER (ORDER BY DATE_TRUNC('month',invoice_date)::DATE 
	   ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS last_max 
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC)

SELECT invoice_month , monthly_revenue , last_max , 
       CASE
        WHEN last_max IS NULL THEN 'New High'
        WHEN monthly_revenue > last_max THEN 'New High'
        ELSE 'No'
    END AS new_all_time_high
FROM month_max
WHERE CASE
        WHEN last_max IS NULL THEN 'New High'
        WHEN monthly_revenue > last_max THEN 'New High'
        ELSE 'No'
    END = 'New High' ;

--58. Compare monthly order count with monthly invoice count.

WITH order_data AS (SELECT DATE_TRUNC('month',order_date)::DATE AS order_month,
       COUNT(order_id) AS monthly_order
FROM erp_orders
GROUP BY order_month
ORDER BY order_month ASC),

invoice_data AS (SELECT DATE_TRUNC('month',invoice_date)::DATE AS invoice_month,
        COUNT(invoice_id) AS monthly_invoices
FROM finance_invoices
WHERE invoice_status = 'Posted'
GROUP BY invoice_month
ORDER BY invoice_month ASC)

SELECT invoice_month, monthly_order , monthly_invoices ,
       CASE 
	       WHEN monthly_order > monthly_invoices THEN 'more orders'
		   WHEN monthly_order < monthly_invoices THEN 'more invoices'
		   ELSE 'order and invoices are same'
		   END AS Comparison
FROM order_data
JOIN invoice_data
    ON order_data.order_month = invoice_data.invoice_month;

-- 59. Find months where order volume rose but revenue fell.

WITH order_table AS (
    SELECT
        DATE_TRUNC('month', order_date)::DATE AS order_month,
        COUNT(order_id) AS monthly_orders,
        LAG(COUNT(order_id)) OVER (
            ORDER BY DATE_TRUNC('month', order_date)::DATE
        ) AS pre_month_orders
    FROM erp_orders
    GROUP BY order_month
),

invoice_table AS (
    SELECT
        DATE_TRUNC('month', invoice_date)::DATE AS invoice_month,
        SUM(invoice_total) AS monthly_revenue,
        LAG(SUM(invoice_total)) OVER (
            ORDER BY DATE_TRUNC('month', invoice_date)::DATE
        ) AS pre_month_revenue
    FROM finance_invoices
    WHERE invoice_status = 'Posted'
    GROUP BY invoice_month
)

SELECT
    order_month,
    monthly_orders,
    pre_month_orders,
    monthly_revenue,
    pre_month_revenue
FROM order_table
JOIN invoice_table
    ON invoice_table.invoice_month = order_table.order_month
WHERE monthly_orders > pre_month_orders
  AND monthly_revenue < pre_month_revenue
ORDER BY order_month;

--60. Calculate monthly gross margin percentage.


WITH joined_column AS (SELECT order_item_id,invoice_date,erp_order_items.order_id,product_id,quantity,unit_price,unit_cost_at_order,invoice_status,
       (quantity)*(unit_price-unit_cost_at_order) AS profit,
	    (quantity*unit_price) AS revenue
FROM erp_order_items
     LEFT JOIN finance_invoices ON 
	 erp_order_items.order_id = finance_invoices.order_id)

SELECT DATE_TRUNC('month',invoice_date)::DATE AS revenue_month,
       SUM(profit) AS monthly_profit,
	   SUM(revenue) AS monthly_revenue,
	   ROUND(((SUM(profit)/SUM(revenue))*100),2) AS Gros_Margin_per
FROM joined_column
WHERE invoice_status = 'Posted'
GROUP BY revenue_month
ORDER BY revenue_month ASC;



