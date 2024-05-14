/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

output "internal_subnet" {
  value = var.internal_prefix
}

output "external_subnet" {
  value = var.external_prefix
}

output "internal_subnet_name" {
  value = azurerm_subnet.internal_subnet.name
}

output "external_subnet_name" {
  value = azurerm_subnet.external_subnet.name
}
