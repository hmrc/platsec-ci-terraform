locals {
  bucket_name = "ci-${substr(local.pipeline_name, 0, 32)}"

}

module "codepipeline_bucket" {
  source         = "hmrc/s3-bucket-core/aws"
  version        = "0.1.1"
  bucket_name    = local.bucket_name
  force_destroy  = true
  kms_key_policy = null

  data_expiry      = "90-days"
  data_sensitivity = "low"

  log_bucket_id = var.access_log_bucket_id
  tags = {
    Pipeline = local.pipeline_name
  }
}
