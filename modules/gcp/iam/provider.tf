terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "= 4.1.0"
    }
  }
}

provider "google" {
  project = var.project
}

provider "google-beta" {
  project = var.project
}