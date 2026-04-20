variable "spoke_subscription_id" {
  type        = string
  description = "Subscription ID where the shared storage account is deployed."
}

variable "location" {
  type        = string
  description = "Azure region override. If empty, resolve from core remote state."
  default     = ""
}

variable "resource_group_name" {
  type        = string
  description = "Resource group override. If empty, resolve from core remote state."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "Tags override. If empty, resolve from core remote state."
  default     = {}
}

variable "core_remote_state" {
  type = object({
    enabled              = bool
    resource_group_name  = string
    storage_account_name = string
    container_name       = string
    key                  = string
    use_azuread_auth     = optional(bool, true)
  })

  default = {
    enabled              = true
    resource_group_name  = ""
    storage_account_name = ""
    container_name       = ""
    key                  = ""
    use_azuread_auth     = true
  }
}

variable "storage_account_name" {
  type        = string
  description = "Shared storage account name."
}

variable "account_kind" {
  type        = string
  description = "Storage account kind."
  default     = "StorageV2"
}

variable "account_tier" {
  type        = string
  description = "Storage account tier."
  default     = "Standard"
}

variable "account_replication_type" {
  type        = string
  description = "Replication type."
  default     = "LRS"
}

variable "is_hns_enabled" {
  type        = bool
  description = "Enable ADLS Gen2 hierarchical namespace."
  default     = true
}

variable "min_tls_version" {
  type        = string
  description = "Minimum TLS version."
  default     = "TLS1_2"
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = false
}

variable "allow_nested_items_to_be_public" {
  type        = bool
  description = "Allow nested items to be public."
  default     = false
}

variable "shared_access_key_enabled" {
  type        = bool
  description = "Whether shared key auth is enabled."
  default     = true
}

variable "default_to_oauth_authentication" {
  type        = bool
  description = "Default to OAuth authentication."
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Enable infrastructure encryption."
  default     = false
}

variable "cross_tenant_replication_enabled" {
  type        = bool
  description = "Enable cross-tenant replication."
  default     = false
}

variable "enable_private_endpoints" {
  type        = bool
  description = "Whether to create private endpoints for the shared storage account."
  default     = false
}

variable "private_endpoints_subnet_id" {
  type        = string
  description = "Private endpoints subnet ID override. If empty, resolve from core remote state."
  default     = ""
}

variable "blob_private_endpoint_name" {
  type        = string
  description = "Optional explicit name for the Blob private endpoint."
  default     = ""
}

variable "dfs_private_endpoint_name" {
  type        = string
  description = "Optional explicit name for the DFS private endpoint."
  default     = ""
}

variable "blob_private_dns_zone_ids" {
  type        = list(string)
  description = "Blob private DNS zone IDs provided manually by the networking team."
  default     = []
}

variable "dfs_private_dns_zone_ids" {
  type        = list(string)
  description = "DFS private DNS zone IDs provided manually by the networking team."
  default     = []
}