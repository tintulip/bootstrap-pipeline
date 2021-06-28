terraform {
  backend "s3" {
    bucket = "tfstate-073232250817-production"
    key    = "pipeline-factory/dali.tfstate"
    region = "eu-west-2"
  }
}

locals {
  aws_account_id            = "073232250817"
  site_publisher_role_name  = "site-publisher"
  log_replication_role_name = "log-replication"
}