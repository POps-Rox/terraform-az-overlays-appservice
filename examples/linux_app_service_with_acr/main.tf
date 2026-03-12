# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_app_service" {
  source = "../.." # Use this line if you are using the local module

  providers = {
    azurerm = azurerm
  }
  #source  = "github.com/POps-Rox/tf-az-overlays-appservice"
  #version = "x.x.x"

  depends_on = [azurerm_resource_group.app-rg]

  # By default, this module will create a resource group and 
  # provide a name for an existing resource group. If you wish 
  # to use an existing resource group, change the option 
  # to "create_sql_resource_group = false." The location of the group 
  # will remain the same if you use the current resource.
  existing_resource_group_name = azurerm_resource_group.app-rg.name
  location                     = module.mod_azure_region_lookup.location_cli
  environment                  = "public"
  deploy_environment           = "dev"
  org_name                     = "anoa"
  workload_name                = "lapp=acr"

  # App Service Plan Configuration
  create_app_service_plan       = true
  app_service_plan_sku_name     = "P1v2"
  app_service_resource_type     = "App"
  app_service_plan_os_type      = "Linux"
  deployment_slot_count         = 1
  website_run_from_package      = "1"
  app_service_plan_worker_count = 1

  # ACR Configuration
  create_app_container_registry = true
  enable_acr_private_endpoint   = true

  # Key Vault Configuration
  # Private Endpoint Configuration is done in the Key Vault Module
  create_app_keyvault          = true
  virtual_network_name         = azurerm_virtual_network.app-vnet.name
  private_endpoint_subnet_name = azurerm_subnet.app-snet.name

  # App Service Site Configuration
  linux_app_site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "6.0"
    }
    container_registry_use_managed_identity = true
    ftps_state                              = "Disabled"
    http2_enabled                           = true
    http_logging_enabled                    = true
    min_tls_version                         = "1.2"
    remote_debugging_enabled                = true
    websockets_enabled                      = false
  }

  add_tags = local.tags
}

