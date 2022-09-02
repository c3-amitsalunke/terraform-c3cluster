locals {
  cluster_name    = var.cluster_name == null ? "${var.project_name}-kube-1" : var.cluster_name
  service_account = var.service_account == null ? "c3-default@${var.project_name}.iam.gserviceaccount.com" : var.service_account

  kms_key_ring_name   = var.kms_key_ring_name == null ? "${var.project_name}-keyring-1" : var.kms_key_ring_name
  kms_crypto_key_name = var.kms_crypto_key_name == null ? "${var.project_name}-key-1" : var.kms_crypto_key_name
}

data "google_container_cluster" "cluster" {
  name     = local.cluster_name
  location = var.region
  project  = var.project_id
}

resource "google_container_node_pool" "pools" {
  provider = google-beta

  name     = var.name
  project  = var.project_id
  location = var.region
  cluster  = local.cluster_name
  version  = data.google_container_cluster.cluster.min_master_version

  initial_node_count = null
  max_pods_per_node  = var.max_pods_per_node
  node_count         = var.node_count

  dynamic "autoscaling" {
    for_each = var.autoscaling == null ? [] : [var.autoscaling]
    content {
      min_node_count = var.autoscaling.min_node_count
      max_node_count = var.autoscaling.max_node_count
    }
  }

  management {
    auto_repair  = var.auto_repair
    auto_upgrade = var.auto_upgrade
  }

  node_config {
    image_type   = var.image_type
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = var.disk_type

    ephemeral_storage_config {
      local_ssd_count = 1
    }

    boot_disk_kms_key = "projects/${var.project_id}/locations/${var.region}/keyRings/${local.kms_key_ring_name}/cryptoKeys/${local.kms_crypto_key_name}"

    spot = false

    service_account = local.service_account
    preemptible     = var.preemptible

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_secure_boot          = var.enable_secure_boot
      enable_integrity_monitoring = var.enable_integrity_monitoring
    }

    metadata = {
      "disable-legacy-endpoints" = true
    }

    labels = var.labels

    dynamic "taint" {
      for_each = var.taints
      content {
        effect = taint.value.effect
        key    = taint.value.key
        value  = taint.value.value
      }
    }

    tags = []
  }

  lifecycle {
    ignore_changes = [initial_node_count, instance_group_urls]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}
