# Azure resource lists

output "external_ip_addresses" {
  value = azurerm_network_interface.azonefs_network_interface_external[*].ip_configuration[0].private_ip_address
}

output "internal_ip_addresses" {
  value = azurerm_network_interface.azonefs_network_interface_internal[*].ip_configuration[0].private_ip_address
}

output "internal_nics" {
  value = azurerm_network_interface.azonefs_network_interface_internal[*].id
}

output "external_nics" {
  value = azurerm_network_interface.azonefs_network_interface_external[*].id
}