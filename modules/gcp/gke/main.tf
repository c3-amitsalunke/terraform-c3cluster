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
  initial_node_count = 1

#  # If we have an alternative default service account to use, set on the node_config so that the default node pool can
#  # be created successfully.
#  dynamic "node_config" {
#    # Ideally we can do `for_each = var.alternative_default_service_account != null ? [object] : []`, but due to a
#    # terraform bug, this doesn't work. See https://github.com/hashicorp/terraform/issues/21465. So we simulate it using
#    # a for expression.
#    for_each = [
#      for x in [var.alternative_default_service_account] : x if var.alternative_default_service_account != null
#    ]
#
#    content {
#      service_account = node_config.value
#    }
#  }
#
#  # ip_allocation_policy.use_ip_aliases defaults to true, since we define the block `ip_allocation_policy`
#  ip_allocation_policy {
#    // Choose the range, but let GCP pick the IPs within the range
#    cluster_secondary_range_name  = var.cluster_secondary_range_name
#    services_secondary_range_name = var.services_secondary_range_name
#  }
#
#  # We can optionally control access to the cluster
#  # See https://cloud.google.com/kubernetes-engine/docs/how-to/private-clusters
#  private_cluster_config {
#    enable_private_endpoint = var.disable_public_endpoint
#    enable_private_nodes    = var.enable_private_nodes
#    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
#  }
#
#  addons_config {
#    http_load_balancing {
#      disabled = !var.http_load_balancing
#    }
#
#    horizontal_pod_autoscaling {
#      disabled = !var.horizontal_pod_autoscaling
#    }
#
#    network_policy_config {
#      disabled = !var.enable_network_policy
#    }
#  }
#
#  network_policy {
#    enabled = var.enable_network_policy
#
#    # Tigera (Calico Felix) is the only provider
#    provider = var.enable_network_policy ? "CALICO" : "PROVIDER_UNSPECIFIED"
#  }
#
#  vertical_pod_autoscaling {
#    enabled = var.enable_vertical_pod_autoscaling
#  }
#
#  master_auth {
#    username = var.basic_auth_username
#    password = var.basic_auth_password
#  }
#
#  dynamic "master_authorized_networks_config" {
#    for_each = var.master_authorized_networks_config
#    content {
#      dynamic "cidr_blocks" {
#        for_each = lookup(master_authorized_networks_config.value, "cidr_blocks", [])
#        content {
#          cidr_block   = cidr_blocks.value.cidr_block
#          display_name = lookup(cidr_blocks.value, "display_name", null)
#        }
#      }
#    }
#  }
#
#  maintenance_policy {
#    daily_maintenance_window {
#      start_time = var.maintenance_start_time
#    }
#  }
#
#  lifecycle {
#    ignore_changes = [
#      # Since we provide `remove_default_node_pool = true`, the `node_config` is only relevant for a valid construction of
#      # the GKE cluster in the initial creation. As such, any changes to the `node_config` should be ignored.
#      node_config,
#    ]
#  }
#
#  # If var.gsuite_domain_name is non-empty, initialize the cluster with a G Suite security group
#  dynamic "authenticator_groups_config" {
#    for_each = [
#    for x in [var.gsuite_domain_name] : x if var.gsuite_domain_name != null
#    ]
#
#    content {
#      security_group = "gke-security-groups@${authenticator_groups_config.value}"
#    }
#  }
#
#  # If var.secrets_encryption_kms_key is non-empty, create ´database_encryption´ -block to encrypt secrets at rest in etcd
#  dynamic "database_encryption" {
#    for_each = [
#    for x in [var.secrets_encryption_kms_key] : x if var.secrets_encryption_kms_key != null
#    ]
#
#    content {
#      state    = "ENCRYPTED"
#      key_name = database_encryption.value
#    }
#  }
#
#  dynamic "workload_identity_config" {
#    for_each = local.workload_identity_config
#
#    content {
#      identity_namespace = workload_identity_config.value.identity_namespace
#    }
#  }
#
#  resource_labels = var.resource_labels
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
