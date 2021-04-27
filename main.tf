provider "aws" {
  alias   = "north_america"
  profile = var.profile
  region  = "us-east-1"
}

provider "aws" {
  alias   = "south_america"
  profile = var.profile
  region  = "sa-east-1"
}

module "route53" {
  source = "./modules/route53"
  providers = {
    aws = aws.north_america
  } 

  domain = var.hosted_zone_domain
  sub_domain = var.hosted_zone_sub_domain
}

module "acm_north_america" {
  source = "./modules/acm"
  providers = {
    aws = aws.north_america
  } 

  domain = var.hosted_zone_domain
  sub_domain = var.hosted_zone_sub_domain
  main_hosted_zone_id = module.route53.main_hosted_zone_id
  sub_domain_hosted_zone_id = module.route53.sub_domain_hosted_zone_id
}

module "acm_south_america" {
  source = "./modules/acm"
  providers = {
    aws = aws.south_america
  } 

  domain = var.hosted_zone_domain
  sub_domain = var.hosted_zone_sub_domain
  main_hosted_zone_id = module.route53.main_hosted_zone_id
  sub_domain_hosted_zone_id = module.route53.sub_domain_hosted_zone_id
}

module "s3_static_website" {
  source = "./modules/s3-static-website"
  providers = {
    aws = aws.north_america
  } 

  bucket_name = var.hosted_zone_domain
  main_hosted_zone_id = module.route53.main_hosted_zone_id
}

module "vpc_north_america" {
  source = "./modules/vpc"
  providers = {
    aws = aws.north_america
  } 

  cidr_block = var.vpc_cidr_block
  availability_zone = var.availability_zone
}

module "vpc_south_america" {
  source = "./modules/vpc"
  providers = {
    aws = aws.south_america
  } 
  
  cidr_block = var.vpc_cidr_block
  availability_zone = var.availability_zone
}

module "ec2_north_america" {
  source = "./modules/ec2"
  providers = {
    aws = aws.north_america
  } 

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.hosted_zone_sub_domain
    geolocation_continent_code = "NA"
  }

  public_subnet_id = module.vpc_north_america.public_subnet_id
  security_group_id = module.vpc_north_america.security_group_id
  availability_zone = var.availability_zone
  ami = var.ami
  ssh_key_pair_name = var.ssh_key_pair_name
}

module "ec2_south_america" {
  source = "./modules/ec2"
  providers = {
    aws = aws.south_america
  }

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.hosted_zone_sub_domain
    geolocation_continent_code = "SA"
  }

  public_subnet_id = module.vpc_south_america.public_subnet_id
  security_group_id = module.vpc_south_america.security_group_id
  availability_zone = var.availability_zone
  ami = var.ami
  ssh_key_pair_name = var.ssh_key_pair_name
}

module "api_gateway_north_america" {
  source = "./modules/api_gateway"
  providers = {
    aws = aws.north_america
  } 

  sub_domain = var.hosted_zone_sub_domain
  certificate_arn = module.acm_north_america.certificate_arn
  zone_id = module.route53.sub_domain_hosted_zone_id
}

module "api_gateway_south_america" {
  source = "./modules/api_gateway"
  providers = {
    aws = aws.south_america
  } 

  sub_domain = var.hosted_zone_sub_domain
  certificate_arn = module.acm_south_america.certificate_arn
  zone_id = module.route53.sub_domain_hosted_zone_id
}