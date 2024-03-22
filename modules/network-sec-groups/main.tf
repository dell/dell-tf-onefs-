/* Network Security groups */

resource "azurerm_network_security_group" "internal-nsg" {
  location            = var.network_security_group_location
  name                = "${var.unique_id}-${var.cluster_name}-internal-${var.network_security_group_name_suffix}"
  resource_group_name = var.resource_group_name

  tags = {
    environment = "Thunderscale-vsa-dev"
  }
}

resource "azurerm_network_security_group" "external-nsg" {
  location            = var.network_security_group_location
  name                = "${var.unique_id}-${var.cluster_name}-external-${var.network_security_group_name_suffix}"
  resource_group_name = var.resource_group_name

  tags = {
    environment = "Thunderscale-vsa-dev"
  }
}
