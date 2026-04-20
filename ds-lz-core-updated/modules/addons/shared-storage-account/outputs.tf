output "storage_account_id" {
  description = "Shared storage account ID."
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Shared storage account name."
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint."
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_dfs_endpoint" {
  description = "Primary dfs endpoint."
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "blob_private_endpoint_id" {
  description = "Blob private endpoint ID for the shared storage account."
  value       = try(azurerm_private_endpoint.blob[0].id, null)
}

output "blob_private_endpoint_name" {
  description = "Blob private endpoint name for the shared storage account."
  value       = try(azurerm_private_endpoint.blob[0].name, null)
}

output "dfs_private_endpoint_id" {
  description = "DFS private endpoint ID for the shared storage account."
  value       = try(azurerm_private_endpoint.dfs[0].id, null)
}

output "dfs_private_endpoint_name" {
  description = "DFS private endpoint name for the shared storage account."
  value       = try(azurerm_private_endpoint.dfs[0].name, null)
}