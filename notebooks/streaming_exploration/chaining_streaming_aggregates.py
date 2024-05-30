# Databricks notebook source
# MAGIC %md
# MAGIC # Setting up the stream chain demo

# COMMAND ----------

# MAGIC %sql
# MAGIC create schema if not exists stream_chain_demo.stream;
# MAGIC CREATE VOLUME if not exists stream_chain_demo.stream.stream_checkpoints_volume;
# MAGIC SET
# MAGIC   spark.databricks.adaptive.autoOptimizeShuffle.enabled = true;
# MAGIC CREATE TABLE if not exists stream_chain_demo.stream.my_table (a STRING, b INT);

# COMMAND ----------

# MAGIC %md
# MAGIC # A cell to insert data into the source table

# COMMAND ----------

# MAGIC %sql
# MAGIC INSERT INTO
# MAGIC   stream_chain_demo.stream.my_table (a, b)
# MAGIC VALUES
# MAGIC   ('value_o', 1)

# COMMAND ----------

# MAGIC %md
# MAGIC # A first stream that works in complete mode

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, expr, count, date_trunc, sum

# Create the streaming DataFrame
streaming_df = spark.readStream.table("stream_chain_demo.stream.my_table")

# Add event_date column from current date
streaming_df = streaming_df.withColumn(
    "event_date", date_trunc("minute", current_timestamp())
)

# Aggregate by a and event_date
aggregated_df = (
    streaming_df
    .groupBy("a", "event_date")
    .agg(sum("b").alias("b"))
)


# Write the aggregated DataFrame to the downstream table
query = (
    aggregated_df.writeStream.format("delta")
    .outputMode("complete")
    .option(
        "checkpointLocation",
        "/Volumes/stream_chain_demo/stream/stream_checkpoints_volume/my_table_downstream_complete",
    )
    .table("stream_chain_demo.stream.my_table_downstream_complete")
)

# COMMAND ----------

# MAGIC %md
# MAGIC # A second stream that fails because of the changes from complete mode

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, expr, count, date_trunc

# Create the streaming DataFrame
streaming_df = spark.readStream.table(
    "stream_chain_demo.stream.my_table_downstream_complete"
)

# Add event_date column from current date
streaming_df = streaming_df.withColumn(
    "event_date", date_trunc("hour", current_timestamp())
)

# Aggregate by a and event_date
aggregated_df = (
    streaming_df
    .groupBy("a", "event_date")
    .agg(count("b").alias("b"))
    .withColumn("something", expr("2"))
)


# Write the aggregated DataFrame to the downstream table
query = (
    aggregated_df.writeStream.format("delta")
    .outputMode("complete")
    .option(
        "checkpointLocation",
        "/Volumes/stream_chain_demo/stream/stream_checkpoints_volume/my_table_downstream_hour_complete",
    )
    .table("stream_chain_demo.stream.my_table_downstream_hour_complete")
)

# COMMAND ----------

# MAGIC %md
# MAGIC # Another version that skips changes, but the results won't be correct

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, expr, count, date_trunc

# Create the streaming DataFrame
streaming_df = spark.readStream.option("skipChangeCommits", "true").table(
    "stream_chain_demo.stream.my_table_downstream_complete"
)

# Add event_date column from current date
streaming_df = streaming_df.withColumn(
    "event_date", date_trunc("hour", current_timestamp())
)

# Aggregate by a and event_date
aggregated_df = (
    streaming_df
    .groupBy("a", "event_date")
    .agg(count("b").alias("b"))
    .withColumn("something", expr("2"))
)


# Write the aggregated DataFrame to the downstream table
query = (
    aggregated_df.writeStream.format("delta")
    .outputMode("complete")
    .option(
        "checkpointLocation",
        "/Volumes/stream_chain_demo/stream/stream_checkpoints_volume/my_table_downstream_hour_complete_skip",
    )
    .table("stream_chain_demo.stream.my_table_downstream_hour_complete_skip")
)

# COMMAND ----------

# MAGIC %md
# MAGIC # A first stream that skips changes in append mode

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, expr, count, date_trunc

# Create the streaming DataFrame
streaming_df = spark.readStream.option("skipChangeCommits", "true").table(
    "stream_chain_demo.stream.my_table"
)

# Add event_date column from current date
streaming_df = streaming_df.withColumn(
    "event_date", date_trunc("second", current_timestamp())
).na.fill({"event_date": "2024-01-01"})

# Aggregate by a and event_date
aggregated_df = (
    streaming_df.withWatermark("event_date", "1 second")
    .groupBy("a", "event_date")
    .agg(count("b").alias("b"))
)


# Write the aggregated DataFrame to the downstream table
query = (
    aggregated_df.writeStream.format("delta")
    .outputMode("append")
    .option(
        "checkpointLocation",
        "/Volumes/stream_chain_demo/stream/stream_checkpoints_volume/my_table_downstream_append",
    )
    .option("mergeSchema", "true")
    .table("stream_chain_demo.stream.my_table_downstream_append")
)

# COMMAND ----------

# MAGIC %sql
# MAGIC select * from stream_chain_demo.stream.my_table_downstream_append

# COMMAND ----------

# MAGIC %md
# MAGIC # A view so that we get the correct aggregation

# COMMAND ----------

# MAGIC %sql
# MAGIC create or replace view stream_chain_demo.stream.my_table_downstream_minute as
# MAGIC select
# MAGIC   a,
# MAGIC   date_trunc("minute", event_date) as event_date_minute,
# MAGIC   sum(b) as b
# MAGIC from
# MAGIC   stream_chain_demo.stream.my_table_downstream_append
# MAGIC group by
# MAGIC   a,
# MAGIC   event_date_minute;
# MAGIC select
# MAGIC   *
# MAGIC from
# MAGIC   stream_chain_demo.stream.my_table_downstream_minute;

# COMMAND ----------

# MAGIC %md
# MAGIC # A second stream that skips changes

# COMMAND ----------

from pyspark.sql.functions import current_timestamp, expr, sum, date_trunc

# Create the streaming DataFrame
streaming_df = spark.readStream.option("skipChangeCommits", "true").table(
    "stream_chain_demo.stream.my_table_downstream_append"
)

# Add event_date column from current date
streaming_df = streaming_df.withColumn(
    "event_date", date_trunc("hour", current_timestamp())
).na.fill({"event_date": "2024-01-01"})

# Aggregate by a and event_date
aggregated_df = (
    streaming_df.withWatermark("event_date", "60 second")
    .groupBy("a", "event_date")
    .agg(sum("b").alias("b"))
)


# Write the aggregated DataFrame to the downstream table
query = (
    aggregated_df.writeStream.format("delta")
    .outputMode("append")
    .option(
        "checkpointLocation",
        "/Volumes/stream_chain_demo/stream/stream_checkpoints_volume/my_table_downstream_hour",
    )
    .table("stream_chain_demo.stream.my_table_downstream_hour")
)

# COMMAND ----------


