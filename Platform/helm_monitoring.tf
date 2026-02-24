variable "grafana_admin_password" {
  type      = string
  sensitive = true
}

resource "helm_release" "kube_prometheus_stack" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({

      grafana = {
        service = {
          type = "LoadBalancer"
        }

        adminUser     = "admin"
        adminPassword = var.grafana_admin_password

        persistence = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp2"
        }
      }

      prometheus = {
        prometheusSpec = {
          retention = "10d"
        }

        service = {
          type = "LoadBalancer"
        }
      }

      alertmanager = {
        alertmanagerSpec = {}

        service = {
          type = "LoadBalancer"
        }
      }
    })
  ]
}