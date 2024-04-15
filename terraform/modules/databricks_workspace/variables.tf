variable "host" {
  type = string
}
variable "token" {
  type      = string
  sensitive = true
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
  default = ["alexischicoinedatadeveloper@gmail.com"]
}

variable "databricks_metastore_admins" {
  type    = list(any)
  default = ["alexischicoinedatadeveloper@gmail.com"]
}

variable "databricks_host" {
  type = string
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix                = "demo${random_string.naming.result}"
  metastore_name        = "${local.prefix}-metastore"
  unity_admin_group     = "${local.prefix}-admin-group"
  workspace_users_group = "${local.prefix}-workspace-users-group"
}