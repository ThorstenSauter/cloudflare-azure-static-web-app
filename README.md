# Azure Static Web App with Cloudflare DNS

Terraform module that creates an [Azure Static Web App](https://learn.microsoft.com/en-us/azure/static-web-apps/) and
binds custom domains from an existing Cloudflare zone to it, including the DNS records and Azure's domain validation.

- **Apex** (`example.com`, optional, on by default): validated with a TXT token. Traffic is routed through a CNAME that
  Cloudflare flattens to A/AAAA records.
- **Subdomains** (`www.example.com`, …): routed and validated through a CNAME (`cname-delegation`). The module waits
  for DNS to propagate before Azure validates them.

All records are DNS-only (not proxied), so Azure can issue and renew the managed certificates.

The module only provisions the infrastructure. Deploy the site content with the `deployment_token` output, for example
with [`Azure/static-web-apps-deploy`](https://github.com/Azure/static-web-apps-deploy).

## Requirements

- An existing resource group. The module doesn't create one, so several apps can share a group.
- An existing Cloudflare zone, and a Cloudflare API token with `Zone:Read` and `DNS:Edit` on it.
- Azure permissions to create a Static Web App in the resource group.

## Usage

```hcl
module "static_web_app" {
  source               = "github.com/ThorstenSauter/cloudflare-azure-static-web-app?ref=1.0.0"
  name                 = "stapp-example-prod-001"
  resource_group_name  = azurerm_resource_group.main.name
  location             = "westeurope"
  cloudflare_zone_name = "example.com"
  subdomains           = ["www"]
}
```

A complete configuration is in the [example](./example) directory.

## Module documentation

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
