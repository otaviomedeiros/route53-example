variable "vpc_id" {
  type = string
}

resource "aws_security_group" "ssh_security_group" {
  name        = "ssh"
  description = "Allow SSH inbound traffic only"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
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