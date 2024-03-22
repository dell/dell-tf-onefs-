/* Get available subnet address*/
data "external" "get_available_subnet" {
  program = [
    "${path.module}/scripts/get_available_subnets.sh"
  ]
  query = {
    arg1 = var.subscription_id
    arg2 = var.vnet_resource_group_name
    arg3 = var.vnet_name
    arg4 = var.cloud_provider
    arg5 = var.get_subnets
  }
}

# Create internal subnet
resource "azurerm_subnet" "internal_subnet" {
  name                 = "${var.unique_id}-${var.computer_name}-internal-${var.subnet_suffix}"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [data.external.get_available_subnet.result.azure_internal_subnet]
}

# Create external subnet
resource "azurerm_subnet" "external_subnet" {
  name                 = "${var.unique_id}-${var.computer_name}-external-${var.subnet_suffix}"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [data.external.get_available_subnet.result.azure_external_subnet]
}
