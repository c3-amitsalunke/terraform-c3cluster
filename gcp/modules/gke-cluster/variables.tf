variable "project_id" {
  description = "The Id for the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "az_count" {
  description = "Number of availability zones for kubernetes nodes"
  type        = number
  default     = 3
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
  default     = null
}

variable "labels" {
  description = "Map of labels for project"
  type        = map(string)
  default     = {}
}
##########################################################################################################################
variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
  default     = null
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
  default     = null
}

variable "gke_pod_secondary_range_name" {
  description = "Secondary Name for GKE pods"
  type        = string
  default     = null
}

variable "gke_svc_secondary_range_name" {
  description = "Secondary Name for GKE services"
  type        = string
  default     = null
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

variable "network_policy" {
  description = "Enable or disable network policy"
  type        = bool
  default     = true
}

variable "calico_provider" {
  description = "Enforce calico as network policy provider"
  type        = bool
  default     = true
}

variable "max_pod_per_node" {
  description = "maximum number of pods per nodes"
  type        = number
  default     = 110
}

variable "datapath_provider" {
  description = "Decide if a specific dataplane should be used (e.g dataplaneV2)"
  type        = string
  default     = "DATAPATH_PROVIDER_UNSPECIFIED"
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`."
  default     = ""
}
##########################################################################################################################
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

##########################################################################################################################
variable "kubernetes_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "1.21"
}

variable "release_channel" {
  type        = string
  description = "The release channel of this cluster. Accepted values are `UNSPECIFIED`, `RAPID`, `REGULAR` and `STABLE`. Defaults to `UNSPECIFIED`."
  default     = "UNSPECIFIED"
}

#variable "node_metadata" {
#  description = "Specifies how node metadata is exposed to the workload running on the node"
#  default     = "GKE_METADATA_SERVER"
#  type        = string
#}
#
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

#variable "identity_namespace" {
#  description = "Workload Identity namespace. (Default value of `enabled` automatically sets project based namespace `[project_id].svc.id.goog`)"
#  type        = string
#  default     = "enabled"
#}
#
