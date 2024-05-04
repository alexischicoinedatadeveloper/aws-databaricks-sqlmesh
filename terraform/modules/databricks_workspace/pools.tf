data "databricks_spark_version" "latest_photon" {
  provider          = databricks.workspace
  latest            = true
  long_term_support = true
}

resource "databricks_instance_pool" "smallest_nodes" {
  provider           = databricks.workspace
  instance_pool_name = "Smallest Nodes"
  min_idle_instances = 0
  max_capacity       = 1
  node_type_id       = "m5d.large"
  aws_attributes {
    availability           = "SPOT"
    zone_id                = "us-east-1a"
    spot_bid_price_percent = "100"
  }
  idle_instance_autotermination_minutes = 60
  enable_elastic_disk                   = true
  preloaded_spark_versions              = [data.databricks_spark_version.latest_photon.id]

}

resource "databricks_permissions" "pool_usage" {
  provider         = databricks.workspace
  instance_pool_id = databricks_instance_pool.smallest_nodes.id

  access_control {
    service_principal_name = databricks_service_principal.sales_data_generator_sp.application_id
    permission_level       = "CAN_ATTACH_TO"
  }
  access_control {
    service_principal_name = databricks_service_principal.upstream_sp.application_id
    permission_level       = "CAN_ATTACH_TO"
  }
  access_control {
    service_principal_name = databricks_service_principal.downstream_sp.application_id
    permission_level       = "CAN_ATTACH_TO"
  }

}
