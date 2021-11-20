variable "project" {}

variable "region" {
  description = "The region for subnetworks in the network. Ref https://cloud.google.com/compute/docs/general-purpose-machines & https://cloud.google.com/compute/docs/regions-zones"
  type        = string
}

variable "activate_apis" {
  description = "List of APIs to be enabled"
  type        = set(string)
  default     = [
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

variable "c3_service_accounts" {
  description = "Service Accounts for c3 deployment"
  type        = map(any)
  default     = {
    "c3-admin" : {
      "display_name" : "Admin service account for c3 deployment",
      "roles" : [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer"
      ]
    },
    "c3-default" : {
      "display_name" : "Default iam role for c3 deployment",
      "roles" : [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer"
      ]
    },
    "c3-server" : {
      "display_name" : "Service account for c3 server",
      "roles" : [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer"
      ]
    }
  }
}


