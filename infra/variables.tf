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
    node_pool_name = "node-pool-stg"
    node_machine_type = "g1-small"
    node_count = 2
    node_disk_size_gb = 10
  }
}

variable "dns" {
  default = {
    zone_name = "cubee-cc-zone"
    dns_name = "cubee.cc."
    # transfer godaddy dns to cloud dns
    ns_records = [
      "ns-cloud-c1.googledomains.com.",
      "ns-cloud-c2.googledomains.com.",
      "ns-cloud-c3.googledomains.com.",
      "ns-cloud-c4.googledomains.com.",
    ]
    soa_records = [
      "ns-cloud-c1.googledomains.com. cloud-dns-hostmaster.google.com. 1 21600 3600 259200 300",
    ]
  }
}
