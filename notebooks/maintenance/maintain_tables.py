# Databricks notebook source
from typing import Optional
from delta import DeltaTable
from databricks.connect import DatabricksSession
from databricks.sdk import WorkspaceClient
from pyspark.sql.connect.session import SparkSession

# COMMAND ----------

spark = DatabricksSession.builder.getOrCreate()
dbutils = WorkspaceClient.dbutils

# COMMAND ----------

catalogs_to_maintain_widget_name = "catalogs_to_maintain"
dbutils.widgets.text(
    catalogs_to_maintain_widget_name,
    "sales",
    f"{catalogs_to_maintain_widget_name}: csv",
)

# COMMAND ----------

def maintain_table(spark : SparkSession, table_full_name: str) -> None:
    table = DeltaTable.forName(spark, table_full_name)
    custom_zorder = get_custom_zorder(spark, table_full_name)
    if custom_zorder:
        table.optimize().executeZOrderBy(custom_zorder)
    else:
        table.optimize().executeCompaction()
    table.vacuum()
    


# COMMAND ----------

def set_table_zorder(spark: SparkSession, table_full_name: str, zorder_columns: list[str]) -> None:
    spark.sql(f"""
              ALTER TABLE {table_full_name} SET TBLPROPERTIES ( custom_z_order = "{','.join(zorder_columns)}" )
              """).first()

# COMMAND ----------

def get_custom_zorder(spark: SparkSession, table_full_name: str) -> Optional[list[str]]:
    table = DeltaTable.forName(spark, table_full_name)
    custom_zorder_property = test_table.detail().select("properties.custom_z_order").first()[0]
    if custom_zorder_property:
        custom_zorder = custom_zorder_property.split(",") 
        return custom_zorder
    return None

# COMMAND ----------

for catalog in dbutils.widgets.get(catalogs_to_maintain_widget_name).split(","):
    # print(catalog)
    spark.catalog.setCurrentCatalog(catalog)
    for database in spark.catalog.listDatabases():
        # print(database)
        spark.sql(f"""
                  analyze tables in {catalog}.{database.name} COMPUTE STATISTICS
                  """).first()
        for table in spark.catalog.listTables(dbName=database.name):
            if table.tableType == "MANAGED":
                maintain_table(spark, f"{table.catalog}.{table.namespace[0]}.{table.name}")
