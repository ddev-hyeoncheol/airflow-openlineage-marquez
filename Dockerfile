ARG AIRFLOW_BASE_IMAGE=apache/airflow:3.2.2
FROM ${AIRFLOW_BASE_IMAGE}

USER root
# Install Java 17 JRE for PySpark compatibility
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup JAVA_HOME supporting both amd64 and arm64 architectures
RUN ln -s /usr/lib/jvm/java-17-openjdk-* /usr/lib/jvm/default-java
ENV JAVA_HOME=/usr/lib/jvm/default-java

# Cache PostgreSQL JDBC driver for PySpark
ADD https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.11/postgresql-42.7.11.jar /opt/airflow/postgresql-42.7.11.jar
RUN chmod 644 /opt/airflow/postgresql-42.7.11.jar

# Cache OpenLineage Spark Agent jar
ADD https://repo1.maven.org/maven2/io/openlineage/openlineage-spark_2.13/1.49.0/openlineage-spark_2.13-1.49.0.jar /opt/airflow/openlineage-spark_2.13-1.49.0.jar
RUN chmod 644 /opt/airflow/openlineage-spark_2.13-1.49.0.jar

USER airflow
# Install PySpark & dbt core packages matching requirements.txt
RUN pip install --no-cache-dir pyspark==4.1.2 dbt-postgres==1.10.1 openlineage-dbt==1.49.0
