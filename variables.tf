variable "profile" {
  type        = string
  description = "Profile to access aws account"
  default = "personal"
}

variable "ami" {
  type = map
  default = {
    "us-east-1" = "ami-0be2609ba883822ec"
    "sa-east-1" = "ami-0717ee8f1c64a9f3c"
  }
}

variable "ssh_key_pair_name" {
  type = map
  default = {
    "us-east-1" = "Route53LearningKeyPairUS"
    "sa-east-1" = "Route53LearningKeyPairBR"
  }
}

variable "availability_zone" {
  type = map
  default = {
    "us-east-1" = "us-east-1a"
    "sa-east-1" = "sa-east-1a"
  }
}

variable "hosted_zone_domain" {
  type = string
}

variable "hosted_zone_sub_domain" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
  default = "192.168.0.0/16"
}