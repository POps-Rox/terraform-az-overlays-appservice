# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_application_insights" "app_service_app_insights" {
  count               = var.enable_application_insights ? 1 : 0
  location            = local.location
  name                = local.app_service_app_insights_name
  workspace_id        = var.log_analytics_workspace_id
  resource_group_name = local.resource_group_name
  application_type    = "web"

  tags = merge(var.add_tags, local.default_tags)
}