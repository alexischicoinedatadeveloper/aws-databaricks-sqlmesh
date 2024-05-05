variable "host" {
  type = string
}
variable "token" {
  type      = string
  sensitive = true
}

variable "github_user" {
  type = string
}

variable "github_token" {
  type      = string
  sensitive = true
}
variable "workspace_repo_path" {
  type = string
}

variable "metastore_id" {
  type = string
}
variable "databricks_account_id" {}
variable "databricks_terraform_account_client_id" {}
variable "databricks_terraform_account_secret" {}
variable "workspace_id" {}

variable "databricks_users" {
  type    = list(any)
  default = ["alexisdatabricksmay2024@outlook.com"]
}

variable "databricks_metastore_admins" {
  type    = list(any)
  default = ["alexisdatabricksmay2024@outlook.com"]
}

variable "databricks_host" {
  type = string
}

variable "vpc_id" {
}


variable "subnet_id" {
}

variable "security_group_id" {
}

variable "subnet_group_name" {}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

resource "random_string" "postgres_admin_user" {
  special = false
  upper   = true
  numeric = false
  length  = 10
}

resource "random_password" "postgres_admin_pw" {
  special          = true
  upper            = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  length           = 20
}

data "external" "yaml_tables" {
  program = ["python", "${path.module}/parse_sqlmesh_external_models.py", "${path.root}/../sqlmesh_projects/downstream/schema.yaml"]
}
locals {
  prefix                     = "demo${random_string.naming.result}"
  metastore_name             = "${local.prefix}-metastore"
  unity_admin_group          = "${local.prefix}-admin-group"
  workspace_users_group      = "${local.prefix}-workspace-users-group"
  downstream_external_models = toset(jsondecode(data.external.yaml_tables.result["tables"])) # for table update trigger but it's not supported yet
}

resource "random_string" "sqlmesh_state_user" {
  length  = 10
  special = false
  upper   = true
  numeric = false
}

resource "random_password" "sqlmesh_state_password" {
  length           = 20
  special          = true
  upper            = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_string" "demo_data_user" {
  length  = 10
  special = false
  upper   = true
  numeric = false
}

resource "random_password" "demo_data_password" {
  length           = 20
  special          = true
  upper            = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}


