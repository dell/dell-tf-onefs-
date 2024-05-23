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
  value = module.vsa_network_subnets.internal_subnet
}

output "external_subnet" {
  value = module.vsa_network_subnets.external_subnet
}

output "internal_subnet_name" {
  value = module.vsa_network_subnets.internal_subnet_name
}

output "external_subnet_name" {
  value = module.vsa_network_subnets.external_subnet_name
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
