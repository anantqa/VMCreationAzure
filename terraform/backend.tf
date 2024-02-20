terraform {
  backend "azurerm" {
    storage_account_name = "fordevopsaccessstg001"
    container_name = "terraform-state"
    key = "createvm.tfstate"
    
  }
}