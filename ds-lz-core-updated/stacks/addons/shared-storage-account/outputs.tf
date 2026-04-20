output "storage_account_id" {
  description = "Shared storage account ID."
  value       = module.shared_storage_account.storage_account_id
}

output "storage_account_name" {
  description = "Shared storage account name."
  value       = module.shared_storage_account.storage_account_name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = module.shared_storage_account.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "Primary dfs endpoint."
  value       = module.shared_storage_account.primary_dfs_endpoint
}

output "blob_private_endpoint_id" {
  description = "Blob private endpoint ID for the shared storage account."
  value       = module.shared_storage_account.blob_private_endpoint_id
}

output "blob_private_endpoint_name" {
  description = "Blob private endpoint name for the shared storage account."
  value       = module.shared_storage_account.blob_private_endpoint_name
}

output "dfs_private_endpoint_id" {
  description = "DFS private endpoint ID for the shared storage account."
  value       = module.shared_storage_account.dfs_private_endpoint_id
}

output "dfs_private_endpoint_name" {
  description = "DFS private endpoint name for the shared storage account."
  value       = module.shared_storage_account.dfs_private_endpoint_name
}