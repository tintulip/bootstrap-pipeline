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

resource "aws_iam_policy" "site_publisher_policy" {
  policy = data.aws_iam_policy_document.site_publisher_policy.json
  name   = "site_publisher_policy"
}





data "aws_iam_policy_document" "site_publisher_policy" {

  statement {
    actions = [
      "iam:CreateUser",
      "iam:DeleteUser",
      "iam:GetUser",
      "iam:ListUserTags",
      "iam:TagUser",
      "iam:UntagUser",
      "iam:CreateAccessKey",
      "iam:GetAccessKeyLastUsed",
      "iam:DeleteAccessKey",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:ListGroupsForUser",
      "iam:UpdateUser"

    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:user/*"
    ]

  }

  statement {
    actions = [
      "iam:AttachGroupPolicy",
      "iam:CreateGroup",
      "iam:DeleteGroup",
      "iam:DeleteGroupPolicy",
      "iam:DetachGroupPolicy",
      "iam:GetGroup",
      "iam:GetGroupPolicy",
      "iam:ListAttachedGroupPolicies",
      "iam:ListGroupPolicies",
      "iam:PutGroupPolicy",
      "iam:AddUserToGroup",
      "iam:RemoveUserFromGroup",
      "iam:UpdateGroup"
    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:group/${local.site_publisher_role_name}"
    ]
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
      "iam:UpdateRoleDescription"

    ]

    resources = [
      "arn:aws:iam::${local.aws_account_id}:role/${local.site_publisher_role_name}",
      "arn:aws:iam::${local.aws_account_id}:role/${local.log_replication_role_name}"


    ]

  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:DeletePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
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
      "Resource": "arn:aws:iam::073232250817:role/website-infra",
      "Sid": "VisualEditor0"
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
        "AWS": "arn:aws:iam::073232250817:root"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  description          = "for usage by the tf stack and pipeline creating the website s infra"
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonS3FullAccess", aws_iam_policy.site_publisher_policy.arn]
  max_session_duration = "3600"
  name                 = "website-infra"
  path                 = "/"
}
