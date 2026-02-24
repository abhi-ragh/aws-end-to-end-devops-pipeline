resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  create_namespace = true
  depends_on = [helm_release.aws_load_balancer_controller]

  values = [
    yamlencode({
      server = {
        ingress = {
          enabled = true
          ingressClassName = "alb"
          annotations = {
            "alb.ingress.kubernetes.io/scheme"      = "internet-facing"
            "alb.ingress.kubernetes.io/target-type" = "ip"
          }
          hosts = [
            {
              host  = "argocd.example.com"
              paths = ["/"]
            }
          ]
        }
      }
    })
  ]
}