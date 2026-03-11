# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_storage_account" {
  source                       = "github.com/POps-Rox/tf-az-overlays-storageaccount"
  count                        = var.app_service_resource_type == "FunctionApp" ? 1 : 0
  location                     = local.location
  existing_resource_group_name = local.resource_group_name
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  workload_name                = var.workload_name
  org_name                     = var.org_name

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.blob.core.azure.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_private_subnet_name` with valid subnet name. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.  
  enable_blob_private_endpoint = var.app_service_resource_type == "FunctionApp" ? true : false
  virtual_network_name         = data.azurerm_virtual_network.pe_vnet.name
  existing_private_dns_zone    = var.existing_storage_private_dns_zone != null ? var.existing_storage_private_dns_zone : null
  existing_private_subnet_name = data.azurerm_subnet.pe_subnet.name

  # This is to enable resource locks for the key vault. 
  enable_resource_locks = var.enable_resource_locks
}
