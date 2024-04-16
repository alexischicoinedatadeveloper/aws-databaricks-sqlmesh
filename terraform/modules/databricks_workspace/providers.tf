terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}

provider "databricks" {
  alias         = "workspace"
  host          = var.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.databricks_terraform_account_client_id
  client_secret = var.databricks_terraform_account_secret
}

provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_terraform_account_client_id
  client_secret = var.databricks_terraform_account_secret
}