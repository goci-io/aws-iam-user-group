# aws-iam-user-group

#### Maintained by [@goci-io/prp-terraform](https://github.com/orgs/goci-io/teams/prp-terraform)

![terraform](https://github.com/goci-io/aws-iam-user-group/workflows/terraform/badge.svg?branch=master)

This module creates a group for humans interacting with AWS. It only allows users without MFA enabled to change their MFA device and denies all access until MFA is enabled.
Once a user is logged in with MFA enabled the user will be able to perform actions defined by the `additional_statements` and they will be granted access to change their own security credentials and read policies attached to them via groups, roles or directly.

To create users and attach created groups to them you can use the [aws-iam-user-keybase](https://github.com/goci-io/aws-iam-user-keybase) or the [terraform-aws-iam-user](https://github.com/cloudposse/terraform-aws-iam-user) (without keybase requirement) module.

## Usage

```hcl
module "group" {
  source                = "git::https://github.com/goci-io/aws-iam-user-group.git?ref=tags/<latest-version>"
  namespace             = "goci"
  stage                 = "staging"
  additional_statements = [
    {
      actions   = ["sts:AssumeRole"]
      resources = ["arn:aws:iam::*:role/goci-staging-account-manager"]
    }
  ]
}
```

