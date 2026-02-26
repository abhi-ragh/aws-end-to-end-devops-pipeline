resource "helm_release" "promtail" {
  name             = "promtail"
  repository       = "https://grafana.github.io/helm-charts"
  chart            = "promtail"
  namespace        = "loki"
  create_namespace = false
    depends_on = [
    helm_release.loki
  ]

  wait    = true
  timeout = 600

  values = [
    yamlencode({

      daemonset = {
        enabled = true
      }

      serviceAccount = {
        create = true
        name   = "promtail-sa"
      }

      config = {
        logLevel = "info"

        clients = [
          {
            url = "http://loki.loki.svc.cluster.local:3100/loki/api/v1/push"
          }
        ]

        positions = {
          filename = "/run/promtail/positions.yaml"
        }

        scrape_configs = [
          {
            job_name = "kubernetes-pods"

            pipeline_stages = [
              {
                cri = {}
              }
            ]

            kubernetes_sd_configs = [
              {
                role = "pod"
              }
            ]

            relabel_configs = [
              {
                source_labels = ["__meta_kubernetes_namespace"]
                action        = "replace"
                target_label  = "namespace"
              },
              {
                source_labels = ["__meta_kubernetes_pod_name"]
                action        = "replace"
                target_label  = "pod"
              },
              {
                source_labels = ["__meta_kubernetes_pod_container_name"]
                action        = "replace"
                target_label  = "container"
              }
            ]
          }
        ]
      }

      tolerations = [
        {
          operator = "Exists"
        }
      ]

    })
  ]
}