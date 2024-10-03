--convert money to usd (run once)
--UPDATE  s
--SET s.TotalCost = ROUND((s.TotalCost * c.ToUSD), 2),
--	s.TotalSales = ROUND((s.TotalSales * c.ToUSD), 2),
--	s.Profit = ROUND((s.Profit * c.ToUSD), 2)
--FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
--JOIN AdventureWorks2019_DDS.dbo.DimCurrency c
--ON s.CurrencyKey = c.CurrencyKey;
-- 

-- EXPLORATORY DATA ANALYSIS
-- total internet sales, total profit, total cost
SELECT ROUND(SUM(TotalSales), 2) AS Total_sales, 
		SUM(Profit) AS Total_profit,
		ROUND(SUM(TotalCost), 2) AS Total_cost
FROM AdventureWorks2019_DDS.dbo.FactInternetSales;

--average sales of an order
WITH sub AS(
	SELECT SUM(s.TotalSales) AS mean_sales 
	FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	GROUP BY s.SalesOrderNumber
)
SELECT AVG(mean_sales) AS avg_order_sales
FROM sub;

--total sales by sales territory
SELECT t.[Group], SUM(s.TotalSales) AS total_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
JOIN AdventureWorks2019_DDS.dbo.DimSalesTerritory t
ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.[Group]
ORDER BY total_sales DESC;

--sales performance by product category
SELECT c.CategoryName, ROUND(SUM(s.TotalSales), 2) AS total_sales, 
		ROUND(SUM(s.Profit), 2) AS total_profit,
		ROUND(AVG(s.ProfitMargin), 2) AS mean_profit_margin
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
JOIN AdventureWorks2019_DDS.dbo.DimProduct p
ON s.ProductKey = p.ProductKey
JOIN AdventureWorks2019_DDS.dbo.DimProductSubcategory sc
ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN AdventureWorks2019_DDS.dbo.DimProductCategory c
ON sc.ProductCategoryKey = c.ProductCategoryKey
GROUP BY c.CategoryName
ORDER BY total_sales DESC, total_profit DESC;

--sales performance by product subcategory
SELECT c.CategoryName, sc.SubcategoryName, ROUND(SUM(s.TotalSales), 2) AS total_sales, 
		ROUND(SUM(profit), 2) AS total_profit, 
		ROUND(AVG(s.profitMargin), 2) AS mean_profit_margin
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
JOIN AdventureWorks2019_DDS.dbo.DimProduct p
ON s.ProductKey = p.ProductKey
JOIN AdventureWorks2019_DDS.dbo.DimProductSubcategory sc
ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN AdventureWorks2019_DDS.dbo.DimProductCategory c
ON sc.ProductCategoryKey = c.ProductCategoryKey
GROUP BY c.CategoryName, sc.SubcategoryName
ORDER BY c.CategoryName, total_sales DESC;

--sales by quarter, year
SELECT DATEPART(YEAR, d.[Date]) AS [year], DATEPART(QUARTER, d.[Date]) AS [quarter], 
		SUM(s.TotalSales) AS total_sales, 
		SUM(SUM(s.TotalSales)) OVER(PARTITION BY DATEPART(YEAR, d.[Date])) AS year_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN AdventureWorks2019_DDS.dbo.DimDate d
	ON s.OrderDateKey = d.DateKey
GROUP BY DATEPART(YEAR, d.[Date]), DATEPART(QUARTER, d.[Date])
ORDER BY [year] , [quarter];

--sales by product category through quarters
WITH sub AS (
	SELECT p.ProductKey, c.CategoryName
	FROM AdventureWorks2019_DDS.dbo.DimProduct p
		JOIN AdventureWorks2019_DDS.dbo.DimProductSubcategory sc
		ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
		JOIN AdventureWorks2019_DDS.dbo.DimProductCategory c
		ON c.ProductCategoryKey = sc.ProductCategoryKey
)
SELECT DATEPART(YEAR, d.[Date]) AS [year], DATEPART(QUARTER, d.[Date]) AS [quarter], 
		SUM(CASE WHEN sub.CategoryName = 'Bikes' 
				THEN s.TotalSales ELSE 0 END) AS Bikes_Sales,
		SUM(CASE WHEN sub.CategoryName = 'Accessories' 
				THEN s.TotalSales ELSE 0 END) AS Accessories_Sales,
		SUM(CASE WHEN sub.CategoryName = 'Clothing' 
				THEN s.TotalSales ELSE 0 END) AS Clothing_Sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN AdventureWorks2019_DDS.dbo.DimDate d
	ON s.OrderDateKey = d.DateKey
	JOIN sub
	ON s.ProductKey = sub.ProductKey
GROUP BY DATEPART(YEAR, d.[Date]), DATEPART(QUARTER, d.[Date])
ORDER BY [year] , [quarter];

-- sales by weekdays
SELECT d.[WeekDay], 
		SUM(s.TotalSales) AS total_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
JOIN AdventureWorks2019_DDS.dbo.DimDate d ON s.OrderDateKey = d.DateKey
GROUP BY d.[WeekDay], d.WeekDayNumber
ORDER BY d.WeekDayNumber;

-- sales by months
SELECT d.[MonthName], SUM(s.TotalSales) AS total_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN AdventureWorks2019_DDS.dbo.DimDate d
	ON s.OrderDateKey = d.DateKey
GROUP BY d.[MonthName], DATEPART(MONTH, d.[Date])
ORDER BY DATEPART(MONTH, d.[Date]);

-- sales by territory group & country
SELECT t.[Group], t.Country, ROUND(SUM(s.TotalSales),2) AS sales,
		SUM(ROUND(SUM(s.TotalSales), 2)) OVER(PARTITION BY t.[Group]) AS group_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN AdventureWorks2019_DDS.dbo.DimSalesTerritory t
	ON s.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.[Group], t.Country

--count territories
SELECT [Group], Country, COUNT(*) number_of_territories
FROM AdventureWorks2019_DDS.dbo.DimSalesTerritory
GROUP BY [Group], Country

--count customer geography
SELECT g.CountryRegionName, COUNT(*) AS number_of_customers
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.DimGeography g
	ON c.GeographyKey = g.GeographyKey
GROUP BY g.CountryRegionName;

--sales by customer gender
SELECT c.Gender, COUNT(*) AS number_of_customers, SUM(s.TotalSales) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.Gender;

--sales by customer marital status
SELECT c.MaritalStatus, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.MaritalStatus;

--sales on if customer a parent status
SELECT c.IsParent, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.IsParent;

--sales on if customer owns a car
SELECT c.IsCarOwner, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.IsCarOwner;

--sales on if customer owns a house
SELECT c.IsHouseOwner, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.IsHouseOwner;

--sales by customer's educational level
SELECT c.EducationLevel, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.EducationLevel;

--sales by customer's job
SELECT c.Job, COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.Job;

--customers age: 
SELECT MAX('2014'- DATEPART(YEAR, BirthDate)) - MIN('2014'- DATEPART(YEAR, BirthDate)) AS age
FROM AdventureWorks2019_DDS.dbo.DimCustomer
ORDER BY age;
---->all customers are from 28 years old to 98

--sales by customer's age 
WITH age_group_sub AS(
	SELECT CustomerKey, 
			CASE WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 28 AND 38 THEN '28-38'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 38 AND 48 THEN '38-48'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 48 AND 58 THEN '48-58'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 58 AND 68 THEN '58-68'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 68 AND 78 THEN '68-78'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 78 AND 88 THEN '78-88'
				 WHEN '2014'- DATEPART(YEAR, BirthDate) BETWEEN 88 AND 98 THEN '88-98'
			END AS age_group
	FROM AdventureWorks2019_DDS.dbo.DimCustomer
)
SELECT sub.age_group, 
		COUNT(*) AS number_of_customers, 
		ROUND(SUM(s.TotalSales), 2) AS total_sales
FROM AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN age_group_sub sub
	ON s.CustomerKey = sub.CustomerKey
GROUP BY sub.age_group
ORDER BY sub.age_group;

--yearly income
select DISTINCT c.YearlyIncome
from AdventureWorks2019_DDS.dbo.DimCustomer c
ORDER BY c.YearlyIncome

--sales by customer's yearly income
SELECT c.YearlyIncome, COUNT(s.CustomerKey) AS customer_count, 
		ROUND(AVG(s.TotalSales), 2) AS mean_sales,
		ROUND(SUM(s.TotalSales), 2) AS total_sales
		--RANK() OVER(ORDER BY s.TotalSales) as 
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY c.YearlyIncome
ORDER BY c.YearlyIncome;

--sales by customer's first date purchase
SELECT DATEDIFF(QUARTER, c.DateFirstPurchase, '2014-02-01') AS quarters_joined, --2014-01-28 is last purchase
		ROUND(AVG(s.TotalSales), 2) AS mean_sales,
		ROUND(SUM(s.TotalSales), 2) AS total_sales
		--RANK() OVER(ORDER BY s.TotalSales) as 
FROM AdventureWorks2019_DDS.dbo.DimCustomer c
	JOIN AdventureWorks2019_DDS.dbo.FactInternetSales s
	ON c.CustomerKey = s.CustomerKey
GROUP BY DATEDIFF(QUARTER, c.DateFirstPurchase, '2014-02-01')
ORDER BY quarters_joined;

--
select TOP(1) d.Date from AdventureWorks2019_DDS.dbo.FactInternetSales s
	JOIN AdventureWorks2019_DDS.dbo.DimDate d
	ON s.OrderDateKey = d.DateKey
ORDER BY d.Date DESC;

SELECT * 
FROM AdventureWorksDW2019.DBO.DimDate