cluster_name = "mbryantemp"
cluster_admin_password = "Dell@1235"
cluster_root_password = "Dell@1235"

timezone = "Greenwich Mean Time"

cluster_nodes = 3
max_num_nodes = 4

image_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/mbryan_demo/providers/Microsoft.Compute/images/onefsimg"

smartconnect_zone = "foo.bar"
network_id = "/subscriptions/0629574c-1c80-4365-b0c6-3f5fdde6518e/resourceGroups/ctrl-thunderscale-central-app-rg/providers/Microsoft.Network/virtualNetworks/ctrl-azure_central-thunderscale-vnet"
internal_subnet_name = "mbryantmp-internal-subnet"
external_subnet_name = "mbryantmp-external-subnet"
internal_prefix = "100.93.97.240/28"
external_prefix = "100.93.104.240/28"
addr_range_offset = 5

resource_group = "mbryan_demo"
