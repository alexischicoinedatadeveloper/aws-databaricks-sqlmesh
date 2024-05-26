# Databricks notebook source
# COMMAND ----------
# MAGIC %md
# Run SQLMesh project in Databricks.

# COMMAND ----------
import os

# COMMAND ----------
from databricks.sdk import WorkspaceClient
from sqlmesh import Context

# MAGIC %pip install "sqlmesh[databricks]"

dbutils = WorkspaceClient.dbutils


# COMMAND ----------

SQLMESH_PROJECT_PATH_INPUT_NAME = "sqlmesh_project_path"
dbutils.widgets.text(SQLMESH_PROJECT_PATH_INPUT_NAME, "")

# COMMAND ----------

sqlmesh_project_path = dbutils.widgets.get(SQLMESH_PROJECT_PATH_INPUT_NAME)
SCOPE = "postgres_secrets"
os.environ["POSTGRES_HOST"] = dbutils.secrets.get(SCOPE, "postgres_host")
os.environ["POSTGRES_PORT"] = dbutils.secrets.get(SCOPE, "postgres_port")
os.environ["POSTGRES_USER"] = dbutils.secrets.get(SCOPE, "sqlmesh_state_user")
os.environ["POSTGRES_PASSWORD"] = dbutils.secrets.get(SCOPE, "sqlmesh_state_password")
context = Context(paths=sqlmesh_project_path, gateway="db_notebook")
context.migrate()
context.create_external_models()
context.plan(auto_apply=True, run=True)
