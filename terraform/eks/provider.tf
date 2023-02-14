provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2"
    }
  }

  backend "s3" {
    bucket = "sre-onboarding-hamada"
    key    = "onboarding/aws/eks/apps"
    region = "ap-northeast-1"
  }
}
