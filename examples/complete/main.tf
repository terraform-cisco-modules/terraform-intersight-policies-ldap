module "ldap" {
  source  = "terraform-cisco-modules/policies-ldap/intersight"
  version = ">= 1.0.1"

  description      = "default LDAP Policy."
  name         = "default"
  organization = "default"
}
