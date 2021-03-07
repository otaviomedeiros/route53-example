provider "aws" {
  profile = var.profile
  region  = var.region
}

module "route53" {
    source = "./modules/route53"

    domain = var.domain
}

module "s3_static_website" {
    source = "./modules/s3-static-website"

    bucket_name = var.domain
    main_hosted_zone_id = module.route53.main_hosted_zone_id
}