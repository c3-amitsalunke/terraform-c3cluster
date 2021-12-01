# gcp services
resource "google_project_service" "project_services" {
  for_each = var.activate_apis
  project  = var.project
  service  = each.value
}

## KMS
data "google_project" "gcp_project" {
}

data "google_storage_project_service_account" "gcs_account" {
}

locals {
  key_ring_name   = var.key_ring_name != "" ? var.key_ring_name : "${var.project}-keyring-1"
  crypto_key_name = var.crypto_key_name != "" ? var.crypto_key_name : "${var.project}-key-1"
}

locals {
  kms_members = concat(
    ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"],
    ["serviceAccount:service-${data.google_project.gcp_project.number}@gcp-sa-cloud-sql.iam.gserviceaccount.com"]
  )
}

resource "google_kms_key_ring" "keyring" {
  name     = local.key_ring_name
  location = var.region
}

resource "google_kms_crypto_key" "kms_key" {
  name            = local.crypto_key_name
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = false
  }
}
resource "google_kms_crypto_key_iam_binding" "EncrypterDecrypter" {
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  crypto_key_id = google_kms_crypto_key.kms_key.id
  members       = local.kms_members
}

## GCS
locals {
  bucket_name = "${replace(var.project, "-", "")}store01"
}

resource "google_storage_bucket" "storage_bucket_default" {
  name          = local.bucket_name
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  encryption {
    default_kms_key_name = google_kms_crypto_key.kms_key.id
  }

  depends_on = [google_kms_crypto_key_iam_binding.EncrypterDecrypter]
}