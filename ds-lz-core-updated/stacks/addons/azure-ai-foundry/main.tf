data "terraform_remote_state" "core" {
  count   = var.core_remote_state.enabled ? 1 : 0
  backend = "azurerm"

  config = {
    resource_group_name  = var.core_remote_state.resource_group_name
    storage_account_name = var.core_remote_state.storage_account_name
    container_name       = var.core_remote_state.container_name
    key                  = var.core_remote_state.key
    use_azuread_auth     = try(var.core_remote_state.use_azuread_auth, true)
  }
}

locals {
  resolved_location                    = var.location != "" ? var.location : try(data.terraform_remote_state.core[0].outputs.location, "")
  resolved_resource_group_name         = var.resource_group_name != "" ? var.resource_group_name : try(data.terraform_remote_state.core[0].outputs.resource_group_name, "")
  resolved_tags                        = length(var.tags) > 0 ? var.tags : try(data.terraform_remote_state.core[0].outputs.tags, {})
  resolved_private_endpoints_subnet_id = var.private_endpoints_subnet_id != "" ? var.private_endpoints_subnet_id : try(data.terraform_remote_state.core[0].outputs.private_endpoints_subnet_id, "")
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
      condition     = local.resolved_location != ""
      error_message = "location could not be resolved. Provide location directly or enable core_remote_state with a valid output."
    }

    precondition {
      condition     = local.resolved_resource_group_name != ""
      error_message = "resource_group_name could not be resolved. Provide resource_group_name directly or enable core_remote_state with a valid output."
    }

    precondition {
      condition     = var.enable_private_endpoint ? local.resolved_private_endpoints_subnet_id != "" : true
      error_message = "enable_private_endpoint=true but private_endpoints_subnet_id could not be resolved."
    }

    precondition {
      condition     = var.enable_private_endpoint ? length(var.private_dns_zone_ids) > 0 : true
      error_message = "enable_private_endpoint=true but private_dns_zone_ids is empty."
    }
  }
}

module "azure_ai_foundry" {
  source = "../../../modules/addons/azure-ai-foundry"

  location            = local.resolved_location
  resource_group_name = local.resolved_resource_group_name
  tags                = local.resolved_tags

  foundry_name                  = var.foundry_name
  foundry_sku_name              = var.foundry_sku_name
  custom_subdomain_name         = var.custom_subdomain_name
  project_management_enabled    = var.project_management_enabled
  disable_local_auth            = var.disable_local_auth
  public_network_access_enabled = var.public_network_access_enabled
  foundry_project               = var.foundry_project

  private_endpoints_subnet_id        = local.resolved_private_endpoints_subnet_id
  enable_private_endpoint            = var.enable_private_endpoint
  private_endpoint_name              = var.private_endpoint_name
  private_endpoint_subresource_names = var.private_endpoint_subresource_names
  private_dns_zone_ids               = var.private_dns_zone_ids

  depends_on = [terraform_data.input_checks]
}