resource "databricks_sql_endpoint" "small_serverless" {
    provider     = databricks.workspace
    name = "Small Serverless"
    cluster_size = "2X-Small"
    auto_stop_mins = 1
    enable_serverless_compute = true
}

resource "databricks_permissions" "serverless_usage" {
    provider = databricks.workspace
    sql_endpoint_id = databricks_sql_endpoint.small_serverless.id

    access_control {
        group_name       = databricks_group.admin_group.display_name
        permission_level = "CAN_USE"
    }

    access_control {
        service_principal_name = databricks_service_principal.sales_data_generator_sp.application_id
        permission_level       = "CAN_USE"
    }
    access_control {
        service_principal_name = databricks_service_principal.upstream_sp.application_id
        permission_level       = "CAN_USE"
    }
    access_control {
        service_principal_name = databricks_service_principal.downstream_sp.application_id
        permission_level       = "CAN_USE"
    }

}