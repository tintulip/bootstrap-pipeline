terraform {
  backend "s3" {
    bucket   = "cla-production-state"
    key      = "pipeline-factory/dali.tfstate"
    region   = "eu-west-2"
  }
}