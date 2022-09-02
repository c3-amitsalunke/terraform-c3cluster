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

variable "key_ring_name" {
  description = "A `KeyRing` is a toplevel logical grouping of `CryptoKeys`"
  type        = string
  default     = null
}

variable "crypto_keys" {
  description = "List of `CryptoKeys`"
  type        = set(string)
  default     = []
}

variable "kms_members" {
  description = "List of SA that require KMS access"
  type        = list(string)
  default = [
    "gs-project-accounts.iam.gserviceaccount.com",
    "gcp-sa-cloud-sql.iam.gserviceaccount.com",
    "container-engine-robot.iam.gserviceaccount.com",
    "compute-system.iam.gserviceaccount.com"
  ]
}

variable "labels" {
  description = "user-defined Labels"
  type        = map(string)
  default     = {}
}
