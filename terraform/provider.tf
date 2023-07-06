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
  features {}
}