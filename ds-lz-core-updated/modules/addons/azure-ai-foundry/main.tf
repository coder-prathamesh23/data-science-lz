data "azurerm_resource_group" "current" {
  name = var.resource_group_name
}

resource "terraform_data" "input_checks" {
  input = {
    foundry_name = var.foundry_name
  }

  lifecycle {
    precondition {
      condition     = var.foundry_name != ""
      error_message = "foundry_name must be set."
    }

    precondition {
      condition     = var.custom_subdomain_name != ""
      error_message = "custom_subdomain_name must be set."
    }

    precondition {
      condition     = var.enable_private_endpoint ? var.private_endpoints_subnet_id != "" : true
      error_message = "enable_private_endpoint=true but private_endpoints_subnet_id is empty."
    }

    precondition {
      condition     = var.enable_private_endpoint ? length(var.private_dns_zone_ids) > 0 : true
      error_message = "enable_private_endpoint=true but private_dns_zone_ids is empty."
    }

    precondition {
      condition = (
        !var.foundry_project.enabled
        || (
          var.foundry_project.name != "" &&
          var.foundry_project.display_name != "" &&
          var.foundry_project.description != ""
        )
      )
      error_message = "If foundry_project.enabled=true, then name, display_name, and description must be set."
    }
  }
}

locals {
  resolved_private_endpoint_name = var.private_endpoint_name != "" ? var.private_endpoint_name : "pe-${var.foundry_name}"
}

resource "azapi_resource" "foundry" {
  type      = "Microsoft.CognitiveServices/accounts@2025-06-01"
  name      = var.foundry_name
  parent_id = data.azurerm_resource_group.current.id
  location  = var.location
  tags      = var.tags

  identity {
    type = "SystemAssigned"
  }

  body = {
    kind = "AIServices"

    sku = {
      name = var.foundry_sku_name
    }

    properties = {
      allowProjectManagement = var.project_management_enabled
      customSubDomainName    = var.custom_subdomain_name
      disableLocalAuth       = var.disable_local_auth
      publicNetworkAccess    = var.public_network_access_enabled ? "Enabled" : "Disabled"
    }
  }

  schema_validation_enabled = false
  response_export_values    = ["identity.principalId"]

  depends_on = [terraform_data.input_checks]
}

resource "azapi_resource" "foundry_project" {
  count     = var.foundry_project.enabled ? 1 : 0
  type      = "Microsoft.CognitiveServices/accounts/projects@2025-06-01"
  name      = var.foundry_project.name
  parent_id = azapi_resource.foundry.id
  location  = var.location

  identity {
    type = "SystemAssigned"
  }

  body = {
    sku = {
      name = var.foundry_project.sku_name
    }

    properties = {
      displayName = var.foundry_project.display_name
      description = var.foundry_project.description
    }
  }

  schema_validation_enabled = false
  response_export_values    = ["identity.principalId"]
}

resource "azurerm_private_endpoint" "foundry" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = local.resolved_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.resolved_private_endpoint_name
    private_connection_resource_id = azapi_resource.foundry.id
    is_manual_connection           = false
    subresource_names              = var.private_endpoint_subresource_names
  }

  private_dns_zone_group {
    name                 = "foundry-dns"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  depends_on = [azapi_resource.foundry]
}