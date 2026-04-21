output "dev_center_id" {
  description = "Dev Center resource ID."
  value       = module.managed_devops_pool.dev_center_id
}

output "dev_center_name" {
  description = "Dev Center name."
  value       = module.managed_devops_pool.dev_center_name
}

output "dev_center_project_id" {
  description = "Dev Center Project resource ID."
  value       = module.managed_devops_pool.dev_center_project_id
}

output "dev_center_project_name" {
  description = "Dev Center Project name."
  value       = module.managed_devops_pool.dev_center_project_name
}

output "managed_devops_pool_id" {
  description = "Managed DevOps Pool resource ID."
  value       = module.managed_devops_pool.managed_devops_pool_id
}

output "managed_devops_pool_name" {
  description = "Managed DevOps Pool name."
  value       = module.managed_devops_pool.managed_devops_pool_name
}

#*************
output "state_storage_account_id" {
  description = "Managed DevOps Pool state storage account ID."
  value       = module.managed_devops_pool.state_storage_account_id
}

output "state_storage_account_name" {
  description = "Managed DevOps Pool state storage account name."
  value       = module.managed_devops_pool.state_storage_account_name
}

output "state_storage_blob_private_endpoint_id" {
  description = "Blob private endpoint ID for Managed DevOps Pool state storage account."
  value       = try(azurerm_private_endpoint.state_storage_blob[0].id, null)
}

output "state_storage_blob_private_endpoint_name" {
  description = "Blob private endpoint name for Managed DevOps Pool state storage account."
  value       = try(azurerm_private_endpoint.state_storage_blob[0].name, null)
}
#***************