#project_id                             = "[your project id]"
network_name                            = "dev-us"
routing_mode                            = "GLOBAL"
shared_vpc_host                         = false
delete_default_internet_gateway_routes  = true
vpc_bgpasn                              = 64514

subnets = [
    {
        subnet_name                     = "shared01"
        subnet_ip                       = "172.16.0.0/24"
        subnet_region                   = "us-east1"
        description                     = "Shared Services Subnet"
    },
    {
        subnet_name                     = "shared02"
        subnet_ip                       = "172.16.1.0/24"
        subnet_region                   = "us-central1"
        description                     = "Shared Services Subnet"
    }
]

secondary_ranges = {
    subnet-01 = []
    subnet-02 = []
}

routes = [
    {
        name                            = "egress-internet-dev-us"
        description                     = "route through IGW to access internet"
        destination_range               = "0.0.0.0/0"
        tags                            = "egress-inet"
        next_hop_internet               = "true"
    }
]

firewall_rules = [
    {
        name                            = "ingress-icmp-allow"
        description                     = "Allow INGRESS ICMP"
        direction                       = "INGRESS"
        ranges                          = ["0.0.0.0/0"]
        allow = [{
                protocol        = "icmp"
                ports           = []
            }]
    },
    {
        name                    = "ingress-mgmt-allow"
        description             = "Allow INGRESS Management"
        direction               = "INGRESS"
        ranges                  = ["10.0.0.0/8", "172.0.0.0/12", "192.168.0.0/16"]
        allow = [
            {
                protocol        = "tcp"
                ports           = ["22", "3389"]
            },
            {
                protocol        = "udp"
                ports           = ["3389"]
            }
        ]
    }
]

vpns = [
  {
    site_name       = "nyc"
    region          = "us-east1"
    ip_address      = "203.0.113.10"
    bgp_as          = 65534
    shared_secret   = "j!S)FuX(5q3E6@O)WZ*#437pcQp6NY0c"
    tun0_cidr       = "169.254.16.0/30"
    tun1_cidr       = "169.254.16.4/30"
  }
]
