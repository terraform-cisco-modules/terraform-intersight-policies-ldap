output "ldap_group" {
  value = module.main.ldap_policy.ldap_groups["server_admins"]
}
output "ldap_policy" {
  value = module.main.moid
}
output "ldap_provider" {
  value = module.main.ldap_policy.ldap_providers["198.18.3.89"]
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
