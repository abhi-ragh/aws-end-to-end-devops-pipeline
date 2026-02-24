resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      server = {
        service = {
          type = "LoadBalancer"
        }
      }

      controller = {
        metrics = {
          enabled = false
        }
      }

      repoServer = {
        metrics = {
          enabled = false
        }
      }
    })
  ]
}