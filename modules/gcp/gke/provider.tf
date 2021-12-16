terraform {
  experiments = [module_variable_optional_attrs]

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.1.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "4.1.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

provider "google-beta" {
  project = var.project
  region  = var.region
}
