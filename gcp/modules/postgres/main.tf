locals {
  name = var.name == null ? "${var.project_name}-pg-01" : var.name

  private_network     = var.private_network == null ? "projects/${var.project_id}/global/networks/${var.project_name}-vpc-1" : var.private_network
  kms_key_ring_name   = var.kms_key_ring_name == null ? "${var.project_name}-keyring-1" : var.kms_key_ring_name
  kms_crypto_key_name = var.kms_crypto_key_name == null ? "${var.project_name}-key-1" : var.kms_crypto_key_name
}

#tfsec:ignore:google-sql-encrypt-in-transit-data
#tfsec:ignore:google-sql-pg-log-checkpoints
#tfsec:ignore:google-sql-pg-log-disconnections
#tfsec:ignore:google-sql-pg-log-lock-waits
#tfsec:ignore:google-sql-pg-log-connections
#tfsec:ignore:google-sql-pg-no-min-statement-logging
#tfsec:ignore:google-sql-enable-pg-temp-file-logging
resource "google_sql_database_instance" "master" {
  provider            = google-beta
  name                = local.name
  project             = var.project_id
  region              = var.region
  database_version    = var.postgres_version
  deletion_protection = var.deletion_protection
  encryption_key_name = "projects/${var.project_id}/locations/${var.region}/keyRings/${local.kms_key_ring_name}/cryptoKeys/${local.kms_crypto_key_name}"

  settings {
    tier                  = var.instance_type
    activation_policy     = "ALWAYS"
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit
    disk_size             = var.disk_size
    disk_type             = var.disk_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = local.private_network
      require_ssl     = false
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      point_in_time_recovery_enabled = var.backup_point_in_time_recovery_enabled
      binary_log_enabled             = false
      transaction_log_retention_days = var.backup_transaction_log_retention_days
      #      backup_retention_settings {
      #        retained_backups = var.backup_retained_backups
      #        retention_unit   = var.backup_retention_units
      #      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = var.labels
  }

  lifecycle {
    ignore_changes = [
      settings[0].disk_size,
      settings[0].maintenance_window,
      settings[0].ip_configuration,
      encryption_key_name,
    ]
  }
}
