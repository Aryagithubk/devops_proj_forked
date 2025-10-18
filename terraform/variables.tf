variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devops-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type (use t2.micro for free tier)"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances (Ubuntu 22.04 LTS in us-east-1)"
  type        = string
  default     = "ami-0e86e20dae9224db8" # Ubuntu 22.04 LTS
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "devops-project-key"
}
