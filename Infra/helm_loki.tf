resource "helm_release" "loki" {
  name             = "loki"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "loki"
  namespace        = "loki"
  create_namespace = true

  values = [
    yamlencode({
      serviceAccount = {
        create = true
        name   = "loki-sa"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.irsa_loki.iam_role_arn
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

        storageConfig = {
          aws = {
            region              = "us-east-1"
            s3forcepathstyle    = false
            bucketnames         = join(",", [
              aws_s3_bucket.loki_chunks.bucket,
              aws_s3_bucket.loki_ruler.bucket,
              aws_s3_bucket.loki_index.bucket
            ])
          }

          boltdb_shipper = {
            shared_store = "s3"
          }
        }
      }
    })
  ]

  depends_on = [
    module.irsa_loki
  ]
}