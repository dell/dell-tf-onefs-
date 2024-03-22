variable "subscription_id" {
  default = null
}

variable "cluster_name" {
  default = null
}

variable "resource_group_name" {
  default = null
}

variable "unique_id" {}

variable "network_security_group_location" {
  type        = string
  default     = "centralus"
  description = "Location of the network security group."
}

variable "network_security_group_name_suffix" {
  type        = string
  default     = "nsg"
  description = "Suffix of the security group name that's combined with a random ID so name is unique in your Azure subscription."
}
