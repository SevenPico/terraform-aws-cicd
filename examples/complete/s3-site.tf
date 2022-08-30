module "site_bucket" {
  source  = "app.terraform.io/SevenPico/s3-bucket/aws"
  version = "3.0.0"
  context = module.context.self

  for_each   = toset(["foo", "bar"])
  name       = each.key
  attributes = ["site-origin"]
}
