variable "subscription_id" {
  default = null
}

variable "cluster_name" {
  default = null
}

variable "resource_group_location" {
  type        = string
  default     = "centralus"
  description = "Location of the resource group."
}

variable "resource_group_name_suffix" {
  type        = string
  default     = "rg"
  description = "Suffix of the resource group name that's combined with a random ID so name is unique in your Azure subscription."
}
