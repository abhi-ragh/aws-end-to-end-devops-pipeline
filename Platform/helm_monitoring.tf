## IAM POLICY FOR ALERTMANAGER
resource "aws_iam_policy" "alertmanager_sns_policy" {
  name = "AlertmanagerSNSPublishPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = aws_sns_topic.eks_alerts.arn
      }
    ]
  })
}

## IRSA ROLE FOR ALERTMANAGER
module "alertmanager_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role = true
  role_name   = "eks-alertmanager-sns-role"

  provider_url = data.terraform_remote_state.infra.outputs.cluster_oidc_provider

  role_policy_arns = [
    aws_iam_policy.alertmanager_sns_policy.arn
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:monitoring:monitoring-kube-prometheus-alertmanager"
  ]
}

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

  alertmanagerSpec = {
    additionalConfig = {
      route = {
        receiver = "sns-notifications"
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
}

    })
  ]
}