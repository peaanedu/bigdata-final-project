#!/bin/bash

set -euo pipefail

echo "================================================="
echo " BIG DATA PLATFORM VALIDATION CHECK"
echo "================================================="

PASS=0
FAIL=0

check() {
    NAME="$1"
    CMD="$2"

    echo ""
    echo "Checking: $NAME"

    if eval "$CMD"; then
        echo "PASS: $NAME"
        PASS=$((PASS+1))
    else
        echo "FAIL: $NAME"
        FAIL=$((FAIL+1))
    fi
}

check "Docker containers running" \
"docker ps --format '{{.Names}}' | grep -E 'namenode|datanode|hive-server|trino|spark-master|jupyter'"

check "NameNode health" \
"docker exec namenode hdfs dfsadmin -report | grep -i 'Live datanodes'"

check "HDFS raw sales directory" \
"docker exec namenode hdfs dfs -ls /data/raw/sales"

check "HDFS warehouse directory" \
"docker exec namenode hdfs dfs -ls /data/warehouse/sales_analytics"

check "YARN ResourceManager API" \
"curl -fs http://localhost:8088/ws/v1/cluster/info"

check "HiveServer2 connection" \
"docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e 'SHOW DATABASES;'"

check "Hive sales_dw database" \
"docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e 'SHOW DATABASES;' | grep sales_dw"

check "Hive fact table" \
"docker exec hive-server beeline -u jdbc:hive2://localhost:10000 -e 'USE sales_dw; SHOW TABLES;' | grep fact_sales"

check "Trino catalogs" \
"docker exec trino trino --execute 'SHOW CATALOGS;' | grep hive"

check "Trino Hive schema" \
"docker exec trino trino --execute 'SHOW SCHEMAS FROM hive;' | grep sales_dw"

check "Spark Master UI" \
"curl -fs http://localhost:8080"

check "Jupyter UI" \
"curl -fs http://localhost:8888"

echo ""
echo "================================================="
echo " VALIDATION SUMMARY"
echo "================================================="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "Overall Status: SUCCESS"
    exit 0
else
    echo "Overall Status: FAILED"
    exit 1
fi