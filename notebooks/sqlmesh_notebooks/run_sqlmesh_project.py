"""Run SQLMesh project in Databricks."""

# Databricks notebook source
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
POSTGRES_SCOPE = "postgres_secrets"
os.environ["POSTGRES_HOST"] = dbutils.secrets.get(POSTGRES_SCOPE, "postgres_host")
os.environ["POSTGRES_PORT"] = dbutils.secrets.get(POSTGRES_SCOPE, "postgres_port")
os.environ["POSTGRES_USER"] = dbutils.secrets.get(POSTGRES_SCOPE, "sqlmesh_state_user")
os.environ["POSTGRES_PASSWORD"] = dbutils.secrets.get(POSTGRES_SCOPE, "sqlmesh_state_password")

SERVERLESS_SCOPE = "serverless_secrets"
os.environ["DATABRICKS_ACCESS_TOKEN"] = (
    dbutils.notebook.entry_point.getDbutils().notebook().getContext().apiToken().getOrElse(None)
)
os.environ["DATABRICKS_SERVER_HOSTNAME"] = dbutils.secrets.get(SERVERLESS_SCOPE, "databricks_server_hostname")
os.environ["DATABRICKS_HTTP_PATH"] = dbutils.secrets.get(SERVERLESS_SCOPE, "databricks_http_path")

context = Context(paths=sqlmesh_project_path, gateway="db_notebook")
context.migrate()
context.create_external_models()
context.plan(auto_apply=True, run=True)
