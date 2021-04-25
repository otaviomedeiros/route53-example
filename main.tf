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

module "acm" {
  source = "./modules/acm"
  providers = {
    aws = aws.north_america
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

module "vpc_us" {
  source = "./modules/vpc"
  providers = {
    aws = aws.north_america
  } 

  cidr_block = var.vpc_cidr_block
  availability_zone = var.availability_zone
}

module "vpc_br" {
  source = "./modules/vpc"
  providers = {
    aws = aws.south_america
  } 
  
  cidr_block = var.vpc_cidr_block
  availability_zone = var.availability_zone
}

module "security_groups_us" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.north_america
  } 

  vpc_id = module.vpc_us.vpc_id
}

module "security_groups_br" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.south_america
  }

  vpc_id = module.vpc_br.vpc_id
}

module "ec2_us" {
  source = "./modules/ec2"
  providers = {
    aws = aws.north_america
  } 

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.hosted_zone_sub_domain
    geolocation_continent_code = "NA"
  }

  public_subnet_id = module.vpc_us.public_subnet_id
  security_group_id = module.security_groups_us.ssh_security_group_id
  availability_zone = var.availability_zone
  ami = var.ami
  ssh_key_pair_name = var.ssh_key_pair_name
}

module "ec2_br" {
  source = "./modules/ec2"
  providers = {
    aws = aws.south_america
  }

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.hosted_zone_sub_domain
    geolocation_continent_code = "SA"
  }

  public_subnet_id = module.vpc_br.public_subnet_id
  security_group_id = module.security_groups_br.ssh_security_group_id
  availability_zone = var.availability_zone
  ami = var.ami
  ssh_key_pair_name = var.ssh_key_pair_name
}