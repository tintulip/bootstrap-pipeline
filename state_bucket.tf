resource "aws_s3_bucket" "state_bucket" {
  arn           = "arn:aws:s3:::cla-production-state"
  bucket        = "cla-production-state"
  force_destroy = "false"


  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }

      bucket_key_enabled = "false"
    }
  }

  versioning {
    enabled    = "true"
    mfa_delete = "false"
  }
}



