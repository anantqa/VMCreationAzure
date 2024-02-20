terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.92.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "c6ecdc71-1b56-4cad-8345-0132e55a09d0"
  tenant_id = var.spn-tenant-id
  client_id = var.spn-client-id
  client_secret = var.spn-client-secret
  features {}
}