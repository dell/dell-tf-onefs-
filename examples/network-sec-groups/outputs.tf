/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

output "cluster_name" {
  description = "The name of the cluster"
  value       = var.cluster_name == null ? random_pet.cluster_name.id : var.cluster_name
}

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.vsa_network_security_groups.resource_group_name
}

output "internal_nsg" {
  description = "The name of the interal network security group"
  value       = module.vsa_network_security_groups.network_security_group_internal
}

output "external_nsg" {
  description = "The name of the external network security group"
  value       = module.vsa_network_security_groups.network_security_group_external
}