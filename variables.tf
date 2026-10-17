variable "name" {
  type        = string
  description = "The name of the Azure Static Web App."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,40}$", var.name))
    error_message = "The name must only contain letters, numbers, and hyphens and not exceed 40 characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group the Azure Static Web App gets deployed to."
}

variable "location" {
  type        = string
  description = "The Azure region where the Static Web App will be deployed. Static Web Apps are only available in a few regions."
}

variable "sku" {
  type        = string
  description = "The SKU of the Static Web App, used as both tier and size."
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.sku)
    error_message = "The SKU has to be one of 'Free' or 'Standard'."
  }
}

variable "tags" {
  type        = map(string)
  description = "The tags for the Static Web App."
  default     = {}
}

variable "cloudflare_zone_name" {
  type        = string
  description = "The name of the existing Cloudflare zone that holds the custom domains, e.g. `example.com`."

  validation {
    condition     = can(regex("^[a-z0-9-]+(\\.[a-z0-9-]+)*\\.[a-z]+$", var.cloudflare_zone_name))
    error_message = "The zone name must be a domain like `example.com`."
  }
}

variable "apex" {
  type        = bool
  description = "Whether to bind the zone apex (`cloudflare_zone_name` itself) as a custom domain. It is validated with a TXT token and routed through a CNAME that Cloudflare flattens."
  default     = true
}

variable "subdomains" {
  type        = set(string)
  description = "Subdomain labels within the zone to bind as custom domains, e.g. `[\"www\"]` for `www.example.com`. They are validated with cname-delegation."
  default     = []

  validation {
    condition = alltrue([
      for label in var.subdomains : can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?(\\.[a-z0-9]([a-z0-9-]*[a-z0-9])?)*$", label))
    ])
    error_message = "Each subdomain must be a lowercase label relative to the zone, e.g. `www` or `staging.app`, not a fully qualified name."
  }
}

variable "wait_for_dns_propagation" {
  type        = string
  description = "How long to wait after creating the DNS records before Azure validates the cname-delegation custom domains, e.g. `30s` or `2m`."
  default     = "120s"

  validation {
    condition     = can(regex("^[0-9]+(\\.[0-9]+)?(ms|s|m|h)$", var.wait_for_dns_propagation))
    error_message = "The duration must be a number immediately followed by ms, s, m or h, e.g. `30s`."
  }
}
