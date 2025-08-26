-- Data cleaning & Explorarion Queries -- 
-- 1. CHECKING FOR MISSING VALUES IN CRITICAL COLUMNS


SELECT
  COUNTIF(Order_ID IS NULL) AS null_order_id,
  COUNTIF(Customer_ID IS NULL) AS null_customer_id,
  COUNTIF(Order_Date IS NULL) AS null_order_date,
  COUNTIF(Sales IS NULL) AS null_sales
FROM `my-superstore-project-470112.superstore_db.orders`;


-- 2. Check the date range of the dataset
SELECT
  MIN(Order_Date) AS earliest_date,
  MAX(Order_Date) AS latest_date
FROM `my-superstore-project-470112.superstore_db.orders`;

-- 3. Check for duplicate rows 
SELECT COUNT(*) AS duplicate_rows
FROM (
  SELECT DISTINCT *
  FROM `my-superstore-project-470112.superstore_db.orders`
);

-------- 
-- 1. Which product category is the most profitable ?
SELECT
  Category,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM `my-superstore-project-470112.superstore_db.orders`
GROUP BY Category
ORDER BY Total_Profit DESC;

--2. What are the total sales and profit by year ? 
SELECT
  EXTRACT(YEAR FROM Order_Date) AS Year,
  ROUND(SUM(Sales), 2) AS Total_Sales,
  ROUND(SUM(Profit), 2) AS Total_Profit
FROM `my-superstore-project-470112.superstore_db.orders`
GROUP BY Year
ORDER BY Year;

-- 3. Who are our best customers?
WITH rfm_calc AS (
  SELECT
    Customer_ID,
    Customer_Name,
    -- Recency
    DATE_DIFF(CAST('2020-12-31' AS DATE), MAX(Order_Date), DAY) AS Recency,
    -- Frequency
    COUNT(DISTINCT Order_ID) AS Frequency,
    -- Monetary
    ROUND(SUM(Sales), 2) AS Monetary
  FROM `my-superstore-project-470112.superstore_db.orders`
  GROUP BY Customer_ID, Customer_Name
)

SELECT
  *,
  
  CASE
    WHEN Recency < 90 AND Frequency > 10 AND Monetary > 5000 THEN 'Champions'
    WHEN Monetary > 3000 THEN 'Loyal'
    WHEN Frequency > 5 THEN 'Potential Loyalists'
    WHEN Recency > 365 THEN 'Lost Customers'
    ELSE 'Regulars'
  END AS Customer_Segment
FROM rfm_calc
ORDER BY Monetary DESC
LIMIT 20;