locals {
  nat_address_name             = var.nat_address_name == null ? "${var.project_name}-eip-nat" : var.nat_address_name
  nat_name                     = var.nat_name == null ? "${var.project_name}-nat" : var.nat_name
  router_name                  = var.router_name == null ? "${var.project_name}-router" : var.router_name
  private_ip_address_name      = var.private_ip_address_name == null ? "${var.project_name}-globaladdress-data" : var.private_ip_address_name
  vpc_name                     = var.vpc_name == null ? "${var.project_name}-vpc-1" : var.vpc_name
  vpc_subnetwork_gke_name      = var.vpc_subnetwork_gke_name == null ? "${var.project_name}-sn-kube-1" : var.vpc_subnetwork_gke_name
  vpc_subnetwork_proxy_name    = var.vpc_subnetwork_proxy_name == null ? "${var.project_name}-sn-proxy-1" : var.vpc_subnetwork_proxy_name
  gke_pod_secondary_range_name = var.gke_pod_secondary_range_name == null ? "${local.vpc_subnetwork_gke_name}-pod-range" : var.gke_pod_secondary_range_name
  gke_svc_secondary_range_name = var.gke_svc_secondary_range_name == null ? "${local.vpc_subnetwork_gke_name}-svc-range" : var.gke_svc_secondary_range_name
}

resource "google_compute_network" "vpc" {
  name                    = local.vpc_name
  project                 = var.project_id
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Subnet - gke
resource "google_compute_subnetwork" "vpc_subnetwork_gke" {
  name          = local.vpc_subnetwork_gke_name
  project       = var.project_id
  region        = var.region
  description   = "Subnet for GKE"
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.gke_cidr_block

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = local.gke_pod_secondary_range_name
    ip_cidr_range = var.gke_pod_secondary_cidr_block
  }

  secondary_ip_range {
    range_name    = local.gke_svc_secondary_range_name
    ip_cidr_range = var.gke_svc_secondary_cidr_block
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : tolist([var.log_config])

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }
}

# Subnet - proxy
#tfsec:ignore:google-compute-enable-vpc-flow-logs
resource "google_compute_subnetwork" "vpc_subnetwork_proxy" {
  name = local.vpc_subnetwork_proxy_name

  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.self_link
  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"

  ip_cidr_range = var.proxy_cidr_block

}

# external ip for NAT gateway
resource "google_compute_address" "nat_address" {
  name    = local.nat_address_name
  project = var.project_id
  region  = var.region
}

# cloud router - cloud NAT
resource "google_compute_router" "router" {
  name    = local.router_name
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = 64514
  }
}

# cloud NAT
resource "google_compute_router_nat" "nat" {
  name    = local.nat_name
  project = var.project_id
  router  = google_compute_router.router.name
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat_address.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                     = google_compute_subnetwork.vpc_subnetwork_gke.self_link
    source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
    secondary_ip_range_names = google_compute_subnetwork.vpc_subnetwork_gke.secondary_ip_range.*.range_name
  }
  subnetwork {
    name                    = google_compute_subnetwork.vpc_subnetwork_proxy.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# vpc connectors
resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = local.private_ip_address_name
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.data_cidr_address
  prefix_length = var.data_cidr_address_prefix
  network       = google_compute_network.vpc.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
