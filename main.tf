
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

data "aws_iam_policy_document" "with_mfa" {
  statement {
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "iam:ListUsers",
      "iam:GetAccountPasswordPolicy",
      "iam:ListVirtualMFADevices",
    ]
  }

  statement {
    effect  = "Allow"
    actions = ["iam:ListMFADevices"]
    resources = [
      "arn:aws:iam::*:mfa/*",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      format("arn:aws:iam::%s:mfa/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
    ]
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetUser",
      "iam:GetAccountSummary",
      "iam:DeactivateMFADevice",
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
    ]
    resources = [
      format("arn:aws:iam::%s:mfa/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
    ]

    condition {
      test     = "Bool"
      values   = ["true"]
      variable = "aws:MultiFactorAuthPresent"
    }
  }

  statement {
    effect    = "Deny"
    resources = ["*"]
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
    ]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:MultiFactorAuthPresent"
    }
  }

  dynamic "statement" {
    for_each = var.additional_statements

    content {
      effect    = "Allow"
      actions   = statement.actions
      resources = statement.resources

      condition {
        test     = "Bool"
        values   = ["true"]
        variable = "aws:MultiFactorAuthPresent"
      }
    }
  }
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
