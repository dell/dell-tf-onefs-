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
}

variable "cluster_name" {
}

variable "cluster_nodes" {
  default = 3
}

variable "location" {
  default = "centralus"
}

variable "address_space" {
  default = "10.20.0.0/16"
}

variable "internal_prefix" {
  default = "10.20.1.0/24"
}

variable "internal_gateway_address" {
  default = null
}

variable "external_prefix" {
  default = "10.20.2.0/24"
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
  default = ""
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
}

variable "storage_account_resource_group" {
}

variable "resource_tags" {
    type = map(string)
    default = {
  }
}

variable "node_size" {
  default = "Standard_D4s_v4"
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

/*
external_secondary_ip is used with node lnn's mapped to
lists of string IPs. Example:

  external_secondary_ip = {
    customer = {
      0 = ["100.93.98.101", "100.93.98.102"]
      1 = ["100.93.98.103", "100.93.98.104"]
      2 = ["100.93.98.106", "100.93.98.105"]
    }
    management = {}
  }
*/
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