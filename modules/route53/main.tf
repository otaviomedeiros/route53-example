variable "domain" {
  type = string
}

variable "sub_domain" {
  type = string
}

resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "domain_ns_record" {
  allow_overwrite = true
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain
  type    = "NS"
  ttl     = "60"
  
  records = aws_route53_zone.main.name_servers
}

resource "aws_route53_zone" "sub_domain" {
  name = var.sub_domain
}

resource "aws_route53_record" "sub_domain_ns_record" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.sub_domain
  type    = "NS"
  ttl     = "60"
  
  records = aws_route53_zone.sub_domain.name_servers
}

output "main_hosted_zone_id" {
    value = aws_route53_zone.main.zone_id
}

output "sub_domain_hosted_zone_id" {
    value = aws_route53_zone.sub_domain.zone_id
}