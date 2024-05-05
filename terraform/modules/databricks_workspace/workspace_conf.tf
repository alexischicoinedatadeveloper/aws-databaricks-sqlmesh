resource "databricks_workspace_conf" "this" {
  provider = databricks.workspace
  custom_config = {
    "storeInteractiveNotebookResultsInCustomerAccount" : true
  }
}
variable "schemas" {
  default = ["access", "billing", "compute", "marketplace", "storage"]
}
resource "databricks_system_schema" "this" {
  provider = databricks.workspace
  for_each = toset(var.schemas)

  schema = each.value
}
