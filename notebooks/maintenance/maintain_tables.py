# Databricks notebook source
"""Maintain tables in the specified catalogs."""
from databricks.connect import DatabricksSession
from databricks.sdk import WorkspaceClient

from notebooks.maintenance.maintenance_utils import maintain_table

# COMMAND ----------

spark = DatabricksSession.builder.getOrCreate()
dbutils = WorkspaceClient().dbutils

# COMMAND ----------

catalogs_to_maintain_widget_name = "catalogs_to_maintain"
dbutils.widgets.text(
    catalogs_to_maintain_widget_name,
    "sales",
    f"{catalogs_to_maintain_widget_name}: csv",
)

# COMMAND ----------

for catalog in dbutils.widgets.get(catalogs_to_maintain_widget_name).split(","):
    # print(catalog)
    spark.catalog.setCurrentCatalog(catalog)
    for database in spark.catalog.listDatabases():
        # print(database)
        spark.sql(
            f"""
                  analyze tables in {catalog}.{database.name} COMPUTE STATISTICS
                  """
        ).first()
        for table in spark.catalog.listTables(dbName=database.name):
            if table.tableType == "MANAGED" and table.namespace:
                maintain_table(spark, f"{table.catalog}.{table.namespace[0]}.{table.name}")
