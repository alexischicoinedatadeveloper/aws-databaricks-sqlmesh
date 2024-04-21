resource "databricks_repo" "this" {
  provider = databricks.workspace
  url      = "https://github.com/alexischicoinedatadeveloper/aws-databaricks-sqlmesh.git"
  path     = var.workspace_repo_path
}

resource "databricks_permissions" "repo_usage" {
  provider = databricks.workspace
  repo_id  = databricks_repo.this.id

  access_control {
    permission_level       = "CAN_READ"
    service_principal_name = databricks_service_principal.sales_data_generator_sp.application_id
  }
}

resource "databricks_git_credential" "sp" {
  provider              = databricks.workspace
  git_username          = var.github_user
  git_provider          = "gitHub"
  personal_access_token = var.github_token
  force                 = true
}

resource "databricks_obo_token" "this" {
  provider         = databricks.workspace
  application_id   = var.databricks_terraform_account_client_id
  lifetime_seconds = 3600
}

resource "null_resource" "update_databricks_repo" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = <<EOF
      pip install databricks-cli
      databricks configure --host "${var.databricks_host}" --token --profile workspace_repo_update <<< "${databricks_obo_token.this.token_value}"
      databricks --profile workspace_repo_update repos update "${databricks_repo.this.path}" --branch "main" &> /tmp/databricks_repos_update.log
EOF
    interpreter = ["/bin/bash", "-c"]
  }
}
