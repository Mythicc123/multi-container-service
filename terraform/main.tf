terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Use the default VPC in the region
data "aws_vpc" "default" {
  default = true
}

data "aws_subnet" "app" {
  id = "subnet-0169389af48015c56"
}

# Existing key pair — managed outside of Terraform
data "aws_key_pair" "app" {
  key_name = "ec2-static-site-key"
}

# Existing security group — managed outside of Terraform
data "aws_security_group" "app" {
  id = "sg-0af639883552f9a6a"
}

# ─── EC2 Instance ────────────────────────────────────────────────────────────

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = data.aws_key_pair.app.key_name
  subnet_id     = data.aws_subnet.app.id

  vpc_security_group_ids = [data.aws_security_group.app.id]

  # Install Docker and Docker Compose on first boot
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io docker-compose-v2 nginx
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ubuntu
              EOF

  tags = {
    Name = "${var.project_name}-server"
  }
}

