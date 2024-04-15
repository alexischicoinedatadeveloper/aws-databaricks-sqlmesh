resource "databricks_metastore" "this" {
  provider      = databricks.mws
  name          = local.metastore_name
  region        = var.region
  owner         = var.databricks_terraform_account_client_id
  storage_root  = "s3://${aws_s3_bucket.root_storage_bucket.id}/metastore"
  force_destroy = true
  depends_on = [
    databricks_mws_workspaces.this
  ]
}


resource "databricks_metastore_data_access" "this" {
  provider     = databricks.mws
  metastore_id = databricks_metastore.this.id
  name         = aws_iam_role.metastore_data_access.name
  aws_iam_role {
    role_arn = aws_iam_role.metastore_data_access.arn
  }
  is_default = true
  depends_on = [
    time_sleep.wait_role_creation
  ]
}

# Sleeping for 20s to wait for the workspace to enable identity federation
resource "time_sleep" "wait_role_creation" {
  depends_on = [
    aws_iam_role.metastore_data_access,
    databricks_metastore.this
  ]
  create_duration = "20s"
}

resource "databricks_metastore_assignment" "default_metastore" {
  provider             = databricks.mws
  count                = 1
  workspace_id         = databricks_mws_workspaces.this.workspace_id
  metastore_id         = databricks_metastore.this.id
  default_catalog_name = "hive_metastore"
}