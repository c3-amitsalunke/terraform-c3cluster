resource "google_service_account" "service_account" {
  for_each     = var.c3_service_accounts
  project      = var.project
  account_id   = each.key
  display_name = each.value.display_name
}

locals {
  project_bindings                        = transpose(zipmap(keys(var.c3_service_accounts), values(var.c3_service_accounts)[*].roles))

  project_iam_bindings                    = { for key, value in local.project_bindings : key => [for sa in value : "serviceAccount:${google_service_account.service_account[sa].email}"] }

  kubernetes_service_account_iam_bindings = { for key, value in var.kubernetes_workload_identity_users : "projects/${var.project}/serviceAccounts/${key}@${var.project}.iam.gserviceaccount.com" => [for member in value : "serviceAccount:${var.project}.svc.id.goog[${member}]"] }
}

resource "google_project_iam_binding" "project_iam_bindings" {
  for_each = local.project_iam_bindings

  project = var.project
  role    = each.key

  members = each.value
}

resource "google_service_account_iam_binding" "kubernetes_service_account_iam_bindings" {
  for_each = local.kubernetes_service_account_iam_bindings

  service_account_id = each.key
  role               = "roles/iam.workloadIdentityUser"

  members = each.value

  depends_on = [google_service_account.service_account]
}
