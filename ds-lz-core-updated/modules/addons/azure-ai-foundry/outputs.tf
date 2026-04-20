output "foundry_id" {
  description = "Azure AI Foundry resource ID."
  value       = azapi_resource.foundry.id
}

output "foundry_name" {
  description = "Azure AI Foundry resource name."
  value       = azapi_resource.foundry.name
}

output "foundry_principal_id" {
  description = "System-assigned managed identity principal ID for the Foundry resource."
  value       = try(azapi_resource.foundry.output.identity.principalId, null)
}

output "foundry_project_id" {
  description = "Foundry project ID, if enabled."
  value       = try(azapi_resource.foundry_project[0].id, null)
}

output "foundry_project_name" {
  description = "Foundry project name, if enabled."
  value       = try(azapi_resource.foundry_project[0].name, null)
}

output "foundry_project_principal_id" {
  description = "System-assigned managed identity principal ID for the Foundry project, if enabled."
  value       = try(azapi_resource.foundry_project[0].output.identity.principalId, null)
}

output "private_endpoint_id" {
  description = "Private endpoint ID for the Foundry resource, if enabled."
  value       = try(azurerm_private_endpoint.foundry[0].id, null)
}