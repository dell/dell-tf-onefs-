/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "resource_unique_id" {
  value = random_string.unique_id.result
}
