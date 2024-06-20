# Deploy a PowerScale Cluster in Azure

A Terraform configuration file, `main.tf`, has been provided in this directory as an example module to deploy a PowerScale cluster.

## Description

In this directory, there is a template file called `terraform.tfvars.template`. Use this as the basis to create your own `terraform.tfvars` file.

There are required input variables that have been left blank which will need to be filled in:

```json
{
    cluster_name           = "<cluster_name>"
    cluster_admin_password = "<cluster_admin_password>"
    cluster_root_password  = "<cluster_root_password>"
    image_id               = "<vhd_image_id_with_location>"

    network_id               = "<vnet_including_location>"

    credentials_hashed = <boolean>

    subscription_id = <#######-####-####-####-############>
    resource_group = <resource group name>
    internal_nsg_name = "<internal network security group>"
    internal_nsg_resource_group = "<interal network security resource group>"
    external_nsg_name = "<external network security group>"
    external_nsg_resource_group = "<external network security resource group>"

    internal_subnet_name     = "<name_of_internal_subnet>"
    external_subnet_name     = "<name_of_external_subnet>"
}
```

## Admin and Root User Passwords

On using the `default_hashed_password` input parameter, both the root and admin user will be assigned the same password as provided in `default_hashed_password`.

You can pass separate passwords for the root and admin user using `hashed_root_passphrase` and `hashed_admin_passphrase` respectively.

To get the hashed password you can use openssl-passwd utility.

<details>
<summary>Click to expand steps to generate hashed password</summary>

You can use the following commands to get the hashed password:

```shell
openssl passwd -5 -salt `head -c 8 /dev/random | xxd -p` "<replace-password-here>"
```

In the above command, `head -c 8 /dev/random | xxd -p` is used to generate an 8 byte random string in its hexadecimal representation which is used as the salt for producing the hashed output.
</details>

> NOTE: It is **strongly recommended** that hashed password(s) are used for deploying the PowerScale clusters.
For testing purposes, you can provide the password(s) in plain-text format using `cluster_admin_password` and `cluster_root_password` for the admin and root user respectively. Additionally, if the passwords are provided in plain-text format, make sure that the `credentials_hashed` parameter is set as `false`.<br><br> The `default_hashed_password` variable is only available in this example module. The PowerScale Cluster does not have that option. While deploying that module, use the respective password parameters for the root and admin users.

For the complete set of input variables that can be provided, check the `variables.tf` file.

## Deploy Terraform Module

```shell
terraform init
```

```shell
terraform apply -auto-approve
```
