/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

/* Create a PowerScale Cluster in Azure */
module "vsa_resource_groups" {
  source       = "../../modules/resource-group"
  cluster_name = var.cluster_name
}

module "vsa_network_security_groups" {
  source              = "../../modules/network-sec-groups"
  cluster_name        = var.cluster_name
  unique_id           = module.vsa_resource_groups.resource_unique_id
  resource_group_name = module.vsa_resource_groups.resource_group_name
}

module "powerscale" {
  source                      = "../.."
  subscription_id             = var.subscription_id
  image_id                    = var.image_id
  cluster_admin_password      = var.cluster_admin_password
  cluster_root_password       = var.cluster_root_password
  credentials_hashed          = var.credentials_hashed
  cluster_name                = var.cluster_name
  cluster_nodes               = var.cluster_nodes
  max_num_nodes               = var.max_num_nodes
  smartconnect_zone           = var.smartconnect_zone
  external_nsg_name           = module.vsa_network_security_groups.network_security_group_external
  external_nsg_resource_group = module.vsa_resource_groups.resource_group_name
  external_subnet_name        = var.external_subnet_name
  # kics-scan ignore-line
  hashed_root_passphrase = var.hashed_root_passphrase == null ? var.default_hashed_password : var.hashed_root_passphrase
  # kics-scan ignore-line
  hashed_admin_passphrase     = var.hashed_admin_passphrase == null ? var.default_hashed_password : var.hashed_admin_passphrase
  internal_nsg_name           = module.vsa_network_security_groups.network_security_group_internal
  internal_nsg_resource_group = module.vsa_network_security_groups.resource_group_name
  internal_subnet_name        = var.internal_subnet_name
  network_id                  = var.network_id
  resource_group              = module.vsa_resource_groups.resource_group_name
}