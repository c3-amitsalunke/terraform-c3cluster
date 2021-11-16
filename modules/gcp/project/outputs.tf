output "project_services" {
  value       = google_project_service.project_services
  description = "The GCP project you want to enable APIs on"
}

output "encryption_key_name" {
  value = google_kms_crypto_key.kms_key.id
  description = "The Encryption Key for gcp project"
}