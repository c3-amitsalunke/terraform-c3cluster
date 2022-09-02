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

variable "name" {
  description = "DB instance name"
  type        = string
  default     = null
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

variable "postgres_version" {
  description = "DB version. Ref https://cloud.google.com/sql/docs/db-versions"
  type        = string
  default     = "POSTGRES_11"
}

variable "instance_type" {
  description = "Instance type. Ref https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type#create"
  type        = string
}

variable "backup_enabled" {
  description = "Enabled / Disable backup"
  type        = bool
  default     = true
}

variable "backup_point_in_time_recovery_enabled" {
  description = "Enable point_in_time_recovery"
  type        = bool
  default     = true
}

variable "backup_transaction_log_retention_days" {
  description = "transaction_log_retention_days"
  type        = string
  default     = null
}

variable "backup_retained_backups" {
  description = "Number of retained_backups"
  type        = number
  default     = null
}

variable "backup_retention_units" {
  description = "backup_retention_units"
  type        = string
  default     = null
}

variable "database_flags" {
  description = "The database flags for the master instance. See [more details](https://cloud.google.com/sql/docs/postgres/flags)"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name : "autovacuum",
      value : "on"
    },
    {
      name : "autovacuum_analyze_scale_factor",
      value : "0.005"
    },
    {
      name : "autovacuum_analyze_threshold",
      value : "10000"
    },
    {
      name : "autovacuum_max_workers",
      value : "35"
    },
    {
      name : "autovacuum_naptime",
      value : "2"
    },
    {
      name : "autovacuum_vacuum_cost_limit",
      value : "7000"
    },
    {
      name : "autovacuum_vacuum_scale_factor",
      value : "0.01"
    },
    {
      name : "autovacuum_vacuum_threshold",
      value : "10000"
    },
    {
      name : "log_min_duration_statement",
      value : "600"
    },
    {
      name : "maintenance_work_mem",
      value : "131072"
    },
    {
      name : "work_mem",
      value : "51200"
    },
    {
      name : "track_activity_query_size",
      value : "2048"
    },
    {
      name : "pg_stat_statements.track",
      value : "all"
    },
    {
      name : "pg_stat_statements.max",
      value : "10000"
    },
    {
      name : "log_temp_files",
      value : "0"
    },
  ]
}

variable "disk_autoresize" {
  description = "Configuration to increase storage size automatically"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "The maximum size to which storage can be auto increased."
  type        = number
  default     = 0
}

variable "disk_size" {
  description = "The size of data disk, in GB"
  type        = number
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

variable "labels" {
  description = "Custom labels"
  type        = map(string)
  default     = {}
}

variable "deletion_protection" {
  description = "Deletion Protection"
  type        = bool
  default     = "true"
}

#variable "default_user_name" {
#  description = "Default user_name for postgres"
#  type        = string
#}
#
#variable "default_user_password" {
#  description = "Password for Default user_name"
#  type        = string
#}
