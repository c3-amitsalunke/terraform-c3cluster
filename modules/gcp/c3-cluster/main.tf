module "gcp-project" {
  source      = "../project"
  project     = var.project
  region      = var.region
  kms_members = []
}

module "gcp-network" {
  source     = "../network"
  project    = var.project
  region     = var.region
  cidr_block = var.cidr_block

  depends_on = [module.gcp-project.project_services]
}

module "gcp-postgres" {
  source = "../postgres"

  project = var.project
  region  = var.region
  name    = "${var.project}-pg-2"

  instance_type = var.pg_instance_type

  private_network = module.gcp-network.network

  # Wait for the vpc connection to complete
  depends_on = [module.gcp-network.private_vpc_connection]

  custom_labels       = {
    c3_cluster = var.project
  }
  deletion_protection = false
  encryption_key_name = module.gcp-project.encryption_key_name
}

module "gke" {
  source = "../gke"

  project      = var.project
  description  = "GKE cluster for c3"
  cluster_name = "${var.project}-gke-1"
  network      = module.gcp-network.network
  region       = var.region
  subnetwork   = module.gcp-network.subnetwork_gke

  primary_nodepool_name = "${var.project}-nodepool-01"
  zk_nodepool_name      = "${var.project}-nodepool-zk"
  cass_nodepool_name    = "${var.project}-nodepool-cass"
  ops_nodepool_name     = "${var.project}-nodepool-ops"

  #sa = module.gcp-project.encryption_key_name
  service_account = "c3-default@${var.project}.iam.gserviceaccount.com"
}
