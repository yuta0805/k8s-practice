provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}
data "aws_eks_cluster" "cluster" {
  name = module.main.cluster_id
}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "sre-onboarding-hamada"
    key    = "onboarding/aws/eks/vpc"
    region = "ap-northeast-1"
  }
}

data "aws_ami" "eks_default" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-${local.cluster_version}-v*"]
  }
}

data "aws_caller_identity" "current" {}
output "account" {
  value = data.aws_caller_identity.current
}

data "aws_availability_zones" "available" {}

module "key_pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "~> 2.0"

  key_name_prefix    = "test-hamada-key"
  create_private_key = true

  tags = {
    Name = "test-hamada-key"
  }
}

locals {
  cluster_version = "1.23"
}


module "main" {
  source  = "terraform-aws-modules/eks/aws"
  version = "18.28.0"

  cluster_name    = "hamada-demo-cluater"
  cluster_version = "1.23"

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids = [
    for private in data.terraform_remote_state.vpc.outputs.private_subnet_ids : private
  ]
  control_plane_subnet_ids = [
    for private in data.terraform_remote_state.vpc.outputs.private_subnet_ids : private
  ]

  create_aws_auth_configmap = false
  manage_aws_auth_configmap = false

  # aws_auth_roles = [
  #   {
  #     rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/role1"
  #     username = "role1"
  #     groups   = ["system:masters"]
  #   },
  # ]

  # aws_auth_users = [
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/user1"
  #     username = "user1"
  #     groups   = ["system:masters"]
  #   },
  #   {
  #     userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/user2"
  #     username = "user2"
  #     groups   = ["system:masters"]
  #   },
  # ]

  self_managed_node_group_defaults = {
    # enable discovery of autoscaling groups by cluster-autoscaler
    # update_launch_template_default_version = true
    # iam_role_additional_policies = {
    #   AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    # }
    autoscaling_group_tags = {
      "k8s.io/cluster-autoscaler/enabled" : true,
      "k8s.io/cluster-autoscaler/test-hamada-cluater" : "owned",
    }
  }

  self_managed_node_groups = {
    # Default node group - as provisioned by the module defaults
    default_node_group = {}
  }
  create_iam_role          = true
  iam_role_name            = "self-managed-node-group-complete-example"
  iam_role_use_name_prefix = false
  iam_role_description     = "Self managed node group complete example role"
  iam_role_tags = {
    Purpose = "Protector of the kubelet"
  }
  iam_role_additional_policies = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    aws_iam_policy.additional.arn
  ]

  tags = {
    ExtraTag = "Self managed node group complete example"
  }
}

resource "aws_iam_policy" "additional" {
  name        = "hamada-additional"
  description = "Example usage of node additional policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:Describe*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = {
    Name = "test-hamada"
  }
}
