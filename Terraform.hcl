# VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name    = "empresa-vpc"
  cidr    = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Terraform   = "true"
    Environment = "prod"
  }
}

# EKS Cluster
module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = "empresa-eks"
  cluster_version = "1.29"
  subnets         = module.vpc.private_subnets
  vpc_id          = module.vpc.vpc_id

  node_groups = {
    default = {
      desired_capacity = 3
      max_capacity     = 5
      min_capacity     = 1

      instance_type = "t3.medium"
      key_name      = "minha-chave-ssh"
    }
  }

  tags = {
    Environment = "prod"
  }
}

# ArgoCD - Helm release
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "5.51.5"

  namespace = "argocd"
  create_namespace = true

  values = [
    file("${path.module}/argocd-values.yaml")
  ]

  depends_on = [module.eks]
}

# RDS - PostgreSQL
module "rds" {
  source              = "terraform-aws-modules/rds/aws"
  identifier          = "empresa-db"
  engine              = "postgres"
  engine_version      = "15.4"
  instance_class      = "db.t3.medium"
  allocated_storage   = 20
  storage_encrypted   = true
  name                = "empresa"
  username            = "admin"
  password            = "SenhaSuperSegura123"
  port                = 5432
  publicly_accessible = false
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids          = module.vpc.private_subnets
}

# S3 - bucket para arquivos
resource "aws_s3_bucket" "empresa_bucket" {
  bucket = "empresa-arquivos-${random_id.sufixo.hex}"

  versioning {
    enabled = true
  }

  tags = {
    Environment = "prod"
    Name        = "empresa-arquivos"
  }
}

resource "random_id" "sufixo" {
  byte_length = 4
}
