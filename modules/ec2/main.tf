variable "ami" {
  type = map
}

variable "dns" {
  type = object({
    hosted_zone_id = string
    sub_domain = string
    geolocation_continent_code = string
  })
}

variable "public_subnet_id" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "availability_zone" {
  type = map
}

variable "ssh_key_pair_name" {
  type = map
}

data "aws_region" "current" {}

resource "aws_instance" "ec2-instance" {
  ami                         = var.ami[data.aws_region.current.name]
  instance_type               = "t3.micro"
  availability_zone           = var.availability_zone[data.aws_region.current.name]
  associate_public_ip_address = true
  key_name                    = var.ssh_key_pair_name[data.aws_region.current.name]
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.public_subnet_id
  user_data                   = templatefile("${path.module}/user_data.tpl", { nginx_file_content = var.dns.geolocation_continent_code })
}

resource "aws_route53_record" "geo_dns_record" {
  zone_id = var.dns.hosted_zone_id
  name    = "geo.${var.dns.sub_domain}"
  type    = "A"
  ttl     = "60"
  set_identifier = var.dns.geolocation_continent_code
  records = [aws_instance.ec2-instance.public_ip]

  geolocation_routing_policy {
    continent = var.dns.geolocation_continent_code
  }
}

output "ec2_public_ip" {
  value = aws_instance.ec2-instance.public_ip
}
