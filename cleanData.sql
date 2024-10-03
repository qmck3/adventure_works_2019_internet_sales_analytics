--CREATE SUBQUERY TO INSERT DATA
  ----------------------------------------------------------------------------------
  --DIMENSION DATE TABLE
  SELECT [DateKey]
      ,[FullDateAlternateKey] AS Date
      ,[DayNumberOfWeek] AS Week_day_number
      ,[EnglishDayNameOfWeek] AS Week_day
      --,[SpanishDayNameOfWeek]
      --,[FrenchDayNameOfWeek]
      --,[DayNumberOfMonth]
      --,[DayNumberOfYear]
      --,[WeekNumberOfYear]
      ,[EnglishMonthName] AS Month_name
      --,[SpanishMonthName]
      --,[FrenchMonthName]
      --,[MonthNumberOfYear]
      ,[CalendarQuarter] AS Quarter
      --,[CalendarYear] 
      --,[CalendarSemester]
      --,[FiscalQuarter]
      --,[FiscalYear]
      --,[FiscalSemester]
  FROM [AdventureWorksDW2019].[dbo].[DimDate]

  ----------------------------------------------------------------------------------
  --DIMENSION CUSTOMER TABLE
  SELECT [CustomerKey]
      ,[GeographyKey]
      --,[CustomerAlternateKey]
      --,[Title] -> same as gender
      --,[FirstName]
      --,[MiddleName]
      --,[LastName]
      --,[NameStyle] all = 0
      ,[BirthDate]
      ,CASE WHEN MaritalStatus = 'M' THEN 'Married'
			WHEN MaritalStatus = 'S' THEN 'Single'
			END AS MaritalStatus
      --,[Suffix]
      ,CASE WHEN [Gender] = 'M' THEN 'Male'
			WHEN Gender = 'F' THEN 'Female'
			END AS Gender
      --,[EmailAddress]
      ,[YearlyIncome]
      ,CASE WHEN [TotalChildren] > 0 THEN 'Yes' 
			WHEN TotalChildren = 0 THEN 'No'
			END AS Is_parent
      --,[NumberChildrenAtHome]
      ,[EnglishEducation] AS Education_level
      --,[SpanishEducation]
      --,[FrenchEducation]
      ,[EnglishOccupation] AS Job
      --,[SpanishOccupation]
      --,[FrenchOccupation]
      ,CASE WHEN [HouseOwnerFlag] = 0 THEN 'No'
			WHEN HouseOwnerFlag = 1 THEN 'Yes'
			END AS Is_house_owner
      ,CASE WHEN NumberCarsOwned = 0 THEN 'No'
			WHEN NumberCarsOwned > 0 THEN 'Yes'
			END AS Is_car_owner
      --,[AddressLine1]
      --,[AddressLine2]
      --,[Phone]
      ,[DateFirstPurchase]
      --,[CommuteDistance] -- don't know what's this for
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer];

  --check email domain
  SELECT EmailAddress
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer]
  WHERE SUBSTRING(EmailAddress, CHARINDEX('@', EmailAddress) + 1, 
					LEN(EmailAddress) - CHARINDEX('@', EmailAddress)) NOT LIKE '%adventure-works.com%';

  -- check distinct values in column
  SELECT DISTINCT EnglishOccupation
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer];

  ----------------------------------------------------------------------------------
  --DIMENSION PRODUCT CATEGORY TABLE
  SELECT [ProductCategoryKey]
      --,[ProductCategoryAlternateKey]
      ,[EnglishProductCategoryName] AS CategoryName
      --,[SpanishProductCategoryName]
      --,[FrenchProductCategoryName]
  FROM [AdventureWorksDW2019].[dbo].[DimProductCategory];

  ----------------------------------------------------------------------------------
  --DIMENSION PRODUCT SUB CATEGORY TABLE
  SELECT [ProductSubcategoryKey]
      --,[ProductSubcategoryAlternateKey]
      ,[EnglishProductSubcategoryName] AS SubcategoryName
      --,[SpanishProductSubcategoryName]
      --,[FrenchProductSubcategoryName]
      ,[ProductCategoryKey]
  FROM [AdventureWorksDW2019].[dbo].[DimProductSubcategory]

  ----------------------------------------------------------------------------------
  --DIMENSION Geography TABLE
  SELECT [GeographyKey]
      ,[City]
      --,[StateProvinceCode]
      ,[StateProvinceName]
      ,[CountryRegionCode]
      ,[EnglishCountryRegionName] AS CountryRegionName
      --,[SpanishCountryRegionName]
      --,[FrenchCountryRegionName]
      --,[PostalCode]
      ,[SalesTerritoryKey]
      --,[IpAddressLocator]
  FROM [AdventureWorksDW2019].[dbo].[DimGeography];

  ----------------------------------------------------------------------------------
  --DIMENSION SALES TERRITORY TABLE
  SELECT [SalesTerritoryKey]
      --,[SalesTerritoryAlternateKey]
      ,[SalesTerritoryRegion] AS Region
      ,[SalesTerritoryCountry] AS Country
      ,[SalesTerritoryGroup] AS [Group]
      --,[SalesTerritoryImage]
  FROM [AdventureWorksDW2019].[dbo].[DimSalesTerritory]
  WHERE SalesTerritoryRegion !=	 'NA';

  ----------------------------------------------------------------------------------
  --DIMENSION CURRENCY TABLE
  SELECT DISTINCT c.CurrencyKey, 
				  CurrencyAlternateKey AS CurrencyAbbreviation,
				  CurrencyName,
		 CASE WHEN CurrencyAlternateKey = 'DEM' THEN 0.56
			  WHEN CurrencyAlternateKey = 'AUD' THEN 0.68
			  WHEN CurrencyAlternateKey = 'GBP' THEN 1.32
			  WHEN CurrencyAlternateKey = 'CAD' THEN 0.73
			  WHEN CurrencyAlternateKey = 'FRF' THEN 0.16
			  WHEN CurrencyAlternateKey = 'USD' THEN 1
			  END AS To_USD_Rate
  FROM AdventureWorksDW2019.dbo.DimCurrency c
  RIGHT JOIN AdventureWorksDW2019.dbo.FactInternetSales s
  ON c.CurrencyKey = s.CurrencyKey;
  
  ----------------------------------------------------------------------------------
  --DIMENSION PRODUCT TABLE
  SELECT DISTINCT p.[ProductKey]
      --,[ProductAlternateKey]
      ,p.[ProductSubcategoryKey]
      --,[WeightUnitMeasureCode]
      --,[SizeUnitMeasureCode]
      ,[EnglishProductName] AS ProductName
      --,[SpanishProductName]
      --,[FrenchProductName]
      ,[StandardCost]
      --,[FinishedGoodsFlag]
      --,[Color]
      --,[SafetyStockLevel]
      --,[ReorderPoint]
      ,[ListPrice]
      --,[Size]
      --,[SizeRange]
      --,[Weight]
      --,[DaysToManufacture]
      --,[ProductLine]
      ,[DealerPrice]
      --,[Class]
      --,[Style]
      ,[ModelName]
      --,[LargePhoto]
      --,[EnglishDescription] -- -> need LLM
      --,[FrenchDescription]
      --,[ChineseDescription]
      --,[ArabicDescription]
      --,[HebrewDescription]
      --,[ThaiDescription]
      --,[GermanDescription]
      --,[JapaneseDescription]
      --,[TurkishDescription]
      ,[StartDate]
      --,[EndDate]
      ,CASE WHEN [Status] IS NULL THEN 'Outdated'
			ELSE Status
			END AS Status
  FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
  JOIN AdventureWorksDW2019.dbo.FactInternetSales s
  ON p.ProductKey = s.ProductKey;

  --check finished goods product
  SELECT COUNT(DISTINCT p.ProductKey) AS in_sales_product, 
		 (SELECT COUNT(DISTINCT p.ProductKey)
			FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
			JOIN AdventureWorksDW2019.dbo.FactInternetSales s
			ON p.ProductKey = s.ProductKey) AS finished_goods
  FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
  JOIN AdventureWorksDW2019.dbo.FactInternetSales s
  ON p.ProductKey = s.ProductKey
  WHERE FinishedGoodsFlag <> 0;

  -- check start, end date
  SELECT StartDate, EndDate
  FROM AdventureWorksDW2019.dbo.DimProduct
  WHERE StartDate < EndDate
  ----------------------------------------------------------------------------------
  --FACT INTERNET SALES TABLE
  --Get sales table 
	SELECT [ProductKey]
      ,[OrderDateKey]
      --,[DueDateKey]
      --,[ShipDateKey]
      ,[CustomerKey]
      --,[PromotionKey]
      ,[CurrencyKey]
      ,[SalesTerritoryKey]
      ,[SalesOrderNumber]
      ,[SalesOrderLineNumber]
      --,[RevisionNumber]
      --,[OrderQuantity] -> all order = 1
      --,[UnitPrice] -> quantity = 1
      --,[ExtendedAmount] -> = unitPrice since all quantity = 1
      --,[UnitPriceDiscountPct] -> all = 0
      --,[DiscountAmount] -> all = 0
      --,[ProductStandardCost] -> quantity = 1
      ,[TotalProductCost] AS Total_cost
      ,[SalesAmount] AS Total_sales
      --,[TaxAmt] AS Tax_amount
      --,[Freight]
      --,[CarrierTrackingNumber]
      --,[CustomerPONumber]
      --,[OrderDate]
      --,[DueDate]
      --,[ShipDate]
	  , (SalesAmount - TotalProductCost)  AS Profit
	  , (SalesAmount - TotalProductCost)/SalesAmount AS Profit_margin
  FROM [AdventureWorksDW2019].[dbo].[FactInternetSales] ;

  SELECT PromotionKey, DiscountAmount
  FROM AdventureWorksDW2019.dbo.FactInternetSales
  WHERE DiscountAmount <> 0;