/*

        Copyright (c) 2024 Dell Inc. or its subsidiaries. All rights reserved.

*/

variable "cluster_name" {
  default     = null
  type        = string
  description = "The cluster name to be used as a tag in the security group"
}

variable "subscription_id" {
  type        = string
  description = "The subscription id to be used to generate the resource group in"
}
