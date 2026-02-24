resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "loki"
  create_namespace = true
  depends_on = [helm_release.aws_load_balancer_controller]

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "loki-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = data.terraform_remote_state.infra.outputs.loki_irsa_role_arn
        }
      }

      loki = {
        auth_enabled = false

        commonConfig = {
          replication_factor = 1
        }

        schemaConfig = {
          configs = [
            {
              from         = "2024-01-01"
              store        = "boltdb-shipper"
              object_store = "s3"
              schema       = "v13"
              index = {
                prefix = "index_"
                period = "24h"
              }
            }
          ]
        }

        storage = {
          type = "s3"

          bucketNames = {
            chunks = data.terraform_remote_state.infra.outputs.loki_chunks_bucket
            ruler  = data.terraform_remote_state.infra.outputs.loki_ruler_bucket
            admin  = data.terraform_remote_state.infra.outputs.loki_index_bucket
          }

          s3 = {
            region = "us-east-1"
          }
        }
      }
    })
  ]
}