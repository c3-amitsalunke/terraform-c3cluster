/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// This file was automatically generated from a template in ./autogen/main

/******************************************
  Get available zones in region
 *****************************************/
data "google_compute_zones" "available" {
  provider = google-beta

  project = var.project
  region  = var.region
}

resource "random_shuffle" "available_zones" {
  input        = data.google_compute_zones.available.names
  result_count = 3
}

locals {
  // Kubernetes version
  master_version = var.kubernetes_version != "latest" ? var.kubernetes_version : data.google_container_engine_versions.region.latest_master_version

  // Build a map of maps of node pools from a list of objects
  node_pool_names = [for np in toset(var.node_pools) : np.name]
  node_pools      = zipmap(local.node_pool_names, tolist(toset(var.node_pools)))

  release_channel      = var.release_channel != null ? [{ channel : var.release_channel }] : []
  default_auto_upgrade = var.release_channel != null ? true : false

  #  cluster_subnet_cidr       = var.add_cluster_firewall_rules ? data.google_compute_subnetwork.gke_subnetwork[0].ip_cidr_range : null
  #  cluster_alias_ranges_cidr = var.add_cluster_firewall_rules ? { for range in toset(data.google_compute_subnetwork.gke_subnetwork[0].secondary_ip_range) : range.range_name => range.ip_cidr_range } : {}

  #  cluster_gce_pd_csi_config = [{ enabled = true }]
}
/******************************************
  Get available container engine versions
 *****************************************/
data "google_container_engine_versions" "region" {
  location = var.region
  project  = var.project
}