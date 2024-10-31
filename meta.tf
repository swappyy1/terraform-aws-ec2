# Define the AWS provider configuration
provider "aws" {
  region = var.region # Reference a variable for region
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}
