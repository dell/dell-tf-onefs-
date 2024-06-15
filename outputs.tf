/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

# Azure resource lists

output "cluster_id" {
  value = local.internal_cluster_id
}


output "first_node_instance_name" {
  value = azurerm_resource_group_template_deployment.azonefs_node[0].name
}

output "first_node_instance_id" {
  value = azurerm_resource_group_template_deployment.azonefs_node[0].id
}


output "first_node_external_ip_address" {
  value = azurerm_network_interface.azonefs_network_interface_external[0].ip_configuration[0].private_ip_address
}

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

output "join_mode" {
  value = var.join_mode
}