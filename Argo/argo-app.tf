resource "kubernetes_manifest" "nodeapp" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "nodeapp"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/abhi-ragh/aws-end-to-end-devops-pipeline.git"
        targetRevision = "main"
        path           = "K8s/nodeapp"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }

      syncPolicy = {
        automated = {
          prune    = false
          selfHeal = true
        }
      }
    }
  }
}

resource "kubernetes_manifest" "alertmanager" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "alertmanager"
      namespace = "argocd"
    }
    spec = {
      project = "default"

      source = {
        repoURL        = "https://github.com/abhi-ragh/aws-end-to-end-devops-pipeline.git"
        targetRevision = "main"
        path           = "K8s/alertmanager"
      }

      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "default"
      }

      syncPolicy = {
        automated = {
          prune    = false
          selfHeal = true
        }
      }
    }
  }
}