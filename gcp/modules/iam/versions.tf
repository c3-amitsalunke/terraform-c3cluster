terraform {
  required_version = ">= 0.13"
  experiments      = [module_variable_optional_attrs]

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.34.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.34.0"
    }
  }
}
