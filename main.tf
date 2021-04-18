provider "aws" {
  alias   = "us"
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
  providers = {
    aws = aws.us
  } 

  domain = var.domain
  sub_domain = var.sub_domain
}

module "s3_static_website" {
  source = "./modules/s3-static-website"
  providers = {
    aws = aws.us
  } 

  bucket_name = var.domain
  main_hosted_zone_id = module.route53.main_hosted_zone_id
}

module "vpc_us" {
  source = "./modules/vpc"
  providers = {
    aws = aws.us
  } 

  cidr_block = var.vpc_cidr_block
  availability_zone = var.us_availability_zone
}

module "vpc_br" {
  source = "./modules/vpc"
  providers = {
    aws = aws.brazil
  } 
  
  cidr_block = var.vpc_cidr_block
  availability_zone = var.br_availability_zone
}

module "security_groups_us" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.us
  } 

  vpc_id = module.vpc_us.vpc_id
}

module "security_groups_br" {
  source = "./modules/security_groups"
  providers = {
    aws = aws.brazil
  }

  vpc_id = module.vpc_br.vpc_id
}

module "ec2_us" {
  source = "./modules/ec2"
  providers = {
    aws = aws.us
  } 

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.sub_domain
    geolocation_continent_code = "NA"
  }

  vpc = {
    availability_zone = var.us_availability_zone
    public_subnet_id = module.vpc_us.public_subnet_id
    security_group_id = module.security_groups_us.ssh_security_group_id
  }

  ami = var.us_ami
  ssh_key_pair_name = "Route53LearningKeyPairUS"
}

module "ec2_br" {
  source = "./modules/ec2"
  providers = {
    aws = aws.brazil
  }

  dns = { 
    hosted_zone_id = module.route53.sub_domain_hosted_zone_id
    sub_domain = var.sub_domain
    geolocation_continent_code = "SA"
  }

  vpc = {
    availability_zone = var.br_availability_zone
    public_subnet_id = module.vpc_br.public_subnet_id
    security_group_id = module.security_groups_br.ssh_security_group_id
  }

  ami = var.br_ami
  ssh_key_pair_name = "Route53LearningKeyPairBR"
}