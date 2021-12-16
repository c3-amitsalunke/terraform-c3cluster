variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "cidr_block" {
  description = "The IP address range of the VPC in CIDR notation. A prefix of /16 is recommended"
  default     = "10.0.0.0/16"
  type        = string
}

variable "secondary_cidr_block" {
  description = "The IP address range of the VPC's secondary address range in CIDR notation"
  type        = string
  default     = "10.255.0.0/16"
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
