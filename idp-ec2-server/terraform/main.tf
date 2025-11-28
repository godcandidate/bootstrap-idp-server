# Data source to get the default VPC
data "aws_vpc" "default" {
  default = true
}

# Data source to get default subnets in the VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Ubuntu 24.04 Noble AMI (Free tier Eligible)
locals {
  ubuntu_ami = "ami-0a716d3f3b16d290c"
}

# Security Group for EC2 instance
resource "aws_security_group" "server-sg" {
  name_prefix = "${var.server_name}-sg"
  description = "Security group for Ubuntu EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access for n8n server
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.server_name}-sg"
  }
}

# idp EC2 Instance
resource "aws_instance" "server" {
  ami                    = local.ubuntu_ami
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.server-sg.id]
  
  # Enable public IP
  associate_public_ip_address = true

  key_name = var.key_pair_name

  # Root block device with 20GB storage
  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = "${var.server_name}"
  }
}