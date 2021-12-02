module "pipeline_bucket" {
  source   = "../pipeline_bucket"
  pipeline = local.pipeline
}
