spoke_subscription_id = "00000000-0000-0000-0000-000000000000"

core_remote_state = {
  enabled              = true
  resource_group_name  = "rg-tfstate-prod-shared"
  storage_account_name = "sttfstateprodshared01"
  container_name       = "tfstate"
  key                  = "stacks/data-science-lz-core/terraform.tfstate"
  use_azuread_auth     = true
}

dev_center_name         = "dc-dev-dslz-westus3"
dev_center_display_name = "dc-dev-dslz-westus3"

dev_center_project_name         = "dcp-dev-dslz-westus3"
dev_center_project_display_name = "dcp-dev-dslz-westus3"
dev_center_project_description  = "Dev Center project for Managed DevOps Pool in DSLZ Dev"

managed_devops_pool_name = "mdp-dev-dslz-westus3"

organization_url = "https://dev.azure.com/your-org"
projects         = ["your-project-name"]
open_access      = false

maximum_concurrency = 2

pool_admin_users  = ["user1@company.com", "user2@company.com"]
pool_admin_groups = []

vm_sku                = "Standard_D2ads_v5"
image_well_known_name = "ubuntu-24.04-gen2"

agent_kind              = "Stateless"
prediction_preference   = "Balanced"
static_ip_address_count = 0

os_logon_type                = "Service"
os_disk_storage_account_type = "StandardSSD"