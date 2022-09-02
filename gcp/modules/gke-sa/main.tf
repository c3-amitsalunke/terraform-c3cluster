resource "google_service_account_iam_binding" "kubernetes_service_account_iam_binding" {
  service_account_id = var.service_account_id
  role               = "roles/iam.workloadIdentityUser"
  members            = var.members
}
