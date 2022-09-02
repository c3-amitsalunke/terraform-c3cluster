data "google_project" "kms_project" {
  project_id = var.project_id
}

locals {
  key_ring_name           = var.key_ring_name == null ? "${var.project_name}-keyring-1" : var.key_ring_name
  default_crypto_key_name = "${var.project_name}-key-1"
  crypto_keys             = length(var.crypto_keys) == 0 ? [local.default_crypto_key_name] : var.crypto_keys
  kms_members             = formatlist("serviceAccount:service-${data.google_project.kms_project.number}@%s", var.kms_members)
}

resource "google_kms_key_ring" "key_ring" {
  name     = local.key_ring_name
  project  = var.project_id
  location = var.region
}

resource "google_kms_crypto_key" "crypto_keys" {
  for_each        = local.crypto_keys
  name            = each.value
  key_ring        = google_kms_key_ring.key_ring.id
  rotation_period = "7776000s"
  purpose         = "ENCRYPT_DECRYPT"

  labels = var.labels

  lifecycle {
    prevent_destroy = true
  }

  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

resource "google_kms_crypto_key_iam_binding" "encrypter_decrypter" {
  for_each      = local.crypto_keys
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  crypto_key_id = google_kms_crypto_key.crypto_keys[each.value].id
  members       = compact(local.kms_members)
}
