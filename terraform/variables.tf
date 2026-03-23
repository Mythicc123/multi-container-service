variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "multi-container-service"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID (Amazon Linux 2023)"
  type        = string
  default     = "ami-0c55b159cbfafe1f0" # us-east-1 Amazon Linux 2023
}

variable "ssh_public_key" {
  description = "SSH public key for ec2-user"
  type        = string
}

variable "my_ip" {
  description = "Your IP address for SSH access restriction (CIDR)"
  type        = string
  default     = "0.0.0.0/0"
}
