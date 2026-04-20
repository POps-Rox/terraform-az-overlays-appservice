<!-- BADGES:START -->
[![CI](https://github.com/POps-Rox/tf-az-overlays-appservice/actions/workflows/ci.yml/badge.svg)](https://github.com/POps-Rox/tf-az-overlays-appservice/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/POps-Rox/tf-az-overlays-appservice/pulls)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/POps-Rox/tf-az-overlays-appservice/graphs/commit-activity)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4.svg?logo=terraform)](https://www.terraform.io)
<!-- BADGES:END -->

# Azure App Service Web (Linux or Windows) Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/POps-Rox/overlays-app-service/azurerm/)

This Overlay terraform module can create a an Azure Service Plan with a an Azure App Service Web/Function (Linux or Windows) associated with an Application Insights component and manage related parameters (Private Endpoints, etc.) to be used in a [SCCA compliant Network](https://registry.terraform.io/modules/POps-Rox/overlays-management-hub/azurerm/latest).

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation]("https://www.cisa.gov/secure-cloud-computing-architecture").

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## Resources Used

* [Azure App Service Plan](https://www.terraform.io/docs/providers/azurerm/r/app_service_plan.html)
* [Azure App Service Web (Linux or Windows)](https://www.terraform.io/docs/providers/azurerm/r/app_service.html)
* [Azure App Service Function (Linux or Windows)](https://www.terraform.io/docs/providers/azurerm/r/app_service.html#app_settings)
* [Azure Application Insights](https://www.terraform.io/docs/providers/azurerm/r/application_insights.html)
* [Azure App Service Slot](https://www.terraform.io/docs/providers/azurerm/r/app_service_slot.html)
* [Private Endpoints](https://www.terraform.io/docs/providers/azurerm/r/private_endpoint.html)
* [Private DNS zone for `privatelink` A records](https://www.terraform.io/docs/providers/azurerm/r/private_dns_zone.html)
* [Azure Reource Locks](https://www.terraform.io/docs/providers/azurerm/r/management_lock.html)

## Overlay Module Usage

```terraform
# Azurerm Provider configuration
provider "azurerm" {
  features {}
}

module "app_service" {
  source  = "POps-Rox/tf-az-overlays-app-service/azurerm"
  version = "x.x.x"

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
  workload_name                = "lapp"

  # App Service Plan Configuration
  create_app_service_plan       = true
  app_service_name              = "linux-app-service-anoa-dev"
  app_service_plan_sku_name     = "I1v2"
  app_service_resource_type     = "App"
  app_service_plan_os_type      = "Linux"
  deployment_slot_count         = 1
  website_run_from_package      = "1"
  app_service_plan_worker_count = 1

  # Key Vault Configuration
  create_app_keyvault = true

  # App Service Site Configuration
  linux_app_site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "6.0"
    }
    ftps_state                              = "Disabled"
    http2_enabled                           = true
    http_logging_enabled                    = true
    min_tls_version                         = "1.2"
    remote_debugging_enabled                = true
    websockets_enabled                      = false
  }

  add_tags = {
    foo = "basic deployment of app service"
  }
}
```

## Resource Group

By default, this module will not create a resource group and the name of an existing resource group to be given in an argument `existing_resource_group_name`. If you want to create a new resource group, set the argument `create_app_resource_group = true`.

> [!NOTE]
> *If you are using an existing resource group, then this module uses the same resource group location to create all resources in this module.*

## Recommended naming and tagging conventions

Applying tags to your Azure resources, resource groups, and subscriptions to logically organize them into a taxonomy. Each tag consists of a name and a value pair. For example, you can apply the name `Environment` and the value `Production` to all the resources in production.
For recommendations on how to implement a tagging strategy, see Resource naming and tagging decision guide.

> [!IMPORTANT]
> Tag names are case-insensitive for operations. A tag with a tag name, regardless of the casing, is updated or retrieved. However, the resource provider might keep the casing you provide for the tag name. You'll see that casing in cost reports. **Tag values are case-sensitive.**

An effective naming convention assembles resource names by using important resource information as parts of a resource's name. For example, using these [recommended naming conventions](https://docs.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging#example-names), a public IP resource for a production SharePoint workload is named like this: `pip-sharepoint-prod-westus-001`.

<!-- BEGIN_TF_DOCS -->

<!-- END_TF_DOCS -->