terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
      configuration_aliases = [
        databricks.mws,
      ]
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
  }
}
