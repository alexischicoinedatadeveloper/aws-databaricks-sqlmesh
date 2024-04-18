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