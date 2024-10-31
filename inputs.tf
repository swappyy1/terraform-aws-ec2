variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  description = "VPC ID for the subnets"
  type        = string
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"] # Replace with your preferred zones
}

variable "ami_id" {
  type        = string
  description = "AMI ID for the EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "Instance type for EC2"
  default     = "t2.micro"
}

variable "account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "tfc_workspace" {
  type        = string
  description = "Terraform Cloud workspace name"
}