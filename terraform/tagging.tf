resource "azurerm_policy_definition" "enforce_resource_group_tags" {
    name         = "dicci_enforce_rg_tags"  
    policy_type  = "Custom"
    mode         = "All"
    display_name = "Enforce Resource Group Tags"

    lifecycle {
        ignore_changes = [
            metadata
        ]
    }

    parameters = <<PARAMETERS
    {
        "tagName": {
            "type": "String",
            "metadata": {
                "displayName": "Tag Name",
                "description": "Name of the tag, such as costCenter"
            }
        },
        "policy-effect": {
        "type": "String",
        "metadata": {
            "displayName": "Policy Effect",
            "description": "The available options for the Policy Effect"
        },
        "allowedValues": [
            "audit",
            "deny"
        ],
        "defaultValue": "audit"
        }
    }
    PARAMETERS

    policy_rule = <<POLICY_RULE
    {
        "if": {
            "allOf": [
                {
                    "field": "type",
                    "equals": "Microsoft.Resources/subscriptions/resourceGroups"
                },
                {
                    "field": "[concat('tags[', parameters('tagName'), ']')]",
                    "exists": "false"
                }
            ]
        },
        "then": {
            "effect": "[parameters('policy-effect')]"
        }
    }
    POLICY_RULE
}

resource "azurerm_policy_definition" "enforce_resource_tags" {
    name         = "dicci_enforce_r_tags"
    policy_type  = "Custom"
    mode         = "Indexed"
    display_name = "Enforce Resource Tags"
    description  = "Policy to enforce that a specific tag exists for a resource.  Excludes metric alerts."

    lifecycle {
        ignore_changes = [
            metadata
        ]
    }

    parameters = <<PARAMETERS
    {
        "tagName": {
            "type": "String",
            "metadata": {
                "displayName": "Tag Name",
                "description": "Name of the tag, such as 'environment'"
            }
        },
        "policy-effect": {
            "type": "String",
            "metadata": {
                "displayName": "Policy Effect",
                "description": "The available options for the Policy Effect"
            },
            "allowedValues": [
                "audit",
                "deny"
            ],
            "defaultValue": "audit"
        }
    }
    PARAMETERS

    policy_rule = <<POLICY_RULE
    {
        "if": {
            "anyOf": [
                {
                    "field": "[concat('tags[', parameters('env'), ']')]",
                    "exists": "false"
                },
                {
                    "field": "[concat('tags[', parameters('owner'), ']')]",
                    "exists": "false"
                }
            ]
        },
        "then": {
            "effect": "[parameters('policy-effect')]"
        }
    }
    POLICY_RULE
}