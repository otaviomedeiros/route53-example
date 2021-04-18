variable "ami" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "sub_domain" {
  type = string
}

variable "availability_zone" {
  type = string
}

variable "public_subnet_id" {
  type = string
}

variable "ssh_key_pair_name" {
  type = string
}

variable "security_group_id" {
  type = string
}

variable "geolocation_continent_code" {
  type = string
}

variable "nginx_file_content" {
  type = string
}

resource "aws_instance" "ec2-instance" {
  ami                         = var.ami
  instance_type               = "t3.micro"
  availability_zone           = var.availability_zone
  associate_public_ip_address = true
  key_name                    = var.ssh_key_pair_name
  vpc_security_group_ids      = [var.security_group_id]
  subnet_id                   = var.public_subnet_id
  user_data                   = templatefile("${path.module}/user_data.tpl", { nginx_file_content = var.nginx_file_content })
}

resource "aws_route53_record" "geo_dns_record" {
  zone_id = var.hosted_zone_id
  name    = "geo.${var.sub_domain}"
  type    = "A"
  ttl     = "60"
  set_identifier = var.geolocation_continent_code
  records = [aws_instance.ec2-instance.public_ip]

  geolocation_routing_policy {
    continent = var.geolocation_continent_code
  }
}

output "ec2_public_ip" {
  value = aws_instance.ec2-instance.public_ip
}
