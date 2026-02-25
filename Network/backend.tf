terraform {
  backend "s3" {
    bucket                  = "nodeapp-terraform-state"
    dynamodb_table          = "nodeapp-terraform-state-lock-db"
    key                     = "nodeapp-terraform-network"
    region                  = "us-east-1"
  }
}