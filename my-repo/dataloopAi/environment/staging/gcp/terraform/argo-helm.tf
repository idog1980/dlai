resource "time_sleep" "wait_5_min" {
  create_duration = "5m"
}


module "argocd" {
  source   = "aigisuk/argocd/kubernetes"
  insecure = true

  depends_on = [
    module.gke,
    time_sleep.wait_5_min
  ]
}