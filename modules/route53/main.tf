variable "domain" {
  type = string
}

variable "sub_domain" {
  type = string
}

variable "north_america_ec2_public_id" {
  type = string
}

variable "south_america_ec2_public_id" {
  type = string
}

locals {
  geo_location_sub_domain = "geo.${var.sub_domain}"
}

resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_zone" "sub_domain" {
  name = var.sub_domain
}

resource "aws_route53_record" "sub_domain_dns_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.sub_domain
  type    = "NS"
  ttl     = "60"
  
  records = [
    aws_route53_zone.sub_domain.name_servers[0],
    aws_route53_zone.sub_domain.name_servers[1],
    aws_route53_zone.sub_domain.name_servers[2],
    aws_route53_zone.sub_domain.name_servers[3],
  ]
}

resource "aws_route53_record" "geo_north_america" {
  zone_id = aws_route53_zone.sub_domain.zone_id
  name    = local.geo_location_sub_domain
  type    = "A"
  ttl     = "60"
  set_identifier = "north-america"
  records = [var.north_america_ec2_public_id]

  geolocation_routing_policy {
    continent = "NA"
  }
}

resource "aws_route53_record" "geo_south_america" {
  zone_id = aws_route53_zone.sub_domain.zone_id
  name    = local.geo_location_sub_domain
  type    = "A"
  ttl     = "60"
  set_identifier = "south-america"
  records = [var.south_america_ec2_public_id]

  geolocation_routing_policy {
    continent = "SA"
  }
}

output "main_hosted_zone_id" {
    value = aws_route53_zone.main.zone_id
}