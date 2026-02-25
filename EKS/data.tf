data "terraform_remote_state" "infra" {
  backend = "s3"

  config = {
    bucket = "nodeapp-terraform-state"
    key    = "nodeapp-terraform-infra"
    region = "us-east-1"
  }
}