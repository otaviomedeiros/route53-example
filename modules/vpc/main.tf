variable "cidr_block" {
  type        = string
  description = "CIDR block"
}

variable "availability_zone" {
  type = map
}

data "aws_region" "current" {}

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
  availability_zone = var.availability_zone[data.aws_region.current.name]

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

resource "aws_security_group" "public_ec2_security_group" {
  name        = "ssh"
  description = "Allow SSH and public inbound traffic only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Route 53 example security group"
  }
}

output "security_group_id" {
  value = aws_security_group.public_ec2_security_group.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}