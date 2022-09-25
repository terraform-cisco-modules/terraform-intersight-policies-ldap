module "ldap" {
  source  = "terraform-cisco-modules/policies-ldap/intersight"
  version = ">= 1.0.1"

  base_settings = {
    base_dn = "dc=example,dc=com"
    domain  = "example.com"
    timeout = 0
  }
  binding_parameters = {
    bind_method = "LoginCredentials"
  }
  description = "default LDAP Policy."
  ldap_groups = [
    {
      name = "server_admins"
      role = "admin"
    },
    {
      name = "server_ops"
      role = "user"
    }
  ]
  ldap_servers = [{
    server = "198.18.3.89"
  }]
  name         = "default"
  organization = "default"
}
