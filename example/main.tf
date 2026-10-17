resource "azurerm_resource_group" "example" {
  name     = "rg-example-prod-001"
  location = "westeurope"
}

module "static_web_app" {
  source               = "../"
  name                 = "stapp-example-prod-001"
  resource_group_name  = azurerm_resource_group.example.name
  location             = azurerm_resource_group.example.location
  cloudflare_zone_name = "example.com"
  subdomains           = ["www"]
  tags = {
    environment = "Production"
  }
}

output "deployment_token" {
  description = "The deployment token used to deploy content from CI pipelines."
  value       = module.static_web_app.deployment_token
  sensitive   = true
}
