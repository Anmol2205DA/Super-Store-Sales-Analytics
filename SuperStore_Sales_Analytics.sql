-- ---------------SuperStore Sales Analysis-----------------
use superstore

Select top 10 * from salesdata;

-- 1. Total Sales
SELECT SUM(Sales) AS Total_Sales FROM SalesData;

-- 2. Total Profit
SELECT SUM(Profit) AS Total_Profit FROM SalesData;

-- 3. Total Quantity Sold
SELECT SUM(Quantity) AS Total_Quantity FROM SalesData;

-- 4. Average Discount Applied
SELECT AVG(Discount) AS Average_Discount FROM SalesData;

-- 5. Total Number of Orders
SELECT COUNT(DISTINCT Order_ID) AS Total_Orders FROM SalesData;


--SALES TRENDS-


-- 6. Monthly Sales Trends
SELECT FORMAT(Order_Date, 'yyyy-MM') AS Month, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY FORMAT(Order_Date, 'yyyy-MM')
ORDER BY Month;


-- 7. Yearly Sales Trends
SELECT YEAR(Order_Date) AS Year, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY YEAR(Order_Date)
ORDER BY Year;


-- 8. Weekly Sales Trends
SELECT DATEPART(WEEK, Order_Date) AS Week, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY DATEPART(WEEK, Order_Date)
ORDER BY Week;


-- 9. Day-wise Sales Analysis
SELECT DAY(Order_Date) AS Day, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY DAY(Order_Date)
ORDER BY Day;


-- 10. Seasonal Sales Patterns
SELECT 
    CASE 
        WHEN MONTH(Order_Date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(Order_Date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(Order_Date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END AS Season, 
    SUM(Sales) AS Total_Sales
FROM SalesData
GROUP BY 
    CASE 
        WHEN MONTH(Order_Date) IN (12, 1, 2) THEN 'Winter'
        WHEN MONTH(Order_Date) IN (3, 4, 5) THEN 'Spring'
        WHEN MONTH(Order_Date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Autumn'
    END;


--Customer Analysis-


-- 11. Top Customers by Sales
SELECT Customer_ID, Customer_Name, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Sales DESC;


-- 12. Top Customers by Profit
SELECT Customer_ID, Customer_Name, SUM(Profit) AS Total_Profit FROM SalesData
GROUP BY Customer_ID, Customer_Name
ORDER BY Total_Profit DESC;


-- 13. Average Sales per Customer
SELECT AVG(Customer_Sales) AS Average_Sales_Per_Customer
FROM (
    SELECT Customer_ID, SUM(Sales) AS Customer_Sales
    FROM SalesData
    GROUP BY Customer_ID
) AS CustomerData;


-- 14. Customer Retention Rate (Example: Count of Repeat Customers)
SELECT COUNT(Customer_ID) AS Repeat_Customers
FROM (
    SELECT Customer_ID, COUNT(DISTINCT Order_ID) AS Order_Count
    FROM SalesData
    GROUP BY Customer_ID
    HAVING COUNT(DISTINCT Order_ID) > 1
) AS RetainedCustomers;


-- 15. Orders per Customer Segment
SELECT Segment, COUNT(Order_ID) AS Orders_Per_Segment FROM SalesData
GROUP BY Segment;


--Product Analysis


-- 16. Best-Selling Products
SELECT Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity_Sold FROM SalesData
GROUP BY Product_ID, Product_Name
ORDER BY Total_Quantity_Sold DESC;


-- 17. Least-Selling Products
SELECT Product_ID, Product_Name, SUM(Quantity) AS Total_Quantity_Sold FROM SalesData
GROUP BY Product_ID, Product_Name
ORDER BY Total_Quantity_Sold ASC;


-- 18. Most Profitable Products
SELECT Product_ID, Product_Name, SUM(Profit) AS Total_Profit FROM SalesData
GROUP BY Product_ID, Product_Name
ORDER BY Total_Profit DESC;


-- 19. Most Discounted Products
SELECT Product_ID, Product_Name, AVG(Discount) AS Average_Discount FROM SalesData
GROUP BY Product_ID, Product_Name
ORDER BY Average_Discount DESC;


-- 20. Profit Margin per Product
SELECT Product_ID, Product_Name,  SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin_Percentage FROM SalesData
GROUP BY Product_ID, Product_Name;


--Regional Analysis-


-- 21. Sales by Region
SELECT Region, SUM(Sales) AS Total_Sales
FROM SalesData GROUP BY Region;


-- 22. Profit by Region
SELECT Region, SUM(Profit) AS Total_Profit
FROM SalesData GROUP BY Region;


-- 23. Top-Performing States
SELECT State, SUM(Sales) AS Total_Sales
FROM SalesData GROUP BY State
ORDER BY Total_Sales DESC;


-- 24. Top-Performing Cities
SELECT City, SUM(Sales) AS Total_Sales
FROM SalesData GROUP BY City
ORDER BY Total_Sales DESC;


-- 25. Sales & Profit by Country
SELECT Country, SUM(Sales) AS Total_Sales, SUM(Profit) AS Total_Profit
FROM SalesData GROUP BY Country;


--Shipping Analysis-


-- 26. Orders by Shipping Mode
SELECT Ship_Mode, COUNT(distinct(Order_ID)) AS Total_Orders
FROM SalesData GROUP BY Ship_Mode;


-- 27. Profit Margin by Shipping Mode
SELECT Ship_Mode, SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin_Percentage
FROM SalesData GROUP BY Ship_Mode;


-- 28. Average Shipping Time
SELECT AVG(DATEDIFF(DAY, Order_Date, Ship_Date)) AS Average_Shipping_Time
FROM SalesData;


-- 29. On-Time Shipping Rate
SELECT COUNT(distinct(order_id)) * 100.0 / (SELECT COUNT(distinct(order_id)) FROM SalesData) AS On_Time_Delivery_rate
FROM SalesData
WHERE Ship_Date <= DATEADD(DAY, 2, Order_Date);


-- 30. Sales by Shipping Mode
SELECT Ship_Mode, SUM(Sales) AS Total_Sales FROM SalesData
GROUP BY Ship_Mode;


--Return Analysis-


-- 31. Return Rate
SELECT COUNT(distinct(order_id)) * 100.0 / (SELECT COUNT(distinct(order_id)) FROM SalesData) AS Return_Rate
FROM SalesData
WHERE Order_Returned =1;


-- 32. Products with the Highest Return Rate which are ordered more than 3 times.
with cte as
(SELECT Product_ID, Product_Name, convert(float,count(Order_Returned)) as total_orders
FROM SalesData
GROUP BY Product_ID, Product_Name),
cte2 as
(SELECT Product_ID, Product_Name, convert(float,count(Order_Returned)) as returned_orders
FROM SalesData where Order_Returned=1
GROUP BY Product_ID, Product_Name)
select cte.product_id,cte.product_name,(returned_orders/total_orders*100) as return_rate
from cte right join cte2 on cte.product_id=cte2.product_id where total_orders>3
order by return_rate desc;



-- 33. Regions with the Highest Return Rate
with cte as
(SELECT Region, convert(float,count(Order_Returned)) as total_orders
FROM SalesData
GROUP BY Region),
cte2 as
(SELECT Region, convert(float,count(Order_Returned)) as returned_orders
FROM SalesData where Order_Returned=1
GROUP BY Region)
select cte.Region,(returned_orders/total_orders*100) as return_rate
from cte right join cte2 on cte.region=cte2.region
order by return_rate desc;


-- 34. Categories with the Highest Return Rate
with cte as
(SELECT Category, convert(float,count(Order_Returned)) as total_orders
FROM SalesData
GROUP BY Category),
cte2 as
(SELECT Category, convert(float,count(Order_Returned)) as returned_orders
FROM SalesData where Order_Returned=1
GROUP BY Category)
select cte.Category,(returned_orders/total_orders*100) as return_rate
from cte right join cte2 on cte.Category=cte2.Category
order by return_rate desc;



-- 35. Profit Loss Due to Returns
SELECT SUM(Profit) AS Total_Profit_Lost
FROM SalesData
WHERE Order_Returned =1;


--Profitability Analysis


-- 36. Average Profit Margin
SELECT AVG(Profit / Sales) * 100 AS Average_Profit_Margin_Percentage
FROM SalesData;


-- 37. Profitability by Category
SELECT Category, 
    SUM(Profit) AS Total_Profit,
    SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin_Percentage
FROM SalesData
GROUP BY Category;


-- 38. Profitability by Sub-Category
SELECT Sub_Category, 
    SUM(Profit) AS Total_Profit,
    SUM(Profit) / SUM(Sales) * 100 AS Profit_Margin_Percentage
FROM SalesData
GROUP BY Sub_Category;


-- 39. Profit Trends Over Time
SELECT YEAR(Order_Date) AS Year, 
    SUM(Profit) AS Total_Profit
FROM SalesData
GROUP BY YEAR(Order_Date)
ORDER BY Year;


-- 40. Products with Negative Profit
SELECT Product_ID, Product_Name, 
    SUM(Profit) AS Total_Profit
FROM SalesData
GROUP BY Product_ID, Product_Name
HAVING SUM(Profit) < 0;


--Discounts Analysis


-- 41. Impact of Discounts on Sales
SELECT Discount, 
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit
FROM SalesData
GROUP BY Discount
ORDER BY Discount;


-- 42. Products with the Highest Discount-to-Profit Ratio
SELECT Product_ID, Product_Name, 
    SUM(Discount) / SUM(Profit) AS Discount_To_Profit_Ratio
FROM SalesData
GROUP BY Product_ID, Product_Name
ORDER BY Discount_To_Profit_Ratio DESC;


-- 43. Regions with the Most Discounted Sales
SELECT Region, 
    SUM(Sales) AS Total_Discounted_Sales
FROM SalesData
WHERE Discount > 0
GROUP BY Region
ORDER BY Total_Discounted_Sales DESC;


-- 44. Customer Segments Availing the Most Discounts
SELECT Segment, 
    SUM(Discount) AS Total_Discount
FROM SalesData
GROUP BY Segment
ORDER BY Total_Discount DESC;


-- 45. Correlation Between Discount and Profit
SELECT Discount, 
    AVG(Profit) AS Average_Profit
FROM SalesData
GROUP BY Discount
ORDER BY Discount;

--Some More Insights-

-- 46. Identify Pairs of Products Frequently Bought Together (in the same order).

SELECT A.Product_ID AS Product1, B.Product_ID AS Product2, COUNT(*) AS Pair_Count
FROM SalesData A
JOIN SalesData B ON A.Order_ID = B.Order_ID AND A.Product_ID < B.Product_ID
GROUP BY A.Product_ID, B.Product_ID
ORDER BY Pair_Count DESC;


-- 47. Customer Lifetime Value

SELECT Customer_ID, 
    SUM(Sales) AS Lifetime_Sales,
    SUM(Profit) AS Lifetime_Profit
FROM SalesData
GROUP BY Customer_ID
ORDER BY Lifetime_Profit DESC;


-- 48. Sales Contribution by Category

SELECT Category, 
    SUM(Sales) AS Total_Sales,
    SUM(Sales) * 100.0 / (SELECT SUM(Sales) FROM SalesData) AS Sales_Contribution_Percentage
FROM SalesData
GROUP BY Category
ORDER BY Sales_Contribution_Percentage DESC;


-- 49. Comparison of Sales Across Years

SELECT YEAR(Order_Date) AS Year, 
    SUM(Sales) AS Total_Sales
FROM SalesData
GROUP BY YEAR(Order_Date)
ORDER BY Year;

--50. Average Shipping time across Regions

select region, avg(convert(float,DATEDIFF(day,Order_Date,Ship_Date),2)) as average_days_to_deliver_order
from salesdata group by region;


