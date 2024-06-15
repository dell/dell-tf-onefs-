/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

# Azure resource lists
output "resource_group_name" {
  value = module.vsa_resource_groups.resource_group_name
}

output "network_security_group_internal" {
  value = module.vsa_network_security_groups.network_security_group_internal
}

output "network_security_group_external" {
  value = module.vsa_network_security_groups.network_security_group_external
}

output "internal_subnet" {
  value = var.internal_prefix
}

output "external_subnet" {
  value = var.external_prefix
}

output "internal_subnet_name" {
  value = var.internal_subnet_name
}

output "external_subnet_name" {
  value = var.external_subnet_name
}

output "internal_nics" {
  value = module.powerscale.internal_nics
}

output "internal_ip_addresses" {
  value = module.powerscale.internal_ip_addresses
}

output "external_nics" {
  value = module.powerscale.external_nics
}

output "external_ip_addresses" {
  value = module.powerscale.external_ip_addresses
}

output "cluster_id" {
  description = "Cluster ID"
  value       = module.powerscale.cluster_id
}

output "first_node_external_ip_address" {
  description = "External IP address of the first node"
  value       = module.powerscale.first_node_external_ip_address
}

output "first_node_instance_name" {
  description = "First node instance name"
  value       = module.powerscale.first_node_instance_name
}

output "first_node_instance_id" {
  description = "First node instance ID"
  value       = module.powerscale.first_node_instance_id
}