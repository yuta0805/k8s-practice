variable "argocd" {
  type = object({
    name = string
    chart = string
    create_namespace = bool
    namespace = string
    version = string
    repository = string
  })
}
