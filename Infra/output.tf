output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
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

output "rds_host" {
  value = module.db.db_instance_address
  sensitive = true
}

output "rds_db_name" {
  value = module.db.db_instance_name
  sensitive = true
}

output "rds_username" {
  value = module.db.db_instance_username
  sensitive = true
}

output "rds_master_secret_arn" {
  value = module.db.db_instance_master_user_secret_arn
  sensitive = true
}