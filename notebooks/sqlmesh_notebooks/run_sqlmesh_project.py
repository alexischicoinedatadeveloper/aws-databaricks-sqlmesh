# Databricks notebook source
# COMMAND ----------
# MAGIC %md
# MAGIC # Run SQLMesh project in Databricks.

# COMMAND ----------
# MAGIC %pip install "sqlmesh[databricks]"

# COMMAND ----------
from databricks.sdk import WorkspaceClient

dbutils = WorkspaceClient().dbutils
dbutils.library.restartPython()

# COMMAND ----------
import os  # pylint: disable=wrong-import-position, wrong-import-order

# COMMAND ----------
from databricks.sdk import WorkspaceClient  # pylint: disable=reimported, wrong-import-position
from sqlmesh import Context  # pylint: disable=wrong-import-position

dbutils = WorkspaceClient().dbutils


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
    dbutils.notebook.entry_point.getDbutils()  # pylint: disable=internal-api
    .notebook()
    .getContext()
    .apiToken()
    .getOrElse(None)
)
os.environ["DATABRICKS_SERVER_HOSTNAME"] = dbutils.secrets.get(SERVERLESS_SCOPE, "databricks_server_hostname")
os.environ["DATABRICKS_HTTP_PATH"] = dbutils.secrets.get(SERVERLESS_SCOPE, "databricks_http_path")

context = Context(paths=sqlmesh_project_path, gateway="db_notebook")
context.migrate()
context.create_external_models()
context.plan(auto_apply=True, run=True)
