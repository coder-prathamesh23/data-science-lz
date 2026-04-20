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
    storage_account_name = var.storage_account_name
  }

  lifecycle {
    precondition {
      condition     = local.resolved_location != ""
      error_message = "location could not be resolved. Provide location directly or enable core_remote_state with a valid output."
    }

    precondition {
      condition     = local.resolved_resource_group_name != ""
      error_message = "resource_group_name could not be resolved. Provide resource_group_name directly or enable core_remote_state with a valid output."
    }

    precondition {
      condition     = var.storage_account_name != ""
      error_message = "storage_account_name must be set."
    }

    precondition {
      condition     = !var.enable_private_endpoints || local.resolved_private_endpoints_subnet_id != ""
      error_message = "enable_private_endpoints=true but private_endpoints_subnet_id could not be resolved."
    }
  }
}

module "shared_storage_account" {
  source = "../../../modules/addons/shared-storage-account"

  location            = local.resolved_location
  resource_group_name = local.resolved_resource_group_name
  tags                = local.resolved_tags

  storage_account_name              = var.storage_account_name
  account_kind                      = var.account_kind
  account_tier                      = var.account_tier
  account_replication_type          = var.account_replication_type
  is_hns_enabled                    = var.is_hns_enabled
  min_tls_version                   = var.min_tls_version
  public_network_access_enabled     = var.public_network_access_enabled
  allow_nested_items_to_be_public   = var.allow_nested_items_to_be_public
  shared_access_key_enabled         = var.shared_access_key_enabled
  default_to_oauth_authentication   = var.default_to_oauth_authentication
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled
  cross_tenant_replication_enabled  = var.cross_tenant_replication_enabled

  enable_private_endpoints    = var.enable_private_endpoints
  private_endpoints_subnet_id = local.resolved_private_endpoints_subnet_id
  blob_private_endpoint_name  = var.blob_private_endpoint_name
  dfs_private_endpoint_name   = var.dfs_private_endpoint_name
  blob_private_dns_zone_ids   = var.blob_private_dns_zone_ids
  dfs_private_dns_zone_ids    = var.dfs_private_dns_zone_ids

  depends_on = [terraform_data.input_checks]
}