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
      Project     = "aws-saa-labs"
      Owner       = "matheus.ferrazzi"
      Description = "laboratio do terraform do matheus para estudos"
    }
  }
}
# 1) O bucket que a EC2 vai poder ler
resource "aws_s3_bucket" "lab" {
  bucket = "aws-saa-labs-matheus-s01" # nome único, ex.: aws-saa-labs-matheus-s01
}

# 2) O role: a trust policy diz QUEM pode vestir (volta ao original!)
resource "aws_iam_role" "lab_role" {
  name = "aws-saa-labs-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole" # a ação de assumir role (dica: é do STS)
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" } # o serviço que pode vestir
      }
    ]
  })
}

# 3) A permission policy: O QUE o role pode fazer
resource "aws_iam_role_policy" "lab_s3_read" {
  name = "aws-saa-labs-s3-read"
  role = aws_iam_role.lab_role.id # referência ao role acima (dica: aws_iam_role.lab_role.id)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListarBucket"
        Effect   = "Allow"
        Action   = "s3:ListBucket"       # listar o conteúdo do bucket
        Resource = aws_s3_bucket.lab.arn # o BUCKET em si (referência, sem aspas)
      },
      {
        Sid      = "LerObjetos"
        Effect   = "Allow"
        Action   = "s3:GetObject"               # baixar/ler um objeto
        Resource = "${aws_s3_bucket.lab.arn}/*" # os OBJETOS dentro do bucket (lembra do /*)
      }
    ]
  })
}

# 4) O instance profile: o "cordão" que prende o role na EC2
resource "aws_iam_instance_profile" "lab_profile" {
  name = "aws-saa-labs-ec2-profile"
  role = aws_iam_role.lab_role.id # de novo, referência ao role
}