variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network"
  type        = string
}

variable "name" {
  description = "DB instance name"
  type        = string
}

#variable "master_user_name" {
#  description = "master_user_name. username - 'master_user_name'@'master_user_host"
#  type        = string
#}
#
#variable "master_user_password" {
#  description = "Password for master_user_password"
#  type        = string
#}


variable "encryption_key_name" {
  description = "The full path to the encryption key"
  type        = string
}

variable "postgres_version" {
  description = "DB version. Ref https://cloud.google.com/sql/docs/db-versions"
  type        = string
  default     = "POSTGRES_11"
}

variable "instance_type" {
  description = "Instance type. Ref https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type#create"
  type        = string
  default     = "db-f1-micro"
}

variable "backup_enabled" {
  description = "Enabled / Disable backup"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Enable point_in_time_recovery"
  type        = bool
  default     = true
}

variable "database_flags" {
  description = "List of Cloud SQL flags that are applied to the database server"
  type        = list(any)
  default     = []
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size automatically"
  type        = bool
  default     = true
}

variable "disk_size" {
  description = "The size of data disk, in GB"
  type        = number
  default     = 100
}

variable "disk_type" {
  description = "storage type. `PD_SSD` or `PD_HDD`"
  type        = string
  default     = "PD_SSD"
}

variable "private_network" {
  description = "The resource link for the VPC network from which the instance is accessible using private IP"
  type        = string
  default     = null
}

variable "custom_labels" {
  description = "Custom labels"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Deletion Protection"
  type        = bool
  default     = "true"
}