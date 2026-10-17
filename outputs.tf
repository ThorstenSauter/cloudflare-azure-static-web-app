output "id" {
  description = "The ID of the Static Web App."
  value       = azurerm_static_web_app.main.id
}

output "name" {
  description = "The name of the Static Web App."
  value       = azurerm_static_web_app.main.name
}

output "default_host_name" {
  description = "The default `*.azurestaticapps.net` host name of the Static Web App."
  value       = azurerm_static_web_app.main.default_host_name
}

output "custom_domains" {
  description = "All custom domains bound to the Static Web App."
  value       = concat(local.apex_domain, values(local.subdomain_domains))
}

output "deployment_token" {
  description = "The deployment token (API key) used to deploy content from CI pipelines."
  value       = azurerm_static_web_app.main.api_key
  sensitive   = true
}
