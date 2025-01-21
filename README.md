# Retail Store Revenue Analysis

### Project Overview

“This project demonstrates using SQL and Tableau to analyze an online retail dataset. It covers data cleaning, analyzing time-based trends, and revenue, and visualizing insights in Tableau. The results highlight how businesses can leverage data to understand customer behavior, optimize profitability, and improve decision-making.”
---
### Data Sources

Retail Data; the primary dataset used for this analysis is the 'copy of online retail.csv' containing detailed information about each sale made by the company [get source here](https://archive.ics.uci.edu/dataset/352/online+retail)

### Tools

- Excel
- SQL Server
- Tableau [veiw dashboard](https://public.tableau.com/app/profile/nissi.douglas/viz/Revenuevisualizationforretailstore/Dashboard1)
---

## Features

1. **Data Cleaning:**
   - Identifies and removes invalid `InvoiceDate` values using the `ISDATE` function.
   - Deletes rows with non-date values in the `InvoiceDate` column.
   - Sets invalid `InvoiceDate` values to `NULL` where necessary.

2. **Schema Updates:**
   - Alters the `InvoiceDate` column to have a `DATETIME` data type to ensure consistency.

3. **Data Transformation:**
   - Calculates `TotalRevenue` for each transaction as `Quantity * UnitPrice`.
   - Extracts and formats date components using `CAST`.

4. **Basic Data Analysis:**
   - Retrieves specific columns and sorted data for reporting.
   - Uses metadata inspection with `sp_columns` for understanding the table structure.

---

## Steps Used in the SQL Script

### 1. **Loading and Cleaning the Data**
   ```sql
   SELECT
       [StockCode],
       [Description],
       [InvoiceDate],
       [CustomerID],
       [Country],
       [Quantity],
       [UnitPrice],
       ([Quantity] * [UnitPrice]) AS TotalRevenue
   FROM [retail project].[dbo].[Copy of Online Retail];

   -- Identify invalid dates
   SELECT *
   FROM [Copy of Online Retail]
   WHERE ISDATE(InvoiceDate) = 0;

   -- Set invalid dates to NULL
   UPDATE [Copy of Online Retail]
   SET InvoiceDate = NULL
   WHERE ISDATE(InvoiceDate) = 0;

   -- Delete rows with invalid dates
   DELETE FROM [Copy of Online Retail]
   WHERE ISDATE(InvoiceDate) = 0;
   ```

### 2. **Schema Modification**
   ```sql
   -- Alter the column to ensure proper data type
   ALTER TABLE [dbo].[Copy of Online Retail]
   ALTER COLUMN InvoiceDate DATETIME;
   ```

### 3. **Data Transformation and Analysis**
   ```sql
   -- Extract date components
   SELECT
       CAST(InvoiceDate AS DATE) AS InvoiceDateOnly,
       CAST(InvoiceDate AS TIME) AS InvoiceTime
   FROM [Copy of Online Retail];

   -- Calculate total revenue per transaction
   SELECT
       [StockCode],
       [Description],
       [Quantity],
       [UnitPrice],
       ([Quantity] * [UnitPrice]) AS TotalRevenue
   FROM [Copy of Online Retail];

   -- Sort transactions by date
   SELECT *
   FROM [Copy of Online Retail]
   WHERE InvoiceDate IS NOT NULL
   ORDER BY InvoiceDate DESC;
   ```

### 4. **Metadata Inspection**
   ```SQL
   -- View table column details
   EXEC sp_columns OnlineRetail;
   ```

---

## How to Use

1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/yourusername/retail-data-cleaning.git
   ```

2. Open the SQL file (`revenue data exploration for online.sql`) in your preferred SQL editor (e.g., SSMS, Azure Data Studio).

3. Execute the script step-by-step to:
   - Clean the data.
   - Modify the schema.
   - Analyze and transform the data.

4. Verify results at each stage to ensure data quality.

---

## Prerequisites

- **Database Management System: ** Please make sure you have access to a SQL Server instance.
- **Dataset:** The script assumes a table named `Copy of Online Retail` exists with the following columns:
  - `StockCode`
  - `Description`
  - `InvoiceDate`
  - `CustomerID`
  - `Country`
  - `Quantity`
  - `UnitPrice`

---

## Contributions

Contributions are welcome! Please submit a pull request with detailed explanations of changes.

---








