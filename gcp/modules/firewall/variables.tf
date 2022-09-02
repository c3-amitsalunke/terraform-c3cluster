variable "project_id" {
  description = "The Id for the project"
  type        = string
}

variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "firewall_rules" {
  description = "Firewall rules"
  type = list(object(
    {
      name = string
      allow = object({
        protocol = string,
        ports    = optional(list(string))
      })
      source_ranges = list(string)
    }
  ))
  default = []
}

variable "security_policies" {
  description = "Google Compute Security Policy"
  type = list(object(
    {
      action   = string
      priority = string
      match = object({
        versioned_expr       = optional(string)
        config_src_ip_ranges = optional(list(string))
        expression           = optional(string)
      })
      description = string
  }))
  default = []
}

variable "ip_allowlist" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "All List of ips to access C3 network"
  default     = []
}

variable "gke_cidr_block" {
  description = "CIDR used by GKE subnet"
  default     = "10.0.0.0/22"
  type        = string
}

variable "gke_master_ipv4_cidr_block" {
  description = "CIDR block for GKE control plain"
  type        = string
  default     = "10.0.6.16/28"
}

variable "vpc_name" {
  description = "Name of the vpc"
  type        = string
  default     = null
}

variable "lb_policy_name" {
  description = "Name of the Cloud armor policy"
  type        = string
  default     = null
}

variable "ssl_policy_name" {
  description = "default ssl policy name"
  type        = string
  default     = null
}

variable "ssl_policy_custom_feature" {
  description = "Cloud armor policy name"
  type        = list(string)
  default = [
    "TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA",
    "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA",
    "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA",
    "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA",
    "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
    "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256",
    "TLS_RSA_WITH_3DES_EDE_CBC_SHA",
    "TLS_RSA_WITH_AES_128_CBC_SHA",
    "TLS_RSA_WITH_AES_128_GCM_SHA256",
    "TLS_RSA_WITH_AES_256_CBC_SHA",
    "TLS_RSA_WITH_AES_256_GCM_SHA384"
  ]
}
