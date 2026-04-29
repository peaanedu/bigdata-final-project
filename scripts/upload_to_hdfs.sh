#!/bin/bash

set -e

echo "Creating HDFS directories..."

docker exec namenode hdfs dfs -mkdir -p /data/raw/sales
docker exec namenode hdfs dfs -mkdir -p /data/warehouse/sales_analytics
docker exec namenode hdfs dfs -mkdir -p /tmp/hive

echo "Uploading CSV files..."

docker cp datasets/sales_orders.csv namenode:/tmp/sales_orders.csv
docker cp datasets/products.csv namenode:/tmp/products.csv
docker cp datasets/categories.csv namenode:/tmp/categories.csv
docker cp datasets/regions.csv namenode:/tmp/regions.csv

docker exec namenode hdfs dfs -put -f /tmp/sales_orders.csv /data/raw/sales/
docker exec namenode hdfs dfs -put -f /tmp/products.csv /data/raw/sales/
docker exec namenode hdfs dfs -put -f /tmp/categories.csv /data/raw/sales/
docker exec namenode hdfs dfs -put -f /tmp/regions.csv /data/raw/sales/

echo "HDFS files:"
docker exec namenode hdfs dfs -ls -R /data/raw/sales