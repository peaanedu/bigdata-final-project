FROM apache/hive:4.1.0

USER root

RUN microdnf install -y findutils procps-ng nc \
    && microdnf clean all

USER hive