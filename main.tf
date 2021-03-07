provider "aws" {
  profile = var.profile
  region  = var.region
}

module "route53" {
    source = "./modules/route53"
}

module "s3-static-website" {
    source = "./modules/s3-static-website"

    bucket_name = "otaviomedeiros.com"
}