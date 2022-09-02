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

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = null
}

variable "name" {
  description = "Name of NodePool"
  type        = string
}

variable "max_pods_per_node" {
  description = "The default maximum number of pods per node in this cluster"
  type        = number
  default     = 110
}

variable "node_count" {
  description = "The number of nodes per instance group"
  type        = number
  default     = 0
}

variable "autoscaling" {
  description = "Configuration for cluster autoscaler"
  type = object({
    min_node_count = number
    max_node_count = number
  })
  default = null
}

variable "auto_repair" {
  description = "Whether the nodes will be automatically repaired"
  type        = bool
  default     = true
}

variable "auto_upgrade" {
  description = "Whether the nodes will be automatically upgraded"
  type        = bool
  default     = true
}

variable "image_type" {
  description = "The default image type for nodepool"
  type        = string
  default     = "COS_CONTAINERD"
}

variable "machine_type" {
  description = "The name of a GCP machine type"
  type        = string
  default     = "n2-standard-4"
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "Type of the disk attached to each node"
  type        = string
  default     = "pd-ssd"
}

variable "service_account" {
  description = "Service Account for the node"
  type        = string
  default     = null
}

variable "preemptible" {
  description = "Whether or not the underlying node VMs are preemptible"
  type        = bool
  default     = false
}

variable "enable_secure_boot" {
  description = "Secure Boot"
  type        = bool
  default     = false
}

variable "enable_integrity_monitoring" {
  description = "Integrity monitoring"
  type        = bool
  default     = false
}

variable "taints" {
  description = "Taints to apply to nodes"
  type = list(object({
    effect = string
    key    = string
    value  = string
  }))
  default = []
}

variable "labels" {
  description = "Labels to be applied to each node"
  type        = map(string)
  default     = {}
}

variable "kms_key_ring_name" {
  description = "Name of KMS Ring"
  type        = string
  default     = null
}

variable "kms_crypto_key_name" {
  description = "Encryption key for GCS"
  type        = string
  default     = null
}
