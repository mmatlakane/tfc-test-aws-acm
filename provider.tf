provider "aws" {
  region  = "af-south-1"
  profile = "default"
}

terraform {
  required_providers {
    aws = {
      source        = "hashicorp/aws"
      version       = "5.22.0"
     
    }
  }
}
provider "aws" {
  alias      = "validation_account"
  access_key = var.dev_aws_key
  secret_key = var.dev_aws_secret
  region     = "us-east-1"

assume_role {
    role_arn = "arn:aws:iam::700688370064:role/route53"
  }
}