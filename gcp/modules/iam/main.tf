data "google_compute_default_service_account" "default_service_account" {
  project = var.project_id
}

data "google_compute_default_service_account" "default_service_account_2" {
  project = var.project_id
}


# This provisions google_storage_project_service_account
data "google_storage_project_service_account" "gcs_account" {
  project = var.project_id
}

resource "google_service_account" "service_account" {
  for_each     = var.service_accounts
  project      = var.project_id
  account_id   = each.key
  display_name = each.value.display_name
}

locals {
  project_bindings     = transpose(zipmap(keys(var.service_accounts), values(var.service_accounts)[*].roles))
  project_iam_bindings = { for key, value in local.project_bindings : key => [for sa in value : "serviceAccount:${google_service_account.service_account[sa].email}"] }
}

resource "google_project_iam_binding" "project_iam_bindings" {
  provider = google-beta
  for_each = local.project_iam_bindings

  project = var.project_id
  role    = each.key

  members = each.value
}
