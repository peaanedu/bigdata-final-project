from pyspark.sql import SparkSession
from pyspark.sql.functions import col, to_date, year, month, quarter

spark = (
    SparkSession.builder
    .appName("Sales Analytics ETL")
    .master("spark://spark-master:7077")
    .config("spark.hadoop.fs.defaultFS", "hdfs://namenode:9000")
    .config("spark.sql.shuffle.partitions", "8")
    .getOrCreate()
)

base_path = "hdfs://namenode:9000/data/raw/sales"
warehouse_path = "hdfs://namenode:9000/data/warehouse/sales_analytics"

sales_df = (
    spark.read.option("header", True)
    .csv(f"{base_path}/sales_orders.csv")
    .withColumn("order_id", col("order_id").cast("int"))
    .withColumn("order_date", to_date(col("order_date"), "yyyy-MM-dd"))
    .withColumn("product_id", col("product_id").cast("int"))
    .withColumn("region_id", col("region_id").cast("int"))
    .withColumn("quantity", col("quantity").cast("int"))
    .withColumn("unit_price", col("unit_price").cast("double"))
    .withColumn("sales_amount", col("sales_amount").cast("double"))
)

products_df = (
    spark.read.option("header", True)
    .csv(f"{base_path}/products.csv")
    .withColumn("product_id", col("product_id").cast("int"))
    .withColumn("category_id", col("category_id").cast("int"))
    .withColumn("unit_price", col("unit_price").cast("double"))
)

categories_df = (
    spark.read.option("header", True)
    .csv(f"{base_path}/categories.csv")
    .withColumn("category_id", col("category_id").cast("int"))
)

regions_df = (
    spark.read.option("header", True)
    .csv(f"{base_path}/regions.csv")
    .withColumn("region_id", col("region_id").cast("int"))
)

sales_clean = (
    sales_df
    .dropna()
    .dropDuplicates(["order_id"])
    .withColumn("sales_year", year(col("order_date")))
    .withColumn("sales_month", month(col("order_date")))
    .withColumn("sales_quarter", quarter(col("order_date")))
)

sales_enriched = (
    sales_clean
    .join(products_df, "product_id", "left")
    .join(categories_df, "category_id", "left")
    .join(regions_df, "region_id", "left")
    .select(
        "order_id",
        "order_date",
        "sales_year",
        "sales_month",
        "sales_quarter",
        "product_id",
        "product_name",
        "category_id",
        "category_name",
        "region_id",
        "region_name",
        "country",
        "quantity",
        sales_clean["unit_price"],
        "sales_amount"
    )
)

sales_enriched.write.mode("overwrite").partitionBy("sales_year", "sales_month").parquet(
    f"{warehouse_path}/fact_sales"
)

products_df.write.mode("overwrite").parquet(f"{warehouse_path}/dim_products")
categories_df.write.mode("overwrite").parquet(f"{warehouse_path}/dim_categories")
regions_df.write.mode("overwrite").parquet(f"{warehouse_path}/dim_regions")

print("ETL completed successfully.")
print("Warehouse path:", warehouse_path)

sales_enriched.show(10)
spark.stop()