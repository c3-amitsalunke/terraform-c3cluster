variable "project" {}

variable "c3_service_accounts" {
  description = "Service Accounts for c3 deployment"
  type = map(object({
    display_name = string
    roles        = list(string)
  }))
  default = {
    "c3-admin" : {
      "display_name" : "Admin service account for c3 deployment",
      "roles" : [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer",
        "roles/cloudkms.cryptoKeyEncrypterDecrypter",
        "roles/storage.admin"
      ]
    },
    "c3-server" : {
      "display_name" : "Service account for c3 server",
      "roles" : [
        "roles/cloudkms.cryptoKeyEncrypterDecrypter",
        "roles/storage.admin"
      ]
    },
    "cassandra" : {
      "display_name" : "Service account for cassandra",
      "roles" : [
        "roles/storage.admin"
      ]
    },
    "c3-default" : {
      "display_name" : "Default Service account for c3 deployment",
      "roles" : [
        "roles/actions.Viewer"
      ]
    }
  }
}

variable "kubernetes_workload_identity_users" {
  description = "Service Accounts binding for kubernetes deployment"
  type        = map(list(string))
  default = {
    "c3-admin" : [
      "argo/argo"
    ],
    "c3-server" : [
      "stage-gcpservices/c3-server"
    ],
    "cassandra" : [
      "stage-gcpservices/cassandra"
    ]
  }
}
