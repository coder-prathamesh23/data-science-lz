location                     = "westus3"
resource_group_name          = "rg-core-dev-dslz-westus3"
allow_resource_group_destroy = false

spoke_subscription_id = "f956ebe7-509b-41be-8dc2-6310517151c1"
hub_subscription_id   = "a03e3bc7-4226-4e1c-a479-7db438c88052"

tags = {
  workorder  = "1198"
  costcenter = "143009534"
  owner1     = "clairelocke@pse.com"
  owner2     = "banjamin.ahlvin@pse.com"
}

# -------------------------------------
# Networking
# -------------------------------------
network_mode = "create"

spoke_vnet_name          = "vnet-spoke-dev-dslz-westus3"
spoke_vnet_address_space = ["10.91.3.0/26"]
spoke_vnet_dns_servers   = ["172.22.7.4"]

workload_subnet_name             = "snet-workload-dev-dslz-westus3"
workload_subnet_address_prefixes = ["10.91.3.0/27"]
private_endpoints_subnet_name             = "snet-pe-dev-dslz-westus3"
private_endpoints_subnet_address_prefixes = ["10.91.3.32/27"]

# -------------------------------------
# Hub connectivity
# -------------------------------------
enable_vhub_connection    = true
hub_virtual_hub_id        = "/subscriptions/a03e3bc7-4226-4e1c-a479-7db438c88052/resourceGroups/rg-hub-azuconnectivity-flz-westus3/providers/Microsoft.Network/virtualHubs/vwan-azuconnectivity-flz-westus3"
vhub_connection_name      = "conn-dslz-dev-westus3"
internet_security_enabled = true

# -------------------------------------
# AML baseline resources
# Log Analytics is the only piece intentionally left out for now.
# -------------------------------------
log_analytics = {
  enabled = false
  name    = ""
}

application_insights = {
  enabled          = true
  name             = "appi-core-dev-dslz-westus3"
  application_type = "web"
}

storage_account = {
  enabled                          = true
  name                             = "stds1zdevwestus301"
  account_replication_type         = "LRS"
  min_tls_version                  = "TLS1_2"
  public_network_access_enabled    = false
  shared_access_key_enabled        = true
  allow_nested_items_to_be_public  = false
}

container_registry = {
  enabled                       = true
  name                          = "crds1zdevwestus301"
  sku                           = "Premium"
  admin_enabled                 = true
  public_network_access_enabled = false
}

key_vault = {
  enabled                       = true
  name                          = "kv-sec-dev-dslz-wus3"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false
}

storage_account_private_endpoints = {
  enabled                      = true
  blob_private_endpoint_name   = "pe-stds1zdevwestus301-blob"
  file_private_endpoint_name   = "pe-stds1zdevwestus301-file"

  blob_private_dns_zone_ids = [
    # Paste the real central DNS zone ID here:
    "/subscriptions/a03e3bc7-4226-4e1c-a479-7db438c88052/resourceGroups/rg-hub-dns-azuconnectivity-flz-westus3/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  ]

  file_private_dns_zone_ids = [
    # Paste the real central DNS zone ID here:
    "/subscriptions/a03e3bc7-4226-4e1c-a479-7db438c88052/resourceGroups/rg-hub-dns-azuconnectivity-flz-westus3/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
  ]
}

shared_key_vault = {
  enabled                       = true
  name                          = "kv-app-dev-dslz-wus3"
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false
  rbac_authorization_enabled    = true
}

shared_key_vault_private_endpoint = {
  enabled               = true
  private_endpoint_name = "pe-kv-app-dev-dslz-wus3"
  private_dns_zone_ids = [
    # Paste the real central DNS zone ID here:
    "/subscriptions/a03e3bc7-4226-4e1c-a479-7db438c88052/resourceGroups/rg-hub-dns-azuconnectivity-flz-westus3/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
  ]
}