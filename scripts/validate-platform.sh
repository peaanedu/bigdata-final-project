#!/bin/bash

set -e

echo "1. Checking Docker containers..."
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "2. Checking HDFS health..."
docker exec namenode hdfs dfsadmin -report

echo "3. Checking HDFS directories..."
docker exec namenode hdfs dfs -ls -R /data || true

echo "4. Checking YARN..."
curl -f http://localhost:8088/ws/v1/cluster/info || exit 1

echo "5. Checking HiveServer2..."
docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e "SHOW DATABASES;"

echo "6. Checking Trino..."
docker exec trino trino --execute "SHOW CATALOGS;"

echo "7. Checking Spark Master..."
curl -f http://localhost:8080 || exit 1

echo "Validation completed successfully."