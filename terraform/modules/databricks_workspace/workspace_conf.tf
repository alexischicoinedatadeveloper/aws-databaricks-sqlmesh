resource "databricks_workspace_conf" "this" {
  provider = databricks.workspace
  custom_config = {
    "storeInteractiveNotebookResultsInCustomerAccount" : true
  }
}