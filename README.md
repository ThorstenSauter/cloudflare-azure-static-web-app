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
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.10.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 5.0 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 5.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | ~> 0.14 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 5.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | ~> 5.0 |
| <a name="provider_time"></a> [time](#provider\_time) | ~> 0.14 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [azurerm_static_web_app.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app) | resource |
| [azurerm_static_web_app_custom_domain.apex](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app_custom_domain) | resource |
| [azurerm_static_web_app_custom_domain.subdomain](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/static_web_app_custom_domain) | resource |
| [cloudflare_dns_record.apex](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.apex_validation](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [cloudflare_dns_record.subdomain](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/dns_record) | resource |
| [time_sleep.dns_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [cloudflare_zone.this](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/data-sources/zone) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_apex"></a> [apex](#input\_apex) | Whether to bind the zone apex (`cloudflare_zone_name` itself) as a custom domain. It is validated with a TXT token and routed through a CNAME that Cloudflare flattens. | `bool` | `true` | no |
| <a name="input_cloudflare_zone_name"></a> [cloudflare\_zone\_name](#input\_cloudflare\_zone\_name) | The name of the existing Cloudflare zone that holds the custom domains, e.g. `example.com`. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the Static Web App will be deployed. Static Web Apps are only available in a few regions. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the Azure Static Web App. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | The name of the existing resource group the Azure Static Web App gets deployed to. | `string` | n/a | yes |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU of the Static Web App, used as both tier and size. | `string` | `"Free"` | no |
| <a name="input_subdomains"></a> [subdomains](#input\_subdomains) | Subdomain labels within the zone to bind as custom domains, e.g. `["www"]` for `www.example.com`. They are validated with cname-delegation. | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | The tags for the Static Web App. | `map(string)` | `{}` | no |
| <a name="input_wait_for_dns_propagation"></a> [wait\_for\_dns\_propagation](#input\_wait\_for\_dns\_propagation) | How long to wait after creating the DNS records before Azure validates the cname-delegation custom domains, e.g. `30s` or `2m`. | `string` | `"120s"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_custom_domains"></a> [custom\_domains](#output\_custom\_domains) | All custom domains bound to the Static Web App. |
| <a name="output_default_host_name"></a> [default\_host\_name](#output\_default\_host\_name) | The default `*.azurestaticapps.net` host name of the Static Web App. |
| <a name="output_deployment_token"></a> [deployment\_token](#output\_deployment\_token) | The deployment token (API key) used to deploy content from CI pipelines. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the Static Web App. |
| <a name="output_name"></a> [name](#output\_name) | The name of the Static Web App. |
<!-- END_TF_DOCS -->
