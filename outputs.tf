output "aws_s3_bucket_state_bucket_id" {
  value = aws_s3_bucket.state_bucket.id
}
output "aws_iam_role_policy_attachment_website_infra_AmazonS3FullAccess_id" {
  value = aws_iam_role_policy_attachment.website_infra_AmazonS3FullAccess.id
}

output "aws_iam_role_website_infra_id" {
  value = aws_iam_role.website_infra.id
}

output "aws_iam_user_policy_website_infra_id" {
  value = aws_iam_user_policy.website_infra.id
}

output "aws_iam_user_website_infra_id" {
  value = aws_iam_user.website_infra.id
}

