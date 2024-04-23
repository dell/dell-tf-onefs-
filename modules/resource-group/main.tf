resource "random_string" "unique_id" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = "${random_string.unique_id.result}-${var.cluster_name}-${var.resource_group_name_suffix}"
}

