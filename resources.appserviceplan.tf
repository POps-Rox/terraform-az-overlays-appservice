# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_service_plan" "asp" {
  count                      = var.create_app_service_plan && var.existing_app_service_plan_name == null ? 1 : 0
  name                       = local.app_service_plan_name
  location                   = local.location
  resource_group_name        = local.resource_group_name
  os_type                    = var.app_service_plan_os_type
  app_service_environment_id = var.enable_app_service_environment == false ? null : data.azurerm_app_service_environment_v3.ase.0.id

  sku_name     = var.app_service_plan_sku_name
  worker_count = var.app_service_plan_worker_count
  tags         = merge(var.add_tags, local.default_tags)
}
