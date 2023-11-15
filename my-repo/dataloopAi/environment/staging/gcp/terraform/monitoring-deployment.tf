resource "kubernetes_namespace" "monitoring-namespace" {
  metadata {
    name = "monitoring"
  }
  depends_on = [module.gke]
}

resource "helm_release" "prometheus" {
  name      = "prometheus"
  namespace = "monitoring"
  chart     = "../apps/prometheus"
  set {
    name  = "service.type"
    value = "NodePort"
  }
  depends_on = [kubernetes_namespace.monitoring-namespace]
}

resource "helm_release" "grafana" {
  name      = "grafana"
  namespace = "monitoring"
  chart     = "../apps/grafana"
  set {
    name  = "service.type"
    value = "NodePort"
  }
  depends_on = [kubernetes_namespace.monitoring-namespace]
}