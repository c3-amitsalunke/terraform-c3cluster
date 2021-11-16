variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "name" {
  description = "The name of the cluster"
  type        = string
}

variable "description" {
  description = "Description of the cluster"
  type        = string
}

#variable "enable_workload_identity" {
#  description = "Enable Workload Identity on the cluster"
#  default     = true
#  type        = bool
#}

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

variable "kubernetes_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region."
  type        = string
  default     = "1.19"
}


variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
}

#variable "cluster_secondary_range_name" {
#  description = "The name of the secondary range within the subnetwork for the cluster to use"
#  type        = string
#}
#
