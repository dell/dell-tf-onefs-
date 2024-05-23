/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

output "resource_group_name" {
  description = "The name of the resource group"
  value       = module.vsa_resource_groups
}

output "cluster_name" {
  description = "The name of the cluster"
  value       = var.cluster_name == null ? random_pet.cluster_name.id : var.cluster_name
}