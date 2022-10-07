<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/terraform-cisco-modules/terraform-intersight-policies-ldap/actions/workflows/terratest.yml/badge.svg)](https://github.com/terraform-cisco-modules/terraform-intersight-policies-ldap/actions/workflows/terratest.yml)
# Terraform Intersight Policies - LDAP
Manages Intersight LDAP Policies

Location in GUI:
`Policies` » `Create Policy` » `LDAP`

## Easy IMM

[*Easy IMM - Comprehensive Example*](https://github.com/terraform-cisco-modules/easy-imm-comprehensive-example) - A comprehensive example for policies, pools, and profiles.

## Example

### main.tf
```hcl
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
  ldap_providers = [{
    server = "198.18.3.89"
  }]
  name         = "default"
  organization = "default"
}
```

### provider.tf
```hcl
terraform {
  required_providers {
    intersight = {
      source  = "CiscoDevNet/intersight"
      version = ">=1.0.32"
    }
  }
  required_version = ">=1.3.0"
}

provider "intersight" {
  apikey    = var.apikey
  endpoint  = var.endpoint
  secretkey = var.secretkey
}
```

### variables.tf
```hcl
variable "apikey" {
  description = "Intersight API Key."
  sensitive   = true
  type        = string
}

variable "endpoint" {
  default     = "https://intersight.com"
  description = "Intersight URL."
  type        = string
}

variable "secretkey" {
  description = "Intersight Secret Key."
  sensitive   = true
  type        = string
}
```

## Environment Variables

### Terraform Cloud/Enterprise - Workspace Variables
- Add variable apikey with value of [your-api-key]
- Add variable secretkey with value of [your-secret-file-content]

### Linux
```bash
export TF_VAR_apikey="<your-api-key>"
export TF_VAR_secretkey=`cat <secret-key-file-location>`
```

### Windows
```bash
$env:TF_VAR_apikey="<your-api-key>"
$env:TF_VAR_secretkey="<secret-key-file-location>"
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
| <a name="requirement_intersight"></a> [intersight](#requirement\_intersight) | >=1.0.32 |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_intersight"></a> [intersight](#provider\_intersight) | 1.0.32 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apikey"></a> [apikey](#input\_apikey) | Intersight API Key. | `string` | n/a | yes |
| <a name="input_endpoint"></a> [endpoint](#input\_endpoint) | Intersight URL. | `string` | `"https://intersight.com"` | no |
| <a name="input_secretkey"></a> [secretkey](#input\_secretkey) | Intersight Secret Key. | `string` | n/a | yes |
| <a name="input_base_settings"></a> [base\_settings](#input\_base\_settings) | * base\_dn - Base Distinguished Name (DN). Starting point from where server will search for users and groups.<br>* domain - The LDAP Base domain that all users must be in.<br>* timeout - LDAP authentication timeout duration, in seconds.  Range is 0 to 180. | <pre>object(<br>    {<br>      base_dn = string<br>      domain  = string<br>      timeout = optional(number, 0)<br>    }<br>  )</pre> | <pre>{<br>  "base_dn": "",<br>  "domain": "",<br>  "timeout": 0<br>}</pre> | no |
| <a name="input_binding_parameters"></a> [binding\_parameters](#input\_binding\_parameters) | * bind\_dn - Distinguished Name (DN) of the user, that is used to authenticate against LDAP servers.<br>* bind\_method - Authentication method to access LDAP servers.<br>  - Anonymous - Requires no username and password. If this option is selected and the LDAP server is configured for Anonymous logins, then the user gains access.<br>  - ConfiguredCredentials - Requires a known set of credentials to be specified for the initial bind process. If the initial bind process succeeds, then the distinguished name (DN) of the user name is queried and re-used for the re-binding process. If the re-binding process fails, then the user is denied access.<br>  - LoginCredentials - Requires the user credentials. If the bind process fails, then user is denied access. | <pre>object(<br>    {<br>      bind_dn     = optional(string)<br>      bind_method = optional(string)<br>    }<br>  )</pre> | <pre>{<br>  "bind_dn": "",<br>  "binding_method": "LoginCredentials"<br>}</pre> | no |
| <a name="input_binding_parameters_password"></a> [binding\_parameters\_password](#input\_binding\_parameters\_password) | The password of the user for initial bind process. It can be any string that adheres to the following constraints. It can have character except spaces, tabs, line breaks. It cannot be more than 254 characters. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the Policy. | `string` | `""` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | If enabled, the endpoint encrypts all information it sends to the LDAP server. | `bool` | `false` | no |
| <a name="input_enable_group_authorization"></a> [enable\_group\_authorization](#input\_enable\_group\_authorization) | If enabled, user authorization is also done at the group level for LDAP users not in the local user database. | `bool` | `false` | no |
| <a name="input_enable_ldap"></a> [enable\_ldap](#input\_enable\_ldap) | Flag to Enable or Disable the Policy. | `bool` | `true` | no |
| <a name="input_ldap_from_dns"></a> [ldap\_from\_dns](#input\_ldap\_from\_dns) | This Array enabled the use of DNS for LDAP Server discovery.<br>* enable - Enables DNS to access LDAP servers.<br>* search\_domain - Domain name that acts as a source for a DNS query.<br>* search\_forest - Forest name that acts as a source for a DNS query.<br>* source - Source of the domain name used for the DNS SRV request.<br>  - Configured - The configured-search domain.<br>  - ConfiguredExtracted - The domain name extracted from the login ID than the configured-search domain.<br>  - Extracted - The domain name extracted-domain from the login ID." | <pre>object(<br>    {<br>      enable        = optional(bool)<br>      search_domain = optional(string)<br>      search_forest = optional(string)<br>      source        = optional(string)<br>    }<br>  )</pre> | <pre>{<br>  "enable": false,<br>  "search_domain": "",<br>  "search_forest": "",<br>  "source": "Extracted"<br>}</pre> | no |
| <a name="input_ldap_groups"></a> [ldap\_groups](#input\_ldap\_groups) | List of LDAP Groups.<br>* domain: (default is base\_settings.domain) - LDAP server domain the Group resides in.<br>* name - Name of the LDAP Group.<br>* role - Role to assign to the group.<br>  1. admin<br>  2. readonly: (default)<br>  3. user | <pre>list(object(<br>    {<br>      domain = optional(string)<br>      name   = string<br>      role   = optional(string, "readonly")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_ldap_providers"></a> [ldap\_providers](#input\_ldap\_providers) | List of LDAP Servers.<br>* port: (default is 389) - Port to Assign to the LDAP Server.  Range is 1-65535.<br>* server - DNS Name or IP address of an LDAP Server. | <pre>list(object(<br>    {<br>      port   = optional(number, 389)<br>      server = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the Policy. | `string` | `"default"` | no |
| <a name="input_nested_group_search_depth"></a> [nested\_group\_search\_depth](#input\_nested\_group\_search\_depth) | Search depth to look for a nested LDAP group in an LDAP group map.  Range is 1 to 128. | `number` | `128` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Intersight Organization Name to Apply Policy to.  https://intersight.com/an/settings/organizations/. | `string` | `"default"` | no |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | List of Profiles to Assign to the Policy.<br>* name - Name of the Profile to Assign.<br>* object\_type - Object Type to Assign in the Profile Configuration.<br>  - server.Profile - For UCS Server Profiles.<br>  - server.ProfileTemplate - For UCS Server Profile Templates. | <pre>list(object(<br>    {<br>      name        = string<br>      object_type = optional(string, "server.Profile")<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_search_parameters"></a> [search\_parameters](#input\_search\_parameters) | * attribute - Role and locale information of the user.<br>* filter - Criteria to identify entries in search requests.<br>* group\_attribute - Groups to which an LDAP user belongs. | <pre>object(<br>    {<br>      attribute       = optional(string)<br>      filter          = optional(string)<br>      group_attribute = optional(string)<br>    }<br>  )</pre> | <pre>{<br>  "attribute": "CiscoAvPair",<br>  "filter": "samAccountName",<br>  "group_attribute": "memberOf"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | List of Tag Attributes to Assign to the Policy. | `list(map(string))` | `[]` | no |
| <a name="input_user_search_precedence"></a> [user\_search\_precedence](#input\_user\_search\_precedence) | Search precedence between local user database and LDAP user database.<br>* LocalUserDb - Precedence is given to local user database while searching.<br>* LDAPUserDb - Precedence is given to LADP user database while searching. | `string` | `"LocalUserDb"` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_moid"></a> [moid](#output\_moid) | LDAP Policy Managed Object ID (moid). |
## Resources

| Name | Type |
|------|------|
| [intersight_iam_ldap_group.ldap_group](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_ldap_group) | resource |
| [intersight_iam_ldap_policy.ldap](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_ldap_policy) | resource |
| [intersight_iam_ldap_provider.ldap_providers](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/resources/iam_ldap_provider) | resource |
| [intersight_iam_end_point_role.roles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/iam_end_point_role) | data source |
| [intersight_organization_organization.org_moid](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/organization_organization) | data source |
| [intersight_server_profile.profiles](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile) | data source |
| [intersight_server_profile_template.templates](https://registry.terraform.io/providers/CiscoDevNet/intersight/latest/docs/data-sources/server_profile_template) | data source |
<!-- END_TF_DOCS -->