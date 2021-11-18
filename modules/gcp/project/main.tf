resource "google_project_service" "project_services" {
  for_each = var.activate_apis
  project  = var.project
  service  = each.value
}

resource "google_kms_key_ring" "keyring" {
  name     = "${var.project}-keyring-1"
  location = var.region
}

resource "google_kms_crypto_key" "kms_key" {
  name            = "${var.project}-key-1"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "7776000s"

  lifecycle {
    prevent_destroy = true
  }
}

#https://cloud.google.com/sql/docs/mysql/configure-cmek#grantkey
#https://cloud.google.com/sql/docs/mysql/configure-cmek#service-account
#https://cloud.google.com/sql/docs/mysql/configure-cmek
#resource "google_kms_crypto_key_iam_binding" "decrypters" {
#  role          = "roles/cloudkms.cryptoKeyDecrypter"
#  crypto_key_id = google_kms_crypto_key.kms_key.id
#  members       = var.kms_members
#}
#
#resource "google_kms_crypto_key_iam_binding" "encrypters" {
#  role          = "roles/cloudkms.cryptoKeyEncrypter"
#  crypto_key_id = google_kms_crypto_key.kms_key.id
#  members       = var.kms_members
#}

#https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster

resource "google_service_account" "service_account" {
  for_each     = var.c3_service_accounts
  project      = var.project
  account_id   = each.key
  display_name = each.value.display_name
}

locals {
  all_service_account_roles = flatten([
    for sa in keys(var.c3_service_accounts) : [
      for role in var.c3_service_accounts[sa].roles : {
        sa  = sa
        role = role
      }
    ]
  ])
}

resource "google_project_iam_member" "service_account-roles" {
  for_each = { for entry in local.all_service_account_roles: "${entry.sa}.${entry.role}" => entry }

  project = var.project
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.service_account[each.value.sa].email}"
}
