package test

import (
	"fmt"
	"os"
	"testing"

	iassert "github.com/cgascoig/intersight-simple-go/assert"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFull(t *testing.T) {
	//========================================================================
	// Setup Terraform options
	//========================================================================

	// Generate a unique name for objects created in this test to ensure we don't
	// have collisions with stale objects
	uniqueId := random.UniqueId()
	instanceName := fmt.Sprintf("test-policies-ldap-%s", uniqueId)

	// Input variables for the TF module
	vars := map[string]interface{}{
		"intersight_keyid":         os.Getenv("IS_KEYID"),
		"intersight_secretkeyfile": os.Getenv("IS_KEYFILE"),
		"name":                     instanceName,
	}

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./full",
		Vars:         vars,
	})

	//========================================================================
	// Init and apply terraform module
	//========================================================================
	defer terraform.Destroy(t, terraformOptions) // defer to ensure that TF destroy happens automatically after tests are completed
	terraform.InitAndApply(t, terraformOptions)
	ldap_group_moid := terraform.Output(t, terraformOptions, "ldap_policy[ldap_groups][server_admins]")
	ldap_policy_moid := terraform.Output(t, terraformOptions, "ldap_policy[moid]")
	ldap_provider_moid := terraform.Output(t, terraformOptions, "ldap_policy[ldap_providers][198.18.3.89]")

	assert.NotEmpty(t, ldap_group_moid, "TF group moid output should not be empty")
	assert.NotEmpty(t, ldap_policy_moid, "TF policy moid output should not be empty")
	assert.NotEmpty(t, ldap_provider_moid, "TF provider moid output should not be empty")

	//========================================================================
	// Make Intersight API call(s) to validate module worked
	//========================================================================

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedJSONTemplate := `
{
	"Name":        "{{ .name }}",
	"Description": "{{ .name }} LDAP Policy.",

	"BaseProperties": {
        "Attribute": "CiscoAvPair",
        "BaseDn": "dc=example,dc=com",
        "BindDn": "",
        "BindMethod": "LoginCredentials",
        "ClassId": "iam.LdapBaseProperties",
        "Domain": "example.com",
        "EnableEncryption": false,
        "EnableGroupAuthorization": false,
        "Filter": "samAccountName",
        "GroupAttribute": "memberOf",
        "IsPasswordSet": false,
        "NestedGroupSearchDepth": 128,
        "ObjectType": "iam.LdapBaseProperties",
        "Timeout": 0
	},
	"DnsParameters": {
        "ClassId": "iam.LdapDnsParameters",
        "ObjectType": "iam.LdapDnsParameters",
        "SearchDomain": "",
        "SearchForest": "",
        "Source": "Extracted"
	},
	"EnableDns": false,
	"Enabled": true,
	"Providers": [
        {
          "ClassId": "mo.MoRef",
          "Moid": "{{ .ldap_provider_moid }}",
          "ObjectType": "iam.LdapProvider",
          "link": "https://www.intersight.com/api/v1/iam/LdapProviders/{{ .ldap_provider_moid }}"
        }
      ],
      "UserSearchPrecedence": "LocalUserDb"
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/iam/LdapPolicies/%s", ldap_policy_moid), expectedJSONTemplate, vars)

	// Setup the expected values of the returned MO.
	// This is a Go template for the JSON object, so template variables can be used
	expectedGroupTemplate := `
{
	"Domain": "example.com",
	"LdapPolicy": {
        "ClassId": "mo.MoRef",
        "Moid": "{{ .ldap_policy_moid }}",
        "ObjectType": "iam.LdapPolicy",
        "link": "https://www.intersight.com/api/v1/iam/LdapPolicies/{{ .ldap_policy_moid }}"
	},
	"Name": "server_admins"
}
`
	// Validate that what is in the Intersight API matches the expected
	// The AssertMOComply function only checks that what is expected is in the result. Extra fields in the
	// result are ignored. This means we don't have to worry about things that aren't known in advance (e.g.
	// Moids, timestamps, etc)
	iassert.AssertMOComply(t, fmt.Sprintf("/api/v1/iam/LdapGroups/%s", ldap_group_moid), expectedGroupTemplate, vars)
}
