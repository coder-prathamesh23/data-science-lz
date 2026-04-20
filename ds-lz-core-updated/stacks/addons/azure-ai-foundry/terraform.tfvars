spoke_subscription_id = "00000000-0000-0000-0000-000000000000"

core_remote_state = {
  enabled              = true
  resource_group_name  = "rg-tfstate-prod-shared"
  storage_account_name = "sttfstateprodshared01"
  container_name       = "tfstate"
  key                  = "stacks/data-science-lz-core/terraform.tfstate"
  use_azuread_auth     = true
}

foundry_name                  = "aif-dev-dslz-westus3"
foundry_sku_name              = "S0"
custom_subdomain_name         = "aif-dev-dslz-westus3"
project_management_enabled    = true
disable_local_auth            = false
public_network_access_enabled = false

foundry_project = {
  enabled      = true
  name         = "aifproj-dev-dslz-westus3"
  display_name = "aifproj-dev-dslz-westus3"
  description  = "Azure AI Foundry project for DSLZ Dev"
  sku_name     = "S0"
}

enable_private_endpoint = true
private_endpoint_name   = "pe-aif-dev-dslz-westus3"

private_endpoint_subresource_names = ["account"]

private_dns_zone_ids = [
  # Paste the real zone IDs that Cloud Services gives you:
  # "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.cognitiveservices.azure.com",
  # "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com",
  # "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Network/privateDnsZones/privatelink.services.ai.azure.com"
]