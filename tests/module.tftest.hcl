# Functional tests for the App Service overlay.
#
# These use mock_provider, so they execute WITHOUT Azure credentials and are
# safe to run on pull requests from forks in a public repository.
#
# Scope note: terraform validate proves only schema validity. These tests
# exercise the module's decision logic: naming precedence, conditional app
# families, tag merging, location passthrough, slots, locks, and runtime stack
# mapping into the azurerm 5.x replacement App Service resources.

mock_provider "azapi" {}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "anoa-eus-web-dev-generated"
    }
  }
}

mock_provider "azurerm" {
  mock_data "azurerm_client_config" {
    defaults = {
      tenant_id       = "00000000-0000-0000-0000-000000000000"
      subscription_id = "00000000-0000-0000-0000-000000000000"
      client_id       = "00000000-0000-0000-0000-000000000000"
      object_id       = "00000000-0000-0000-0000-000000000000"
    }
  }

  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg"
      name     = "existing-rg"
      location = "eastus"
    }
  }

  mock_data "azurerm_virtual_network" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg/providers/Microsoft.Network/virtualNetworks/app-vnet"
      name                = "app-vnet"
      resource_group_name = "existing-rg"
      location            = "eastus"
    }
  }

  mock_data "azurerm_subnet" {
    defaults = {
      id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg/providers/Microsoft.Network/virtualNetworks/app-vnet/subnets/private-endpoints"
      name                 = "private-endpoints"
      virtual_network_name = "app-vnet"
      resource_group_name  = "existing-rg"
    }
  }

  mock_data "azurerm_service_plan" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/existing-rg/providers/Microsoft.Web/serverFarms/existing-asp"
      name                = "existing-asp"
      resource_group_name = "existing-rg"
      location            = "eastus"
      os_type             = "Linux"
      sku_name            = "P1v3"
    }
  }
}

variables {
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "web"
  org_name                     = "anoa"
  existing_resource_group_name = "existing-rg"
  virtual_network_name         = "app-vnet"
  private_endpoint_subnet_name = "private-endpoints"
  app_service_plan_sku_name    = "P1v3"
  app_service_custom_name      = "explicit-web-app"
  app_service_plan_custom_name = "explicit-service-plan"

  windows_app_site_config = {
    always_on = true
    application_stack = {
      current_stack  = "dotnet"
      dotnet_version = "v8.0"
    }
    ftps_state             = "Disabled"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    websockets_enabled     = false
    use_32_bit_worker      = false
    vnet_route_all_enabled = true
  }

  linux_app_site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "8.0"
    }
    ftps_state             = "Disabled"
    http2_enabled          = true
    minimum_tls_version    = "1.2"
    websockets_enabled     = false
    vnet_route_all_enabled = true
  }

  windows_function_app_site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "v8.0"
    }
    ftps_state          = "Disabled"
    http2_enabled       = true
    minimum_tls_version = "1.2"
  }

  linux_function_app_site_config = {
    always_on = true
    application_stack = {
      dotnet_version = "8.0"
    }
    ftps_state          = "Disabled"
    http2_enabled       = true
    minimum_tls_version = "1.2"
  }
}

run "custom_names_override_generated_names" {
  command = plan

  assert {
    condition     = azurerm_windows_web_app.appService[0].name == "explicit-web-app"
    error_message = "app_service_custom_name must drive the azurerm_windows_web_app name."
  }

  assert {
    condition     = azurerm_service_plan.asp[0].name == "explicit-service-plan"
    error_message = "app_service_plan_custom_name must drive the azurerm_service_plan name."
  }
}

run "empty_custom_names_fall_through_to_generated_names" {
  command = plan

  variables {
    app_service_custom_name      = ""
    app_service_plan_custom_name = ""
  }

  assert {
    condition     = azurerm_windows_web_app.appService[0].name == "anoa-eus-web-dev-generated"
    error_message = "Empty app_service_custom_name must fall through to the generated name."
  }

  assert {
    condition     = azurerm_service_plan.asp[0].name == "anoa-eus-web-dev-generated"
    error_message = "Empty app_service_plan_custom_name must fall through to the generated name."
  }
}

run "windows_web_app_is_default_branch" {
  command = plan

  assert {
    condition     = length(azurerm_windows_web_app.appService) == 1
    error_message = "Default inputs should create one Windows web app."
  }

  assert {
    condition     = length(azurerm_linux_web_app.linuxapp) == 0
    error_message = "Default Windows web app inputs must not create a Linux web app."
  }

  assert {
    condition     = length(azurerm_windows_function_app.func) == 0 && length(azurerm_linux_function_app.func) == 0
    error_message = "App resource type must not create function apps."
  }

  assert {
    condition     = azurerm_windows_web_app.appService[0].site_config[0].application_stack[0].dotnet_version == "v8.0"
    error_message = "Existing windows_app_site_config input must drive the azurerm_windows_web_app replacement resource runtime stack."
  }
}

run "linux_web_app_branch_uses_linux_replacement_resource" {
  command = plan

  variables {
    app_service_plan_os_type = "Linux"
    deployment_slot_count    = 2
  }

  assert {
    condition     = length(azurerm_linux_web_app.linuxapp) == 1 && length(azurerm_windows_web_app.appService) == 0
    error_message = "Linux app inputs must create one azurerm_linux_web_app and no azurerm_windows_web_app."
  }

  assert {
    condition     = azurerm_service_plan.asp[0].os_type == "Linux"
    error_message = "app_service_plan_os_type must pass through to azurerm_service_plan.os_type."
  }

  assert {
    condition     = azurerm_linux_web_app.linuxapp[0].site_config[0].application_stack[0].dotnet_version == "8.0"
    error_message = "Existing linux_app_site_config input must drive the azurerm_linux_web_app replacement resource runtime stack."
  }

  assert {
    condition     = length(azurerm_linux_web_app_slot.slot) == 2
    error_message = "deployment_slot_count = 2 must create two Linux web app slots."
  }
}

run "linux_function_app_branch_uses_function_replacement_resource" {
  command = plan

  variables {
    app_service_plan_os_type  = "Linux"
    app_service_resource_type = "FunctionApp"
  }

  assert {
    condition     = length(azurerm_linux_function_app.func) == 1 && length(azurerm_linux_web_app.linuxapp) == 0
    error_message = "Linux FunctionApp inputs must create one azurerm_linux_function_app and no Linux web app."
  }

  assert {
    condition     = azurerm_linux_function_app.func[0].site_config[0].application_stack[0].dotnet_version == "8.0"
    error_message = "Existing linux_function_app_site_config input must drive the azurerm_linux_function_app replacement resource runtime stack."
  }
}

run "windows_function_app_branch_uses_function_replacement_resource" {
  command = plan

  variables {
    app_service_resource_type = "FunctionApp"
  }

  assert {
    condition     = length(azurerm_windows_function_app.func) == 1 && length(azurerm_windows_web_app.appService) == 0
    error_message = "Windows FunctionApp inputs must create one azurerm_windows_function_app and no Windows web app."
  }

  assert {
    condition     = azurerm_windows_function_app.func[0].site_config[0].application_stack[0].dotnet_version == "v8.0"
    error_message = "Existing windows_function_app_site_config input must drive the azurerm_windows_function_app replacement resource runtime stack."
  }
}

run "tags_and_location_are_passed_through" {
  command = plan

  variables {
    add_tags = {
      costCenter = "cc-1234"
    }
  }

  assert {
    condition     = azurerm_service_plan.asp[0].location == "eastus" && azurerm_windows_web_app.appService[0].location == "eastus"
    error_message = "location must pass through to the service plan and app resources."
  }

  assert {
    condition     = azurerm_service_plan.asp[0].tags["costCenter"] == "cc-1234" && azurerm_windows_web_app.appService[0].tags["costCenter"] == "cc-1234"
    error_message = "Caller-supplied add_tags must be merged into app service resources."
  }
}

run "resource_locks_are_conditionally_created" {
  command = plan

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 0
    error_message = "enable_resource_locks defaults to false, so no management lock should be planned."
  }
}

run "enabling_resource_locks_creates_one_lock" {
  command = plan

  variables {
    enable_resource_locks = true
    lock_level            = "ReadOnly"
  }

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 1
    error_message = "enable_resource_locks = true must create exactly one management lock."
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].lock_level == "ReadOnly"
    error_message = "lock_level input must be passed to the management lock."
  }
}
