variable "profile" {
  type        = string
  description = "Profile to access aws account"
}

variable "us_region" {
  type = string
}

variable "br_region" {
  type = string
}

variable "domain" {
  type = string
}

variable "sub_domain" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}