variable "certificate_arn" {
    type = string
}

variable "sub_domain" {
    type = string
}

variable "zone_id" {
    type = string
}

resource "aws_api_gateway_rest_api" "api_gateway_service" {
  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "Service"
      version = "1.0"
    }
    paths = {
      "/todos" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://jsonplaceholder.typicode.com/todos"
          }
        }
      }
    }
  })

  name = "Service"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "api_gateway_service_deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_service.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api_gateway_service.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.api_gateway_service_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway_service.id
  stage_name    = "prod"
}

resource "aws_api_gateway_domain_name" "custom_domain_name" {
  regional_certificate_arn = var.certificate_arn
  domain_name     = "api.${var.sub_domain}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  api_id      = aws_api_gateway_rest_api.api_gateway_service.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  domain_name = aws_api_gateway_domain_name.custom_domain_name.domain_name
}

resource "aws_route53_record" "service_dns_record" {
  name    = aws_api_gateway_domain_name.custom_domain_name.domain_name
  type    = "A"
  zone_id = var.zone_id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.custom_domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.custom_domain_name.regional_zone_id
  }
}