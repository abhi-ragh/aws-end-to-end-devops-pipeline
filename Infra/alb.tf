############################
# ALB Controller IAM Policy
############################

resource "aws_iam_policy" "alb_controller" {
  name   = "AWSLoadBalancerControllerPolicy"
  policy = file("${path.module}/alb_iam_policy.json")
}

#################################
# ALB Controller IRSA IAM Role
#################################

module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "5.39.0"

  create_role = true
  role_name   = "eks-alb-controller-role"

  provider_url = module.eks.oidc_provider

  role_policy_arns = [
    aws_iam_policy.alb_controller.arn
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:kube-system:aws-load-balancer-controller"
  ]
}

#################################
# Helm Install ALB Controller
#################################

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  wait    = true
  timeout = 600

  values = [
    yamlencode({
      clusterName = module.eks.cluster_name

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
        annotations = {
          "eks.amazonaws.com/role-arn" = module.alb_irsa.iam_role_arn
        }
      }
    })
  ]
}