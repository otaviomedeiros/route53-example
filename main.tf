provider "aws" {
  profile = var.profile
  region  = var.us_region
}

provider "aws" {
  alias   = "brazil"
  profile = var.profile
  region  = var.br_region
}

module "route53" {
    source = "./modules/route53"

    domain = var.domain
    sub_domain = var.sub_domain
}

module "s3_static_website" {
    source = "./modules/s3-static-website"

    bucket_name = var.domain
    main_hosted_zone_id = module.route53.main_hosted_zone_id
}

module "vpc_us" {
  source = "./modules/vpc"

  cidr_block = var.vpc_cidr_block
}

module "vpc_br" {
  source = "./modules/vpc"
  providers = {
    aws = aws.brazil
  }

  cidr_block = var.vpc_cidr_block
}

module "security_groups_us" {
  source = "./modules/security_groups"

  vpc_id = module.vpc_us.vpc_id
}

module "security_groups_br" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.brazil
  }

  vpc_id = module.vpc_br.vpc_id
}