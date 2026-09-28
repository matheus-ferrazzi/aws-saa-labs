terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region  = "us-west-2"
  profile = "sek-lab-infra"

  default_tags {
    tags = {
      Project = "aws-saa-labs"
      Owner = "matheus.ferrazzi"
      Description = "laboratio do terraform do matheus para estudos"
    }
  }
}
resource "aws_s3_bucket" "lab" {
  bucket = "aws-saa-labs-matheus-s00"
}