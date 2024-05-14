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
    postgresql = {
      source = "cyrilgdn/postgresql"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.15.0"
    }
  }
}
provider "aws" {
  region     = var.region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}
provider "databricks" {
  alias         = "mws"
  host          = "https://accounts.cloud.databricks.com"
  account_id    = var.databricks_account_id
  client_id     = var.databricks_terraform_account_client_id
  client_secret = var.databricks_terraform_account_secret
}


module "databricks_account" {
  source                                               = "./modules/databricks_account"
  tags                                                 = var.tags
  cidr_block                                           = var.cidr_block
  region                                               = var.region
  databricks_account_id                                = var.databricks_account_id
  aws_access_key_id                                    = var.aws_access_key_id
  aws_secret_access_key                                = var.aws_secret_access_key
  databricks_terraform_account_client_id               = var.databricks_terraform_account_client_id
  databricks_terraform_account_secret                  = var.databricks_terraform_account_secret
  enable_nat_gateway_for_databricks_vpc_and_public_rds = var.enable_nat_gateway_for_databricks_vpc_and_public_rds
  aws_account_id                                       = var.aws_account_id

  providers = {
    aws            = aws
    databricks.mws = databricks.mws
  }
}

provider "databricks" {
  alias         = "workspace"
  host          = module.databricks_account.databricks_host
  account_id    = var.databricks_account_id
  client_id     = var.databricks_terraform_account_client_id
  client_secret = var.databricks_terraform_account_secret
}

module "databricks_workspace" {
  depends_on                                           = [module.databricks_account]
  source                                               = "./modules/databricks_workspace"
  host                                                 = module.databricks_account.databricks_host
  token                                                = module.databricks_account.databricks_token
  metastore_id                                         = module.databricks_account.metastore_id
  databricks_account_id                                = var.databricks_account_id
  databricks_terraform_account_client_id               = var.databricks_terraform_account_client_id
  databricks_terraform_account_secret                  = var.databricks_terraform_account_secret
  workspace_id                                         = module.databricks_account.workspace_id
  databricks_host                                      = module.databricks_account.databricks_host
  vpc_id                                               = module.databricks_account.vpc_id
  subnet_id                                            = module.databricks_account.subnet_id
  security_group_id                                    = module.databricks_account.security_group_id
  subnet_group_name                                    = module.databricks_account.subnet_group_name
  github_user                                          = var.github_user
  github_token                                         = var.github_token
  workspace_repo_path                                  = var.workspace_repo_path
  enable_nat_gateway_for_databricks_vpc_and_public_rds = var.enable_nat_gateway_for_databricks_vpc_and_public_rds

  providers = {
    databricks.workspace = databricks.workspace
    databricks.mws       = databricks.mws
  }
}
provider "postgresql" {
  host            = module.databricks_workspace.postgres_host
  scheme          = "awspostgres"
  port            = 5432
  username        = module.databricks_workspace.postgres_admin_user
  password        = module.databricks_workspace.postgres_admin_password
  sslmode         = "require"
  connect_timeout = 15
  superuser       = false
}

module "postgres" {
  source = "./modules/postgres"
  providers = {
    postgresql = postgresql
  }
  sqlmesh_state_user_secret     = module.databricks_workspace.sqlmesh_state_user_secret
  sqlmesh_state_password_secret = module.databricks_workspace.sqlmesh_state_password_secret
  demo_data_user_secret         = module.databricks_workspace.demo_data_user_secret
  demo_data_password_secret     = module.databricks_workspace.demo_data_password_secret
}