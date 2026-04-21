output "dev_center_id" {
  description = "Dev Center resource ID."
  value       = azapi_resource.dev_center.id
}

output "dev_center_name" {
  description = "Dev Center name."
  value       = azapi_resource.dev_center.name
}

output "dev_center_project_id" {
  description = "Dev Center Project resource ID."
  value       = azapi_resource.dev_center_project.id
}

output "dev_center_project_name" {
  description = "Dev Center Project name."
  value       = azapi_resource.dev_center_project.name
}

output "managed_devops_pool_id" {
  description = "Managed DevOps Pool resource ID."
  value       = azapi_resource.managed_devops_pool.id
}

output "managed_devops_pool_name" {
  description = "Managed DevOps Pool name."
  value       = azapi_resource.managed_devops_pool.name
}
#***********************

output "state_storage_account_id" {
  description = "Managed DevOps Pool state storage account ID."
  value       = try(azurerm_storage_account.state[0].id, null)
}

output "state_storage_account_name" {
  description = "Managed DevOps Pool state storage account name."
  value       = try(azurerm_storage_account.state[0].name, null)
}
#***********************