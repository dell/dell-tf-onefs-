Azure PowerScale IAM Requirements
===============

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
