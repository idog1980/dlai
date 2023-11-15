module "argocd" {
  source   = "aigisuk/argocd/kubernetes"
  insecure = true

  depends_on = [
    module.gke
  ]
}