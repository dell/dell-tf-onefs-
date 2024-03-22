terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.9"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.6"
    }
  }
}

provider "azurerm" {
  skip_provider_registration = true
  subscription_id = var.subscription_id
  features {}
}
