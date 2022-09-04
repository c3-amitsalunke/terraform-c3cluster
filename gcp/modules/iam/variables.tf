variable "project_id" {
  description = "The Id for the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "service_accounts" {
  description = "Service Accounts for c3 deployment with workload load identities"
  type = map(object({
    display_name = string
    roles        = list(string)
    kubernetes_service_accounts = optional(list(object({
      namespace       = string
      service_account = string
    })))
  }))
  default = {}
}
