
resource "postgresql_database" "sqlmesh_state" {
  provider = postgresql
  name     = "sqlmesh_state"
}
resource "postgresql_database" "demo_data" {
  provider = postgresql
  name     = "demo_data"
}

resource "postgresql_role" "sqlmesh_state_user" {
  provider = postgresql
  name     = var.sqlmesh_state_user_secret
  login    = true
  password = var.sqlmesh_state_password_secret
}

resource "postgresql_role" "demo_data_user" {
  provider = postgresql
  name     = var.demo_data_user_secret
  login    = true
  password = var.demo_data_password_secret
}

resource "postgresql_grant" "sqlmesh_state_user_grant" {
  provider    = postgresql
  database    = postgresql_database.sqlmesh_state.name
  role        = postgresql_role.sqlmesh_state_user.name
  object_type = "database"
  privileges  = ["ALL"]
}

resource "postgresql_grant" "demo_data_user_grant" {
  provider    = postgresql
  database    = postgresql_database.demo_data.name
  role        = postgresql_role.demo_data_user.name
  object_type = "database"
  privileges  = ["ALL"]
}
