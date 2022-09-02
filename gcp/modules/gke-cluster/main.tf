locals {
  cluster_name                 = var.cluster_name == null ? "${var.project_name}-kube-1" : var.cluster_name
  network                      = var.network == null ? "${var.project_name}-vpc-1" : var.network
  subnetwork                   = var.subnetwork == null ? "${var.project_name}-sn-kube-1" : var.subnetwork
  gke_pod_secondary_range_name = var.gke_pod_secondary_range_name == null ? "${local.subnetwork}-pod-range" : var.gke_pod_secondary_range_name
  gke_svc_secondary_range_name = var.gke_svc_secondary_range_name == null ? "${local.subnetwork}-svc-range" : var.gke_svc_secondary_range_name
}

data "google_compute_zones" "available_zones" {
  provider = google-beta

  project = var.project_id
  region  = var.region
}

#tfsec:ignore:google-gke-enforce-pod-security-policy
#tfsec:ignore:google-gke-use-cluster-labels
resource "google_container_cluster" "primary_cluster" {
  provider = google-beta

  name     = local.cluster_name
  project  = var.project_id
  location = var.region

  node_locations = slice(data.google_compute_zones.available_zones.names, 0, var.az_count)

  network    = local.network
  subnetwork = local.subnetwork
  #  cluster_ipv4_cidr
  default_max_pods_per_node = var.max_pod_per_node
  #  networking_mode =
  datapath_provider = var.datapath_provider

  enable_kubernetes_alpha     = false
  enable_legacy_abac          = false
  enable_shielded_nodes       = true
  enable_intranode_visibility = true

  logging_service          = var.logging_service
  monitoring_service       = var.monitoring_service
  remove_default_node_pool = true
  initial_node_count       = 1

  resource_labels = var.labels

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  ip_allocation_policy {
    cluster_secondary_range_name  = local.gke_pod_secondary_range_name
    services_secondary_range_name = local.gke_svc_secondary_range_name
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  release_channel {
    channel = var.release_channel
  }

  min_master_version = var.kubernetes_version

  addons_config {
    dns_cache_config {
      enabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = false
    }
    gcp_filestore_csi_driver_config {
      enabled = false
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    http_load_balancing {
      disabled = false
    }
    network_policy_config {
      disabled = var.network_policy ? false : true
    }
  }

  cluster_autoscaling {
    enabled = false
  }

  dynamic "database_encryption" {
    for_each = var.database_encryption

    content {
      key_name = database_encryption.value.key_name
      state    = database_encryption.value.state
    }
  }

  network_policy {
    enabled  = var.network_policy ? true : false
    provider = var.network_policy && var.calico_provider ? "CALICO" : "PROVIDER_UNSPECIFIED"
  }

  pod_security_policy_config {
    enabled = false
  }

  default_snat_status {
    disabled = false
  }

  #  logging_config {
  #    enable_components = [
  #      "SYSTEM_COMPONENTS",
  #      "WORKLOADS",
  #    ]
  #  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "05:00"
    }
  }

  master_auth {
    client_certificate_config {
      issue_client_certificate = false
    }
  }

  #  monitoring_config {
  #
  #  }

  notification_config {
    pubsub {
      enabled = false
    }
  }

  vertical_pod_autoscaling {
    enabled = false
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  timeouts {
    create = "45m"
    delete = "45m"
    update = "45m"
  }
}
