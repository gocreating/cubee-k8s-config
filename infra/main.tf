provider "google" {
  credentials = file(var.project.credentials_file_path)

  project = var.project.id
  region  = var.project.region
  zone    = var.project.zone
}

#######################
##                   ##
##  Staging Cluster  ##
##                   ##
#######################

resource "google_container_cluster" "staging" {
  name     = var.cluster_stg.cluster_name
  location = var.project.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.cluster_stg.master_and_node_version

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  provisioner "local-exec" {
    command = "echo ${google_container_cluster.staging.name}: ${google_container_cluster.staging.endpoint} >> ip_address.txt"
  }
}

resource "google_container_node_pool" "staging_preemptible_nodes" {
  name       = var.cluster_stg.node_pool_name
  location   = var.project.zone
  cluster    = google_container_cluster.staging.name
  version    = var.cluster_stg.master_and_node_version
  node_count = var.cluster_stg.node_count

  node_config {
    preemptible  = true
    machine_type = var.cluster_stg.node_machine_type
    disk_size_gb = var.cluster_stg.node_disk_size_gb

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

##########################
##                      ##
##  Production Cluster  ##
##                      ##
##########################

resource "google_container_cluster" "production" {
  name     = var.cluster_prod.cluster_name
  location = var.project.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.cluster_prod.master_and_node_version

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    http_load_balancing {
      disabled = true
    }
  }

  provisioner "local-exec" {
    command = "echo ${google_container_cluster.production.name}: ${google_container_cluster.production.endpoint} >> ip_address.txt"
  }
}

resource "google_container_node_pool" "production_preemptible_nodes" {
  name       = var.cluster_prod.node_pool_name
  location   = var.project.zone
  cluster    = google_container_cluster.production.name
  version    = var.cluster_prod.master_and_node_version
  node_count = var.cluster_prod.node_count

  node_config {
    preemptible  = true
    machine_type = var.cluster_prod.node_machine_type
    disk_size_gb = var.cluster_prod.node_disk_size_gb

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

################
##            ##
##  DNS Zone  ##
##            ##
################

resource "google_dns_managed_zone" "primary_zone" {
  name = var.dns.zone_name
  dns_name = var.dns.dns_name
}

resource "google_dns_record_set" "ns" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = google_dns_managed_zone.primary_zone.dns_name
  type = "NS"
  ttl = 21600
  rrdatas = var.dns.ns_records
}

resource "google_dns_record_set" "soa" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = google_dns_managed_zone.primary_zone.dns_name
  type = "SOA"
  ttl = 21600
  rrdatas = var.dns.soa_records
}

######################
##                  ##
##  Staging Record  ##
##                  ##
######################

resource "google_dns_record_set" "stg_main" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = "stg.${google_dns_managed_zone.primary_zone.dns_name}"
  type = "A"
  ttl = 300

  rrdatas = [
    google_container_cluster.staging.endpoint,
  ]
}

resource "google_dns_record_set" "stg_wildcard_main" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = "*.stg.${google_dns_managed_zone.primary_zone.dns_name}"
  type = "A"
  ttl = 300

  rrdatas = [
    google_container_cluster.staging.endpoint,
  ]
}

#########################
##                     ##
##  Production Record  ##
##                     ##
#########################

resource "google_dns_record_set" "prod_main" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = google_dns_managed_zone.primary_zone.dns_name
  type = "A"
  ttl = 300

  rrdatas = [
    google_container_cluster.production.endpoint,
  ]
}

resource "google_dns_record_set" "prod_wildcard_main" {
  managed_zone = google_dns_managed_zone.primary_zone.name
  name = "*.${google_dns_managed_zone.primary_zone.dns_name}"
  type = "A"
  ttl = 300

  rrdatas = [
    google_container_cluster.production.endpoint,
  ]
}
