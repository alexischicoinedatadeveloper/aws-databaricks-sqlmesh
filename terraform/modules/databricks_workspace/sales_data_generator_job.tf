resource "databricks_service_principal" "sales_data_generator_sp" {
  provider                   = databricks.workspace
  display_name               = "Service principal for Sales Data Generator"
  workspace_access           = true
  allow_cluster_create       = true
  databricks_sql_access      = false
  allow_instance_pool_create = false
}

data "databricks_service_principal" "terraform_user" {
  provider       = databricks.workspace
  application_id = var.databricks_terraform_account_client_id
}

resource "databricks_secret_acl" "sales_data_generator_secret_acl" {
  provider   = databricks.workspace
  principal  = databricks_service_principal.sales_data_generator_sp.application_id
  permission = "READ"
  scope      = databricks_secret_scope.postgres_secrets.name
}

resource "databricks_access_control_rule_set" "sales_data_generator_acl" {
  provider = databricks.mws
  name     = "accounts/${var.databricks_account_id}/servicePrincipals/${databricks_service_principal.sales_data_generator_sp.application_id}/ruleSets/default"

  grant_rules {
    principals = [data.databricks_service_principal.terraform_user.acl_principal_id]
    role       = "roles/servicePrincipal.user"
  }
}

resource "databricks_job" "sales_data_generator_job" {
  depends_on  = [databricks_access_control_rule_set.sales_data_generator_acl, null_resource.update_databricks_repo]
  provider    = databricks.workspace
  name        = "Sales data generator"
  description = "This jobs add data in the postgres database."
  queue {
    enabled = true
  }

  job_cluster {
    job_cluster_key = "j"
    new_cluster {
      runtime_engine   = "STANDARD" # don't need photon to run regular python code
      num_workers      = 0
      instance_pool_id = databricks_instance_pool.smallest_nodes.id
      spark_version    = data.databricks_spark_version.latest_photon.id
      spark_conf = {
        # Single-node
        "spark.databricks.cluster.profile" : "singleNode"
        "spark.master" : "local[*]"
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
      notebook_path = "${databricks_repo.this.path}/notebooks/postgres_data_generation/sales_data_generator"
    }
  }
  run_as {
    service_principal_name = databricks_service_principal.sales_data_generator_sp.application_id
  }

}
