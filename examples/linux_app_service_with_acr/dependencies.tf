# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------
# Azure Region Lookup
#----------------------------------------------------------
module "mod_azure_region_lookup" {
  source  = "github.com/POps-Rox/tf-az-overlays-azregionslookup"

  azure_region = "eastus"
}

resource "azurerm_resource_group" "app-rg" {
  name     = "app-service-rg"
  location = module.mod_azure_region_lookup.location_cli
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_network" "app-vnet" {
  depends_on = [
    azurerm_resource_group.app-rg
  ]
  name                = "app-service-network"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.app-rg.name
  address_space       = ["10.0.0.0/16"]
  tags = {
    environment = "test"
  }
}

resource "azurerm_subnet" "app-snet" {
  depends_on = [
    azurerm_resource_group.app-rg,
    azurerm_virtual_network.app-vnet
  ]
  name                 = "app-service-subnet"
  resource_group_name  = azurerm_resource_group.app-rg.name
  virtual_network_name = azurerm_virtual_network.app-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "app-nsg" {
  depends_on = [
    azurerm_resource_group.app-rg,
  ]
  name                = "app-service-nsg"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.app-rg.name
  tags = {
    environment = "test"
  }
}

resource "azurerm_log_analytics_workspace" "app-log" {
  depends_on = [
    azurerm_resource_group.app-rg
  ]
  name                = "app-service-log"
  location            = module.mod_azure_region_lookup.location_cli
  resource_group_name = azurerm_resource_group.app-rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "test"
  }
}
