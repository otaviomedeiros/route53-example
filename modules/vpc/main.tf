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
    Name = "Route 53 example - VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Route 53 example - Internet Gateway"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Route 53 example - Public route table"
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

resource "aws_route_table_association" "public_rt_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

resource "aws_main_route_table_association" "main_rt_association" {
  vpc_id         = aws_vpc.main_vpc.id
  route_table_id = aws_route_table.main_route_table.id
}

output "vpc_id" {
  value = aws_vpc.main_vpc.id
}