locals {
  bucket_name = var.bucket_name == null ? "${replace(var.project_name, "-", "")}store01" : var.bucket_name

  kms_key_ring_name   = var.kms_key_ring_name == null ? "${var.project_name}-keyring-1" : var.kms_key_ring_name
  kms_crypto_key_name = var.kms_crypto_key_name == null ? "${var.project_name}-key-1" : var.kms_crypto_key_name
}

resource "google_storage_bucket" "default" {
  name          = local.bucket_name
  project       = var.project_id
  location      = var.region
  force_destroy = false

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = "projects/${var.project_id}/locations/${var.region}/keyRings/${local.kms_key_ring_name}/cryptoKeys/${local.kms_crypto_key_name}"
  }

  labels = var.labels

  dynamic "cors" {
    for_each = var.cors == null ? [] : var.cors
    content {
      origin          = lookup(cors.value, "origin", null)
      method          = lookup(cors.value, "method", null)
      response_header = lookup(cors.value, "response_header", null)
      max_age_seconds = lookup(cors.value, "max_age_seconds", null)
    }
  }
}
