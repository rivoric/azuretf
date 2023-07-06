locals {
    environment_tags = [
        "dev",
        "test",
        "qa",
        "uat",
        "staging",
        "prod"
    ]
}

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
                    "field": "[concat('tags[', parameters('Environment'), ']')]",
                    "exists": "false"
                },
                {
                    "field": "[concat('tags[', parameters('Owner'), ']')]",
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

resource "azurerm_policy_set_definition" "tagging_standards" {
    name                  = "dicci_tagging_standards"
    policy_type           = "Custom"
    display_name          = "Tagging Standards"
    management_group_name = data.azurerm_management_group.tenant_root.name
    description           = "Tagging Standards to be applied to the Azure environment."

    lifecycle {
        ignore_changes = [
            metadata
        ]
    }

    parameters = <<PARAMETERS
    {
    "policy-effect":
        {
            "allowedValues":["audit","deny"],
            "metadata":{
                "description":"The effect options for the initiative.",
                "displayName":"policy-effect"
            },
            "type":"String",
            "defaultValue": "audit"
        }
    }
    PARAMETERS

    # Enforces the Environment tag on any resource group that is created.
    policy_definition_reference {
        policy_definition_id = azurerm_policy_definition.enforce_resource_group_tags.id
        parameter_values = jsonencode({
            policy-effect = {value = "[parameters('policy-effect')]"},
            tagName = {value = "Environment"}
        })
    }

    # Enforces the Environment tag on any resource that is created.
    policy_definition_reference {
        policy_definition_id = azurerm_policy_definition.enforce_resource_tags.id
        parameter_values = jsonencode({
            policy-effect = {value = "[parameters('policy-effect')]"},
            tagName = {value = "Environment"}
        })
    }

    # Appends the Environment tag on a resource based on the parent resource group if one is not provided.
    # policy_definition_reference {
    #     policy_definition_id = azurerm_policy_definition.append_resource_group_tags.id
    #     parameter_values = jsonencode({
    #         tagName = {value = "Environment"}
    #     })
    # }
}

# resource "azurerm_policy_assignment" "dicci_tagging_standards" {
#     name                 = "apa_tagging_standards"
#     scope                = data.azurerm_management_group.tenant_root.id
#     policy_definition_id = azurerm_policy_set_definition.tagging_standards.id
#     description          = ""
#     display_name         = "Example Tagging Standards"
#     location             = "eastus"

#     parameters = <<PARAMETERS
#         {
#             "policy-effect": {
#                 "value": "deny"
#             }
#         }
#     PARAMETERS

#     identity {
#         type          = "SystemAssigned"
#     }
# }

# resource "azurerm_role_assignment" "apa_tagging_standards" {
#     scope                 = "/providers/Microsoft.Management/managementGroups/${data.azurerm_management_group.tenant_root.name}"
#     role_definition_name  = "Contributor"
#     principal_id          = azurerm_policy_assignment.apa_tagging_standards.identity[0].principal_id
# }
