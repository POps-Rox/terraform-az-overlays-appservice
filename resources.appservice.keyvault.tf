# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_key_vault_access_policy" "app_access_policy" {
  depends_on = [
    module.mod_key_vault,
    azurerm_user_assigned_identity.app_identity
  ]
  count        = var.create_app_keyvault ? 1 : 0
  key_vault_id = module.mod_key_vault[0].key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}