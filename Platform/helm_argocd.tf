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
        cm = {
          "resource.customizations.health.argoproj.io_Rollout" = <<EOF
            hs = {}
            if obj.status ~= nil then
              if obj.status.phase == "Healthy" then
                hs.status = "Healthy"
                hs.message = "Rollout is healthy"
                return hs
              end
            end
            hs.status = "Progressing"
            hs.message = "Rollout is progressing"
            return hs
          EOF
        }

        secret = {
          argocdServerAdminPassword      = var.argocd_admin_password_hash
          argocdServerAdminPasswordMtime = timestamp()
        }
      }
      
    })
  ]
}

resource "helm_release" "argo_rollouts" {
  name             = "argo-rollouts"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-rollouts"
  namespace        = "argo-rollouts"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      installCRDs = true

      controller = {
        metrics = {
          enabled = false
        }
      }

      dashboard = {
        enabled = true
        service = {
          type = "ClusterIP"
        }
      }
    })
  ]
}