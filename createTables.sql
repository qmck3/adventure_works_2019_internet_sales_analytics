--CREATE TABLES FOR DIMENSIONAL DATA STORE
--Remember to run each code block by sequence
-- Connect to the destination database
USE AdventureWorks2019_DDS;

-- DIMENSION DATE TABLE
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimDate') 
	BEGIN
    CREATE TABLE DimDate (
		[DateKey] int NOT NULL,
		[Date] date,
        [WeekDayNumber] int,
        [WeekDay] varchar(20),
		[MonthName] varchar(10),
		[Quarter] int,
		 PRIMARY KEY (DateKey)
    );
	END;

-- Dimension currency table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimCurrency') 
	BEGIN
    CREATE TABLE DimCurrency (
		CurrencyKey int NOT NULL PRIMARY KEY,
		Abbreviation varchar(5),
        CurrencyName varchar(50),
        ToUSD float,
    );
	END;

-- Dimension product category table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimProductCategory') 
	BEGIN
    CREATE TABLE DimProductCategory (
		ProductCategoryKey int NOT NULL PRIMARY KEY,
        CategoryName varchar(50),
    );
	END;

-- Dimension product subcategory table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimProductSubcategory') 
	BEGIN
    CREATE TABLE DimProductSubcategory (
		ProductSubcategoryKey int NOT NULL PRIMARY KEY,
		ProductCategoryKey int FOREIGN KEY REFERENCES DimProductCategory(ProductCategoryKey), 
        SubcategoryName varchar(50),
    );
	END;

-- Dimension product table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimProduct') 
	BEGIN
    CREATE TABLE DimProduct (
		ProductKey int NOT NULL PRIMARY KEY,
		ProductSubcategoryKey int FOREIGN KEY REFERENCES DimProductSubcategory(ProductSubcategoryKey), 
        ProductName varchar(50),
		StandardCost float,
		ListPrice float,
		DealerPrice float,
		ModelName varchar(50),
		StartDate date,
		Status varchar(10)
    );
	END;

-- Dimension Sales Territory
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimSalesTerritory') 
	BEGIN
    CREATE TABLE DimSalesTerritory (
		SalesTerritoryKey int NOT NULL PRIMARY KEY,
		Region varchar(50),
		Country varchar(50),
		[Group] varchar(50)
    );
	END;

-- Dimension Geography
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimGeography') 
	BEGIN
    CREATE TABLE DimGeography (
		GeographyKey int NOT NULL PRIMARY KEY,
		City varchar(50),
		StateProvinceName varchar(50),
		CountryRegionCode varchar(10),
		CountryRegionName varchar(50),
		SalesTerritoryKey int FOREIGN KEY REFERENCES DimSalesTerritory(SalesTerritoryKey)
    );
	END;

-- Dimension Customer table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'DimCustomer') 
	BEGIN
    CREATE TABLE DimCustomer (
		CustomerKey int NOT NULL PRIMARY KEY,
		BirthDate date,
		MaritalStatus varchar(10),
		Gender varchar(10),
		YearlyIncome Numeric,
		IsParent varchar(5),
		EducationLevel varchar(20),
		Job varchar(50),
		IsHouseOwner varchar(5),
		IsCarOwner varchar(5),
		DateFirstPurchase date,
		GeographyKey int FOREIGN KEY REFERENCES DimGeography(GeographyKey)
    );
	END;

-- Fact Internet Sales table
IF NOT EXISTS (SELECT * FROM information_schema.tables WHERE table_schema = 'AdventureWorks2019_DDS' 
				AND table_name = 'FactInternetSales') 
	BEGIN
    CREATE TABLE FactInternetSales (
		SalesOrderNumber char(7) NOT NULL,
		SalesOrderLineNumber int NOT NULL,
		SalesTerritoryKey int FOREIGN KEY REFERENCES DimSalesTerritory(SalesTerritoryKey),
		ProductKey int FOREIGN KEY REFERENCES DimProduct(ProductKey),
		OrderDateKey int FOREIGN KEY REFERENCES DimDate(DateKey),
		CustomerKey int FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
		CurrencyKey int FOREIGN KEY REFERENCES DimCurrency(CurrencyKey),
		TotalCost float,
		TotalSales float,
		Profit float,
		ProfitMargin float,
		CONSTRAINT PK_FactInternetSales PRIMARY KEY (SalesOrderNumber, SalesOrderLineNumber)
    );
	END;
