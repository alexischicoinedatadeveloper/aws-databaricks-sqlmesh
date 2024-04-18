terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }

  }
}

provider "databricks" {
  alias = "mws"
}
provider "databricks" {
  alias = "workspace"
}