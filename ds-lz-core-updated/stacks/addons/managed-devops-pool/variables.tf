variable "spoke_subscription_id" {
  type        = string
  description = "Subscription ID where the Managed DevOps Pool add-on is deployed."
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

variable "subnet_id" {
  type        = string
  description = "Subnet ID override for Managed DevOps Pool. If empty, resolve from core remote state."
  default     = ""
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

variable "dev_center_name" {
  type        = string
  description = "Dev Center name."
}

variable "dev_center_display_name" {
  type        = string
  description = "Dev Center display name."
  default     = ""
}

variable "dev_center_project_name" {
  type        = string
  description = "Dev Center Project name."
}

variable "dev_center_project_display_name" {
  type        = string
  description = "Dev Center Project display name."
  default     = ""
}

variable "dev_center_project_description" {
  type        = string
  description = "Dev Center Project description."
  default     = ""
}

variable "managed_devops_pool_name" {
  type        = string
  description = "Managed DevOps Pool name."
}

variable "organization_url" {
  type        = string
  description = "Azure DevOps organization URL."
}

variable "projects" {
  type        = list(string)
  description = "Azure DevOps project names where the pool should be available."
  default     = []
}

variable "open_access" {
  type        = bool
  description = "Whether the pool should have open access in the Azure DevOps organization."
  default     = false
}

variable "maximum_concurrency" {
  type        = number
  description = "Maximum concurrency for the pool."
}

variable "pool_admin_users" {
  type        = list(string)
  description = "Pool admin user email addresses."
  default     = []
}

variable "pool_admin_groups" {
  type        = list(string)
  description = "Pool admin group email addresses."
  default     = []
}

variable "vm_sku" {
  type        = string
  description = "Azure VM SKU for pool agents."
}

variable "image_well_known_name" {
  type        = string
  description = "Well-known image name for the pool agents."
}

variable "agent_kind" {
  type        = string
  description = "Agent kind."
  default     = "Stateless"
}

variable "prediction_preference" {
  type        = string
  description = "Automatic prediction preference."
  default     = "Balanced"
}

variable "static_ip_address_count" {
  type        = number
  description = "Optional count of static public IPs."
  default     = 0
}

variable "os_logon_type" {
  type        = string
  description = "OS logon type."
  default     = "Service"
}

variable "os_disk_storage_account_type" {
  type        = string
  description = "OS disk storage account type."
  default     = "StandardSSD"
}
#*******************
variable "state_storage_account" {
  description = "Optional storage account for Managed DevOps Pool state files."
  type = object({
    enabled                              = bool
    name                                 = string
    account_kind                         = optional(string, "StorageV2")
    account_tier                         = optional(string, "Standard")
    account_replication_type             = optional(string, "ZRS")
    is_hns_enabled                       = optional(bool, true)
    min_tls_version                      = optional(string, "TLS1_2")
    public_network_access_enabled        = optional(bool, false)
    allow_nested_items_to_be_public      = optional(bool, false)
    shared_access_key_enabled            = optional(bool, true)
    default_to_oauth_authentication      = optional(bool, true)
    infrastructure_encryption_enabled    = optional(bool, false)
    cross_tenant_replication_enabled     = optional(bool, false)
  })

  default = {
    enabled                           = false
    name                              = ""
    account_kind                      = "StorageV2"
    account_tier                      = "Standard"
    account_replication_type          = "ZRS"
    is_hns_enabled                    = true
    min_tls_version                   = "TLS1_2"
    public_network_access_enabled     = false
    allow_nested_items_to_be_public   = false
    shared_access_key_enabled         = true
    default_to_oauth_authentication   = true
    infrastructure_encryption_enabled = false
    cross_tenant_replication_enabled  = false
  }
}

variable "state_storage_private_endpoint" {
  description = "Blob private endpoint configuration for Managed DevOps Pool state storage account."
  type = object({
    enabled                    = bool
    blob_private_endpoint_name = optional(string, "")
    blob_private_dns_zone_ids  = optional(list(string), [])
  })

  default = {
    enabled                    = false
    blob_private_endpoint_name = ""
    blob_private_dns_zone_ids  = []
  }
}
#*******************