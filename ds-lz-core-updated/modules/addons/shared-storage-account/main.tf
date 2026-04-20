locals {
  resolved_blob_private_endpoint_name = var.blob_private_endpoint_name != "" ? var.blob_private_endpoint_name : "pe-${var.storage_account_name}-blob"
  resolved_dfs_private_endpoint_name  = var.dfs_private_endpoint_name  != "" ? var.dfs_private_endpoint_name  : "pe-${var.storage_account_name}-dfs"
}

resource "terraform_data" "input_checks" {
  input = {
    storage_account_name = var.storage_account_name
  }

  lifecycle {
    precondition {
      condition     = var.storage_account_name != ""
      error_message = "storage_account_name must be set."
    }

    precondition {
      condition     = var.is_hns_enabled
      error_message = "Shared AML/Fabric storage account must have HNS enabled."
    }

    precondition {
      condition     = !var.enable_private_endpoints || var.private_endpoints_subnet_id != ""
      error_message = "enable_private_endpoints=true but private_endpoints_subnet_id is empty."
    }

    precondition {
      condition     = !var.enable_private_endpoints || length(var.blob_private_dns_zone_ids) > 0
      error_message = "enable_private_endpoints=true but blob_private_dns_zone_ids is empty."
    }

    precondition {
      condition     = !var.enable_private_endpoints || length(var.dfs_private_dns_zone_ids) > 0
      error_message = "enable_private_endpoints=true but dfs_private_dns_zone_ids is empty."
    }
  }
}

resource "azurerm_storage_account" "this" {
  name                              = var.storage_account_name
  location                          = var.location
  resource_group_name               = var.resource_group_name

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

  tags = var.tags

  depends_on = [terraform_data.input_checks]
}

resource "azurerm_private_endpoint" "blob" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = local.resolved_blob_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.resolved_blob_private_endpoint_name
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  private_dns_zone_group {
    name                 = "blob-dns"
    private_dns_zone_ids = var.blob_private_dns_zone_ids
  }

  depends_on = [azurerm_storage_account.this]
}

resource "azurerm_private_endpoint" "dfs" {
  count               = var.enable_private_endpoints ? 1 : 0
  name                = local.resolved_dfs_private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoints_subnet_id

  private_service_connection {
    name                           = local.resolved_dfs_private_endpoint_name
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["dfs"]
  }

  private_dns_zone_group {
    name                 = "dfs-dns"
    private_dns_zone_ids = var.dfs_private_dns_zone_ids
  }

  depends_on = [azurerm_storage_account.this]
}