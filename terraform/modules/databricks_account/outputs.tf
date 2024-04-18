output "metastore_id" {
  value = databricks_metastore.this.id
}
output "databricks_host" {
  value = databricks_mws_workspaces.this.workspace_url
}

output "databricks_token" {
  value     = databricks_mws_workspaces.this.token[0].token_value
  sensitive = true
}

output "workspace_id" {
  value = databricks_mws_workspaces.this.workspace_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "subnet_id" {
  value = module.vpc.private_subnets[0]
}

output "security_group_id" {
  value = module.vpc.default_security_group_id
}

output "subnet_group_name" {
  #   value       = aws_db_subnet_group.my_db_subnet_group.name
  value       = aws_db_subnet_group.public_db_subnet_group.name
  description = "The name of the database subnet group"
}
