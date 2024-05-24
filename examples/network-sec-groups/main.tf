/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

module "vsa_network_security_groups" {
  source              = "../../modules/network-sec-groups"
  cluster_name        = var.cluster_name == null ? random_pet.cluster_name.id : var.cluster_name
  unique_id           = module.vsa_resource_groups.resource_unique_id
  resource_group_name = module.vsa_resource_groups.resource_group_name
}

module "vsa_resource_groups" {
  source       = "../../modules/resource-group"
  cluster_name = var.cluster_name == null ? random_pet.cluster_name.id : var.cluster_name
}

resource "random_pet" "cluster_name" {
  length = 2
}