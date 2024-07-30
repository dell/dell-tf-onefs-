## Introduction

This folder contains a [Terraform](https://www.terraform.io/) module that deploys a single node
[PowerScale](https://www.delltechnologies.com/partner/en-us/partner/powerscale.htm) cluster in the [Azure](https://azure.microsoft.com/en-us) platform. 

It provisions all the necessary resources required to deploy the cluster including the following:
1. [Proximity Placement Groups](https://learn.microsoft.com/en-us/azure/virtual-machines/co-location)
2. [Network interface(s)](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-network-interface?tabs=azure-portal)
3. [Availability Sets](https://learn.microsoft.com/en-us/azure/virtual-machines/availability-set-overview)
4. [Virtual Machine(s)](https://learn.microsoft.com/en-us/azure/virtual-machines/overview)
5. [Managed Disk(s)](https://learn.microsoft.com/en-us/azure/virtual-machines/managed-disks-overview)


## Additional Components

The additional components which needs to be performed/deployed separately and are not included in this module are:
* [Resource Groups](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal#what-is-a-resource-group)
* [Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
* [Virtual Network Subnets](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-manage-subnet?tabs=azure-portal)
* [Network Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
* [Disk Encryption ](https://learn.microsoft.com/en-us/azure/virtual-machines/disk-encryption)

## Definition

## Input Parameters

## Post Deploy Steps

## Persistence of State

## Terraform Errors

If an error appears during the terraform apply stage, one of the below actions can be taken
* `terraform apply` : Run the `terraform apply` command to retry
* `terraform destroy` : To destroy all resources created from the `terraform apply` command