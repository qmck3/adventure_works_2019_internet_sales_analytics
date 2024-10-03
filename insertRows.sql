--INSERT DATA

-- Connect to the source database
USE AdventureWorksDW2019;

-- Connect to the destination database
USE AdventureWorks2019_DDS;

--CHECK FOR PRIMARY KEY EXIST BEFORE INSERTING ROW
--DIMENSION DATE TABLE
MERGE AdventureWorks2019_DDS.dbo.DimDate AS dest
USING (
    SELECT [DateKey]
      ,[FullDateAlternateKey] AS [Date]
      ,[DayNumberOfWeek] AS [WeekDayNumber]
      ,[EnglishDayNameOfWeek] AS [WeekDay]
      ,[EnglishMonthName] AS [MonthName]
      ,[CalendarQuarter] AS [Quarter]
  FROM [AdventureWorksDW2019].[dbo].[DimDate]
) AS src
ON dest.DateKey = src.DateKey
WHEN NOT MATCHED BY target THEN
    INSERT ([DateKey], [Date], [WeekDayNumber], [WeekDay], [MonthName], [Quarter])
    VALUES (src.[DateKey], src.[Date], src.[WeekDayNumber], src.[WeekDay], src.[MonthName], src.[Quarter]);


--DIM PRODUCT CATEGORY
MERGE AdventureWorks2019_DDS.dbo.DimProductCategory AS dest
USING (
  SELECT [ProductCategoryKey]
      ,[EnglishProductCategoryName] AS CategoryName
  FROM [AdventureWorksDW2019].[dbo].[DimProductCategory]
) AS src
ON dest.[ProductCategoryKey] = src.[ProductCategoryKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([ProductCategoryKey], CategoryName)
    VALUES (src.[ProductCategoryKey], src.CategoryName);

-- DIM PRODUCT SUBCATEGORY
MERGE AdventureWorks2019_DDS.dbo.DimProductSubcategory AS dest
USING (
  SELECT [ProductSubcategoryKey]
      ,[EnglishProductSubcategoryName] AS SubcategoryName
      ,[ProductCategoryKey]
  FROM [AdventureWorksDW2019].[dbo].[DimProductSubcategory]
) AS src
ON dest.[ProductSubcategoryKey] = src.[ProductSubcategoryKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([ProductSubcategoryKey], SubcategoryName, [ProductCategoryKey])
    VALUES (src.[ProductSubcategoryKey], src.SubcategoryName, src.[ProductCategoryKey]);

--DIM PRODUCT
MERGE AdventureWorks2019_DDS.dbo.DimProduct AS dest
USING (
  SELECT DISTINCT p.[ProductKey]
      ,p.[ProductSubcategoryKey]
      ,[EnglishProductName] AS ProductName
      ,[StandardCost]
      ,[ListPrice]
      ,[DealerPrice]
      ,[ModelName]
      ,[StartDate]
      ,CASE WHEN [Status] IS NULL THEN 'Outdated'
			ELSE Status
			END AS Status
  FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
  JOIN AdventureWorksDW2019.dbo.FactInternetSales s
  ON p.ProductKey = s.ProductKey
) AS src
ON dest.[ProductKey] = src.[ProductKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([ProductKey], [ProductSubcategoryKey], ProductName, [StandardCost], 
			[ListPrice], [DealerPrice], [ModelName], [StartDate], [EndDate], [Status])
    VALUES (src.[ProductKey], src.[ProductSubcategoryKey], src.ProductName, src.[StandardCost], 
			src.[ListPrice], src.[DealerPrice], src.[ModelName], src.[StartDate], src.Status);

--DIM CURRENCY
MERGE AdventureWorks2019_DDS.dbo.DimCurrency AS dest
USING (
  SELECT DISTINCT c.CurrencyKey, 
				  CurrencyAlternateKey AS Abbreviation,
				  CurrencyName,
		 CASE WHEN CurrencyAlternateKey = 'DEM' THEN 0.56
			  WHEN CurrencyAlternateKey = 'AUD' THEN 0.68
			  WHEN CurrencyAlternateKey = 'GBP' THEN 1.32
			  WHEN CurrencyAlternateKey = 'CAD' THEN 0.73
			  WHEN CurrencyAlternateKey = 'FRF' THEN 0.16
			  WHEN CurrencyAlternateKey = 'USD' THEN 1
			  END AS ToUSD
  FROM AdventureWorksDW2019.dbo.DimCurrency c
  RIGHT JOIN AdventureWorksDW2019.dbo.FactInternetSales s
  ON c.CurrencyKey = s.CurrencyKey
) AS src
ON dest.CurrencyKey = src.CurrencyKey
WHEN NOT MATCHED BY target THEN
    INSERT (CurrencyKey, Abbreviation, CurrencyName, ToUSD)
    VALUES (src.CurrencyKey, src.Abbreviation, src.CurrencyName, src.ToUSD);

--INSERT DIM SALES TERRITORY
MERGE AdventureWorks2019_DDS.dbo.DimSalesTerritory AS dest
USING (
  SELECT [SalesTerritoryKey]
      ,[SalesTerritoryRegion] AS Region
      ,[SalesTerritoryCountry] AS Country
      ,[SalesTerritoryGroup] AS [Group]
  FROM [AdventureWorksDW2019].[dbo].[DimSalesTerritory]
  WHERE SalesTerritoryRegion !=	 'NA'
) AS src
ON dest.[SalesTerritoryKey] = src.[SalesTerritoryKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([SalesTerritoryKey], Region, Country, [Group])
    VALUES (src.[SalesTerritoryKey], src.Region, src.Country, src.[Group]);

-- INSERT DIM GEOGRAPHY
MERGE AdventureWorks2019_DDS.dbo.DimGeography AS dest
USING (
  SELECT [GeographyKey]
      ,[City]
      ,[StateProvinceName]
      ,[CountryRegionCode]
      ,[EnglishCountryRegionName] AS CountryRegionName
      ,[SalesTerritoryKey]
  FROM [AdventureWorksDW2019].[dbo].[DimGeography]
) AS src
ON dest.[SalesTerritoryKey] = src.[SalesTerritoryKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([GeographyKey], [City], [StateProvinceName], [CountryRegionCode], 
			CountryRegionName, [SalesTerritoryKey])
    VALUES (src.[GeographyKey], src.[City], src.[StateProvinceName], src.[CountryRegionCode], 
			src.CountryRegionName, src.[SalesTerritoryKey]);

-- INSERT DIM CUSTOMER
MERGE AdventureWorks2019_DDS.dbo.DimCustomer AS dest
USING (
  SELECT [CustomerKey]
      ,[GeographyKey]
      ,[BirthDate]
      ,CASE WHEN MaritalStatus = 'M' THEN 'Married'
			WHEN MaritalStatus = 'S' THEN 'Single'
			END AS [MaritalStatus]
      ,CASE WHEN [Gender] = 'M' THEN 'Male'
			WHEN Gender = 'F' THEN 'Female'
			END AS [Gender]
      ,[YearlyIncome]
      ,CASE WHEN [TotalChildren] > 0 THEN 'Yes' 
			WHEN TotalChildren = 0 THEN 'No'
			END AS [IsParent]
      ,[EnglishEducation] AS [EducationLevel]
      ,[EnglishOccupation] AS [Job]
      ,CASE WHEN [HouseOwnerFlag] = 0 THEN 'No'
			WHEN HouseOwnerFlag = 1 THEN 'Yes'
			END AS [IsHouseOwner]
      ,CASE WHEN NumberCarsOwned = 0 THEN 'No'
			WHEN NumberCarsOwned > 0 THEN 'Yes'
			END AS [IsCarOwner]
      ,[DateFirstPurchase]
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer]
) AS src
ON dest.[CustomerKey] = src.[CustomerKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([CustomerKey], [GeographyKey], [BirthDate], [MaritalStatus], [Gender], [YearlyIncome], 
			[IsParent], [EducationLevel], [Job], [IsHouseOwner], [IsCarOwner], [DateFirstPurchase] )
    VALUES (src.[CustomerKey], src.[GeographyKey], src.[BirthDate], src.[MaritalStatus], 
			src.[Gender], src.[YearlyIncome], src.[IsParent], src.[EducationLevel], src.[Job], 
			src.[IsHouseOwner], src.[IsCarOwner], src.[DateFirstPurchase]);

--INSERT FACT INTERNET SALES
MERGE AdventureWorks2019_DDS.dbo.FactInternetSales AS dest
USING (
  	SELECT [ProductKey]
      ,[OrderDateKey]
      ,[CustomerKey]
      ,[CurrencyKey]
      ,[SalesTerritoryKey]
      ,[SalesOrderNumber]
      ,[SalesOrderLineNumber]
      ,[TotalProductCost] AS [TotalCost]
      ,[SalesAmount] AS [TotalSales]
	  , (SalesAmount - TotalProductCost)  AS [Profit]
	  , (SalesAmount - TotalProductCost)/SalesAmount AS [ProfitMargin]
  FROM [AdventureWorksDW2019].[dbo].[FactInternetSales] 

) AS src
ON dest.[CustomerKey] = src.[CustomerKey]
WHEN NOT MATCHED BY target THEN
    INSERT ([SalesOrderNumber], [SalesOrderLineNumber], [ProductKey], [OrderDateKey], 
			[CustomerKey], [CurrencyKey], [SalesTerritoryKey], [TotalCost], 
			[TotalSales], [Profit], [ProfitMargin])
    VALUES (src.[SalesOrderNumber], src.[SalesOrderLineNumber], src.[ProductKey], src.[OrderDateKey], 
			src.[CustomerKey], src.[CurrencyKey], src.[SalesTerritoryKey], src.[TotalCost], 
			src.[TotalSales], src.[Profit], src.[ProfitMargin]);

--update 
select * from AdventureWorks2019_DDS.dbo.FactInternetSales





