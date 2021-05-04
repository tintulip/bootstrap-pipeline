resource "aws_iam_user" "website_infra" {
  force_destroy = "false"
  name          = "website-infra"
  path          = "/"
}

resource "aws_iam_role_policy_attachment" "website_infra_AmazonS3FullAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = "website-infra"
}

resource "aws_iam_user_policy" "website_infra" {
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
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AmazonS3FullAccess"]
  max_session_duration = "3600"
  name                 = "website-infra"
  path                 = "/"
}

