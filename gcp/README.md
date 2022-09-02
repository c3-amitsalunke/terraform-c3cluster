# GCP Terraform module
Terraform module to create c3 cluster on GCP
## Usage
```hcl
module "c3cluster-gcp" {
  source = "terraform-c3cluster/gcp"

  c3_env                      = "local"
  c3_pod                      = "env"
  c3_region                   = "us-central1"
  folder_id                   = "folders/123456789"
  ip_allowlist = [
    "0.0.0.0/0"
  ]
  postgres_default_user_name     = "admin"
  postgres_default_user_password = "welcome1"
  service_accounts = {
    "c3-admin" : {
      "display_name" : "Admin service account for c3 deployment",
      "roles" : [
        "roles/logging.logWriter",
        "roles/monitoring.metricWriter",
        "roles/monitoring.viewer",
        "roles/stackdriver.resourceMetadata.writer",
        "roles/cloudkms.cryptoKeyEncrypterDecrypter",
        "roles/storage.admin"
      ],
      "kubernetes_service_accounts" : [
        {
          namespace       = "local-env"
          service_account = "c3server"
        }
      ]
    }
  }
  node_pools = [
    {
      name         = "default"
      machine_type = "n2-highmem-4"
      node_count   = 1
      min_count    = 1
      max_count    = 3
      labels       = {
        role = "default"
      }
    }
  ]
}
```

## References
[GKE cluster hardening](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 3.50, < 5.0 |
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | >= 3.50, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 3.50, < 5.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gcp-gcs"></a> [gcp-gcs](#module\_gcp-gcs) | ./modules/gcs | n/a |
| <a name="module_gcp-gke"></a> [gcp-gke](#module\_gcp-gke) | ./modules/gke | n/a |
| <a name="module_gcp-iam"></a> [gcp-iam](#module\_gcp-iam) | ./modules/iam | n/a |
| <a name="module_gcp-kms"></a> [gcp-kms](#module\_gcp-kms) | ./modules/kms | n/a |
| <a name="module_gcp-network"></a> [gcp-network](#module\_gcp-network) | ./modules/network | n/a |
| <a name="module_gcp-postgres"></a> [gcp-postgres](#module\_gcp-postgres) | ./modules/postgres | n/a |
| <a name="module_gcp-project"></a> [gcp-project](#module\_gcp-project) | ./modules/project | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_network.vpc_network](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_network) | data source |
| [google_kms_crypto_key.default_crypto_key_name](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_crypto_key) | data source |
| [google_kms_key_ring.key_ring](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/kms_key_ring) | data source |
| [google_project.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |
| [google_storage_project_service_account.gcs_account](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_project_service_account) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_activate_api_identities"></a> [activate\_api\_identities](#input\_activate\_api\_identities) | The list of service identities (Google Managed service account for the API) to force-create for the project (e.g. in order to grant additional roles).<br>    APIs in this list will automatically be appended to `activate_apis`.<br>    Not including the API in this list will follow the default behaviour for identity creation (which is usually when the first resource using the API is created).<br>    Any roles (e.g. service agent role) must be explicitly listed. See https://cloud.google.com/iam/docs/understanding-roles#service-agent-roles-roles for a list of related roles. | <pre>list(object({<br>    api   = string<br>    roles = list(string)<br>  }))</pre> | <pre>[<br>  {<br>    "api": "sqladmin.googleapis.com",<br>    "roles": [<br>      "roles/cloudsql.admin"<br>    ]<br>  },<br>  {<br>    "api": "container.googleapis.com",<br>    "roles": [<br>      "roles/container.serviceAgent"<br>    ]<br>  }<br>]</pre> | no |
| <a name="input_activate_apis"></a> [activate\_apis](#input\_activate\_apis) | List of APIs to be enabled | `set(string)` | <pre>[<br>  "iam.googleapis.com",<br>  "compute.googleapis.com",<br>  "bigquery.googleapis.com",<br>  "dns.googleapis.com",<br>  "cloudresourcemanager.googleapis.com",<br>  "storage-component.googleapis.com",<br>  "serviceusage.googleapis.com",<br>  "cloudkms.googleapis.com",<br>  "servicenetworking.googleapis.com",<br>  "file.googleapis.com",<br>  "storage-api.googleapis.com",<br>  "storage.googleapis.com",<br>  "container.googleapis.com"<br>]</pre> | no |
| <a name="input_billing_account"></a> [billing\_account](#input\_billing\_account) | The ID of the billing account to associate this project with | `string` | `""` | no |
| <a name="input_c3_env"></a> [c3\_env](#input\_c3\_env) | c3\_env | `string` | n/a | yes |
| <a name="input_c3_pod"></a> [c3\_pod](#input\_c3\_pod) | c3\_env | `string` | n/a | yes |
| <a name="input_c3_region"></a> [c3\_region](#input\_c3\_region) | c3\_region | `string` | n/a | yes |
| <a name="input_folder_id"></a> [folder\_id](#input\_folder\_id) | The ID of a folder to host this project | `string` | `""` | no |
| <a name="input_ip_allowlist"></a> [ip\_allowlist](#input\_ip\_allowlist) | All List of ips to access C3 network | `list(object({ cidr_block = string, display_name = string }))` | `[]` | no |
| <a name="input_kms_accessors"></a> [kms\_accessors](#input\_kms\_accessors) | List of Services that require KMS access | `list(string)` | <pre>[<br>  "sqladmin.googleapis.com",<br>  "storage.googleapis.com",<br>  "container.googleapis.com"<br>]</pre> | no |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | List of maps containing node pools | `list` | `[]` | no |
| <a name="input_postgres_default_user_name"></a> [postgres\_default\_user\_name](#input\_postgres\_default\_user\_name) | Default user\_name for postgres | `string` | n/a | yes |
| <a name="input_postgres_default_user_password"></a> [postgres\_default\_user\_password](#input\_postgres\_default\_user\_password) | Password for Default user\_name | `string` | n/a | yes |
| <a name="input_postgres_instance_name"></a> [postgres\_instance\_name](#input\_postgres\_instance\_name) | DB instance name | `string` | `""` | no |
| <a name="input_postgres_instance_type"></a> [postgres\_instance\_type](#input\_postgres\_instance\_type) | Instance type. Ref https://cloud.google.com/compute/docs/instances/creating-instance-with-custom-machine-type#create | `string` | `"db-f1-micro"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID to give the project. If not provided, the `name` will be used. | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name for the project | `string` | `""` | no |
| <a name="input_service_accounts"></a> [service\_accounts](#input\_service\_accounts) | Service Accounts for c3 deployment with workload load identities | <pre>map(object({<br>    display_name = string<br>    roles        = list(string)<br>    kubernetes_service_accounts = optional(list(object({<br>      namespace       = string<br>      service_account = string<br>    })))<br>  }))</pre> | `{}` | no |

## Outputs

No outputs.

<!-- END_TF_DOCS -->

[//]: # (BEGIN_TF_DOCS)
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

[//]: # (END_TF_DOCS)
