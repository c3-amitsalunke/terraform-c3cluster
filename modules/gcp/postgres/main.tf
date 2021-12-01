resource "google_sql_database_instance" "master" {
  provider         = google-beta
  name             = var.name
  project          = var.project
  region           = var.region
  database_version = var.postgres_version
  deletion_protection = var.deletion_protection
  encryption_key_name = var.encryption_key_name

  settings {
    tier              = var.instance_type
    activation_policy = "ALWAYS"
    disk_autoresize   = var.disk_autoresize
    disk_size         = var.disk_size
    disk_type         = var.disk_type

    ip_configuration {
      ipv4_enabled    = true
      private_network = var.private_network
      require_ssl     = false

      authorized_networks = [

      ]
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.custom_labels
  }
}
