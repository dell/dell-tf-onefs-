output "internal_subnet" {
  value = data.external.get_available_subnet.result.azure_internal_subnet
}

output "external_subnet" {
  value = data.external.get_available_subnet.result.azure_external_subnet
}

output "internal_subnet_name" {
  value = azurerm_subnet.internal_subnet.name
}

output "external_subnet_name" {
  value = azurerm_subnet.external_subnet.name
}
