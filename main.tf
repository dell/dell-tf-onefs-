/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

/**
 Main terraform Script to deploy PowerScale Cluster in Azure
*/

provider "azurerm" {
  skip_provider_registration = true
  #features {}
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

locals {
  network_id_fields   = regex("/subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/Microsoft.Network/virtualNetworks/(?P<name>.+)", var.network_id)
  internal_cluster_id = var.cluster_id != null ? var.cluster_id : var.cluster_name
}


data "azurerm_resource_group" "azonefs_resource_group" {
  name = var.resource_group != null ? var.resource_group : "${local.internal_cluster_id}-resource-group"
  #name = azurerm_resource_group.rg.name != null ? azurerm_resource_group.rg.name : "${local.internal_cluster_id}-resource-group"
}

resource "azurerm_proximity_placement_group" "azonefs_proximity_placement_group" {
  name                = "${local.internal_cluster_id}-proximity-placement-group"
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
}

resource "azurerm_availability_set" "azonefs_aset" {
  name                         = "${local.internal_cluster_id}-aset"
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

data "azurerm_network_security_group" "azonefs_internal_network_security_group" {
  name                = var.internal_nsg_name
  resource_group_name = var.internal_nsg_resource_group
}

data "azurerm_network_security_group" "azonefs_external_network_security_group" {
  name                = var.external_nsg_name
  resource_group_name = var.external_nsg_resource_group
}


resource "azurerm_network_interface" "azonefs_network_interface_internal" {
  count                         = var.cluster_nodes
  name                          = "${local.internal_cluster_id}-${count.index}-network-interface-internal"
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
  network_security_group_id = data.azurerm_network_security_group.azonefs_internal_network_security_group.id
  # The depends_one is needed if we don't define a network security rule. Otherwise Terraform will attempt to
  # create this association before it creates the network security group which leads to an error.
  depends_on = [
    azurerm_network_interface.azonefs_network_interface_internal
  ]
}

resource "azurerm_network_interface" "azonefs_network_interface_external" {
  count                         = var.cluster_nodes
  name                          = "${local.internal_cluster_id}-${count.index}-network-interface-external"
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
  network_security_group_id = data.azurerm_network_security_group.azonefs_external_network_security_group.id
  # The depends_one is needed if we don't define a network security rule. Otherwise Terraform will attempt to
  # create this association before it creates the network security group which leads to an error.
  depends_on = [
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
        credentials_hashed       = var.credentials_hashed,
        hashed_root_password     = var.hashed_admin_passphrase,
        hashed_admin_password    = var.hashed_root_passphrase,
        smartconnect_zone        = var.smartconnect_zone,
        timezone                 = var.timezone,
      }
    )
  )
}

locals {
  root_password     = coalesce(var.cluster_root_password, "a")
  admin_password    = coalesce(var.cluster_admin_password, "a")
  root_length_check = length(local.root_password) > 6 && length(local.root_password) <= 72
  root_complexity_check = (
    min(1, length(regexall("[a-z]+", local.root_password))) +
    min(1, length(regexall("[A-Z]+", local.root_password))) +
    min(1, length(regexall("[0-9]+", local.root_password))) +
    min(1, length(regexall("[!-/:-@[-`{-~]+", local.root_password)))
  ) >= 3
  root_space_control_check = length(regexall("[[:space:]]+", local.admin_password)) == 0 && length(regexall("[[:cntrl:]]+", local.admin_password)) == 0
  admin_length_check       = length(local.admin_password) > 6 && length(local.admin_password) <= 72
  admin_complexity_check = (
    min(1, length(regexall("[a-z]+", local.admin_password))) +
    min(1, length(regexall("[A-Z]+", local.admin_password))) +
    min(1, length(regexall("[0-9]+", local.admin_password))) +
    min(1, length(regexall("[!-/:-@[-`{-~]+", local.admin_password)))
  ) >= 3
  admin_space_control_check = length(regexall("[[:space:]]+", local.admin_password)) == 0 && length(regexall("[[:cntrl:]]+", local.admin_password)) == 0
}

resource "azurerm_resource_group_template_deployment" "azonefs_node" {
  count               = var.cluster_nodes
  name                = "${local.internal_cluster_id}-node-${count.index}-deployment-${uuid()}"
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
  deployment_mode     = "Incremental"
  template_content    = file("${path.module}/vm.json")
  parameters_content = jsonencode({
    "name" : {
      value = "${local.internal_cluster_id}-node-${count.index}"
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
    precondition {
      condition = (var.cluster_root_password == null) || (
        local.root_length_check && local.root_complexity_check && local.root_space_control_check
      )
      error_message = "The supplied password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following:\r\n1) Contains an uppercase character\r\n2) Contains a lowercase character\r\n3) Contains a numeric digit\r\n4) Contains a special character\r\n5) Control characters are not allowed."
    }
    precondition {
      condition = (var.cluster_admin_password == null) || (
        local.admin_length_check && local.admin_complexity_check && local.admin_space_control_check
      )
      error_message = "The supplied password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following:\r\n1) Contains an uppercase character\r\n2) Contains a lowercase character\r\n3) Contains a numeric digit\r\n4) Contains a special character\r\n5) Control characters are not allowed."
    }
  }

  depends_on = [
    azurerm_network_interface.azonefs_network_interface_external,
    azurerm_network_interface.azonefs_network_interface_internal,
    azurerm_proximity_placement_group.azonefs_proximity_placement_group,
    azurerm_availability_set.azonefs_aset,
    azurerm_network_interface_security_group_association.azonefs_network_interface_external_nsg_association,
    azurerm_network_interface_security_group_association.azonefs_network_interface_internal_nsg_association
  ]
}
