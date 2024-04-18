output "postgres_host" {
  value = aws_db_instance.postgres_for_databricks.address
}
output "postgres_admin_user" {
  value     = databricks_secret.postgres_admin_user.string_value
  sensitive = true
}
output "postgres_admin_password" {
  value     = databricks_secret.postgres_admin_password.string_value
  sensitive = true
}
output "sqlmesh_state_user_secret" {
  value     = databricks_secret.sqlmesh_state_user_secret.string_value
  sensitive = true
}

output "sqlmesh_state_password_secret" {
  value     = databricks_secret.sqlmesh_state_password_secret.string_value
  sensitive = true
}

output "demo_data_user_secret" {
  value     = databricks_secret.demo_data_user_secret.string_value
  sensitive = true
}

output "demo_data_password_secret" {
  value     = databricks_secret.demo_data_password_secret.string_value
  sensitive = true
}