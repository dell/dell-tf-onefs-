<!--

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

-->

## Requirements

### Azure PowerScale IAM Requirements

In order to create a PowerScale cluster in the Azure Public Cloud, an administrator must create a role with the following permissions.

```
[
  {
    "assignableScopes": [
      "/subscriptions/{subscriptionId1}"
    ],
    "description": "PowerScale cluster lifecycle role.",
    "id": "/subscriptions/{subscriptionId1}/providers/Microsoft.Authorization/roleDefinitions/pscaleliferole",
    "name": "pscaleliferole",
    "permissions": [
      {
        "actions": [
          "Microsoft.Resources/subscriptions/resourceGroups/read",
          "Microsoft.Resources/subscriptions/resourceGroups/write", # Only if we want to be able to create RGs from terraform.
          "Microsoft.Compute/availabilitySets/read",
          "Microsoft.Compute/availabilitySets/write",
          "Microsoft.Compute/availabilitySets/delete",
          "Microsoft.Compute/proximityPlacementGroups/read",
          "Microsoft.Compute/proximityPlacementGroups/write",
          "Microsoft.Compute/proximityPlacementGroups/delete",
          "Microsoft.Network/virtualNetworks/read",
          "Microsoft.Network/virtualNetworks/subnets/read",
          "Microsoft.Network/networkSecurityGroups/read",
          "Microsoft.Network/networkSecurityGroups/write",
          "Microsoft.Network/networkSecurityGroups/delete",
          #"Microsoft.Network/networkSecurityGroups/securityRules/read",
          #"Microsoft.Network/networkSecurityGroups/securityRules/write",
          #"Microsoft.Network/networkSecurityGroups/securityRules/delete",
          "Microsoft.Network/networkInterfaces/read",
          "Microsoft.Network/networkInterfaces/write",
          "Microsoft.Network/networkInterfaces/delete",
          "Microsoft.Compute/disks/read",
          "Microsoft.Compute/disks/write",
          "Microsoft.Compute/disks/delete"",
          "Microsoft.Compute/images/read",
          "Microsoft.Compute/virtualMachines/read",
          "Microsoft.Compute/virtualMachines/write",
          "Microsoft.Compute/virtualMachines/delete",
        ],
        "dataActions": [],
        "notActions": [],
        "notDataActions": []
      }
    ],
    "roleName": "PowerScale Cluster Lifecycle Operator",
    "roleType": "CustomRole",
    "type": "Microsoft.Authorization/roleDefinitions"
  }
]
```

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_interface.azonefs_network_interface_external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface.azonefs_network_interface_internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.azonefs_network_interface_external_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_interface_security_group_association.azonefs_network_interface_internal_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.azonefs_network_security_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_proximity_placement_group.azonefs_proximity_placement_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/proximity_placement_group) | resource |
| [azurerm_resource_group.azonefs_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_storage_account.bootdiag_storage_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_subnet.azonefs_external_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.azonefs_internal_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_machine.azonefs_node](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine) | resource |
| [azurerm_virtual_network.azonefs_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address\_space](#input\_address\_space) | n/a | `string` | `"10.20.0.0/16"` | no |
| <a name="input_cluster_admin_password"></a> [cluster\_admin\_password](#input\_cluster\_admin\_password) | n/a | `any` | n/a | yes |
| <a name="input_cluster_admin_username"></a> [cluster\_admin\_username](#input\_cluster\_admin\_username) | n/a | `string` | `"azonefs"` | no |
| <a name="input_cluster_id"></a> [cluster\_id](#input\_cluster\_id) | n/a | `any` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | n/a | `any` | n/a | yes |
| <a name="input_cluster_nodes"></a> [cluster\_nodes](#input\_cluster\_nodes) | n/a | `number` | `3` | no |
| <a name="input_cluster_root_password"></a> [cluster\_root\_password](#input\_cluster\_root\_password) | n/a | `any` | n/a | yes |
| <a name="input_data_disk_size"></a> [data\_disk\_size](#input\_data\_disk\_size) | n/a | `number` | `12` | no |
| <a name="input_data_disk_type"></a> [data\_disk\_type](#input\_data\_disk\_type) | n/a | `string` | `"StandardSSD_LRS"` | no |
| <a name="input_data_disks_per_node"></a> [data\_disks\_per\_node](#input\_data\_disks\_per\_node) | n/a | `number` | `3` | no |
| <a name="input_dns_domains"></a> [dns\_domains](#input\_dns\_domains) | n/a | `string` | `"c.daring-sunset-250103.internal"` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | n/a | `string` | `"[ \"168.63.129.16\", \"169.254.169.254\"]"` | no |
| <a name="input_external_gateway_address"></a> [external\_gateway\_address](#input\_external\_gateway\_address) | n/a | `any` | `null` | no |
| <a name="input_external_prefix"></a> [external\_prefix](#input\_external\_prefix) | n/a | `string` | `"10.20.2.0/24"` | no |
| <a name="input_external_secondary_ip"></a> [external\_secondary\_ip](#input\_external\_secondary\_ip) | n/a | <pre>object({<br>    customer   = map(list(string))<br>    management = map(list(string))<br>  })</pre> | <pre>{<br>  "customer": {},<br>  "management": {}<br>}</pre> | no |
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | n/a | `string` | `""` | no |
| <a name="input_internal_gateway_address"></a> [internal\_gateway\_address](#input\_internal\_gateway\_address) | n/a | `any` | `null` | no |
| <a name="input_internal_prefix"></a> [internal\_prefix](#input\_internal\_prefix) | n/a | `string` | `"10.20.1.0/24"` | no |
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | `"centralus"` | no |
| <a name="input_network_id"></a> [network\_id](#input\_network\_id) | n/a | `any` | n/a | yes |
| <a name="input_node_size"></a> [node\_size](#input\_node\_size) | n/a | `string` | `"Standard_D32s_v4"` | no |
| <a name="input_ocm_endpoint"></a> [ocm\_endpoint](#input\_ocm\_endpoint) | Endpoint for OneFS cluster to communicate with OCM. | `string` | `""` | no |
| <a name="input_os_disk_type"></a> [os\_disk\_type](#input\_os\_disk\_type) | n/a | `string` | `"Standard_LRS"` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | n/a | `any` | `null` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_smartconnect_zone"></a> [smartconnect\_zone](#input\_smartconnect\_zone) | FQDN to use as the DNS zone for SmartConnect | `string` | `""` | no |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name) | n/a | `any` | `null` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | n/a | `string` | `"Greenwich Mean Time"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_internal_ip_addresses"></a> [internal\_ip\_addresses](#output\_internal\_ip\_addresses) | n/a |
| <a name="output_ip_addresses"></a> [ip\_addresses](#output\_ip\_addresses) | n/a |
