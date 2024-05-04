# Databricks notebook source
# MAGIC %pip install "sqlmesh[databricks]"

# COMMAND ----------

from sqlmesh import Context
import os


# COMMAND ----------

sqlmesh_project_path_input_name = "sqlmesh_project_path"
dbutils.widgets.text(sqlmesh_project_path_input_name, "")

# COMMAND ----------

sqlmesh_project_path = dbutils.widgets.get(sqlmesh_project_path_input_name)
scope = "postgres_secrets"
os.environ["POSTGRES_HOST"] = dbutils.secrets.get(scope, "postgres_host")
os.environ["POSTGRES_PORT"] = dbutils.secrets.get(scope, "postgres_port")
os.environ["POSTGRES_USER"] = dbutils.secrets.get(scope, "sqlmesh_state_user")
os.environ["POSTGRES_PASSWORD"] = dbutils.secrets.get(scope, "sqlmesh_state_password")
context = Context(paths=sqlmesh_project_path, gateway="db_notebook")
context.migrate()
context.plan(auto_apply=True, run=True)
