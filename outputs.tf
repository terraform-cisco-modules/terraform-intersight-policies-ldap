#____________________________________________________________
#
# Collect the moid of the LDAP Policy as an Output
#____________________________________________________________

output "moid" {
  description = "LDAP Policy Managed Object ID (moid)."
  value       = intersight_iam_ldap_policy.ldap.moid
}

output "ldap_policy" {
  value = {
    ldap_groups = length(var.ldap_groups) > 0 ? {
      for v in sort(keys(intersight_iam_ldap_group.ldap_group)
      ) : v => intersight_iam_ldap_group.ldap_group[v].moid
    } : {}
    ldap_providers = length(var.ldap_providers) > 0 ? {
      for v in sort(keys(intersight_iam_ldap_provider.ldap_providers)
      ) : v => intersight_iam_ldap_provider.ldap_providers[v].moid
    } : {}
    moid = intersight_iam_ldap_policy.ldap.moid
    name = var.name
  }
}