module "multi-node-example" {
  source = "../../"

  cluster_id = "tfeerre"
  cluster_name = "tfeerre"
  cluster_admin_password = "Dell@123"
  cluster_root_password = "Dell@123"
  cluster_nodes = 3

  storage_account_name = "bneigetest123"
  storage_account_resource_group = "bneigee_newbootdiag"

  location = "centralus"
  image_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/ducttape-images/providers/Microsoft.Compute/images/b.tscale.082r"


  smartconnect_zone = "foo.bar"
  network_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/ctrl-thunderscale-central-app-rg/providers/Microsoft.Network/virtualNetworks/ctrl-azure_central-thunderscale-vnet"
  internal_prefix = "100.93.117.16/28"
  external_prefix = "100.93.103.128/28"
    external_secondary_ip = {
    customer = {
      0 = ["10.93.111.151", "10.93.111.152"]
    }
    management = {}
  }
}
