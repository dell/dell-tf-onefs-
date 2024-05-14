/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

output "resource_group_name" {
  value = var.resource_group_name
}

output "network_security_group_internal" {
  value = azurerm_network_security_group.internal-nsg.name
}

output "network_security_group_external" {
  value = azurerm_network_security_group.external-nsg.name
}
