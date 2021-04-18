variable "ami" {
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

output "ec2_public_ip" {
  value = aws_instance.ec2-instance.public_ip
}
