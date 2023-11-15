resource "time_sleep" "wait_5_min" {
  create_duration = "5m"
  depends_on      = [
    module.gke
    ]
}


module "argocd" {
  source   = "aigisuk/argocd/kubernetes"
  insecure = true

  depends_on = [
    time_sleep.wait_5_min
  ]
}