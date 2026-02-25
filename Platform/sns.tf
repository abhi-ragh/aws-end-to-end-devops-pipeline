resource "aws_sns_topic" "eks_alerts" {
  name = "eks-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.eks_alerts.arn
  protocol  = "email"
  endpoint  = "b.ragh03@gmail.com"
}