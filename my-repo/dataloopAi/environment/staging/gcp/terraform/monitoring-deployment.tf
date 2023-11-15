resource "kubernetes_manifest" "kube-prometheus-stack" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "kube-prometheus-stack"
      namespace = "argocd"
    }
    spec = {
      project = local.project_id
      source = {
        repoURL        = "https://github.com/idog1980/dlai.git"
        path           = "my-repo/dataloopAi/environment/staging/gcp/apps/kube-prometheus-stack"
        targetRevision = "HEAD"
        chart          = "kube-prometheus-stack"
        helm = {
          valueFiles = ["values.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "monitoring"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [module.gke, module.argocd]
}