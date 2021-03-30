variable "cidr_block" {
  type        = string
  description = "CIDR block"
}

variable "availability_zone" {
  type = string
  description = "Single availability zone for the VPC"
}

resource "aws_vpc" "main_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "Route 53 example VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = cidrsubnet(var.cidr_block, 4, 1)
  availability_zone = var.availability_zone

  tags = {
    Name = "Route 53 example VPC - Public subnet"
  }
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}