variable "project" {
  description = "The project ID for the network"
  type        = string
}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "cidr_block" {
  description = "The IP address range of the VPC in CIDR notation."
  default     = "10.0.0.0/16"
  type        = string
}

variable "pg_instance_type" {
  description = "Instance size for postgres"
  default     = "db-custom-4-26624"
  type        = string
}

