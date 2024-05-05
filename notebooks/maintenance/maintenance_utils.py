"""Functions to maintain Delta tables."""

from typing import Optional

from delta import DeltaTable
from pyspark.sql import SparkSession


def maintain_table(spark: SparkSession, table_full_name: str) -> None:
    table = DeltaTable.forName(spark, table_full_name)
    custom_zorder = get_custom_zorder(spark, table_full_name)
    if custom_zorder:
        table.optimize().executeZOrderBy(custom_zorder)
    else:
        table.optimize().executeCompaction()
    table.vacuum()


def set_table_zorder(spark: SparkSession, table_full_name: str, zorder_columns: list[str]) -> None:
    spark.sql(
        f"""
              ALTER TABLE {table_full_name} SET TBLPROPERTIES ( custom_z_order = "{','.join(zorder_columns)}" )
              """
    ).first()


def get_custom_zorder(spark: SparkSession, table_full_name: str) -> Optional[list[str]]:
    table = DeltaTable.forName(spark, table_full_name)
    custom_zorder_property = table.detail().select("properties.custom_z_order").first()[0]
    if custom_zorder_property:
        custom_zorder = custom_zorder_property.split(",")
        return custom_zorder
    return None
