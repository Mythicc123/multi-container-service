variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
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
  description = "Ubuntu 22.04 LTS AMI ID for your region. Find it at: AWS EC2 → Instances → Launch an instance → Ubuntu 22.04 LTS"
  type        = string
  default     = "" # REQUIRED — must be set in terraform.tfvars
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair (must exist in AWS under EC2 → Key Pairs)"
  type        = string
  default     = "" # REQUIRED — must be set in terraform.tfvars
}

variable "my_ip" {
  description = "Your IP address for SSH access restriction (CIDR). Use 0.0.0.0/0 for anywhere."
  type        = string
  default     = "0.0.0.0/0"
}
