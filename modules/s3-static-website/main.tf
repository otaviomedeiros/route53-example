data "aws_iam_policy_document" "website_s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]
    effect    = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket" "static_website" {
  bucket        = var.bucket_name
  acl           = "public-read"
  policy        = data.aws_iam_policy_document.website_s3_policy.json
  force_destroy = true

  website {
    index_document = "index.html"
  }
}
