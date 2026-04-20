data "azurerm_client_config" "current" {}

locals {
  resource_group_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  resolved_dev_center_display_name = var.dev_center_display_name != "" ? var.dev_center_display_name : var.dev_center_name

  resolved_dev_center_project_display_name = var.dev_center_project_display_name != "" ? var.dev_center_project_display_name : var.dev_center_project_name

  has_specific_accounts = length(var.pool_admin_users) > 0 || length(var.pool_admin_groups) > 0

  permission_profile = jsondecode(
    local.has_specific_accounts
    ? jsonencode({
        kind   = "SpecificAccounts"
        users  = var.pool_admin_users
        groups = var.pool_admin_groups
      })
    : jsonencode({
        kind = "Inherit"
      })
  )

  network_profile = jsondecode(
    var.static_ip_address_count > 0
    ? jsonencode({
        subnetId             = var.subnet_id
        staticIpAddressCount = var.static_ip_address_count
      })
    : jsonencode({
        subnetId = var.subnet_id
      })
  )
}

resource "terraform_data" "input_checks" {
  input = {
    managed_devops_pool_name = var.managed_devops_pool_name
  }

  lifecycle {
    precondition {
      condition     = var.subnet_id != ""
      error_message = "subnet_id must be set."
    }

    precondition {
      condition     = var.dev_center_name != ""
      error_message = "dev_center_name must be set."
    }

    precondition {
      condition     = var.dev_center_project_name != ""
      error_message = "dev_center_project_name must be set."
    }

    precondition {
      condition     = var.managed_devops_pool_name != ""
      error_message = "managed_devops_pool_name must be set."
    }

    precondition {
      condition     = var.organization_url != ""
      error_message = "organization_url must be set."
    }

    precondition {
      condition     = var.maximum_concurrency > 0
      error_message = "maximum_concurrency must be greater than 0."
    }

    precondition {
      condition     = var.vm_sku != ""
      error_message = "vm_sku must be set."
    }

    precondition {
      condition     = var.image_well_known_name != ""
      error_message = "image_well_known_name must be set."
    }

    precondition {
      condition     = var.open_access || length(var.projects) > 0
      error_message = "If open_access=false, then at least one Azure DevOps project must be specified."
    }
  }
}

resource "azapi_resource" "dev_center" {
  type      = "Microsoft.DevCenter/devcenters@2025-02-01"
  name      = var.dev_center_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      displayName = local.resolved_dev_center_display_name
      networkSettings = {
        microsoftHostedNetworkEnableStatus = "Disabled"
      }
    }
  }

  schema_validation_enabled = false

  depends_on = [terraform_data.input_checks]
}

resource "azapi_resource" "dev_center_project" {
  type      = "Microsoft.DevCenter/projects@2025-02-01"
  name      = var.dev_center_project_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      description        = var.dev_center_project_description
      devCenterId        = azapi_resource.dev_center.id
      displayName        = local.resolved_dev_center_project_display_name
      maxDevBoxesPerUser = 0
    }
  }

  schema_validation_enabled = false

  depends_on = [azapi_resource.dev_center]
}

resource "azapi_resource" "managed_devops_pool" {
  type      = "Microsoft.DevOpsInfrastructure/pools@2025-09-20"
  name      = var.managed_devops_pool_name
  parent_id = local.resource_group_id
  location  = var.location
  tags      = var.tags

  body = {
    properties = {
      agentProfile = {
        kind = var.agent_kind
        resourcePredictionsProfile = {
          kind                 = "Automatic"
          predictionPreference = var.prediction_preference
        }
      }

      devCenterProjectResourceId = azapi_resource.dev_center_project.id
      maximumConcurrency         = var.maximum_concurrency

      organizationProfile = {
        kind = "AzureDevOps"
        organizations = [
          {
            url         = var.organization_url
            projects    = var.projects
            parallelism = var.maximum_concurrency
            openAccess  = var.open_access
          }
        ]
        permissionProfile = local.permission_profile
      }

      fabricProfile = {
        kind = "Vmss"
        sku = {
          name = var.vm_sku
        }
        images = [
          {
            wellKnownImageName = var.image_well_known_name
          }
        ]
        networkProfile = local.network_profile
        osProfile = {
          logonType = var.os_logon_type
        }
        storageProfile = {
          osDiskStorageAccountType = var.os_disk_storage_account_type
        }
      }
    }
  }

  schema_validation_enabled = false

  depends_on = [azapi_resource.dev_center_project]
}