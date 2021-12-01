terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.43.0"
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