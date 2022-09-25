#____________________________________________________________
#
# Collect the moid of the LDAP Policy as an Output
#____________________________________________________________

output "moid" {
  description = "LDAP Policy Managed Object ID (moid)."
  value       = intersight_iam_ldap_policy.ldap.moid
}


#____________________________________________________________
#
# Collect the moid of the LDAP Server as an Output
#____________________________________________________________

output "moid" {
  description = "LDAP Server Managed Object ID (moid)."
  value       = intersight_iam_ldap_provider.ldap_provider.moid
}

#____________________________________________________________
#
# Collect the moid of the LDAP Group as an Output
#____________________________________________________________

output "moid" {
  description = "LDAP Group Managed Object ID (moid)."
  value       = intersight_iam_ldap_group.ldap_group.moid
}
