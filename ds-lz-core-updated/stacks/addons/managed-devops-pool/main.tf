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
  resolved_location            = var.location != "" ? var.location : try(data.terraform_remote_state.core[0].outputs.location, "")
  resolved_resource_group_name = var.resource_group_name != "" ? var.resource_group_name : try(data.terraform_remote_state.core[0].outputs.resource_group_name, "")
  resolved_tags                = length(var.tags) > 0 ? var.tags : try(data.terraform_remote_state.core[0].outputs.tags, {})
  resolved_subnet_id           = var.subnet_id != "" ? var.subnet_id : try(data.terraform_remote_state.core[0].outputs.managed_devops_pool_subnet_id, "")
}

resource "terraform_data" "input_checks" {
  input = {
    managed_devops_pool_name = var.managed_devops_pool_name
  }

  lifecycle {
    precondition {
      condition     = local.resolved_location != ""
      error_message = "location must be set directly or resolved from core remote state."
    }

    precondition {
      condition     = local.resolved_resource_group_name != ""
      error_message = "resource_group_name must be set directly or resolved from core remote state."
    }

    precondition {
      condition     = local.resolved_subnet_id != ""
      error_message = "subnet_id must be set directly or resolved from core remote state."
    }
  }
}

module "managed_devops_pool" {
  source = "../../../modules/addons/managed-devops-pool"

  resource_group_name = local.resolved_resource_group_name
  location            = local.resolved_location
  tags                = local.resolved_tags
  subnet_id           = local.resolved_subnet_id

  dev_center_name                 = var.dev_center_name
  dev_center_display_name         = var.dev_center_display_name
  dev_center_project_name         = var.dev_center_project_name
  dev_center_project_display_name = var.dev_center_project_display_name
  dev_center_project_description  = var.dev_center_project_description
  managed_devops_pool_name        = var.managed_devops_pool_name
  organization_url                = var.organization_url
  projects                        = var.projects
  open_access                     = var.open_access
  maximum_concurrency             = var.maximum_concurrency
  pool_admin_users                = var.pool_admin_users
  pool_admin_groups               = var.pool_admin_groups
  vm_sku                          = var.vm_sku
  image_well_known_name           = var.image_well_known_name
  agent_kind                      = var.agent_kind
  prediction_preference           = var.prediction_preference
  static_ip_address_count         = var.static_ip_address_count
  os_logon_type                   = var.os_logon_type
  os_disk_storage_account_type    = var.os_disk_storage_account_type

  depends_on = [terraform_data.input_checks]
}