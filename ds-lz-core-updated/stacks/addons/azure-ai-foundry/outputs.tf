output "foundry_id" {
  description = "Azure AI Foundry resource ID."
  value       = module.azure_ai_foundry.foundry_id
}

output "foundry_name" {
  description = "Azure AI Foundry resource name."
  value       = module.azure_ai_foundry.foundry_name
}

output "foundry_principal_id" {
  description = "Azure AI Foundry managed identity principal ID."
  value       = module.azure_ai_foundry.foundry_principal_id
}

output "foundry_project_id" {
  description = "Foundry project ID."
  value       = module.azure_ai_foundry.foundry_project_id
}

output "foundry_project_name" {
  description = "Foundry project name."
  value       = module.azure_ai_foundry.foundry_project_name
}

output "foundry_project_principal_id" {
  description = "Foundry project managed identity principal ID."
  value       = module.azure_ai_foundry.foundry_project_principal_id
}

output "private_endpoint_id" {
  description = "Private endpoint ID for Azure AI Foundry."
  value       = module.azure_ai_foundry.private_endpoint_id
}