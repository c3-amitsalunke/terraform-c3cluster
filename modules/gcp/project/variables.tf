variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network. Ref https://cloud.google.com/compute/docs/general-purpose-machines & https://cloud.google.com/compute/docs/regions-zones"
  type        = string
}

variable "activate_apis" {
  description = "List of APIs to be enabled"
  type        = set(string)
  default = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "bigquery.googleapis.com",
    "dns.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage-component.googleapis.com",
    "container.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudkms.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com",
    "file.googleapis.com"
  ]
}

variable "key_ring_name" {
  description = "A `KeyRing` is a toplevel logical grouping of `CryptoKeys`"
  type        = string
  default     = ""
}

variable "crypto_key_name" {
  description = "A logical key that can be used for cryptographic operations"
  type        = string
  default     = ""
}

variable "kms_members" {
  description = "Service Accounts who has encrypters & decrypters access on kms_key"
  type        = set(string)
  default     = []
}
