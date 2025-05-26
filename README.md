# Infra de Empresa Grande com Terraform

## O que tem nesse projeto?
Infraestrutura completassa pra levantar o core de uma empresa moderna, usando só open source e Terraform:

- ✅ VPC com subnets públicas e privadas
- ✅ EKS (Kubernetes) gerenciado
- ✅ ArgoCD pra CI/CD GitOps style
- ✅ RDS PostgreSQL pra dados transacionais
- ✅ S3 pra armazenamento de arquivos

## Pré-requisitos
- Terraform >= 1.3
- AWS CLI configurado (aws configure)
- kubectl
- Helm

## Como usar
1. Clone o repositório
git clone https://github.com/seu-usuario/infra-empresa.git
cd infra-empresa

2. Configure as variáveis sensíveis
Crie um arquivo terraform.tfvars ou exporte via env:
region = "us-east-1"
aws_profile = "default"

3. Inicialize o Terraform
terraform init

4. Veja o que vai ser criado
terraform plan

5. Aplique a infra
terraform apply -auto-approve

## O que vai ser criado?

### VPC
- 3 Subnets privadas
- 3 Subnets públicas
- NAT Gateway
- Roteamento configurado

### EKS
- Cluster Kubernetes 1.29
- NodeGroup com autoscaling

### ArgoCD
- Deploy via Helm automático
- Namespace isolado

### RDS
- PostgreSQL 15
- Subnet Group privado
- Criptografia habilitada

### S3
- Bucket versionado
- Nome único via random ID

## Depois do deploy

1. Configure o kubeconfig:
aws eks update-kubeconfig --name empresa-eks --region us-east-1

2. Acesse o ArgoCD:
kubectl port-forward svc/argocd-server -n argocd 8080:443
Depois, abra: https://localhost:8080

Usuário padrão: admin
Senha: pega com:
kubectl get secret argocd-initial-admin-secret -n argocd -o yaml

## Dica de ouro
Se quiser deixar a infra ainda mais nervosa:
- Habilita o autoscaling no EKS
- Bota o Argo Rollouts pro deploy canário
- Configura o IAM Roles for Service Accounts (IRSA)

## Licença
MIT — mete bronca, só não vende como se fosse teu sem mudar nada!
