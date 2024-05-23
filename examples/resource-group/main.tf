/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

resource "random_pet" "cluster_name" {
  length = 2
}

module "vsa_resource_groups" {
  source       = "../../modules/resource-group"
  cluster_name = var.cluster_name == null ? random_pet.cluster_name.id : var.cluster_name
}