provider "aws" {
  profile = var.profile
  region  = var.region
}

module "route53" {
    source = "./modules/route53"
}