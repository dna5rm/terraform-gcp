


/******************************************
	VPC configuration
 *****************************************/
module "vpc" {
  source = "github.com/terraform-google-modules/terraform-google-network//modules/vpc"

  network_name                           = var.network_name
  auto_create_subnetworks                = var.auto_create_subnetworks
  routing_mode                           = var.routing_mode
  project_id                             = var.project_id
  description                            = var.description
  shared_vpc_host                        = var.shared_vpc_host
  delete_default_internet_gateway_routes = var.delete_default_internet_gateway_routes
  mtu                                    = var.mtu
}

/******************************************
	Subnet configuration
 *****************************************/
module "subnets" {
  source = "github.com/terraform-google-modules/terraform-google-network//modules/subnets"

  project_id       = var.project_id
  network_name     = module.vpc.network_name
  subnets          = var.subnets
  secondary_ranges = var.secondary_ranges
}

/******************************************
	Cloud NAT gateway
 *****************************************/
# module "cloud_router" {
#   source  = "terraform-google-modules/cloud-router/google"
#   version = "~> 0.4"
#   project = var.project_id
#   name    = join("-", [module.vpc.network_name, "nat", element(var.subnets, 0).subnet_region])
#   network = module.vpc.network_name
#   region  = element(var.subnets, 0).subnet_region
#
#   nats = [{
#     name = join("-", [element(var.subnets, 0).subnet_region, "nat-gateway"])
#   }]
# }

/******************************************
	Routes
 *****************************************/
module "routes" {
  source = "github.com/terraform-google-modules/terraform-google-network//modules/routes"

  project_id        = var.project_id
  network_name      = module.vpc.network_name
  routes            = var.routes
  module_depends_on = [module.subnets.subnets]
}

/******************************************
	Firewall rules
 *****************************************/
locals {
  rules = [
    for f in var.firewall_rules : {
      name                    = f.name
      direction               = f.direction
      priority                = lookup(f, "priority", null)
      description             = lookup(f, "description", null)
      ranges                  = lookup(f, "ranges", null)
      source_tags             = lookup(f, "source_tags", null)
      source_service_accounts = lookup(f, "source_service_accounts", null)
      target_tags             = lookup(f, "target_tags", null)
      target_service_accounts = lookup(f, "target_service_accounts", null)
      allow                   = lookup(f, "allow", [])
      deny                    = lookup(f, "deny", [])
      log_config              = lookup(f, "log_config", null)
    }
  ]
}

module "firewall_rules" {
  source = "github.com/terraform-google-modules/terraform-google-network//modules/firewall-rules"

  project_id   = var.project_id
  network_name = module.vpc.network_name
  rules        = local.rules
}

/******************************************
	VPN Connectivity
 *****************************************/
# module "vpn_ha" {
#   count                 = length(var.vpns)
#   source                = "github.com/terraform-google-modules/terraform-google-vpn//modules/vpn_ha"
#
#   project_id            = var.project_id
#   region                = var.vpns[count.index].region
#   network               = module.vpc.network_name
#   name                  = join("-", [module.vpc.network_name, var.vpns[count.index].site_name, var.vpns[count.index].region])
#
#   peer_external_gateway = {
#       redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
#       interfaces = [
#         {
#           id = 0
#           ip_address = var.vpns[count.index].ip_address
#         }
#       ]
#   }
#
#   router_asn = var.vpc_bgpasn
#   tunnels = {
#     tunnel-0 = {
#       bgp_peer = {
#         address = cidrhost(var.vpns[count.index].tun0_cidr, 1)
#         asn     = var.vpns[count.index].bgp_as
#       }
#       bgp_peer_options                = null
#       bgp_session_range               = join("/", [cidrhost(var.vpns[count.index].tun0_cidr, 2), "30"])
#       ike_version                     = 2
#       vpn_gateway_interface           = 0
#       peer_external_gateway_interface = 0
#       shared_secret                   = var.vpns[count.index].shared_secret
#     }
#     tunnel-1 = {
#       bgp_peer = {
#         address = cidrhost(var.vpns[count.index].tun1_cidr, 1)
#         asn     = var.vpns[count.index].bgp_as
#       }
#       bgp_peer_options                = null
#       bgp_session_range               = join("/", [cidrhost(var.vpns[count.index].tun1_cidr, 2), "30"])
#       ike_version                     = 2
#       vpn_gateway_interface           = 1
#       peer_external_gateway_interface = 0
#       shared_secret                   = var.vpns[count.index].shared_secret
#     }
#   }
# }

/******************************************
	VM Instances
 *****************************************/
# resource "google_compute_instance" "vm_instance" { ... }
