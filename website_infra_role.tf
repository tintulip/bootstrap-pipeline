locals {
  log_archive_aws_account_id = "689141309029"
}

resource "aws_iam_user" "website_infra" {
  force_destroy = "false"
  name          = "website-infra"
  path          = "/"
}

resource "aws_iam_role_policy_attachment" "website_infra_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "website-infra"
}

resource "aws_iam_role_policy_attachment" "website_infra_iam_policy" {
  policy_arn = aws_iam_policy.site_publisher_policy.arn
  role       = "website-infra"
}

resource "aws_iam_role_policy_attachment" "state_bucket" {
  policy_arn = aws_iam_policy.state_bucket_access.arn
  role       = "website-infra"
}

resource "aws_iam_policy" "state_bucket_access" {
  policy = module.kms_bucket.policy_document
  name   = "prod_state_bucket_policy"
}

resource "aws_iam_policy" "site_publisher_policy" {
  policy = data.aws_iam_policy_document.site_publisher_policy.json
  name   = "site_publisher_policy"
}

resource "aws_iam_policy" "site_logs_policy" {
  policy = data.aws_iam_policy_document.site_logs_policy.json
  name   = "site_logs_policy"
}

resource "aws_iam_role_policy_attachment" "site_logs_iam_policy" {
  policy_arn = aws_iam_policy.site_logs_policy.arn
  role       = "website-infra"
}

data "aws_iam_policy_document" "site_logs_policy" {
  statement {
    actions = [
      "s3:GetReplicationConfiguration",
      "s3:PutReplicationConfiguration",
      "s3:PutBucketPolicy",
      "s3:List*",
      "s3:GetBucketLocation",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [
      "arn:aws:s3:::cla-website-logs"
    ]
  }

  statement {
    actions = [
      "kms:DescribeKey"
    ]

    resources = [
      "arn:aws:kms:eu-west-2:${local.log_archive_aws_account_id}:alias/s3/log-archive",
      "arn:aws:kms:eu-west-2:${local.log_archive_aws_account_id}:key/*",
      "arn:aws:kms:eu-west-2:${local.aws_account_id}:key/*"
    ]

  }
}

data "aws_iam_policy_document" "site_publisher_policy" {

  statement {
    actions = [
      "iam:GetUser",
      "iam:AttachUserPolicy",
      "iam:DetachUserPolicy",
      "iam:ListAttachedUserPolicies",
      "iam:ListAccessKeys"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "aws:Resource"
      values   = [aws_iam_user.website_infra.arn]
    }
  }

  statement {
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:ListUserTags",
      "iam:TagUser",
      "iam:UntagUser",
      "iam:CreateAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:DeleteAccessKey",
      "iam:UpdateAccessKey",
      "iam:ListGroupsForUser",
      "iam:DeleteUserPolicy",
      "iam:PutUserPolicy",
      "iam:ListUserPolicies",
      "iam:UpdateUser"
    ]
    resources = [
      "arn:aws:iam::${local.aws_account_id}:user/${local.site_publisher_role_name}"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "aws:Resource"
      values   = [aws_iam_user.website_infra.arn]
    }
  }

  statement {
    actions = [
      "iam:CreateRole",
      "iam:AttachRolePolicy",
      "iam:DeleteRole",
      "iam:DeleteRolePolicy",
      "iam:DetachRolePolicy",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",
      "iam:PutRolePolicy",
      "iam:PutRolePermissionsBoundary",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",
      "iam:UpdateRole",
      "iam:UpdateRoleDescription",
      "iam:ListInstanceProfilesForRole",
      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:role/${local.site_publisher_role_name}",
      "arn:aws:iam::${local.aws_account_id}:role/${local.log_replication_role_name}"
    ]

  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:CreatePolicyVersion",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:ListPolicyVersions",
      "iam:TagPolicy",
      "iam:DeletePolicyVersion"
    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:policy/${local.site_publisher_role_name}",
      "arn:aws:iam::${local.aws_account_id}:policy/${local.log_replication_role_name}"
    ]

  }

  statement {
    actions = [
      "iam:ListUsers",
      "iam:ListGroups",
      "iam:ListPolicies",
      "iam:ListRoles"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "cloudfront:CreateDistribution",
      "cloudfront:CreateInvalidation",
      "cloudfront:CreateCloudFrontOriginAccessIdentity",
      "cloudfront:TagResource",
      "cloudfront:Get*",
      "cloudfront:List*",
      "cloudfront:Update*"
    ]

    resources = [
      "*"
    ]
  }

}

resource "aws_iam_user_policy" "website_infra" {
  #checkov:skip=CKV_AWS_40: Do not want to attach IAM policy to group, single user use case
  name = "website-infra-assume-role"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Resource": "arn:aws:iam::${local.aws_account_id}:role/website-infra"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  user = "website-infra"
}

resource "aws_iam_role" "website_infra" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Condition": {},
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.aws_account_id}:user/website-infra"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  description = "for usage by the tf stack and pipeline creating the website s infra"
  name        = "website-infra"
  path        = "/"
}
