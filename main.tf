#____________________________________________________________
#
# Intersight Organization Data Source
# GUI Location: Settings > Settings > Organizations > {Name}
#____________________________________________________________

data "intersight_organization_organization" "org_moid" {
  for_each = {
    for v in [var.organization] : v => v if length(
      regexall("[[:xdigit:]]{24}", var.organization)
    ) == 0
  }
  name     = each.value
}

#____________________________________________________________
#
# Intersight UCS Server Profile(s) Data Source
# GUI Location: Profiles > UCS Server Profiles > {Name}
#____________________________________________________________

data "intersight_server_profile" "profiles" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.Profile" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight UCS Server Profile Template(s) Data Source
# GUI Location: Templates > UCS Server Profile Templates > {Name}
#__________________________________________________________________

data "intersight_server_profile_template" "templates" {
  for_each = { for v in var.profiles : v.name => v if v.object_type == "server.ProfileTemplate" }
  name     = each.value.name
}

#__________________________________________________________________
#
# Intersight LDAP Policy
# GUI Location: Policies > Create Policy > LDAP
#__________________________________________________________________

resource "intersight_iam_ldap_policy" "ldap" {
  depends_on = [
    data.intersight_server_profile.profiles,
    data.intersight_server_profile_template.templates,
    data.intersight_organization_organization.org_moid
  ]
  description = var.description != "" ? var.description : "${var.name} LDAP Policy."
  name        = var.name
  enabled     = var.enable_ldap
  base_properties {
    # Base Settings
    base_dn = var.base_settings.base_dn
    domain  = var.base_settings.domain
    timeout = var.base_settings.timeout != null ? var.base_settings.timeout : 0
    # Enable LDAP Encryption
    enable_encryption = var.enable_encryption
    # Binding Parameters
    bind_method = var.binding_parameters.bind_method
    bind_dn     = var.binding_parameters.bind_dn
    password    = var.binding_parameters_password
    # Search Parameters
    attribute       = var.search_parameters.attribute
    filter          = var.search_parameters.filter
    group_attribute = var.search_parameters.group_attribute
    # Group Authorization
    enable_group_authorization = var.enable_group_authorization
    nested_group_search_depth  = var.nested_group_search_depth
  }
  # Configure LDAP Servers
  enable_dns = var.ldap_from_dns.enable
  dns_parameters {
    nr_source     = var.ldap_from_dns.source
    search_domain = var.ldap_from_dns.search_domain
    search_forest = var.ldap_from_dns.search_forest
  }
  user_search_precedence = var.user_search_precedence
  organization {
    moid = length(
      regexall("[[:xdigit:]]{24}", var.organization)
      ) > 0 ? var.organization : data.intersight_organization_organization.org_moid[
      var.organization].results[0
    ].moid
    object_type = "organization.Organization"
  }
  dynamic "profiles" {
    for_each = { for v in var.profiles : v.name => v }
    content {
      moid = length(regexall("server.ProfileTemplate", profiles.value.object_type)
        ) > 0 ? data.intersight_server_profile_template.templates[profiles.value.name].results[0
      ].moid : data.intersight_server_profile.profiles[profiles.value.name].results[0].moid
      object_type = profiles.value.object_type
    }
  }
  dynamic "tags" {
    for_each = var.tags
    content {
      key   = tags.value.key
      value = tags.value.value
    }
  }
}

#____________________________________________________________________
#
# Intersight LDAP Policy > Add New LDAP Group
# GUI Location: Policies > Create Policy > LDAP > Add New LDAP Group
#____________________________________________________________________

locals {
  roles = toset([for v in var.ldap_groups : v.role])
}

data "intersight_iam_end_point_role" "roles" {
  for_each = { for v in local.roles : v => v }
  name = each.value
  type = "IMC"
}

resource "intersight_iam_ldap_group" "ldap_group" {
  depends_on = [
    data.intersight_iam_end_point_role.roles,
    intersight_iam_ldap_policy.ldap
  ]
  for_each = { for v in var.ldap_groups : v.name => v }
  domain = length(compact([each.value.domain])) > 0 ? each.value.domain : var.base_settings.domain
  name   = each.value.name
  end_point_role {
    moid        = data.intersight_iam_end_point_role.roles[each.value.role].results[0].moid
    object_type = "iam.EndPointRole"
  }
  ldap_policy {
    moid = intersight_iam_ldap_policy.ldap.moid
  }
}

#__________________________________________________________________
#
# Intersight LDAP Policy - Server
# GUI Location: Policies > Create Policy > LDAP Policy > Server
#__________________________________________________________________

resource "intersight_iam_ldap_provider" "ldap_providers" {
  for_each = { for v in var.ldap_servers : v.server => v }
  depends_on = [
    intersight_iam_ldap_policy.ldap
  ]
  ldap_policy {
    moid = intersight_iam_ldap_policy.ldap.moid
  }
  port   = each.value.port
  server = each.value.server
}

