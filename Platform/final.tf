resource "aws_s3_object" "infra_complete_file" {
  bucket       = "s3-for-capstone"
  key          = "infra-status.txt"
  content      = "Infra complete"
  content_type = "text/plain"

  depends_on = [
    helm_release.argocd,
    helm_release.argo_rollouts,
    helm_release.loki,
    helm_release.promtail,
    helm_release.kube_prometheus_stack,
    kubernetes_manifest.nodeapp,
    kubernetes_manifest.alertmanager,
    module.alertmanager_irsa,
    aws_sns_topic.eks_alerts,
    aws_sns_topic_subscription.email_subscription
  ]
}