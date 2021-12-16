output "network" {
  description = "A reference (self_link) to the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnetwork_gke" {
  description = "A reference (self_link) to the VPC network"
  value       = google_compute_subnetwork.vpc_subnetwork_gke.self_link
}

output "private_vpc_connection" {
  description = "A reference (self_link) to the vpc_connection"
  value       = google_service_networking_connection.private_vpc_connection.network
}
