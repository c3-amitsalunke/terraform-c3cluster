variable "project_id" {
  description = "The Id for the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "service_account_id" {
  description = "The fully-qualified name of the service account to apply policy to"
  type        = string
}

variable "members" {
  description = "Identities that will be granted the privilege"
  type        = list(string)
}
