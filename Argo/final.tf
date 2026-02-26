resource "aws_s3_object" "infra_complete_file" {
  bucket       = "s3-for-capstone"
  key          = "infra-status.txt"
  content      = "Infra complete"
  content_type = "text/plain"

  depends_on = [
    kubernetes_manifest.nodeapp,
    kubernetes_manifest.alertmanager,
  ]
}