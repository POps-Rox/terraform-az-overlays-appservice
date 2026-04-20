# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
#------------------------------------------------------------
data "popsrox_utils_resource_name" "app_service_web" {
  name          = var.workload_name
  resource_type = "azurerm_app_service"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "web"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "app_service_plan" {
  name          = var.workload_name
  resource_type = "azurerm_app_service_plan"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "asp"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "application_insights" {
  name          = var.workload_name
  resource_type = "azurerm_application_insights"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "ai"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_utils_resource_name" "app_user_assigned_identity" {
  name          = var.workload_name
  resource_type = "azurerm_user_assigned_identity"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "uid"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
