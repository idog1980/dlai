resource "kubernetes_manifest" "nginx_argocd_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "nginx-deployment"
      namespace = "argocd"
    }
    spec = {
      project = local.project_id
      source = {
        repoURL        = "https://github.com/idog1980/dlai.git"
        targetRevision = "HEAD"
        path           = "my-repo/dataloopAi/environment/staging/gcp/apps/nginx"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "services"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
      }

      syncOptions = [
        "CreateNamespace=true"
      ]
      retry = {
        limit = 5
      }

      syncPeriod = "2m"
    }
  }
  depends_on = [module.argocd]
}
