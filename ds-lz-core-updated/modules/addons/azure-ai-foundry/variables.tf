variable "location" {
  type        = string
  description = "Azure region."
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name for Azure AI Foundry resources."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}

variable "foundry_name" {
  type        = string
  description = "Azure AI Foundry resource name."
}

variable "foundry_sku_name" {
  type        = string
  description = "SKU for the Foundry resource."
  default     = "S0"
}

variable "custom_subdomain_name" {
  type        = string
  description = "Custom subdomain name required for the Foundry resource."
}

variable "project_management_enabled" {
  type        = bool
  description = "Whether project management is enabled on the Foundry resource."
  default     = true
}

variable "disable_local_auth" {
  type        = bool
  description = "Whether local auth is disabled."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "foundry_project" {
  description = "Optional Foundry project configuration."
  type = object({
    enabled      = bool
    name         = string
    display_name = string
    description  = string
    sku_name     = string
  })

  default = {
    enabled      = false
    name         = ""
    display_name = ""
    description  = ""
    sku_name     = "S0"
  }
}

variable "private_endpoints_subnet_id" {
  type        = string
  description = "Private endpoints subnet ID."
  default     = ""
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Foundry resource."
  default     = false
}

variable "private_endpoint_name" {
  type        = string
  description = "Optional explicit private endpoint name."
  default     = ""
}

variable "private_endpoint_subresource_names" {
  type        = list(string)
  description = "Private Link subresource names for the Foundry private endpoint."
  default     = ["account"]
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Central Foundry private DNS zone IDs provided manually by Cloud Services."
  default     = []
}