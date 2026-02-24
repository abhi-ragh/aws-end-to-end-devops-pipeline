resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "loki"
  create_namespace = true

  wait    = true
  timeout = 600

  values = [
    yamlencode({

      deploymentMode = "SingleBinary"

      singleBinary = {
        replicas = 1

        resources = {
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }

        persistence = {
          enabled      = true
          size         = "10Gi"
          storageClass = "gp2"
        }
      }

      # HARD disable distributed components
      backend = { replicas = 0 }
      read    = { replicas = 0 }
      write   = { replicas = 0 }
      gateway = { enabled = false }

      # HARD disable all caching layers
      chunksCache = {
        enabled = false
      }

      resultsCache = {
        enabled = false
      }

      memcached = {
        enabled = false
      }

      memcachedExporter = {
        enabled = false
      }

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

        limits_config = {
          allow_structured_metadata = false
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