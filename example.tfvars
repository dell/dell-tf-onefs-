cluster_name           = "pscaledemo"
cluster_admin_password = "Dell@1235"
cluster_root_password  = "Dell@1235"

timezone = "Greenwich Mean Time"

cluster_nodes = 3
max_num_nodes = 6

image_id = "<please fill in>"

smartconnect_zone    = "foo.bar"
network_id           = "<please fill in>"
internal_subnet_name = "dedicated-powerscale-backend-subnet"
external_subnet_name = "dedicated-powerscale-frontend-subnet"
internal_prefix      = "10.1.50.0/28"
external_prefix      = "10.1.150.0/28"
addr_range_offset    = 5

resource_group = "pscale-demo"
