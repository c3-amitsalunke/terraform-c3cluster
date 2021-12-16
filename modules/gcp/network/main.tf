resource "google_compute_network" "vpc" {
  name                    = "${var.project}-vpc-1"
  auto_create_subnetworks = "false"
  routing_mode            = "REGIONAL"
}

resource "google_compute_firewall" "c3-443" {
  name    = "c3-443"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = [
    "54.76.64.220/32",
    "12.226.154.130/32",
    "34.238.215.224/32",
    "34.231.113.223/32",
    "52.48.79.190/32",
    "34.232.23.54/32"
  ]
}

resource "google_compute_firewall" "internal-5432" {
  name    = "internal-5432"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [
    "10.0.0.0/8"
  ]
}

# Subnet - dmz
resource "google_compute_subnetwork" "vpc_subnetwork_dmz" {
  name = "${var.project}-sn-dmz-1"

  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  private_ip_google_access = true
  ip_cidr_range            = cidrsubnet(var.cidr_block, 4, 0)

  secondary_ip_range {
    range_name    = "dmz"
    ip_cidr_range = cidrsubnet(var.secondary_cidr_block, 4, 0)
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : tolist([var.log_config])

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }

  enable_flow_logs = true
}

# Subnet - gke
resource "google_compute_subnetwork" "vpc_subnetwork_gke" {
  name          = "${var.project}-sn-gke-1"
  region        = var.region
  description   = "Subnet for GKE"
  network       = google_compute_network.vpc.name
  ip_cidr_range = cidrsubnet(var.cidr_block, 4, 1)

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "${var.project}-pod-range"
    ip_cidr_range = cidrsubnet(var.secondary_cidr_block, 4, 1)
  }

  secondary_ip_range {
    range_name    = "${var.project}-svc-range"
    ip_cidr_range = cidrsubnet(var.secondary_cidr_block, 4, 2)
  }

  dynamic "log_config" {
    for_each = var.log_config == null ? [] : tolist([var.log_config])

    content {
      aggregation_interval = var.log_config.aggregation_interval
      flow_sampling        = var.log_config.flow_sampling
      metadata             = var.log_config.metadata
    }
  }

  enable_flow_logs = true
}

# external ip for NAT gateway
resource "google_compute_address" "nat_address" {
  name    = "${var.project}-eip-1"
  project = var.project
  region  = var.region
}

# cloud router - cloud NAT
resource "google_compute_router" "router" {
  name    = "${var.project}-router-1"
  project = var.project
  region  = var.region
  network = google_compute_network.vpc.self_link

  bgp {
    asn = 64514
  }
}

# cloud NAT
resource "google_compute_router_nat" "nat" {
  name    = "${var.project}-nat-1"
  project = var.project
  router  = google_compute_router.router.name
  region  = var.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat_address.self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.vpc_subnetwork_gke.self_link
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = google_compute_subnetwork.vpc_subnetwork_gke.secondary_ip_range.*.range_name
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# vpc connectors
resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = "${var.project}-sn-sql-1"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.vpc.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.vpc.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}
