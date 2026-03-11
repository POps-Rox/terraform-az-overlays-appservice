# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_key_vault" {
  depends_on = [
    azurerm_user_assigned_identity.app_identity
  ]
  source                       = "github.com/POps-Rox/tf-az-overlays-keyvault"
  version                      = "~> 2.0"
  count                        = var.create_app_keyvault ? 1 : 0
  existing_resource_group_name = local.resource_group_name
  location                     = local.location
  environment                  = var.environment
  deploy_environment           = var.deploy_environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # Creating Private Endpoint requires, VNet name to create a Private Endpoint
  # By default this will create a `privatelink.vaultcore.azure.net` DNS zone. if created in commercial cloud
  # To use existing subnet, specify `existing_private_subnet_name` with valid subnet name. 
  # To use existing private DNS zone specify `existing_private_dns_zone` with valid zone name.
  enable_private_endpoint      = var.create_app_keyvault
  virtual_network_name         = data.azurerm_virtual_network.pe_vnet.name
  existing_private_dns_zone    = var.existing_keyvault_private_dns_zone != null ? var.existing_keyvault_private_dns_zone : null
  existing_private_subnet_name = data.azurerm_subnet.pe_subnet.name

  # Current user should be here to be able to create keys and secrets
  #admin_objects_ids = [
  #  data.azuread_group.admin_group.id
  #]

  # This is to enable resource locks for the key vault. 
  enable_resource_locks = var.enable_resource_locks

  # Tags for Azure Resources
  add_tags = merge(var.add_tags, local.default_tags)
}
