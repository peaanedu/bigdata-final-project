CREATE DATABASE IF NOT EXISTS sales_dw;
USE sales_dw;

DROP TABLE IF EXISTS raw_sales_transactions;
DROP TABLE IF EXISTS raw_products;
DROP TABLE IF EXISTS raw_categories;
DROP TABLE IF EXISTS raw_regions;

CREATE EXTERNAL TABLE raw_sales_transactions (
    SalesID INT,
    ProductID INT,
    RegionID INT,
    QuantitySold INT,
    SalesAmount DOUBLE,
    SalesDate STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/raw/sales/sales_transactions'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE raw_products (
    ProductID INT,
    ProductName STRING,
    CategoryID INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/raw/sales/products'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE raw_categories (
    CategoryID INT,
    CategoryName STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/raw/sales/categories'
TBLPROPERTIES ("skip.header.line.count"="1");

CREATE EXTERNAL TABLE raw_regions (
    RegionID INT,
    RegionName STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/data/raw/sales/regions'
TBLPROPERTIES ("skip.header.line.count"="1");

DROP TABLE IF EXISTS fact_sales_analytics_hive;

CREATE TABLE fact_sales_analytics_hive AS
SELECT
    s.SalesID,
    s.ProductID,
    p.ProductName,
    p.CategoryID,
    c.CategoryName,
    s.RegionID,
    r.RegionName,
    s.QuantitySold,
    s.SalesAmount,
    TO_DATE(s.SalesDate) AS SalesDate,
    YEAR(TO_DATE(s.SalesDate)) AS SalesYear,
    MONTH(TO_DATE(s.SalesDate)) AS SalesMonth,
    QUARTER(TO_DATE(s.SalesDate)) AS SalesQuarter
FROM raw_sales_transactions s
LEFT JOIN raw_products p ON s.ProductID = p.ProductID
LEFT JOIN raw_categories c ON p.CategoryID = c.CategoryID
LEFT JOIN raw_regions r ON s.RegionID = r.RegionID;

SELECT RegionName, SUM(SalesAmount) AS TotalSales
FROM fact_sales_analytics_hive
GROUP BY RegionName
ORDER BY TotalSales DESC;