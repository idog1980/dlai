## Data Sources
data "google_client_config" "default" {}

## Variables
variable "cluster_name" {
    default = "gke-dlai"
}
variable "network" { default = "default" }
variable "subnetwork" { default = "" }
variable "ip_range_pods" { default = "" }
variable "ip_range_services" { default = "" }
variable "arogcd_namespace" { default = "argocd" }
variable "nginx_namespace" { default = "services" }
variable "grafana_namespace" { default = "monitoring" }

## GKE Cluster
module "gke" {
  source  = "terraform-google-modules/kubernetes-engine/google"
  version = "29.0.0"

  # required variables
  project_id        = local.project_id
  name              = var.cluster_name
  region            = local.region
  network           = var.network
  subnetwork        = var.subnetwork
  ip_range_pods     = var.ip_range_pods
  ip_range_services = var.ip_range_services

  # optional variables
  kubernetes_version       = "1.27.3-gke.100"
  regional                 = true
  create_service_account   = false
  remove_default_node_pool = true
  deletion_protection = false

  # addons
  network_policy             = false
  horizontal_pod_autoscaling = true
  http_load_balancing        = true

  node_pools = [
    {
      name               = "default-node-pool"
      machine_type       = "e2-medium"
      min_count          = 2
      max_count          = 4
      local_ssd_count    = 0
      disk_size_gb       = 100
      disk_type          = "pd-standard"
      image_type         = "COS_CONTAINERD"
      auto_repair        = true
      auto_upgrade       = true
      initial_node_count = 1
    },
  ]

  node_pools_oauth_scopes = {
    all = []
    default-node-pool = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  node_pools_labels = {
    all = {}
    default-node-pool = {
      default-node-pool = true,
    }
  }

  node_pools_tags = {
    all = []
    default-node-pool = [
      "default-node-pool",
    ]
  }

  depends_on = [
    google_project_service.container_api,
    google_project_service.compute_api
  ]

}