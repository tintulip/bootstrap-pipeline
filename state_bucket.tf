module "kms_bucket" {
  source      = "./modules/kms-state-bucket"
  bucket_name = "production"
}