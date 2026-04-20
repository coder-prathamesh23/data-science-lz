variable "resource_group_name" {
  type        = string
  description = "Resource group name."
}

variable "location" {
  type        = string
  description = "Azure region."
}

variable "tags" {
  type        = map(string)
  description = "Common tags."
  default     = {}
}

variable "subnet_id" {
  type        = string
  description = "Delegated subnet ID for the Managed DevOps Pool."
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
  description = "Azure DevOps organization URL, for example https://dev.azure.com/your-org."
}

variable "projects" {
  type        = list(string)
  description = "Azure DevOps project names where the pool should be available. Leave empty only if open_access=true."
  default     = []
}

variable "open_access" {
  type        = bool
  description = "Whether the pool should be available to all projects in the organization."
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
  description = "Well-known image name for the pool, for example ubuntu-24.04-gen2."
}

variable "agent_kind" {
  type        = string
  description = "Agent profile kind."
  default     = "Stateless"
}

variable "prediction_preference" {
  type        = string
  description = "Automatic buffer preference for the pool."
  default     = "Balanced"
}

variable "static_ip_address_count" {
  type        = number
  description = "Optional count of static public IPs for outbound connectivity. Set to 0 to use existing/default outbound behavior."
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