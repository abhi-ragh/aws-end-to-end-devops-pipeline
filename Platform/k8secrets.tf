data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.terraform_remote_state.infra.outputs.rds_master_secret_arn
}

locals {
  db_secret = jsondecode(
    data.aws_secretsmanager_secret_version.db_password.secret_string
  )
}

resource "kubernetes_secret" "backend_env" {
  metadata {
    name      = "backend-env"
    namespace = "default"
  }

  data = {
    DB_HOST     = data.terraform_remote_state.infra.outputs.rds_endpoint
    DB_NAME     = data.terraform_remote_state.infra.outputs.rds_db_name
    DB_USER     = data.terraform_remote_state.infra.outputs.rds_username
    DB_PASSWORD = local.db_secret.password
    DB_PORT     = "3306"

    JWT_SECRET        = "jwt_secret"
    PAYPAL_CLIENT_ID  = "paypal_secret"
  }

  type = "Opaque"
}