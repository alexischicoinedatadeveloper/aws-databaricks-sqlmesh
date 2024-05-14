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
variable "enable_nat_gateway_for_databricks_vpc_and_public_rds" {
  default = false
  type    = bool
}
variable "aws_account_id" {
  type = string
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