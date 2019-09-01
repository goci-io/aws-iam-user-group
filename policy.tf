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
      format("arn:aws:iam::%s:mfa/*", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
    ]
  }

  statement {
    effect = "Allow"
    resources = [
      format("arn:aws:iam::%s:mfa/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
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
      format("arn:aws:iam::%s:user/%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
    ]

    condition {
      values   = ["true"]
      test     = "BoolIfExists"
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
      values   = ["false"]
      test     = "BoolIfExists"
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
        values   = ["true"]
        test     = "BoolIfExists"
        variable = "aws:MultiFactorAuthPresent"
      }
    }
  }
}