data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "nodeapp-terraform-state"
    key    = "nodeapp-terraform-network"
    region = "us-east-1"
  }
}