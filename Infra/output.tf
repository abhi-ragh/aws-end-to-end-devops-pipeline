output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks.cluster_certificate_authority_data
}

output "cluster_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}

output "cluster_oidc_provider" {
  value = module.eks.oidc_provider
}

output "loki_irsa_role_arn" {
  value = module.irsa_loki.iam_role_arn
}

output "loki_chunks_bucket" {
  value = aws_s3_bucket.loki_chunks.bucket
}

output "loki_ruler_bucket" {
  value = aws_s3_bucket.loki_ruler.bucket
}

output "loki_index_bucket" {
  value = aws_s3_bucket.loki_index.bucket
}