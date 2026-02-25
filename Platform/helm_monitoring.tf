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

      ########################
      # GRAFANA
      ########################
      grafana = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
          }
        }

        adminUser     = "admin"
        adminPassword = var.grafana_admin_password

        persistence = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp2"
        }

        additionalDataSources = [
          {
            name   = "Loki"
            type   = "loki"
            access = "proxy"
            url    = "http://loki.loki.svc.cluster.local:3100"
            jsonData = {
              maxLines = 1000
            }
          }
        ]
      }

      ########################
      # PROMETHEUS
      ########################
      prometheus = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
          }
        }

        prometheusSpec = {
          retention = "10d"
        }
      }

      ########################
      # ALERTMANAGER
      ########################
      alertmanager = {

        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"            = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
            "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
          }
        }

        serviceAccount = {
          create = true
          name   = "monitoring-kube-prometheus-alertmanager"
          annotations = {
            "eks.amazonaws.com/role-arn" = module.alertmanager_irsa.iam_role_arn
          }
        }

        config = {
          global = {
            resolve_timeout = "5m"
          }

          route = {
            receiver       = "sns-notifications"
            group_wait     = "30s"
            group_interval = "5m"
            repeat_interval = "4h"
          }

          receivers = [
            {
              name = "sns-notifications"
              sns_configs = [
                {
                  topic_arn = aws_sns_topic.eks_alerts.arn
                  sigv4 = {
                    region = "us-east-1"
                  }
                }
              ]
            }
          ]
        }
      }

    })
  ]
}