resource "databricks_secret_scope" "postgres_secrets" {
  provider = databricks.workspace
  name     = "postgres_secrets"
}



resource "databricks_secret" "postgres_admin_user" {
  provider     = databricks.workspace
  key          = "postgres_admin_user"
  string_value = random_string.postgres_admin_user.result
  scope        = databricks_secret_scope.postgres_secrets.id
}

resource "databricks_secret" "postgres_admin_password" {
  provider     = databricks.workspace
  key          = "postgres_admin_password"
  string_value = random_password.postgres_admin_pw.result
  scope        = databricks_secret_scope.postgres_secrets.id
}

resource "databricks_secret" "sqlmesh_state_user_secret" {
  provider     = databricks.workspace
  key          = "sqlmesh_state_user"
  string_value = random_string.sqlmesh_state_user.result
  scope        = databricks_secret_scope.postgres_secrets.id
}

resource "databricks_secret" "sqlmesh_state_password_secret" {
  provider     = databricks.workspace
  key          = "sqlmesh_state_password"
  string_value = random_password.sqlmesh_state_password.result
  scope        = databricks_secret_scope.postgres_secrets.id
}

resource "databricks_secret" "demo_data_user_secret" {
  provider     = databricks.workspace
  key          = "demo_data_user"
  string_value = random_string.demo_data_user.result
  scope        = databricks_secret_scope.postgres_secrets.id
}

resource "databricks_secret" "demo_data_password_secret" {
  provider     = databricks.workspace
  key          = "demo_data_password"
  string_value = random_password.demo_data_password.result
  scope        = databricks_secret_scope.postgres_secrets.id
}
