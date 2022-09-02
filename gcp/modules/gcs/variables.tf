variable "project_id" {
  description = "The Id for the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "region" {
  description = "The region for subnetworks in the network. Ref https://cloud.google.com/compute/docs/general-purpose-machines & https://cloud.google.com/compute/docs/regions-zones"
  type        = string
}

variable "labels" {
  description = "Map of labels for project"
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

variable "bucket_name" {
  description = "Bucket Name"
  type        = string
  default     = null
}

variable "cors" {
  description = "Configuration of CORS for bucket with structure as defined in https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket#cors."
  type        = any
  default     = []
}
