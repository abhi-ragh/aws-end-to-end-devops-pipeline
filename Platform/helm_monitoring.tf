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
          type = "ClusterIP"
        }

        adminUser     = "admin"
        adminPassword = var.grafana_admin_password

        grafana.ini = {
          server = {
            root_url = "%(protocol)s://%(domain)s/grafana"
            serve_from_sub_path = true
          }
        }

        persistence = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp2"
        }
      }

      prometheus = {
        service = {
          type = "ClusterIP"
        }

        prometheusSpec = {
          retention = "10d"
          externalUrl = "/prometheus"
          routePrefix = "/prometheus"
        }
      }

      alertmanager = {
        service = {
          type = "ClusterIP"
        }

        alertmanagerSpec = {
          externalUrl = "/alertmanager"
          routePrefix = "/alertmanager"
        }
      }
    })
  ]
}