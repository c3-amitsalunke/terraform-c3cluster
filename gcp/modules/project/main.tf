locals {
  activate_compute_identity = 0 != length([for i in var.activate_api_identities : i if i.api == "compute.googleapis.com"])
  service_identities = flatten([
    for i in var.activate_api_identities : [
      for r in i.roles :
      { api = i.api, role = r }
    ]
  ])
}

resource "google_project_service_identity" "project_service_identities" {
  for_each = {
    for i in var.activate_api_identities :
    i.api => i
    if i.api != "compute.googleapis.com"
  }

  provider = google-beta
  project  = var.project_id
  service  = each.value.api
}

### Process the compute.googleapis.com identity separately, if present in the inputs.
data "google_compute_default_service_account" "default" {
  count   = local.activate_compute_identity ? 1 : 0
  project = var.project_id
}

locals {
  add_service_roles = merge(
    {
      for si in local.service_identities :
      "${si.api} ${si.role}" => {
        email = google_project_service_identity.project_service_identities[si.api].email
        role  = si.role
      }
      if si.api != "compute.googleapis.com"
    },
    {
      for si in local.service_identities :
      "${si.api} ${si.role}" => {
        email = data.google_compute_default_service_account.default[0].email
        role  = si.role
      }
      if si.api == "compute.googleapis.com"
    }
  )
}

resource "google_project_iam_member" "project_service_identity_roles" {
  for_each = local.add_service_roles

  project = var.project_id
  role    = each.value.role
  member  = "serviceAccount:${each.value.email}"
}
