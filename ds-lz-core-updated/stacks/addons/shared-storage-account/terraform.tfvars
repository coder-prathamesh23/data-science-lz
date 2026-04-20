spoke_subscription_id = "00000000-0000-0000-0000-000000000000"

core_remote_state = {
  enabled              = true
  resource_group_name  = "rg-tfstate-prod-shared"
  storage_account_name = "sttfstateprodshared01"
  container_name       = "tfstate"
  key                  = "stacks/data-science-lz-core/terraform.tfstate"
  use_azuread_auth     = true
}

storage_account_name              = "stdslzshareddevwestus301"
account_kind                      = "StorageV2"
account_tier                      = "Standard"
account_replication_type          = "LRS"
is_hns_enabled                    = true
min_tls_version                   = "TLS1_2"
public_network_access_enabled     = false
allow_nested_items_to_be_public   = false
shared_access_key_enabled         = true
default_to_oauth_authentication   = false
infrastructure_encryption_enabled = false
cross_tenant_replication_enabled  = false

enable_private_endpoints = true

blob_private_endpoint_name = "pe-stdslzshareddevwestus301-blob"
dfs_private_endpoint_name  = "pe-stdslzshareddevwestus301-dfs"

blob_private_dns_zone_ids = [
  # Paste the real zone ID provided by the networking team:
  # "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
]

dfs_private_dns_zone_ids = [
  # Paste the real zone ID provided by the networking team:
  # "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.dfs.core.windows.net"
]