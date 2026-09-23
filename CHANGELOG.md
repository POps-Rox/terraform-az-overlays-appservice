# Changelog

# v3.0.0 - azurerm 5.x upgrade

Changed
- Raised the root `azurerm` provider constraint from `~> 4.20` to
  `>= 5.0, < 6.0`; examples now pin `~> 5.6` for functional test stability.
- Repointed pinned sibling module sources to the azurerm 5.x `v3.0.0` tags.
- Kept examples pointed at the local module path (`../..`) so they validate the
  current checkout instead of the pre-migration tag.
- Removed the unsupported `ruby_version` argument from the
  `azurerm_linux_web_app` application stack for azurerm 5.x.
- Made the Key Vault access policy conditional on `create_app_keyvault` so the
  default no-Key-Vault plan remains valid.

Audited
- No removed App Service Terraform resource declarations are present in this
  module. The module already uses `azurerm_linux_web_app`,
  `azurerm_windows_web_app`, `azurerm_linux_function_app`,
  `azurerm_windows_function_app`, and `azurerm_service_plan`.
- No `azurerm_monitor_diagnostic_setting` resources are present.

Testing
- Added `terraform test` coverage using `mock_provider` for naming precedence,
  empty-string fallthrough, conditional App/WebApp branches, function branches,
  tag merging, location passthrough, deployment slots, locks, and azurerm 5.x
  replacement resource runtime-stack mapping.

# v2.0.0 - Phase 1 azurerm 4.x upgrade

Changed (BREAKING)
- Raised `required_version` from `>= 1.9` to `>= 1.10`
- Raised `azurerm` provider constraint from `~> 3.116` to `~> 4.20`
- Added `azapi ~> 2.0` to `required_providers` for fleet alignment
- All `examples/**/versions.tf` files updated with matching constraints

Audited (no code change needed)
- No `enable_https_traffic_only`, `allow_blob_public_access`, or
  `enable_rbac_authorization` usage in this module.
- No `private_endpoint_network_policies_enabled` (4.x bool→enum codemod) hits.
- No `azurerm_monitor_diagnostic_setting` resources, so no `retention_policy`
  block removals required.
- `azurerm_app_service` / `azurerm_app_service_plan` resources were already
  migrated to `azurerm_linux_web_app` / `azurerm_windows_web_app` /
  `azurerm_service_plan` in a prior 3.x maintenance pass. The literal strings
  `"azurerm_app_service"` and `"azurerm_app_service_plan"` in `naming.tf` are
  *resource_type lookup keys* into the `popsrox_resource_name` data source's
  naming convention map (controls the `web` / `asp` abbreviation), NOT
  declarations of those deprecated resources. They are intentionally retained.

Consumer-facing notes
- `azurerm` 4.x requires an explicit subscription (`ARM_SUBSCRIPTION_ID` env
  var or `subscription_id` in `provider "azurerm"`). Module repos don't
  declare a provider block, so this is a downstream concern.

# v1.0.1 - 2023-05-03

(Previous releases)

# v1.0.0 - 2023-05-03
