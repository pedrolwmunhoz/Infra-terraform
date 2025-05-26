Infra de Empresa Grande com Terraform

O que tem nesse projeto?

Infraestrutura completassa pra levantar o core de uma empresa moderna, usando só open source e Terraform:

- ✅ IAM com roles e policies pra EKS, serviços e segurança
- ✅ VPC com subnets públicas e privadas
- ✅ EKS (Kubernetes) gerenciado com autoscaling
- ✅ ArgoCD pra CI/CD GitOps style
- ✅ RDS PostgreSQL pra dados transacionais
- ✅ S3 pra armazenamento de arquivos

Pré-requisitos

- Terraform >= 1.3
- AWS CLI configurado (aws configure)
- kubectl
- Helm

Como usar

1. Clone o repositório:
   git clone https://github.com/seu-usuario/infra-empresa.git
   cd infra-empresa

2. Configure as variáveis sensíveis:
   Crie terraform.tfvars ou exporte via env:
   region = "us-east-1"
   aws_profile = "default"
   db_password = "sua_senha_segura"

3. Inicialize o Terraform:
   terraform init

4. Veja o que vai ser criado:
   terraform plan

5. Aplique a infra:
   terraform apply -auto-approve

O que vai ser criado?

IAM
- Role para EKS Cluster
- Role para NodeGroup
- Policies customizadas:
  - Acesso mínimo necessário ao S3
  - Permissão para CloudWatch e autoscaling
  - IRSA configurado para pods críticos

VPC
- 3 Subnets privadas
- 3 Subnets públicas
- NAT Gateway e roteamento configurado

EKS
- Cluster Kubernetes 1.29
- NodeGroup com autoscaling (min 1, max 5 nós)
- Configuração de IAM Roles for Service Accounts (IRSA)
- Policies customizadas pra pods acessarem S3 e outros serviços com segurança

ArgoCD
- Deploy via Helm automático
- Namespace isolado
- GitOps 100% integrado com o cluster

RDS
- PostgreSQL 15
- Subnet Group privado
- Criptografia habilitada
- Backup automático configurado

S3
- Bucket versionado
- Nome único via random ID
- Policy de acesso restrito via IAM

Autoscaling
- Habilitado no NodeGroup (Cluster Autoscaler)
- Configuração de métricas via K8s + CloudWatch
- Escala automática conforme uso de CPU/Memória

Depois do deploy

1. Configure o kubeconfig:
   aws eks update-kubeconfig --name empresa-eks --region us-east-1

2. Acesse o ArgoCD:
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   Depois, abra: https://localhost:8080

Usuário padrão: admin
Senha: pega com:
kubectl get secret argocd-initial-admin-secret -n argocd -o yaml

Dica de ouro

Se quiser deixar a infra ainda mais nervosa:

- Habilita o Argo Rollouts pro deploy canário
- Configura HPA (Horizontal Pod Autoscaler) pros deployments
- Coloca o ExternalDNS pra gerenciar DNS automático
- Mete um cert-manager pra SSL automático

Licença

MIT — mete bronca, só não vende como se fosse teu sem mudar nada!
