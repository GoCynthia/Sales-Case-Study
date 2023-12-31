SELECT * FROM sys.superstoredata;

select Product_ID ,sum(Sales) , count(*) from superstoredata
group by Product_ID ;

#1. Find out the Total Average Revenue per Customer and the Total Average Revenue per Product for the year 2017. (return values in 2 decimal places)
select 

(select round(sum(Sales)/count(distinct Customer_ID),2)   from superstoredata where year(ship_date) = 2017) as Avg_rev_per_customer,

(select round(sum(sales)/count(distinct Product_ID), 2)  from superstoredata  where year(ship_date) = 2017) as Avg_rev_per_product

from superstoredata

limit 1;

 #2. Give a list of all products that generated revenue below the Total Average Revenue per Product (TAR/P) in 2017(Showing the least revenues first)

select product_id, product_name, round(sum(sales), 2) as Revenue from superstoredata where year (Ship_Date) = 2017
group by Product_ID , Product_Name 
having round(sum(Sales), 2) < (select round (sum(Sales)/count(distinct Product_ID), 2) from superstoredata 
where year(Ship_Date) = 2017) order by Revenue;

#2b. Find out the number of products that fall below the TAR/P under each category per region.

WITH TAR_per_product AS (
    SELECT
        Category,
        Region,
        Product_ID,
        ROUND(SUM(Sales) / COUNT(DISTINCT Product_ID), 2) AS TAR_per_product
    FROM
        superstoredata
    WHERE
        YEAR(Order_Date) = 2017
    GROUP BY
        Category, Region, Product_ID
)
SELECT
    sd.Region,
    SUM(CASE WHEN sd.Category = 'Office Supplies' AND sd.Sales < tar.TAR_per_product THEN 1 ELSE 0 END) AS Office_Supplies,
    SUM(CASE WHEN sd.Category = 'Furniture' AND sd.Sales < tar.TAR_per_product THEN 1 ELSE 0 END) AS Furniture,
    SUM(CASE WHEN sd.Category = 'Technology' AND sd.Sales < tar.TAR_per_product THEN 1 ELSE 0 END) AS Technology
FROM
    superstoredata sd
JOIN
    TAR_per_product tar ON sd.Category = tar.Category AND sd.Region = tar.Region AND sd.Product_ID = tar.Product_ID
WHERE
    YEAR(sd.Order_Date) = 2017
GROUP BY
    sd.Region;

  #3. Find out the Y-O-Y growth rate from 2014 – 2017. (Your answer should be rounded to 3 decimal places, and show the “%” sign)
   SELECT
    CONCAT(ROUND((SUM(CASE WHEN YEAR(ship_date) = 2015 THEN Sales ELSE 0 END) /
                 SUM(CASE WHEN YEAR(ship_date) = 2014 THEN Sales ELSE 0 END) - 1) * 100, 3), '%') AS YOY_2015,
    
    CONCAT(ROUND((SUM(CASE WHEN YEAR(ship_date) = 2016 THEN Sales ELSE 0 END) /
                 SUM(CASE WHEN YEAR(ship_date) = 2015 THEN Sales ELSE 0 END) - 1) * 100, 3), '%') AS YOY_2016,
    
    CONCAT(ROUND((SUM(CASE WHEN YEAR(ship_date) = 2017 THEN Sales ELSE 0 END) /
                 SUM(CASE WHEN YEAR(ship_date) = 2016 THEN Sales ELSE 0 END) - 1) * 100, 3), '%') AS YOY_2017
FROM
    superstoredata
WHERE
    YEAR(ship_date) BETWEEN 2014 AND 2017;
  
#4. Return a table that shows the Total Revenue against the Total Cost of goods sold (COGS) for each region and in each year (2014 – 2017)
   SELECT
    YEAR(ship_date) AS Year,
    SUM(CASE WHEN Region = 'East' THEN Sales ELSE 0 END) AS Rev_East,
    SUM(CASE WHEN Region = 'East' THEN Sales - Profit ELSE 0 END) AS COGS_East,
    SUM(CASE WHEN Region = 'West' THEN Sales ELSE 0 END) AS Rev_West,
    SUM(CASE WHEN Region = 'West' THEN Sales - Profit ELSE 0 END) AS COGS_West,
    SUM(CASE WHEN Region = 'South' THEN Sales ELSE 0 END) AS Rev_South,
    SUM(CASE WHEN Region = 'South' THEN Sales - Profit ELSE 0 END) AS COGS_South,
    SUM(CASE WHEN Region = 'Central' THEN Sales ELSE 0 END) AS Rev_Central,
    SUM(CASE WHEN Region = 'Central' THEN Sales - Profit ELSE 0 END) AS COGS_Central
FROM
    superstoredata
WHERE
    YEAR(ship_date) BETWEEN 2014 AND 2017
GROUP BY
    YEAR(ship_date);
   
#5.Return a table that shows the Profit generated per state, then per region in 2018 alone.
SELECT
    State,
    SUM(CASE WHEN sd.Region = 'South'  THEN profit ELSE 0 END) AS South,
    SUM(CASE WHEN sd.Region = 'East'  THEN profit ELSE 0 END) AS East,
    SUM(CASE WHEN sd.Region = 'Central' THEN profit ELSE 0 END) AS Central,
    SUM(CASE WHEN sd.Region = 'West' THEN profit ELSE 0 END) AS West
FROM
    superstoredata sd
WHERE
    YEAR(Ship_Date) = 2018
   group by State;
  
  #6.Return a table that shows the total number of orders received on each day of the week for year 2014, 2015, 2016 and 2017.
  SELECT
    Day_Of_Week,
    SUM(YEAR(Order_Date) = 2014) AS Order_2014,
    SUM(YEAR(Order_Date) = 2015) AS Order_2015,
    SUM(YEAR(Order_Date) = 2016) AS Order_2016,
    SUM(YEAR(Order_Date) = 2017) AS Order_2017
FROM
    (SELECT
        DAYNAME(Order_Date) AS Day_Of_Week,
        Order_Date
    FROM
        superstoredata
    WHERE
        YEAR(Order_Date) BETWEEN 2014 AND 2017) AS subquery
GROUP BY
    Day_Of_Week
ORDER BY
    CASE Day_Of_Week
        WHEN 'Sunday' THEN 1
        WHEN 'Monday' THEN 2
        WHEN 'Tuesday' THEN 3
        WHEN 'Wednesday' THEN 4
        WHEN 'Thursday' THEN 5
        WHEN 'Friday' THEN 6
        WHEN 'Saturday' THEN 7
    END;
   