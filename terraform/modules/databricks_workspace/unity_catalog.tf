resource "databricks_catalog" "demo_catalog" {
  provider = databricks.workspace
  name     = "sandbox_demo_catalog"
  comment  = "This catalog is managed by terraform"
  properties = {
    purpose = "Demoing catalog creation and management using Terraform"
  }

  depends_on = [
    databricks_group_member.my_service_principal,
    databricks_mws_permission_assignment.add_admin_group,
    databricks_group.users
  ]

  force_destroy = true

}

resource "databricks_connection" "postgres_sales" {
  provider        = databricks.workspace
  name            = "postgres_demo_sales_data"
  connection_type = "POSTGRESQL"
  owner           = databricks_group.postgres_connection_owners.display_name
  options = {
    host     = aws_db_instance.postgres_for_databricks.address
    port     = aws_db_instance.postgres_for_databricks.port
    user     = databricks_secret.demo_data_user_secret.string_value
    password = databricks_secret.demo_data_password_secret.string_value
  }
  depends_on = [databricks_group_member.postgres_connection_owners_group_member]
}

resource "databricks_grant" "postgres_connection_admins" {
  provider           = databricks.workspace
  foreign_connection = databricks_connection.postgres_sales.name

  principal  = databricks_group.users.display_name
  privileges = ["USE_CONNECTION"]
}

resource "databricks_catalog" "postgres_sales" {
  provider        = databricks.workspace
  owner           = databricks_group.admin_group.display_name
  name            = "postgres_demo_sales_data"
  connection_name = databricks_connection.postgres_sales.name
  options = {
    database = "demo_data"
  }
  depends_on = [
    databricks_group_member.my_service_principal,
    databricks_mws_permission_assignment.add_admin_group,
    databricks_group.users
  ]
}

resource "databricks_grants" "postgres_catalog" {
  provider = databricks.workspace
  catalog  = databricks_catalog.postgres_sales.name
  grant {
    principal  = databricks_group.users.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
  grant {
    principal  = databricks_service_principal.sales_data_generator_sp.application_id
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
  grant {
    principal  = databricks_service_principal.upstream_sp.application_id
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }

  depends_on = [
    databricks_mws_permission_assignment.add_user_group, databricks_catalog.postgres_sales
  ]

}

resource "databricks_catalog" "sales" {
  provider = databricks.workspace
  owner    = databricks_group.admin_group.display_name
  name     = "sales"
  depends_on = [
    databricks_mws_permission_assignment.add_admin_group,
    databricks_group.users
  ]
}

resource "databricks_grants" "sales_catalog_grants" {
  provider = databricks.workspace
  catalog  = databricks_catalog.sales.name
  grant {
    principal  = databricks_group.users.display_name
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
  grant {
    principal  = databricks_service_principal.upstream_sp.application_id
    privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
  }

}


resource "databricks_grants" "unity_catalog_grants" {
  provider = databricks.workspace
  catalog  = databricks_catalog.demo_catalog.name
  grant {
    principal  = local.workspace_users_group
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
  }
  grant {
    principal  = local.workspace_users_group
    privileges = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]

  }

  depends_on = [
    databricks_mws_permission_assignment.add_admin_group
  ]
}