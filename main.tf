provider "azurerm" {
  features {}
  skip_provider_registration = true
}

locals {
  network_id_fields   = regex("/subscriptions/(?P<subscription_id>[^/]+)/resourceGroups/(?P<resource_group>[^/]+)/providers/Microsoft.Network/virtualNetworks/(?P<name>.+)", var.network_id)
  internal_cluster_id = var.cluster_id != null ? var.cluster_id : var.cluster_name
}


data "azurerm_resource_group" "azonefs_resource_group" {
  name = var.resource_group != null ? var.resource_group : "${local.internal_cluster_id}-resource-group"
}

resource "azurerm_storage_account" "bootdiag_storage_account" {
  name                     = var.storage_account_name != null ? var.storage_account_name : "${local.internal_cluster_id}stact"
  resource_group_name      = data.azurerm_resource_group.azonefs_resource_group.name
  location                 = data.azurerm_resource_group.azonefs_resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_proximity_placement_group" "azonefs_proximity_placement_group" {
  name                = "${local.internal_cluster_id}-proximity-placement-group"
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
}

resource "azurerm_availability_set" "azonefs_aset" {
  name                          = "${local.internal_cluster_id}-aset"
  location                      = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name           = data.azurerm_resource_group.azonefs_resource_group.name
  proximity_placement_group_id  = azurerm_proximity_placement_group.azonefs_proximity_placement_group.id
  platform_update_domain_count  = var.update_domain_count
  platform_fault_domain_count   = 2
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

resource "azurerm_network_security_group" "azonefs_network_security_group" {
  name                = "${local.internal_cluster_id}-network-security-group"
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
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
    private_ip_address            = cidrhost(var.internal_prefix, count.index + var.addr_range_offset)
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
  name                          = "${local.internal_cluster_id}-${count.index}-network-interface-external"
  location                      = data.azurerm_virtual_network.azonefs_virtual_network.location
  resource_group_name           = data.azurerm_resource_group.azonefs_resource_group.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "external"
    subnet_id                     = data.azurerm_subnet.azonefs_external_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = cidrhost(var.external_prefix, count.index + var.addr_range_offset)
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

resource "azurerm_virtual_machine" "azonefs_node" {
  count               = var.cluster_nodes
  name                = "${local.internal_cluster_id}-node-${count.index}"
  resource_group_name = data.azurerm_resource_group.azonefs_resource_group.name
  location            = data.azurerm_resource_group.azonefs_resource_group.location
  vm_size             = var.node_size
  tags                = var.resource_tags
  availability_set_id = azurerm_availability_set.azonefs_aset.id

  proximity_placement_group_id = azurerm_proximity_placement_group.azonefs_proximity_placement_group.id
  primary_network_interface_id = azurerm_network_interface.azonefs_network_interface_external[count.index].id
  network_interface_ids = [
    azurerm_network_interface.azonefs_network_interface_external[count.index].id,
    azurerm_network_interface.azonefs_network_interface_internal[count.index].id,
  ]

  os_profile {
    admin_username = var.cluster_admin_username
    admin_password = var.cluster_admin_password
    computer_name  = "${local.internal_cluster_id}-node-${count.index}"

    # OneFS requires json on a single line and it must be double base64 encoded.
    custom_data = base64encode(base64encode(jsonencode(jsondecode(
      templatefile("${path.module}/machineid.template.json", {
        jdev                     = var.jdev
        addr_range_offset        = var.addr_range_offset,
        max_num_nodes            = var.max_num_nodes,
        cluster_name             = var.cluster_name,
        cluster_nodes            = var.cluster_nodes,
        node_number              = count.index,
        admin_password           = var.cluster_admin_password,
        root_password            = var.cluster_root_password,
        dns_servers              = var.dns_servers,
        dns_domains              = var.dns_domains,
        internal_prefix          = var.internal_prefix
        internal_gateway_address = var.internal_gateway_address == null ? cidrhost(var.internal_prefix, 1) : var.internal_gateway_address,
        external_prefix          = var.external_prefix,
        external_gateway_address = var.external_gateway_address == null ? cidrhost(var.external_prefix, 1) : var.external_gateway_address,
        smartconnect_zone        = var.smartconnect_zone,
        ocm_endpoint             = var.ocm_endpoint,
        timezone                 = var.timezone,
        drive_size               = var.data_disk_size,
        num_drives               = var.data_disks_per_node,
      })
    ))))

  }

  lifecycle {
    ignore_changes = [os_profile]
    precondition {
      condition     = var.cluster_nodes <= 20 && var.cluster_nodes <= var.max_num_nodes
      error_message = "PowerScale maximum number of nodes must be specified at cluster creation time and cannot scale more than 20 nodes."
    }
  }


  os_profile_linux_config {
    disable_password_authentication = false
  }

  storage_image_reference {
    id = var.image_id
  }

  delete_os_disk_on_termination = true
  storage_os_disk {
    name              = "${local.internal_cluster_id}-node-os-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = var.os_disk_type
  }

  delete_data_disks_on_termination = true
  dynamic "storage_data_disk" {
    for_each = range(var.data_disks_per_node)

    content {
      create_option     = "Empty"
      lun               = storage_data_disk.key
      name              = "${local.internal_cluster_id}-node-data-${count.index}-${storage_data_disk.key}"
      disk_size_gb      = var.data_disk_size
      managed_disk_type = var.data_disk_type
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.bootdiag_storage_account.primary_blob_endpoint
  }

  depends_on = [
    azurerm_network_interface_security_group_association.azonefs_network_interface_external_nsg_association,
    azurerm_network_interface_security_group_association.azonefs_network_interface_internal_nsg_association
  ]
}

output "ip_addresses" {
  value = azurerm_network_interface.azonefs_network_interface_external[*].ip_configuration[0].private_ip_address
}
