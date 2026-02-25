variable "argocd_admin_password_hash" {
  type      = string
  sensitive = true
}

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
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
          }
        }
      }

      controller = {
        metrics = { enabled = false }
      }

      repoServer = {
        metrics = { enabled = false }
      }

      configs = {
        secret = {
          argocdServerAdminPassword      = var.argocd_admin_password_hash
          argocdServerAdminPasswordMtime = timestamp()
        }
      }
    })
  ]
}