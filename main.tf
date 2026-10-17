# Built from the input rather than the zone data source, so for_each keys are known at plan time.
locals {
  apex_domain       = var.apex ? [var.cloudflare_zone_name] : []
  subdomain_domains = { for label in var.subdomains : label => "${label}.${var.cloudflare_zone_name}" }
}

data "cloudflare_zone" "this" {
  filter = {
    name = var.cloudflare_zone_name
  }
}

resource "azurerm_static_web_app" "main" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_tier            = var.sku
  sku_size            = var.sku
  tags                = var.tags

  # Content is pushed with the deployment token, not from a linked repository.
  lifecycle {
    ignore_changes = [
      repository_branch,
      repository_url,
    ]
  }
}

# The apex can't use cname-delegation, so it is validated with a TXT token.
resource "azurerm_static_web_app_custom_domain" "apex" {
  for_each = toset(local.apex_domain)

  static_web_app_id = azurerm_static_web_app.main.id
  domain_name       = each.value
  validation_type   = "dns-txt-token"
}

resource "cloudflare_dns_record" "apex_validation" {
  for_each = azurerm_static_web_app_custom_domain.apex

  zone_id = data.cloudflare_zone.this.id
  name    = each.value.domain_name
  type    = "TXT"
  content = each.value.validation_token
  ttl     = 1
  comment = "Azure Static Web App ${azurerm_static_web_app.main.name} apex domain validation"

  # Keep the record as created so a later token rotation in Azure doesn't show up as drift.
  lifecycle {
    ignore_changes = [content]
  }
}

# Cloudflare flattens this CNAME at the apex to A/AAAA records.
resource "cloudflare_dns_record" "apex" {
  for_each = toset(local.apex_domain)

  zone_id = data.cloudflare_zone.this.id
  name    = each.value
  type    = "CNAME"
  content = azurerm_static_web_app.main.default_host_name
  proxied = false
  ttl     = 1
  comment = "Azure Static Web App ${azurerm_static_web_app.main.name}"
}

# Serves as both routing and cname-delegation validation.
resource "cloudflare_dns_record" "subdomain" {
  for_each = local.subdomain_domains

  zone_id = data.cloudflare_zone.this.id
  name    = each.value
  type    = "CNAME"
  content = azurerm_static_web_app.main.default_host_name
  proxied = false
  ttl     = 1
  comment = "Azure Static Web App ${azurerm_static_web_app.main.name}"
}

# Azure checks the CNAME as soon as a cname-delegation domain is created, so give DNS time to propagate.
resource "time_sleep" "dns_propagation" {
  count = length(local.subdomain_domains) > 0 ? 1 : 0

  create_duration = var.wait_for_dns_propagation

  depends_on = [
    cloudflare_dns_record.apex_validation,
    cloudflare_dns_record.apex,
    cloudflare_dns_record.subdomain,
  ]
}

resource "azurerm_static_web_app_custom_domain" "subdomain" {
  for_each = local.subdomain_domains

  static_web_app_id = azurerm_static_web_app.main.id
  domain_name       = each.value
  validation_type   = "cname-delegation"

  depends_on = [time_sleep.dns_propagation]
}
