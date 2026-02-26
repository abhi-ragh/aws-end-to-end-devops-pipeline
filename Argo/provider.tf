provider "aws" {
  region = "us-east-1"
}

data "aws_eks_cluster" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = data.terraform_remote_state.infra.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.cluster_endpoint
  cluster_ca_certificate = base64decode(
    data.terraform_remote_state.infra.outputs.cluster_certificate_authority_data
  )
  token = data.aws_eks_cluster_auth.this.token
}