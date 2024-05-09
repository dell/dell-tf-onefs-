/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

variable "unique_id" {}

variable "cluster_name" {}

variable "subnet_suffix" {
  default = "subnet"
}

variable "vnet_resource_group_name" {}

variable "vnet_name" {}

variable "internal_prefix" {
  type = string
}

variable "external_prefix" {
  type = string
}

