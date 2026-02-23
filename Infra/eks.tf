module "eks" {
    source  = "terraform-aws-modules/eks/aws"
    version = "~> 21.0"
    
    name       = "terraform-eks"
    kubernetes_version = 1.31 
    
    endpoint_public_access = true
    endpoint_private_access = true
    
    enable_cluster_creator_admin_permissions = true

    addons = {
          aws-ebs-csi-driver = {
    service_account_role_arn = module.irsa-ebs-csi.iam_role_arn
        }
        coredns                = {}
        eks-pod-identity-agent = {
        before_compute = true
        }
        kube-proxy             = {}
        vpc-cni                = {
        before_compute = true
        }
    }
    
    eks_managed_node_groups = {
        eks-nodes = {
            instance_types = ["c7i-flex.large"]
            ami_type       = "AL2_x86_64"
            min_size       = 2
            max_size       = 5
            desired_size   = 3
        }
    }
    
    vpc_id     = module.vpc.vpc_id
    subnet_ids = module.vpc.private_subnets
    
    tags = {
        Environment = "dev"
        Terraform   = "true"
    }
}

# EBS CSI Driver IAM Role
data "aws_iam_policy" "ebs_csi_policy" {
    arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
    source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
    version = "5.39.0"
    
    create_role                   = true
    role_name                     = "AmazonEKSTFEBSCSIRole-${module.eks.cluster_name}"
    provider_url                  = module.eks.oidc_provider
    role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
    oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}