provider "google" {
  # version = "~> 5.0.0"
  region  = local.region
  project = local.project_id
}

provider "random" {
  #version = "~> 3.5.0"
}

provider "null" {
  #version = "~> 3.2.0"
}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.21.1"
    }
  }
}

## Data Sources
data "google_client_config" "default" {}
