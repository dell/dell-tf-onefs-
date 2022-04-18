module "multi-node-example" {
  source = "../"

  cluster_name = "ben2"
  cluster_admin_password = "Dell@1235"
  cluster_root_password = "Dell@1235"

  timezone = "Greenwich Mean Time"

  cluster_nodes = 5

  location = "centralus"
  image_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/ducttape-images/providers/Microsoft.Compute/images/b.tscale.138r"

  smartconnect_zone = "foo.bar"
  network_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/ctrl-thunderscale-central-app-rg/providers/Microsoft.Network/virtualNetworks/ctrl-azure_central-thunderscale-vnet"
  internal_prefix = "100.93.97.240/28"
  external_prefix = "100.93.104.240/28"
}
