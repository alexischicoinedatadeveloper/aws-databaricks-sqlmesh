terraform {
  backend "s3" {
    bucket = "alexischicoinedeveloperterraform"
    key    = "terraform_state"
    region = "us-east-1"
  }
}
terraform {
  required_providers {
    databricks = {
      source = "databricks/databricks"
    }
  }
}
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_terraform_account_client_id
  client_secret = var.databricks_terraform_account_secret
}

module "databricks_account" {
  source                                 = "./modules/databricks_account"
  tags                                   = var.tags
  cidr_block                             = var.cidr_block
  region                                 = var.region
  databricks_account_id                  = var.databricks_account_id
  aws_access_key_id                      = var.aws_access_key_id
  aws_secret_access_key                  = var.aws_secret_access_key
  databricks_terraform_account_client_id = var.databricks_terraform_account_client_id
  databricks_terraform_account_secret    = var.databricks_terraform_account_secret
  enable_nat_gateway_for_databricks_vpc  = var.enable_nat_gateway_for_databricks_vpc
  aws_account_id                         = var.aws_account_id
}

module "databricks_workspace" {
  source                                 = "./modules/databricks_workspace"
  host                                   = module.databricks_account.databricks_host
  token                                  = module.databricks_account.databricks_token
  metastore_id                           = module.databricks_account.metastore_id
  databricks_account_id                  = var.databricks_account_id
  databricks_terraform_account_client_id = var.databricks_terraform_account_client_id
  databricks_terraform_account_secret    = var.databricks_terraform_account_secret
  workspace_id                           = module.databricks_account.workspace_id
  databricks_host                        = module.databricks_account.databricks_host

}