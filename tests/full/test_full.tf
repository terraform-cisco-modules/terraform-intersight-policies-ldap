terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
}

# Setup provider, variables and outputs
provider "intersight" {
  apikey    = var.intersight_keyid
  secretkey = file(var.intersight_secretkeyfile)
  endpoint  = var.intersight_endpoint
}

variable "intersight_keyid" {}
variable "intersight_secretkeyfile" {}
variable "intersight_endpoint" {
  default = "intersight.com"
}
variable "name" {}

output "ldap_policy" {
  value = {
    ldap_groups = {
      for v in sort(keys(module.main.ldap_policy.ldap_groups)
      ) : v => module.main.ldap_policy.ldap_groups[v]
    }
    ldap_providers = {
      for v in sort(keys(module.main.ldap_policy.ldap_providers)
      ) : v => module.main.ldap_policy.ldap_providers[v]
    }
    moid = module.main.moid
    name = var.name
  }
}

# This is the module under test
module "main" {
  source = "../.."
  base_settings = {
    base_dn = "dc=example,dc=com"
    domain  = "example.com"
    timeout = 0
  }
  binding_parameters = {
    bind_method = "LoginCredentials"
  }
  description = "${var.name} LDAP Policy."
  ldap_groups = [
    {
      name = "server_admins"
      role = "admin"
    },
  ]
  ldap_providers = [{
    server = "198.18.3.89"
  }]
  name         = var.name
  organization = "terratest"
}
