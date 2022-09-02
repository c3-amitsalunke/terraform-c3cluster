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

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = null
}

variable "vpc_subnetwork_gke_name" {
  description = "Name of the subnetwork for GKE"
  type        = string
  default     = null
}

variable "gke_cidr_block" {
  description = "CIDR used by GKE subnet"
  type        = string
  default     = "10.0.0.0/22"
}

variable "gke_pod_secondary_cidr_block" {
  description = "secondary subnet CIDR used for GKE pods"
  type        = string
  default     = "172.20.0.0/14"
}

variable "gke_pod_secondary_range_name" {
  description = "Secondary Name for GKE pods"
  type        = string
  default     = null
}

variable "gke_svc_secondary_cidr_block" {
  description = "secondary subnet CIDR used for GKE services"
  type        = string
  default     = "172.16.0.0/18"
}

variable "gke_svc_secondary_range_name" {
  description = "Secondary Name for GKE services"
  type        = string
  default     = null
}

variable "data_cidr_address" {
  description = "private service connect subnet address used by data services"
  type        = string
  default     = "10.0.4.0"
}

variable "data_cidr_address_prefix" {
  description = "private service connect subnet prefix used by data services"
  default     = "24"
  type        = string
}

variable "vpc_subnetwork_proxy_name" {
  description = "Name of the subnetwork for proxy subnet"
  type        = string
  default     = null
}

variable "proxy_cidr_block" {
  description = "CIDR used by subnet dedicated to proxy"
  type        = string
  default     = "10.0.5.0/24"
}

variable "tool_cidr_block" {
  description = "CIDR used by tool subnet"
  type        = string
  default     = "10.0.6.0/28"
}

variable "log_config" {
  description = "The logging options for the subnetwork flow logs. Setting this value to `null` will disable them"
  type = object({
    aggregation_interval = string
    flow_sampling        = number
    metadata             = string
  })

  default = {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.7
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

variable "vpc_connectors" {
  description = "List of VPC serverless connectors."
  type        = list(map(string))
  default     = []
}

variable "nat_address_name" {
  description = "Name of the NAT address"
  type        = string
  default     = null
}

variable "nat_name" {
  description = "Name of the NAT"
  type        = string
  default     = null
}

variable "router_name" {
  description = "Name of the router"
  type        = string
  default     = null
}

variable "private_ip_address_name" {
  description = "Name of the Global Address resource for PG subnet peering"
  type        = string
  default     = null
}
