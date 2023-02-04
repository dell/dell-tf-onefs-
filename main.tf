
terraform {
  required_providers {
    azurerm = {
      version = "~>3.00"
    }
  }
}


locals {
  network_id_fields = regex("/subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/Microsoft.Network/virtualNetworks/(?P<name>.+)", var.network_id)
}


data "azurerm_resource_group" "azonefs_resource_group" {
  name = var.resource_group != null ? var.resource_group : "${var.cluster_name}-resource-group"
}

resource "azurerm_proximity_placement_group" "azonefs_proximity_placement_group" {
  name                = "${var.cluster_name}-proximity-placement-group"
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
}

resource "azurerm_availability_set" "azonefs_aset" {
  name                         = "${var.cluster_name}-aset"
  location                     = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name          = data.azurerm_resource_group.azonefs_resource_group.name
  proximity_placement_group_id = azurerm_proximity_placement_group.azonefs_proximity_placement_group.id
  platform_update_domain_count = var.update_domain_count
  platform_fault_domain_count  = 2
}

data "azurerm_virtual_network" "azonefs_virtual_network" {
  name                = local.network_id_fields.name
  resource_group_name = local.network_id_fields.resource_group
}

data "azurerm_subnet" "azonefs_internal_subnet" {
  name                 = var.internal_subnet_name
  resource_group_name  = data.azurerm_virtual_network.azonefs_virtual_network.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.azonefs_virtual_network.name
}

data "azurerm_subnet" "azonefs_external_subnet" {
  name                 = var.external_subnet_name
  resource_group_name  = data.azurerm_virtual_network.azonefs_virtual_network.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.azonefs_virtual_network.name
}

locals {
  internal_prefix = data.azurerm_subnet.azonefs_internal_subnet.address_prefixes[0]
  external_prefix = data.azurerm_subnet.azonefs_external_subnet.address_prefixes[0]
}

resource "azurerm_network_security_group" "azonefs_network_security_group" {
  name                = "${var.cluster_name}-network-security-group"
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
}

resource "azurerm_network_interface" "azonefs_network_interface_internal" {
  count                         = var.cluster_nodes
  name                          = "${var.cluster_name}-${count.index}-network-interface-internal"
  location                      = data.azurerm_virtual_network.azonefs_virtual_network.location
  resource_group_name           = data.azurerm_resource_group.azonefs_resource_group.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.azonefs_internal_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(local.internal_prefix, count.index + var.addr_range_offset)
  }
}

resource "azurerm_network_interface_security_group_association" "azonefs_network_interface_internal_nsg_association" {
  count                     = var.cluster_nodes
  network_interface_id      = azurerm_network_interface.azonefs_network_interface_internal[count.index].id
  network_security_group_id = azurerm_network_security_group.azonefs_network_security_group.id
  # The depends_one is needed if we don't define a network security rule. Otherwise Terraform will attempt to
  # create this association before it creates the network security group which leads to an error.
  depends_on = [
    azurerm_network_security_group.azonefs_network_security_group,
    azurerm_network_interface.azonefs_network_interface_internal
  ]
}

resource "azurerm_network_interface" "azonefs_network_interface_external" {
  count                         = var.cluster_nodes
  name                          = "${var.cluster_name}-${count.index}-network-interface-external"
  location                      = data.azurerm_virtual_network.azonefs_virtual_network.location
  resource_group_name           = data.azurerm_resource_group.azonefs_resource_group.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "external"
    subnet_id                     = data.azurerm_subnet.azonefs_external_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(local.external_prefix, count.index + var.addr_range_offset)
    primary                       = true
  }

  dynamic "ip_configuration" {
    for_each = lookup(var.external_secondary_ip.customer, count.index, [])
    content {
      name                          = "external_secondary${ip_configuration.key}"
      subnet_id                     = data.azurerm_subnet.azonefs_external_subnet.id
      private_ip_address_allocation = "Static"
      private_ip_address            = ip_configuration.value
      primary                       = false
    }
  }
  # TODO: management secondary IPs when management subnet is added
}

resource "azurerm_network_interface_security_group_association" "azonefs_network_interface_external_nsg_association" {
  count                     = var.cluster_nodes
  network_interface_id      = azurerm_network_interface.azonefs_network_interface_external[count.index].id
  network_security_group_id = azurerm_network_security_group.azonefs_network_security_group.id
  # The depends_one is needed if we don't define a network security rule. Otherwise Terraform will attempt to
  # create this association before it creates the network security group which leads to an error.
  depends_on = [
    azurerm_network_security_group.azonefs_network_security_group,
    azurerm_network_interface.azonefs_network_interface_external

  ]
}

locals {
  mid = jsondecode(
    templatefile("${path.module}/machineid.tftpl", {
      addr_range_offset = var.addr_range_offset
      cluster_nodes     = var.cluster_nodes,
      drive_size        = var.data_disk_size,
      external_prefix   = local.external_prefix,
      internal_prefix   = local.internal_prefix,
      jdev              = jsonencode(var.jdev)
      num_drives        = var.data_disks_per_node,
      lj                = startswith(var.jdev, "bay") ? true : false
      journal_bays      = startswith(var.jdev, "bay") ? 1 : 0
      journal_type      = startswith(var.jdev, "bay") ? 1 : 8 # Assume NVDIMM
    })
  )

  acs = jsondecode(
    templatefile(
      "${path.module}/acs.tftpl", {
        addr_range_offset        = var.addr_range_offset,
        admin_password           = var.cluster_admin_password,
        cluster_name             = var.cluster_name,
        cluster_nodes            = var.cluster_nodes,
        dns_domains              = var.dns_domains,
        dns_servers              = var.dns_servers,
        external_gateway_address = var.external_gateway_address == null ? cidrhost(local.external_prefix, 1) : var.external_gateway_address,
        external_prefix          = local.external_prefix,
        internal_gateway_address = var.internal_gateway_address == null ? cidrhost(local.internal_prefix, 1) : var.internal_gateway_address,
        internal_prefix          = local.internal_prefix
        max_num_nodes            = var.max_num_nodes
        root_password            = var.cluster_root_password,
        smartconnect_zone        = var.smartconnect_zone,
        timezone                 = var.timezone,
      }
    )
  )
}

resource "azurerm_resource_group_template_deployment" "azonefs_node" {
  count               = var.cluster_nodes
  name                = "${var.cluster_name}-node-${count.index}-deployment-${uuid()}"
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/vm.json")
  parameters_content = jsonencode({
    "name" : {
      value = "${var.cluster_name}-node-${count.index}"
    },
    "location" : {
      value = data.azurerm_resource_group.azonefs_resource_group.location
    },
    "sku" : {
      value = var.node_size
    },
    "os_disk_type" : {
      value = var.os_disk_type
    },
    "data_disk_type" : {
      value = var.data_disk_type
    },
    "data_disk_size" : {
      value = var.data_disk_size
    },
    "data_disk_count" : {
      value = var.data_disks_per_node
    },
    "avset_id" : {
      value = azurerm_availability_set.azonefs_aset.id
    },
    "ppg_id" : {
      value = azurerm_proximity_placement_group.azonefs_proximity_placement_group.id
    },
    "image_id" : {
      value = var.image_id
    },
    "user_data" : {
      value = base64encode(format(count.index != 0 ? jsonencode(local.mid) : jsonencode(merge(local.mid, local.acs)), count.index))
    },
    "internal_nic_id" : {
      value = azurerm_network_interface.azonefs_network_interface_internal[count.index].id
    },
    "external_nic_id" : {
      value = azurerm_network_interface.azonefs_network_interface_external[count.index].id
    }
  })

  lifecycle {
    ignore_changes = [name]
    precondition {
      condition     = var.cluster_nodes <= 20 && var.cluster_nodes <= var.max_num_nodes
      error_message = "PowerScale maximum number of nodes must be specified at cluster creation time and cannot scale more than 20 nodes."
    }
  }

  depends_on = [
    azurerm_network_interface_security_group_association.azonefs_network_interface_external_nsg_association,
    azurerm_network_interface_security_group_association.azonefs_network_interface_internal_nsg_association
  ]
}

output "ip_addresses" {
  value = azurerm_network_interface.azonefs_network_interface_external[*].ip_configuration[0].private_ip_address
}

output "internal_ip_addresses" {
  value = azurerm_network_interface.azonefs_network_interface_internal[*].ip_configuration[0].private_ip_address
}

