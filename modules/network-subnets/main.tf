/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

/* Get available subnet address*/

# Create internal subnet
resource "azurerm_subnet" "internal_subnet" {
  name                 = "${var.unique_id}-${var.cluster_name}-internal-${var.subnet_suffix}"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.internal_prefix]
}

# Create external subnet
resource "azurerm_subnet" "external_subnet" {
  name                 = "${var.unique_id}-${var.cluster_name}-external-${var.subnet_suffix}"
  resource_group_name  = var.vnet_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.external_prefix]
}
