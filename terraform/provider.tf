terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.63"
    }
  }

  backend "azurerm" {
    resource_group_name  = "bootstrap"
    storage_account_name = "tf4pinmqgfv7ncm"
    container_name       = "sf4pinmqgfv7ncm"
    key                  = "azuretf.tfstate"
  }
}
 
provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  version = "~>2.0"
  features {}
}