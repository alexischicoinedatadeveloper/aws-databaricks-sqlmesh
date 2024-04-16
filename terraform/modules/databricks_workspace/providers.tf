terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "~> 1.14.0" // Specify the version based on the latest or required compatibility
    }
  }
}

provider "databricks" {
  alias = "mws"
}
provider "databricks" {
  alias = "workspace"
}