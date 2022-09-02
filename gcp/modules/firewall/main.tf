locals {
  vpc_name        = var.vpc_name == null ? "${var.project_name}-vpc-1" : var.vpc_name
  ssl_policy_name = var.ssl_policy_name == null ? "${var.project_name}-sslpolicy" : var.ssl_policy_name
  lb_policy_name  = var.lb_policy_name == null ? "${var.project_name}-securitypolicy-lb" : var.lb_policy_name

  allowlist_443  = [for key, value in var.ip_allowlist : value.cidr_block]
  allowlist_5432 = concat([], [var.gke_cidr_block])

  firewall_rules = length(var.firewall_rules) == 0 ? [
    {
      name = "allowlist-443"
      allow = {
        protocol = "tcp"
        ports    = ["443"]
      }
      source_ranges = local.allowlist_443
    },
    {
      name = "control-plane-cidr-webhooks"
      allow = {
        protocol = "tcp"
        ports    = ["443", "9443"]
      }
      source_ranges = [
        var.gke_master_ipv4_cidr_block
      ]
    },
    {
      name = "internal-5432"
      allow = {
        protocol = "tcp"
        ports    = ["5432"]
      }
      source_ranges = local.allowlist_5432
    },
  ] : var.firewall_rules
}

#tfsec:ignore:google-compute-no-public-ingress
resource "google_compute_firewall" "default_firewall_rules" {
  count = length(local.firewall_rules)

  name    = local.firewall_rules[count.index].name
  project = var.project_id
  network = local.vpc_name

  allow {
    protocol = local.firewall_rules[count.index].allow.protocol
    ports    = local.firewall_rules[count.index].allow.ports
  }

  source_ranges = local.firewall_rules[count.index].source_ranges
}

## Cloud Armor configuration
resource "google_compute_security_policy" "lb_policy" {
  name    = local.lb_policy_name
  project = var.project_id

  # Ref : https://docs.bridgecrew.io/docs/ensure-cloud-armor-prevents-message-lookup-in-log4j2
  rule {
    action   = "deny(403)"
    priority = 1
    match {
      expr {
        expression = "evaluatePreconfiguredExpr('cve-canary')"
      }
    }
  }

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = local.allowlist_443
      }
    }
    description = "Allow access to whitelisted IPs"
  }

  rule {
    action   = "deny(404)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default DenyAll rule"
  }

  dynamic "rule" {
    for_each = var.security_policies
    content {
      action   = rule.value.action
      priority = rule.value.priority
      match {
        versioned_expr = rule.value.match.versioned_expr
        config {
          src_ip_ranges = rule.value.match.config_src_ip_ranges
        }
      }
    }
  }
}

# Cloud Armor ssl policy
resource "google_compute_ssl_policy" "default_ssl_policy" {
  name            = local.ssl_policy_name
  project         = var.project_id
  min_tls_version = "TLS_1_2"
  profile         = "CUSTOM"
  custom_features = var.ssl_policy_custom_feature
}
