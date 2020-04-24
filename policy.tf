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
    resources = distinct([
      format("arn:aws:iam::%s:mfa/*", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
    ])
  }

  statement {
    effect = "Allow"
    resources = distinct([
      format("arn:aws:iam::%s:mfa/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
    ])
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:GetUser",
      "iam:ListGroupsForUser",
      "iam:ListAttachedUserPolicies",
      "iam:ListUserPolicies",
      "iam:GetAccountSummary",
      "iam:DeactivateMFADevice",
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:DeleteAccessKey",
      "iam:DeleteVirtualMFADevice",
      "iam:GetAccessKeyLastUsed",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:DeleteSSHPublicKey",
      "iam:GetSSHPublicKey",
      "iam:ListSSHPublicKeys",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey",
    ]
    resources = distinct([
      format("arn:aws:iam::%s:mfa/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user/&{aws:username}", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:user%s/&{aws:username}", data.aws_caller_identity.current.account_id, var.users_path),
    ])

    condition {
      values   = ["true"]
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "iam:ListGroups",
      "iam:ListRoles",
      "iam:ListPolicies",
      "iam:ListRolePolicies",
      "iam:ListGroupPolicies",
      "iam:GetPolicyVersion",
      "iam:ListAttachedRolePolicies",
      "iam:ListAttachedGroupPolicies",
    ]
    resources = [
      format("arn:aws:iam::%s:group/", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:group/*", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:policy/", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:policy/*", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:role/", data.aws_caller_identity.current.account_id),
      format("arn:aws:iam::%s:role/*", data.aws_caller_identity.current.account_id),
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
      "iam:GetAccountPasswordPolicy",
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
