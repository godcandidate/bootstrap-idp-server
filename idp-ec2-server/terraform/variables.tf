# Variables for the Terraform configuration
variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-north-1"
}

variable "key_pair_name" {
  description = "Name of the AWS key pair for SSH access (optional)"
  type        = string
  default     = "ec2-key"  
}

variable "server_name" {
    description = "Name tag for the EC2 instance"
    type        = string
    default     = "idp-server"
}