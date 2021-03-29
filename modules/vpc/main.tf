variable "cidr_block" {
  type        = string
  description = "CIDR block"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "Route 53 example VPC"
  }
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}