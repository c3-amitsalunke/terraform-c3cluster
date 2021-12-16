variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "description" {
  description = "Description of the cluster"
  type        = string
}

#########################################################################################################################
variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
  default     = "10.0.0.0/28"
}

#variable "ip_range_pods" {
#  type        = string
#  description = "Secondary subnet ip range to use for pods"
#}
#
#variable "ip_range_services" {
#  type        = string
#  description = "Secondary subnet range to use for services"
#}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`."
  default     = ""
}
#########################################################################################################################
variable "logging_service" {
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com/kubernetes, logging.googleapis.com (legacy), and none"
  type        = string
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Stackdriver Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting. Available options include monitoring.googleapis.com/kubernetes, monitoring.googleapis.com (legacy), and none"
  type        = string
  default     = "monitoring.googleapis.com/kubernetes"
}

#########################################################################################################################
variable "kubernetes_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "1.21"
}

variable "release_channel" {
  type        = string
  description = "The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `UNSPECIFIED`."
  default     = null
}

variable "node_metadata" {
  description = "Specifies how node metadata is exposed to the workload running on the node"
  default     = "GKE_METADATA_SERVER"
  type        = string
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
  type        = list(object({ state = string, key_name = string }))

  default = [
    {
      state    = "DECRYPTED"
      key_name = ""
    }
  ]
}

variable "identity_namespace" {
  description = "Workload Identity namespace. (Default value of `enabled` automatically sets project based namespace `[project_id].svc.id.goog`)"
  type        = string
  default     = "enabled"
}

#########################################################################################################################
variable "node_pools" {
  type        = list(object({
    name                        = string,
    version                     = optional(string),
    max_pods_per_node           = optional(number)
    node_count                  = optional(number)
    autoscaling                 = optional(map(string))
    auto_repair                 = optional(bool)
    auto_upgrade                = optional(bool)
    image_type                  = optional(string)
    machine_type                = optional(string)
    disk_size_gb                = optional(number)
    disk_type                   = optional(number)
    service_account             = optional(string)
    min_cpu_platform            = optional(string)
    preemptible                 = optional(bool)
    enable_secure_boot          = optional(bool)
    enable_integrity_monitoring = optional(bool)
    labels                      = optional(map(string))
    taints                      = optional(list(object({
      effect = string
      key    = string
      value  = string
    })))
  }))
  description = "List of maps containing node pools"

  default = []
}