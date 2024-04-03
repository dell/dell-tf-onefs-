# susbscription
subscription_id = "3ba4b388-a3ce-492f-8eaa-2fe1fb6a66f4"

# Cluster OS Information
cluster_name           = "oguartZZ"
cluster_admin_password = "Dell@123"
cluster_root_password  = "Dell@123"
#image_id               = "/subscriptions/3ba4b388-a3ce-492f-8eaa-2fe1fb6a66f4/resourceGroups/ducttape-onefs-images-s2s/providers/Microsoft.Compute/images/b.main.4135r"
image_id = "/subscriptions/3ba4b388-a3ce-492f-8eaa-2fe1fb6a66f4/resourceGroups/pscale-images/providers/Microsoft.Compute/images/b.main.4135r"

# Cluster Scale
node_size     = "Standard_D8ds_v4"
cluster_nodes = 3
max_num_nodes = 3

# Networking Information
smartconnect_zone        = "foo.bar"
network_id               = "/subscriptions/3ba4b388-a3ce-492f-8eaa-2fe1fb6a66f4/resourceGroups/IPEISGRG/providers/Microsoft.Network/virtualNetworks/ipeisgvpngw-vnet"
addr_range_offset        = 4 # 80                                   # <---- Attention!  This is your starting IP range, make sure it is not conflict. (step by 20)
data_disk_type           = "Premium_LRS"
vnet_resource_group_name = "IPEISGRG"
vnet_name                = "ipeisgvpngw-vnet"
cloud_provider           = "azure"

# Storage Configuration
os_disk_type        = "Premium_LRS"
data_disk_size      = 12
data_disks_per_node = 3
jdev                = "bay.0"
