# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_container_registry" {
  source                       = "github.com/POps-Rox/tf-az-overlays-containerregistry"
  count                        = var.create_app_container_registry ? 1 : 0
  existing_resource_group_name = local.resource_group_name
  location                     = local.location
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name
  sku                          = var.acr_sku

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_private_subnet_name` with valid subnet name. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name. 
  enable_private_endpoint       = var.enable_acr_private_endpoint
  virtual_network_name          = data.azurerm_virtual_network.pe_vnet.name
  existing_private_dns_zone     = var.existing_acr_private_dns_zone
  existing_private_subnet_name  = data.azurerm_subnet.pe_subnet.name
  public_network_access_enabled = false

  # This is to enable resource locks for the key vault. 
  enable_resource_locks = var.enable_resource_locks
}
