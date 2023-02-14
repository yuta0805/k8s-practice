# provider "helm" {
#   kubernetes {
#     config_path = "~/.kube/config"
#   }
# }

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
    key    = "onboarding/aws/eks/argocd"
    region = "ap-northeast-1"
  }
}

data "aws_eks_cluster" "this" {
  name = "hamada-demo-cluater"
}

data "aws_eks_cluster_auth" "this" {
  name = "hamada-demo-cluater"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.this.endpoint
    token                  = data.aws_eks_cluster_auth.this.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority.0.data)
  }
}
