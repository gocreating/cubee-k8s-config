terraform {
  backend "remote" {
    organization = "cubee"

    workspaces {
      name = "cubee"
    }
  }
}

variable "project" {
  default = {
    id = "cubee-259905"
    region = "asia-east1"
    zone = "asia-east1-a"
    credentials_file_path = "../cubee-259905-sa-terraform.json"
  }
}

variable "cluster_stg" {
  default = {
    cluster_name = "cubee-stg"
    master_and_node_version = "1.14"
    node_pool_name = "node-pool-stg"
    node_machine_type = "g1-small"
    node_count = 2
    node_disk_size_gb = 10
  }
}

variable "cluster_prod" {
  default = {
    cluster_name = "cubee-prod"
    master_and_node_version = "1.14"
    node_pool_name = "node-pool-prod"
    node_machine_type = "g1-small"
    node_count = 2
    node_disk_size_gb = 10
  }
}

variable "dns" {
  default = {
    zone_name = "cubee-cc-zone"
    dns_name = "cubee.cc."
  }
}
