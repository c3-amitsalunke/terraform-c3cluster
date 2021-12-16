#tfsec:ignore:google-gke-enforce-pod-security-policy
resource "google_container_cluster" "cluster" {
  provider = google-beta

  #checkov:skip=CKV_GCP_22:Ensure Container-Optimized OS (cos) is used for Kubernetes Engine Clusters Node image
  #checkov:skip=CKV_GCP_72:Ensure Integrity Monitoring for Shielded GKE Nodes is Enabled
  #checkov:skip=CKV_GCP_13:Ensure a client certificate is used by clients to authenticate to Kubernetes Engine Cluster
  #checkov:skip=CKV_GCP_19:Ensure GKE basic auth is disabled
  #checkov:skip=CKV_GCP_69:Ensure the GKE Metadata Server is Enabled
  #checkov:skip=CKV_GCP_65:Manage Kubernetes RBAC users with Google Groups for GKE
  #checkov:skip=CKV_GCP_24:Ensure PodSecurityPolicy controller is enabled on the Kubernetes Engine Clusters
  #checkov:skip=CKV_GCP_67:Ensure legacy Compute Engine instance metadata APIs are Disabled

  name        = var.cluster_name
  description = var.description
  project     = var.project
  location    = var.region

  network    = var.network
  subnetwork = var.subnetwork

  logging_service    = var.logging_service
  monitoring_service = var.monitoring_service

  enable_legacy_abac          = false
  enable_shielded_nodes       = true
  enable_binary_authorization = true
  enable_intranode_visibility = true

  remove_default_node_pool = true
  initial_node_count       = 1

  resource_labels = {
    c3_project = var.project
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

    ip_allocation_policy {
#      cluster_secondary_range_name  = var.ip_range_pods
#      services_secondary_range_name = var.ip_range_services
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

  dynamic "release_channel" {
    for_each = local.release_channel

    content {
      channel = release_channel.value.channel
    }
  }

  min_master_version = var.release_channel != null ? null : local.master_version

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = true
    }

    network_policy_config {
      disabled = true
    }
  }

#  cluster_autoscaling {
#    enabled = true
#
#    auto_provisioning_defaults {
#      min_cpu_platform = "Intel Ice Lake"
#      service_account = var.service_account
#    }
#  }

  dynamic "database_encryption" {
    for_each = var.database_encryption

    content {
      key_name = database_encryption.value.key_name
      state    = database_encryption.value.state
    }
  }

  pod_security_policy_config {
    #tfsec:ignore:google-gke-enforce-pod-security-policy
    enabled = false
  }

  network_policy {
    #tfsec:ignore:google-gke-enable-network-policy
    enabled = false
    #    provider = "PROVIDER_UNSPECIFIED"
  }

  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  lifecycle {
    ignore_changes = [node_pool, initial_node_count]
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}

locals {
  force_node_pool_recreation_resources = [
    "disk_size_gb",
    "disk_type",
    "machine_type",
    "preemptible",
    "service_account"
  ]
}

resource "random_id" "name" {
  for_each    = local.node_pools
  byte_length = 2
  prefix      = format("%s-", lookup(each.value, "name"))
  keepers     = merge(
  zipmap(
  local.force_node_pool_recreation_resources,
  [for keeper in local.force_node_pool_recreation_resources : lookup(each.value, keeper, "")]
  ),
  {
    labels = join(",", sort(concat(
    keys(lookup(each.value, "labels", {})),
    values(lookup(each.value, "labels", {}))
    )))
  }
  )
}

resource "google_container_node_pool" "pools" {
  provider = google-beta

  for_each = local.node_pools

  name     = {for k, v in random_id.name : k => v.hex}[each.key]
  project  = var.project
  location = var.region
  cluster  = google_container_cluster.cluster.name
  version  = lookup(each.value, "version", google_container_cluster.cluster.min_master_version)

  #  initial_node_count = lookup(each.value, "autoscaling", true) ? lookup(each.value, "initial_node_count", lookup(each.value["autoscaling"], "min_count", 1)) : null
  initial_node_count = null
  max_pods_per_node  = lookup(each.value, "max_pods_per_node", null)
  node_count         = lookup(each.value, "node_count", 1)
  #  node_count         = lookup(each.value, "autoscaling", true) ? null : lookup(each.value, "node_count", 1)

  #  dynamic "autoscaling" {
  #    for_each = lookup(each.value, "autoscaling", true) ? [each.value] : []
  #    content {
  #      min_node_count = lookup(autoscaling.value, "min_count", 1)
  #      max_node_count = lookup(autoscaling.value, "max_count", 10)
  #    }
  #  }

#  min_cpu_platform           = "Intel Skylake"

  management {
    #checkov:skip=CKV_GCP_9:Ensure 'Automatic node repair' is enabled for Kubernetes Clusters
    auto_repair  = lookup(each.value, "auto_repair", true)
    #    auto_upgrade = lookup(each.value, "auto_upgrade", local.default_auto_upgrade)
    auto_upgrade = true
  }

  node_config {
    #checkov:skip=CKV_GCP_22:Ensure Container-Optimized OS (cos) is used for Kubernetes Engine Clusters Node image
    image_type   = lookup(each.value, "image_type", "COS")
    machine_type = lookup(each.value, "machine_type", "n2-standard-4")
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")

    service_account = lookup(each.value, "service_account", var.service_account)
    preemptible     = lookup(each.value, "preemptible", false)

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      #checkov:skip=CKV_GCP_68:Ensure Secure Boot for Shielded GKE Nodes is Enabled
      enable_secure_boot          = lookup(each.value, "enable_secure_boot", false)
      #checkov:skip=CKV_GCP_72:Ensure Integrity Monitoring for Shielded GKE Nodes is Enabled
      enable_integrity_monitoring = lookup(each.value, "enable_integrity_monitoring", true)
    }

    metadata = {
      "disable-legacy-endpoints" = true
    }

    labels = lookup(each.value, "labels", {})

    dynamic "taint" {
      for_each = (lookup(each.value, "taints", null) != null || length(lookup(each.value, "taints", [])) != 0 ) ? lookup(each.value, "taints", []) : []
      content {
        effect = lookup(taint.value, "effect", )
        key    = lookup(taint.value, "key", )
        value  = lookup(taint.value, "value", )
      }
    }
  }

  #  tags              = []

  lifecycle {
    ignore_changes = [initial_node_count]

    create_before_destroy = true
  }

  timeouts {
    create = "45m"
    update = "45m"
    delete = "45m"
  }
}