resource "databricks_service_principal" "downstream_sp" {
  provider                   = databricks.workspace
  display_name               = "Service principal for downstream job"
  workspace_access           = true
  allow_cluster_create       = true
  databricks_sql_access      = false
  allow_instance_pool_create = false
}

resource "databricks_secret_acl" "downstream_secret_acl" {
  provider   = databricks.workspace
  principal  = databricks_service_principal.downstream_sp.application_id
  permission = "READ"
  scope      = databricks_secret_scope.postgres_secrets.name
}

resource "databricks_access_control_rule_set" "downstream_acl" {
  provider = databricks.mws
  name     = "accounts/${var.databricks_account_id}/servicePrincipals/${databricks_service_principal.downstream_sp.application_id}/ruleSets/default"

  grant_rules {
    principals = [data.databricks_service_principal.terraform_user.acl_principal_id]
    role       = "roles/servicePrincipal.user"
  }
}

resource "databricks_job" "downstream_job" {
  depends_on  = [databricks_access_control_rule_set.downstream_acl, null_resource.update_databricks_repo]
  provider    = databricks.workspace
  name        = "Downstream Job"
  description = "Aggregations at a different frequency."
  queue {
    enabled = true
  }

  job_cluster {
    job_cluster_key = "j"
    new_cluster {
      data_security_mode = "SINGLE_USER"
      runtime_engine     = "PHOTON"
      num_workers        = 0
      instance_pool_id   = databricks_instance_pool.smallest_nodes.id
      spark_version      = data.databricks_spark_version.latest_photon.id
      spark_conf = {
        # Single-node
        "spark.databricks.cluster.profile" : "singleNode"
        "spark.master" : "local[*]"
        "spark.sql.parquet.compression.codec" : "zstd"
        "parquet.compression.codec.zstd.level" : "1"
      }

      custom_tags = {
        "ResourceClass" = "SingleNode"
      }
    }
  }

  task {
    task_key        = "a"
    job_cluster_key = "j"

    notebook_task {
      notebook_path = "${databricks_repo.this.path}/notebooks/sqlmesh_notebooks/run_sqlmesh_project"
      base_parameters = {
        "sqlmesh_project_path" = "${databricks_repo.this.workspace_path}/sqlmesh_projects/downstream"
      }
    }
  }
  run_as {
    service_principal_name = databricks_service_principal.downstream_sp.application_id
  }

}
