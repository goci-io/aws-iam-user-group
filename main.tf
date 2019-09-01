
data "aws_caller_identity" "current" {}

module "base_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  namespace  = var.namespace
  stage      = var.stage
  attributes = var.attributes
  tags       = var.tags
  delimiter  = "-"
}

module "users_group_label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.15.0"
  context    = module.base_label.context
  attributes = ["users", "with", "mfa"]
}

resource "aws_iam_group" "with_mfa" {
  name = module.users_group_label.id
  path = "/users/"
}

resource "aws_iam_policy" "users_with_mfa" {
  name   = module.users_group_label.id
  policy = data.aws_iam_policy_document.with_mfa.json
  path   = "/users/"
}

resource "aws_iam_policy_attachment" "users_group" {
  name       = module.users_group_label.id
  groups     = [aws_iam_group.with_mfa.name]
  policy_arn = aws_iam_policy.users_with_mfa.arn
}
