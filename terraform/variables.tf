variable "tags" {
  default = {}
}

variable "cidr_block" {
  default = "10.4.0.0/16"
}

variable "region" {
  default = "us-east-1"
}

variable "databricks_account_id" {}
variable "aws_access_key_id" {}
variable "aws_secret_access_key" {}
variable "databricks_terraform_account_client_id" {}
variable "databricks_terraform_account_secret" {}
variable "enable_nat_gateway_for_databricks_vpc" {
  default = false
  type    = bool
}

resource "random_string" "naming" {
  special = false
  upper   = false
  length  = 6
}

locals {
  prefix = "demo${random_string.naming.result}"
}