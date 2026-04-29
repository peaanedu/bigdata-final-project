CREATE DATABASE IF NOT EXISTS sales_dw;
USE sales_dw;

DROP TABLE IF EXISTS fact_sales;
DROP TABLE IF EXISTS dim_products;
DROP TABLE IF EXISTS dim_categories;
DROP TABLE IF EXISTS dim_regions;

CREATE EXTERNAL TABLE fact_sales (
    order_id INT,
    order_date DATE,
    sales_quarter INT,
    product_id INT,
    product_name STRING,
    category_id INT,
    category_name STRING,
    region_id INT,
    region_name STRING,
    country STRING,
    quantity INT,
    unit_price DOUBLE,
    sales_amount DOUBLE
)
PARTITIONED BY (
    sales_year INT,
    sales_month INT
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/data/warehouse/sales_analytics/fact_sales';

MSCK REPAIR TABLE fact_sales;

CREATE EXTERNAL TABLE dim_products (
    product_id INT,
    product_name STRING,
    category_id INT,
    unit_price DOUBLE
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/data/warehouse/sales_analytics/dim_products';

CREATE EXTERNAL TABLE dim_categories (
    category_id INT,
    category_name STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/data/warehouse/sales_analytics/dim_categories';

CREATE EXTERNAL TABLE dim_regions (
    region_id INT,
    region_name STRING,
    country STRING
)
STORED AS PARQUET
LOCATION 'hdfs://namenode:9000/data/warehouse/sales_analytics/dim_regions';