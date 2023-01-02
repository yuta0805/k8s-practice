# resource "helm_release" "nginx_ingress" {
#   name       = "nginx-ingress-controller"

#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "nginx-ingress-controller"

#   set {
#     name  = "service.type"
#     value = "ClusterIP"
#   }
# }

## argocdのリリース　project, applicationはデプロイしていない。
resource "helm_release" "argocd" {
  name             = "argocd"
  chart            = "argo-cd"
  create_namespace = true
  namespace        = "argocd"
  version          = "4.10.8"
  repository       ="https://argoproj.github.io/argo-helm"
}
