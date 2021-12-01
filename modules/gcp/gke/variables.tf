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
  default     = "1.21"
}

variable "network" {
  description = "A reference (self link) to the VPC network to host the cluster in"
  type        = string
}

variable "subnetwork" {
  description = "A reference (self link) to the subnetwork to host the cluster in"
  type        = string
}

variable "primary_nodepool_name" {
  description = "The name of the primary nodepool"
  type        = string
}

variable "zk_nodepool_name" {
  description = "The name of the zk nodepool"
  type        = string
}

variable "cass_nodepool_name" {
  description = "The name of the cass nodepool"
  type        = string
}

variable "ops_nodepool_name" {
  description = "The name of the ops nodepool"
  type        = string
}

variable "service_account" {
  description = "The c3 default service account"
  type        = string
}