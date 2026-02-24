resource "aws_s3_bucket" "loki_chunks" {
  bucket = "dev-loki-chunks"
}

resource "aws_s3_bucket" "loki_ruler" {
  bucket = "dev-loki-ruler"
}

resource "aws_s3_bucket" "loki_index" {
  bucket = "dev-loki-index"
}

resource "aws_s3_bucket_public_access_block" "chunks" {
  bucket = aws_s3_bucket.loki_chunks.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "ruler" {
  bucket = aws_s3_bucket.loki_ruler.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "index" {
  bucket = aws_s3_bucket.loki_index.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "loki_s3_policy" {
  name = "LokiS3AccessPolicy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${aws_s3_bucket.loki_chunks.arn}/*",
          "${aws_s3_bucket.loki_ruler.arn}/*",
          "${aws_s3_bucket.loki_index.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.loki_chunks.arn,
          aws_s3_bucket.loki_ruler.arn,
          aws_s3_bucket.loki_index.arn
        ]
      }
    ]
  })
}

module "irsa_loki" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role  = true
  role_name    = "LokiIRSA-${module.eks.cluster_name}"

  provider_url = module.eks.oidc_provider

  role_policy_arns = [
    aws_iam_policy.loki_s3_policy.arn
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:loki:loki-sa"
  ]
}

output "loki_irsa_role_arn" {
  value = module.irsa_loki.iam_role_arn
}