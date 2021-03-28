locals {
  website_domain = var.bucket_name
  website_www_subdomain = "www.${var.bucket_name}"
}

data "aws_iam_policy_document" "website_domain_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.website_domain}/*"]
    effect    = "Allow"
    sid       = "PublicReadGetObject"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

data "aws_iam_policy_document" "website_www_subdomain_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${local.website_www_subdomain}/*"]
    effect    = "Allow"
    sid       = "PublicReadGetObject"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "website_domain_bucket" {
  bucket        = local.website_domain
  acl           = "public-read"
  policy        = data.aws_iam_policy_document.website_domain_s3_policy.json
  force_destroy = true

  website {
    index_document = "index.html"
  }
}

resource "aws_s3_bucket" "website_www_subdomain_bucket" {
  bucket        = local.website_www_subdomain
  acl           = "public-read"
  policy        = data.aws_iam_policy_document.website_www_subdomain_s3_policy.json
  force_destroy = true

  website {
    redirect_all_requests_to = aws_s3_bucket.website_domain_bucket.website_endpoint
  }
}

resource "aws_route53_record" "website_domain" {
  zone_id = var.main_hosted_zone_id
  name    = local.website_domain
  type    = "A"
  
  alias {
    name = aws_s3_bucket.website_domain_bucket.website_domain
    zone_id = aws_s3_bucket.website_domain_bucket.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "website_www_subdomain" {
  zone_id = var.main_hosted_zone_id
  name    = local.website_www_subdomain
  type    = "A"
  
  alias {
    name = aws_s3_bucket.website_www_subdomain_bucket.website_domain
    zone_id = aws_s3_bucket.website_www_subdomain_bucket.hosted_zone_id
    evaluate_target_health = true
  }
}






