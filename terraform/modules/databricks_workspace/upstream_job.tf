resource "databricks_service_principal" "upstream_sp" {
  provider                   = databricks.workspace
  display_name               = "Service principal for upstream"
  workspace_access           = true
  allow_cluster_create       = true
  databricks_sql_access      = false
  allow_instance_pool_create = false
}

resource "databricks_secret_acl" "upstream_secret_acl" {
  provider   = databricks.workspace
  principal  = databricks_service_principal.upstream_sp.application_id
  permission = "READ"
  scope      = databricks_secret_scope.postgres_secrets.name
}

resource "databricks_secret_acl" "upstream_secret_acl_serverless" {
  provider   = databricks.workspace
  principal  = databricks_service_principal.upstream_sp.application_id
  permission = "READ"
  scope      = databricks_secret_scope.serverless_secrets.name
}

resource "databricks_access_control_rule_set" "upstream_acl" {
  provider = databricks.mws
  name     = "accounts/${var.databricks_account_id}/servicePrincipals/${databricks_service_principal.upstream_sp.application_id}/ruleSets/default"

  grant_rules {
    principals = [data.databricks_service_principal.terraform_user.acl_principal_id]
    role       = "roles/servicePrincipal.user"
  }
}

resource "databricks_job" "upstream_job" {
  depends_on  = [databricks_access_control_rule_set.upstream_acl, null_resource.update_databricks_repo]
  provider    = databricks.workspace
  name        = "Upstream Job"
  description = "This job ingests data from the postgres db."
  queue {
    enabled = true
  }


  task {
    task_key        = "a"

    notebook_task {
      notebook_path = "${databricks_repo.this.path}/notebooks/sqlmesh_notebooks/run_sqlmesh_project"
      base_parameters = {
        "sqlmesh_project_path" = "${databricks_repo.this.workspace_path}/sqlmesh_projects/upstream"
      }
    }
  }
  run_as {
    service_principal_name = databricks_service_principal.upstream_sp.application_id
  }

}
