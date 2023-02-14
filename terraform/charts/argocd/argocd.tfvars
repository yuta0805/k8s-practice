argocd = {
  name             = "argocd"
  chart            = "argo-cd"
  create_namespace = true
  namespace        = "argocd"
  version          = "4.10.8"
  repository       ="https://argoproj.github.io/argo-helm"
}
