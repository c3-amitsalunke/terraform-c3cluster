resource "google_container_cluster" "cluster" {
  provider = google-beta

  name        = var.cluster_name
  description = var.description

  project    = var.project
  location   = var.region
  network    = var.network
  subnetwork = var.subnetwork

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service
  min_master_version = var.kubernetes_version
  enable_legacy_abac = false

  remove_default_node_pool = true
  initial_node_count       = 1

  #  workload_identity_config {
  #    workload_pool = "${var.project}.svc.id.goog"
  #  }

  ip_allocation_policy {}
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "192.168.0.0/28"
  }
}

resource "google_container_node_pool" "primary_nodepool" {
  provider = google-beta

  name     = var.primary_nodepool_name
  cluster  = google_container_cluster.cluster.id
  location = var.region

  initial_node_count = 1
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  autoscaling {
    min_node_count = 3
    max_node_count = 15
  }

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    disk_size_gb = 500
    disk_type    = "pd-standard"
    machine_type = "n2-highmem-8"

    service_account = var.service_account

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = false
    }
  }
}

resource "google_container_node_pool" "zk_nodepool" {
  provider = google-beta

  name       = var.zk_nodepool_name
  cluster    = google_container_cluster.cluster.id
  location   = var.region
  node_count = 1

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    disk_size_gb = 100
    disk_type    = "pd-standard"
    machine_type = "n2-standard-8"

    service_account = var.service_account

    taint {
      key    = "apps.c3.ai/part-of"
      value  = "zookeeper"
      effect = "NO_SCHEDULE"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = false
    }
  }
}

resource "google_container_node_pool" "cass_nodepool" {
  provider = google-beta

  name       = var.cass_nodepool_name
  cluster    = google_container_cluster.cluster.id
  location   = var.region
  node_count = 2

  management {
    auto_repair  = false
    auto_upgrade = false
  }

  node_config {
    disk_size_gb = 100
    disk_type    = "pd-standard"
    machine_type = "n2-highmem-4"

    service_account = var.service_account

    taint {
      key    = "apps.c3.ai/part-of"
      value  = "cassandra"
      effect = "NO_SCHEDULE"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = false
    }
  }
}

resource "google_container_node_pool" "ops_nodepool" {
  provider = google-beta

  name       = var.ops_nodepool_name
  cluster    = google_container_cluster.cluster.id
  location   = var.region
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    disk_size_gb = 100
    disk_type    = "pd-standard"
    machine_type = "n2-standard-4"

    service_account = var.service_account

    taint {
      key    = "app.kubernetes.io/part-of"
      value  = "c3-ops"
      effect = "NO_SCHEDULE"
    }

    shielded_instance_config {
      enable_secure_boot          = false
      enable_integrity_monitoring = false
    }
  }
}

data "google_compute_zones" "available" {
  project = var.project
  region  = var.region
  status  = "UP"
}

resource "google_filestore_instance" "instance" {
  provider = google-beta

  name = var.project
  zone = data.google_compute_zones.available.names[0]
  tier = "PREMIUM"

  file_shares {
    capacity_gb = 2560
    name        = "c3_cfw"
  }

  networks {
    network = "${var.project}-vpc-1"
    modes   = ["MODE_IPV4"]
#
    connect_mode = "DIRECT_PEERING"
  }

  project = var.project
}

# Enable CSI for filestore - https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/filestore-csi-driver