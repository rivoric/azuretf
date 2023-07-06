data "azurerm_client_config" "current" {}

# create a resource group
resource "azurerm_resource_group" "tftest" {
  name     = "tftest"
  location = "North Europe"
}