provider "aws" {
  region = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
}

data "aws_availability_zones" "available" {
}

data "aws_caller_identity" "current" {
}
