# Old versions of terraform need to enable variable_validation
# so we can validate the passwords. New versions do not need this.
# TODO(tswanson): What version are we using?
terraform {
  
}
variable "resource_group" {
  default = null
}

variable "network_id" {
}

variable "cluster_id" {
  default = null
}


variable "cluster_name" {
}

variable "cluster_nodes" {
  default = 3
}

variable "internal_prefix" {
}

variable "internal_gateway_address" {
  default = null
}

variable "external_prefix" {
}

variable "internal_subnet_name" {
}

variable "external_subnet_name" {
}

# The offset into the address ranges where we will begin our IP ranges
variable "addr_range_offset" {
  default = 4
  validation {
    condition = var.addr_range_offset > 3
    error_message = "Azure reserves the first four IP addresses in subnets. addr_range_offset must be >3."
  }
}

# The max number of nodes we will scale up to
variable "max_num_nodes" {
  default = 3
}

variable "external_gateway_address" {
  default = null
}

variable "cluster_root_password" {
  validation {
    condition = (
      length(var.cluster_root_password) > 6 &&
      length(var.cluster_root_password) <= 72 &&
      (min(1, length(regexall("[a-z]+", var.cluster_root_password))) +
       min(1, length(regexall("[A-Z]+", var.cluster_root_password))) +
       min(1, length(regexall("[0-9]+", var.cluster_root_password))) +
       min(1, length(regexall("[!-/:-@[-`{-~]+", var.cluster_root_password)))) >= 3 &&
      length(regexall("[[:space:]]+", var.cluster_root_password)) == 0 &&
      length(regexall("[[:cntrl:]]+", var.cluster_root_password)) == 0)
    error_message = "The supplied password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following:\r\n1) Contains an uppercase character\r\n2) Contains a lowercase character\r\n3) Contains a numeric digit\r\n4) Contains a special character\r\n5) Control characters are not allowed."
  }
}

variable "cluster_admin_username" {
  default = "azonefs"
}

variable "cluster_admin_password" {
  validation {
    condition = (
      length(var.cluster_admin_password) > 6 &&
      length(var.cluster_admin_password) <= 72 &&
      (min(1, length(regexall("[a-z]+", var.cluster_admin_password))) +
       min(1, length(regexall("[A-Z]+", var.cluster_admin_password))) +
       min(1, length(regexall("[0-9]+", var.cluster_admin_password))) +
       min(1, length(regexall("[!-/:-@[-`{-~]+", var.cluster_admin_password)))) >= 3 &&
      length(regexall("[[:space:]]+", var.cluster_admin_password)) == 0 &&
      length(regexall("[[:cntrl:]]+", var.cluster_admin_password)) == 0)
    error_message = "The supplied password must be between 6-72 characters long and must satisfy at least 3 of password complexity requirements from the following:\r\n1) Contains an uppercase character\r\n2) Contains a lowercase character\r\n3) Contains a numeric digit\r\n4) Contains a special character\r\n5) Control characters are not allowed."
  }
}

variable "image_id" {
}

variable "dns_servers" {
  default = "[ \"168.63.129.16\", \"169.254.169.254\"]"
}

variable "dns_domains" {
  default = "c.daring-sunset-250103.internal"
}

variable "smartconnect_zone" {
  type        = string
  description = "FQDN to use as the DNS zone for SmartConnect"
  default     = ""
}

variable "ocm_endpoint" {
  type        = string
  description = "Endpoint for OneFS cluster to communicate with OCM."
  default     = ""
}

variable "storage_account_name" {
  default = null
}

variable "resource_tags" {
    type = map(string)
    default = {
  }
}

variable "node_size" {
  default = "Standard_D32s_v4"
}

variable "os_disk_type" {
  default = "Standard_LRS"
}

variable "data_disk_type" {
  default = "StandardSSD_LRS"
}

variable "data_disk_size" {
  default = 12
}

variable "data_disks_per_node" {
  default = 3
}

variable "external_secondary_ip" {
  type = object({
    customer = map(list(string))
    management = map(list(string))
  })
  default = {
    customer = {}
    management = {}
  }
}

variable "timezone" {
  type        = string
  default     = "Greenwich Mean Time"
}
