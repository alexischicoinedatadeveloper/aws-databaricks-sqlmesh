resource "aws_db_instance" "postgres_for_databricks" {
  identifier             = "postgres-for-databricks"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  max_allocated_storage  = 20 # Enables autoscaling up to 20GB
  username               = databricks_secret.postgres_admin_user.string_value
  password               = databricks_secret.postgres_admin_password.string_value
  db_subnet_group_name   = var.subnet_group_name
  apply_immediately      = true
  vpc_security_group_ids = [var.security_group_id]
  skip_final_snapshot    = true
  publicly_accessible    = true
  multi_az               = false
}

# provider "postgresql" {
#   host            = aws_db_instance.postgres_for_databricks.address
#   scheme          = "awspostgres"
#   port            = 5432
#   username        = databricks_secret.postgres_admin_user.string_value
#   password        = databricks_secret.postgres_admin_password.string_value
#   sslmode         = "require"
#   connect_timeout = 15
#   superuser       = false
# }
#
# resource "postgresql_database" "sqlmesh_state" {
#   name = "sqlmesh_state"
# }
# resource "postgresql_database" "demo_data" {
#   name = "demo_data"
# }
#
# resource "postgresql_role" "sqlmesh_state_user" {
#   name     = databricks_secret.sqlmesh_state_user_secret.string_value
#   login    = true
#   password = databricks_secret.sqlmesh_state_password_secret.string_value
# }
#
# resource "postgresql_role" "demo_data_user" {
#   name     = databricks_secret.demo_data_user_secret.string_value
#   login    = true
#   password = databricks_secret.demo_data_password_secret.string_value
# }
#
#
#
#
# resource "postgresql_grant" "sqlmesh_state_user_grant" {
#   database    = postgresql_database.sqlmesh_state.name
#   role        = postgresql_role.sqlmesh_state_user.name
#   object_type = "database"
#   privileges  = ["ALL"]
# }
#
# resource "postgresql_grant" "demo_data_user_grant" {
#   database    = postgresql_database.demo_data.name
#   role        = postgresql_role.demo_data_user.name
#   object_type = "database"
#   privileges  = ["ALL"]
# }
