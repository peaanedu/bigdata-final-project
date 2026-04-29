FROM apache/hive:4.1.0

USER root

RUN apt-get update && apt-get install -y findutils procps netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

USER hive