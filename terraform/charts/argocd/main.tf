## argocdのリリース　project, applicationはデプロイしていない。
resource "helm_release" "argocd" {
  name             = var.argocd.name
  chart            = var.argocd.chart
  create_namespace = var.argocd.create_namespace
  namespace        = var.argocd.namespace
  version          = var.argocd.version
  repository       = var.argocd.repository
}
