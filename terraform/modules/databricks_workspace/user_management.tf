data "databricks_service_principal" "admin_service_principal" {
  provider       = databricks.mws
  application_id = var.databricks_terraform_account_client_id
}

resource "databricks_user" "unity_users" {
  provider  = databricks.mws
  for_each  = toset(concat(var.databricks_users, var.databricks_metastore_admins))
  user_name = each.key
  force     = true
}

resource "databricks_group" "admin_group" {
  provider     = databricks.mws
  display_name = local.unity_admin_group
}

resource "databricks_group" "users" {
  provider     = databricks.mws
  display_name = local.workspace_users_group
  depends_on   = [databricks_group.admin_group]
}

resource "databricks_group" "postgres_connection_owners" {
  provider     = databricks.mws
  display_name = "postgres_connection_owners"
}

resource "databricks_group_member" "postgres_connection_owners_group_member" {
  provider  = databricks.mws
  for_each  = toset([databricks_group.admin_group.id, databricks_service_principal.upstream_sp.id])
  group_id  = databricks_group.postgres_connection_owners.id
  member_id = each.value
  depends_on = [
    databricks_group_member.admin_group_member
  ]
}

resource "databricks_group_member" "admin_group_member" {
  provider  = databricks.mws
  for_each  = toset(var.databricks_metastore_admins)
  group_id  = databricks_group.admin_group.id
  member_id = databricks_user.unity_users[each.value].id
}

resource "databricks_group_member" "my_service_principal" {
  provider  = databricks.mws
  group_id  = databricks_group.admin_group.id
  member_id = data.databricks_service_principal.admin_service_principal.id
}


resource "databricks_group_member" "users_group_members" {
  provider  = databricks.mws
  for_each  = toset(var.databricks_users)
  group_id  = databricks_group.users.id
  member_id = databricks_user.unity_users[each.value].id
}
resource "databricks_mws_permission_assignment" "add_user_group" {
  provider     = databricks.mws
  workspace_id = var.workspace_id
  principal_id = databricks_group.users.id
  permissions  = ["USER"]
  depends_on = [
    time_sleep.wait_for_permission_apis
  ]
}
# Sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_for_permission_apis" {
  create_duration = "20s"
}

resource "databricks_mws_permission_assignment" "add_admin_group" {
  provider     = databricks.mws
  workspace_id = var.workspace_id
  principal_id = databricks_group.admin_group.id
  permissions  = ["ADMIN"]
  depends_on = [
    time_sleep.wait_for_permission_apis
  ]
}

resource "databricks_grant" "admin_metastore_grants" {
  provider   = databricks.workspace
  metastore  = var.metastore_id
  principal  = databricks_group.admin_group.display_name
  privileges = ["CREATE_CATALOG"]
}
