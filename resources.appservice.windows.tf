# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_windows_web_app" "appService" {
  depends_on = [
    azurerm_service_plan.asp,
    azurerm_application_insights.app_service_app_insights,
    azurerm_user_assigned_identity.app_identity
  ]
  count               = var.app_service_plan_os_type == "Windows" && var.app_service_resource_type == "App" ? 1 : 0
  name                = local.app_service_name
  resource_group_name = local.resource_group_name
  location            = local.location
  service_plan_id     = var.create_app_service_plan == false && var.existing_app_service_plan_name != null ? data.azurerm_service_plan.existing_asp.0.id : azurerm_service_plan.asp.0.id

  key_vault_reference_identity_id = azurerm_user_assigned_identity.app_identity.id
  site_config {
    always_on             = var.windows_app_site_config.always_on
    api_definition_url    = var.windows_app_site_config.api_definition_url
    api_management_api_id = var.windows_app_site_config.api_management_api_id
    app_command_line      = var.windows_app_site_config.app_command_line
    application_stack {
      current_stack                = var.windows_app_site_config.application_stack.current_stack
      docker_container_name        = var.windows_app_site_config.application_stack.docker_container_name
      docker_container_registry    = var.create_app_container_registry ? module.mod_container_registry.0.login_server : var.windows_app_site_config.application_stack.docker_container_registry
      docker_container_tag         = var.windows_app_site_config.application_stack.docker_container_tag
      dotnet_version               = var.windows_app_site_config.application_stack.dotnet_version
      dotnet_core_version          = var.windows_app_site_config.application_stack.dotnet_core_version
      tomcat_version               = var.windows_app_site_config.application_stack.tomcat_version
      java_embedded_server_enabled = var.windows_app_site_config.application_stack.java_embedded_server_enabled
      java_version                 = var.windows_app_site_config.application_stack.java_version
      node_version                 = var.windows_app_site_config.application_stack.node_version
      php_version                  = var.windows_app_site_config.application_stack.php_version
      python                       = var.windows_app_site_config.application_stack.python
    }
    container_registry_managed_identity_client_id = var.windows_app_site_config.container_registry_use_managed_identity == true ? azurerm_user_assigned_identity.app_identity.principal_id : null
    container_registry_use_managed_identity       = var.windows_app_site_config.container_registry_use_managed_identity
    cors {
      allowed_origins     = var.windows_app_site_config.cors == null ? null : var.windows_app_site_config.cors.allowed_origins
      support_credentials = var.windows_app_site_config.cors == null ? null : var.windows_app_site_config.cors.support_credentials
    }
    default_documents                 = var.windows_app_site_config.default_documents
    ftps_state                        = var.windows_app_site_config.ftps_state
    health_check_path                 = var.windows_app_site_config.health_check_path
    health_check_eviction_time_in_min = var.windows_app_site_config.health_check_eviction_time_in_min
    http2_enabled                     = var.windows_app_site_config.http2_enabled
    #ip_restriction                   //todo
    load_balancing_mode      = var.windows_app_site_config.load_balancing_mode
    local_mysql_enabled      = var.windows_app_site_config.local_mysql_enabled
    managed_pipeline_mode    = var.windows_app_site_config.managed_pipeline_mode
    minimum_tls_version      = var.windows_app_site_config.minimum_tls_version
    remote_debugging_enabled = var.windows_app_site_config.remote_debugging_enabled
    remote_debugging_version = var.windows_app_site_config.remote_debugging_version
    #scm_ip_restriction               //todo
    scm_minimum_tls_version     = var.windows_app_site_config.scm_minimum_tls_version
    scm_use_main_ip_restriction = var.windows_app_site_config.scm_use_main_ip_restriction
    use_32_bit_worker           = var.windows_app_site_config.use_32_bit_worker
    #virtual_application        //todo
    vnet_route_all_enabled = var.windows_app_site_config.vnet_route_all_enabled
    websockets_enabled     = var.windows_app_site_config.websockets_enabled
    worker_count           = var.windows_app_site_config.worker_count
  }

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.app_service_app_insights[0].instrumentation_key
    APPINSIGHTS_CONNECTION_STRING  = azurerm_application_insights.app_service_app_insights[0].connection_string
    WEBSITE_RUN_FROM_PACKAGE       = var.website_run_from_package
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.app_identity.id
    ]
  }
  tags = merge(var.add_tags, local.default_tags)
}

resource "azurerm_windows_web_app_slot" "slot" {
  depends_on = [
    azurerm_windows_web_app.appService
  ]
  count          = var.app_service_plan_os_type == "Windows" && var.app_service_resource_type == "App" ? var.deployment_slot_count : 0
  name           = var.deployment_slot_count == 1 ? "${local.app_service_name}-slot-1" : "${local.app_service_name}-slot-${count.index + 1}"
  app_service_id = azurerm_windows_web_app.appService[0].id

  site_config {}
}
