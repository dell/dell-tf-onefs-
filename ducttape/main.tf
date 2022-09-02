terraform {
  backend "azurerm" {
    resource_group_name  = "ocm_infrastructure"
    storage_account_name = "ocmterraformstate"
    container_name       = "ocm-terraform-state"
    key                  = "terraform"
  }
}

module "onefs" {
  source = "../"
}


output "ip_addresses" {
  value = module.onefs.ip_addresses
}

output "internal_ip_addresses" {
  value = module.onefs.internal_ip_addresses
}