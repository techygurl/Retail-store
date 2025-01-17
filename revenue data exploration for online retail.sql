---cleaning the data
SELECT 
       [StockCode]
      ,[Description]
      ,[InvoiceDate]
      ,[CustomerID]
      ,[Country]
	  ,[Quantity]
	  ,[UnitPrice]
     ,([Quantity]*[UnitPrice]) AS TotalRevenue
  FROM [retail project].[dbo].[Copy of Online Retail]


SELECT TOP 50 InvoiceDate
FROM [Copy of Online Retail];

SELECT InvoiceDate
FROM [Copy of Online Retail];

SELECT *
FROM [Copy of Online Retail]
WHERE ISDATE(InvoiceDate) = 0;

SELECT *
FROM [Copy of Online Retail]
WHERE ISDATE(InvoiceDate) = 1; 

UPDATE [Copy of Online Retail]
SET InvoiceDate = NULL
WHERE ISDATE(InvoiceDate) = 0;

DELETE FROM [Copy of Online Retail]
WHERE ISDATE(InvoiceDate) = 0;
EXEC sp_columns OnlineRetail;

ALTER TABLE [dbo].[Copy of Online Retail]
ALTER COLUMN InvoiceDate DATETIME;

SELECT  InvoiceDate
FROM [Copy of Online Retail]
WHERE InvoiceDate IS NOT NULL
ORDER BY InvoiceDate DESC;
--- fix the invoice date and time column

SELECT
    CAST(InvoiceDate AS DATE) AS InvoiceDateOnly, -- Date
    CAST(InvoiceDate AS TIME) AS InvoiceTimeOnly  -- Time
FROM [Copy of Online Retail];

--SELECT
--    DATENAME(WEEKDAY, InvoiceDate) AS TransactionDay,  -- Extract day of the week
--    DATEPART(HOUR, InvoiceDate) AS TransactionHour,    -- Extract hour of the day
--    SUM(Quantity * UnitPrice) AS TotalRevenue,         -- Calculate total revenue
--    COUNT(DISTINCT InvoiceNo) AS TransactionCount      -- Count unique transactions
--FROM
--    [Copy of Online Retail]
--WHERE
--    InvoiceDate IS NOT NULL                            -- Ensure no NULL values
--GROUP BY
--    DATENAME(WEEKDAY, InvoiceDate),                   -- Group by day of the week
--    DATEPART(HOUR, InvoiceDate)                       -- Group by hour of the day
--ORDER BY
--    TransactionDay,                                   -- Sort by day
--    TransactionHour;                                  -- Sort by hour


--	SELECT
--    DATENAME(WEEKDAY, InvoiceDate) AS TransactionDay,
--    DATEPART(WEEKDAY, InvoiceDate) AS WeekdayOrder,    -- Numerical day of the week
--    DATEPART(HOUR, InvoiceDate) AS TransactionHour,
--    SUM(Quantity * UnitPrice) AS TotalRevenue,
--    COUNT(DISTINCT InvoiceNo) AS TransactionCount
--FROM
--    [Copy of Online Retail]
--WHERE
--    InvoiceDate IS NOT NULL
--GROUP BY
--    DATENAME(WEEKDAY, InvoiceDate),
--    DATEPART(WEEKDAY, InvoiceDate),                   -- Include for sorting
--    DATEPART(HOUR, InvoiceDate)
--ORDER BY
--    WeekdayOrder, TransactionHour;


/*  

Queries used for tableau visualization

*/

	----country with highest revenue

SELECT
    Country,                                      -- Customer's country
    COUNT(DISTINCT CustomerID) AS UniqueCustomers, -- Number of unique customers
    SUM(Quantity * UnitPrice) AS TotalRevenue      -- Total revenue generated
FROM
    [Copy of Online Retail]
WHERE
    InvoiceDate IS NOT NULL                       -- Ensure valid transaction dates
    AND CustomerID IS NOT NULL                   -- Exclude rows with missing CustomerID
GROUP BY
    Country
ORDER BY
    TotalRevenue DESC;                            -- Rank countries by revenue


---- country with highest revenue by percentage

SELECT
    Country,
     SUM(Quantity * UnitPrice) AS TotalRevenue,
    (SUM(Quantity * UnitPrice) * 100.0 / (SELECT SUM(Quantity * UnitPrice) FROM [Copy of Online Retail])) AS RevenuePercentage
FROM
    [Copy of Online Retail]
GROUP BY
    Country
ORDER BY
    RevenuePercentage DESC;

-----country with most customers
SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS CustomerCount
FROM
    [Copy of Online Retail]
WHERE
    CustomerID IS NOT NULL
GROUP BY
    Country
ORDER BY
    CustomerCount DESC;


----- country with highest revenue per month
WITH MonthlyCountryRevenue AS (
    SELECT
        DATENAME(MONTH, InvoiceDate) AS MonthName,
        MONTH(InvoiceDate) AS MonthNumber,
        Country,
        SUM(Quantity * UnitPrice) AS TotalRevenue
    FROM
        [Copy of Online Retail]
    WHERE
        Quantity > 0 AND UnitPrice > 0
    GROUP BY
        DATENAME(MONTH, InvoiceDate),
        MONTH(InvoiceDate),
        Country
),
RankedCountries AS (
    SELECT
        MonthName,
        MonthNumber,
        Country,
        TotalRevenue,
        RANK() OVER (PARTITION BY MonthNumber ORDER BY TotalRevenue DESC) AS RankByRevenue
    FROM
        MonthlyCountryRevenue
)
SELECT
    MonthName,
    Country,
    TotalRevenue
FROM
    RankedCountries
WHERE
    RankByRevenue = 1
ORDER BY
    MonthNumber;






-----%item with highest revenue from highest to lowest
SELECT
    Description AS Item,
    SUM(Quantity * UnitPrice) AS TotalRevenue,
    (SUM(Quantity * UnitPrice) * 100.0 / (SELECT SUM(Quantity * UnitPrice) FROM [Copy of Online Retail])) AS RevenuePercentage
FROM
    [Copy of Online Retail]
GROUP BY
    Description
ORDER BY
    RevenuePercentage DESC ;

----item that sold the most by percentage
SELECT
    Description AS Item,
    SUM(Quantity) AS TotalQuantity,
    (SUM(Quantity) * 100.0 / (SELECT SUM(Quantity) FROM [Copy of Online Retail])) AS QuantityPercentage
FROM
    [Copy of Online Retail]
GROUP BY
    Description
ORDER BY
    QuantityPercentage DESC;


-----quaterly growth for 2011
WITH QuarterlyRevenue AS (
    SELECT
        DATEPART(QUARTER, InvoiceDate) AS Quarter,
        SUM(Quantity * UnitPrice) AS TotalRevenue
    FROM
        [Copy of Online Retail]
    WHERE
        YEAR(InvoiceDate) = 2011
    GROUP BY
        DATEPART(QUARTER, InvoiceDate)
)
SELECT
    Quarter,
    TotalRevenue,
    LAG(TotalRevenue) OVER (ORDER BY Quarter) AS PreviousQuarterRevenue,
    ((TotalRevenue - LAG(TotalRevenue) OVER (ORDER BY Quarter)) * 100.0 / 
     NULLIF(LAG(TotalRevenue) OVER (ORDER BY Quarter), 0)) AS QuarterlyGrowthPercentage
FROM
    QuarterlyRevenue
ORDER BY
    Quarter;


------month with highest revenue by %

SELECT
    DATENAME(MONTH, InvoiceDate) AS MonthName,
    MONTH(InvoiceDate) AS MonthNumber,
    SUM(Quantity * UnitPrice) AS TotalRevenue,
    (SUM(Quantity * UnitPrice) * 100.0 / (SELECT SUM(Quantity * UnitPrice) FROM [Copy of Online Retail])) AS RevenuePercentage
FROM
    [Copy of Online Retail]
GROUP BY
    DATENAME(MONTH, InvoiceDate),
    MONTH(InvoiceDate)
ORDER BY
    MonthNumber;


------identify most sold items per month

	WITH MonthlyItemSales AS (
    SELECT
        DATENAME(MONTH, InvoiceDate) AS MonthName,
        MONTH(InvoiceDate) AS MonthNumber,
        StockCode,
        Description,
        SUM(Quantity) AS TotalQuantity
    FROM
        [Copy of Online Retail]
    GROUP BY
        DATENAME(MONTH, InvoiceDate),
        MONTH(InvoiceDate),
        StockCode,
        Description
),
RankedItems AS (
    SELECT
        MonthName,
        MonthNumber,
        StockCode,
        Description,
        TotalQuantity,
        RANK() OVER (PARTITION BY MonthNumber ORDER BY TotalQuantity DESC) AS RankByQuantity
    FROM
        MonthlyItemSales
)
SELECT
    MonthName,
    StockCode,
    Description,
    TotalQuantity
FROM
    RankedItems
WHERE
    RankByQuantity = 1
ORDER BY
    MonthNumber;

----- profit margin for all products
WITH ProductProfitability AS (
    SELECT
        StockCode,
        Description,
        SUM(Quantity * UnitPrice) AS TotalRevenue,
        SUM(Quantity * (UnitPrice * 0.7)) AS EstimatedTotalCost,
        SUM(Quantity * (UnitPrice - (UnitPrice * 0.7))) AS TotalProfit,
        (SUM(Quantity * (UnitPrice - (UnitPrice * 0.7))) * 100.0 / SUM(Quantity * UnitPrice)) AS ProfitMarginPercentage
    FROM
        [Copy of Online Retail]
    WHERE
        Quantity > 0 AND UnitPrice > 0
    GROUP BY
        StockCode,
        Description
)
SELECT
    StockCode,
    Description,
    TotalRevenue,
    TotalProfit,
    ProfitMarginPercentage
FROM
    ProductProfitability
ORDER BY
    ProfitMarginPercentage DESC;
	----total revene by year

	SELECT
    YEAR(InvoiceDate) AS Year,
    SUM(Quantity * UnitPrice) AS TotalRevenue
FROM
   [Copy of Online Retail]
WHERE
    Quantity > 0 AND UnitPrice > 0
GROUP BY
    YEAR(InvoiceDate)
ORDER BY
    Year;

