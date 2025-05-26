provider "aws" {
  region  = var.region
  profile = var.aws_profile
}

##########################
# IAM Roles e Policies
##########################

module "iam_assumable_role_admin" {
  source = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "5.34.0"

  name                 = "eks-admin-role"
  create_role          = true
  role_requires_mfa    = false
  trusted_role_services = ["ec2.amazonaws.com"]

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]
}

##########################
# VPC com Subnets
##########################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name = "empresa-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

##########################
# EKS Cluster com Autoscaling
##########################

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "20.0.0"
  cluster_name    = "empresa-eks"
  cluster_version = "1.29"

  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id

  eks_managed_node_groups = {
    default = {
      desired_size = 2
      min_size     = 1
      max_size     = 5

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
    }
  }

  manage_aws_auth_configmap = true
}

##########################
# ArgoCD via Helm
##########################

resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.14"

  values = [
    <<EOF
server:
  service:
    type: LoadBalancer
EOF
  ]

  depends_on = [module.eks]
}

##########################
# RDS PostgreSQL
##########################

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.6.0"

  identifier         = "empresa-db"
  engine             = "postgres"
  engine_version     = "15.3"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20

  name               = "empresa"
  username           = "postgres"
  password           = var.db_password
  port               = 5432

  vpc_security_group_ids = [module.vpc.default_security_group_id]
  db_subnet_group_name   = module.vpc.database_subnet_group
  publicly_accessible    = false
}

##########################
# S3 Bucket
##########################

resource "aws_s3_bucket" "empresa_bucket" {
  bucket        = "empresa-${random_id.bucket_id.hex}"
  force_destroy = true

  versioning {
    enabled = true
  }
}

resource "random_id" "bucket_id" {
  byte_length = 4
}

##########################
# Outputs
##########################

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_endpoint" {
  value = module.rds.db_instance_endpoint
}

output "s3_bucket" {
  value = aws_s3_bucket.empresa_bucket.bucket
}
