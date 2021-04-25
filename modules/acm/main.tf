variable "domain" {
    type = string
}

variable "sub_domain" {
    type = string
}

variable "main_hosted_zone_id" {
    type = string
}

variable "sub_domain_hosted_zone_id" {
    type = string
}

locals {
  domain_name_wildcard = "*.${var.domain}"
  sub_domain_name_wildcard = "*.${var.sub_domain}"
}

resource "aws_acm_certificate" "cert" {
  domain_name       = local.domain_name_wildcard
  subject_alternative_names = [local.sub_domain_name_wildcard]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm_validation_dns_record" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
      zone_id = dvo.domain_name == local.domain_name_wildcard ? var.main_hosted_zone_id : var.sub_domain_hosted_zone_id
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = each.value.zone_id
}

resource "aws_acm_certificate_validation" "example" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation_dns_record : record.fqdn]
}