locals {
  tags = {
    Name = "desafio-rds"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-west-1"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Módulo responsável por criar a VPC (Virtual Private Cloud) e suas respectivas subnets, NAT Gateways, e outras configurações de rede necessárias.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "desafio-vpc"
  cidr = "10.123.0.0/16"

  azs             = ["us-west-1b", "us-west-1c"]
  private_subnets = ["10.123.3.0/24", "10.123.4.0/24"]
  public_subnets  = ["10.123.1.0/24", "10.123.2.0/24"]

  enable_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

# Módulo responsável pela criação do cluster EKS (Elastic Kubernetes Service).
module "eks" {
  source = "../../modules/eks"

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.private_subnets
}

# Módulo responsável pela criação do banco de dados RDS (Relational Database Service) e suas configurações.
module "rds" {
  source             = "../../modules/rds"
  name               = "desafio-rds"
  allocated_storage  = 20
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  db_name            = "desafio"
  username           = "admin"
  password           = "desafio_6"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [module.rds.rds_security_group_id]
  vpc_id             = module.vpc.vpc_id
  tags               = local.tags
}

# Gera uma string aleatória, que será utilizada na composição de nomes de recursos, para evitar conflitos.
resource "random_string" "suffix" {
  length  = 5
  special = false
}

# Criação do Load Balancer do tipo Application, responsável por distribuir o tráfego para os nodes do cluster.
resource "aws_lb" "desafio_alb" {
  name               = "desafio-alb-${random_string.suffix.result}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets

  enable_deletion_protection = false
  idle_timeout               = 60

  tags = local.tags
}

# Criação do Security Group para o Load Balancer, definindo regras de entrada e saída de tráfego.
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${random_string.suffix.result}"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg-${random_string.suffix.result}"
  }
}

# Criação do Target Group do Load Balancer, que agrupa os recursos de destino para balanceamento de carga.
resource "aws_lb_target_group" "desafio_target_group" {
  name     = "desafio-target-group-${random_string.suffix.result}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200"
  }
}

# Criação da IAM Role que será atribuída aos nodes do cluster EKS, permitindo que eles interajam com outros serviços da AWS.
resource "aws_iam_role" "eks_node_role" {
  name = "eks_node_role-${random_string.suffix.result}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })

  tags = local.tags
}

# Anexando políticas à IAM Role dos nodes, garantindo permissões necessárias para operar no EKS.
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Criação do Node Group dentro do cluster EKS, que define as instâncias EC2 que farão parte do cluster.
resource "aws_eks_node_group" "desafio_nodegroup" {
  cluster_name    = "desafio-cluster"
  node_group_name = "desafio-nodegroup-${random_string.suffix.result}"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = module.vpc.private_subnets

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 1
  }

  instance_types = ["t3.large"]

  tags = local.tags

  depends_on = [
    module.eks
  ]
}

# Associação do Auto Scaling Group ao Target Group do Load Balancer, garantindo que as instâncias do node group recebam tráfego.
resource "aws_autoscaling_attachment" "asg_attachment" {
  depends_on = [aws_eks_node_group.desafio_nodegroup] 
  autoscaling_group_name = aws_eks_node_group.desafio_nodegroup.resources[0].autoscaling_groups[0].name
  lb_target_group_arn    = aws_lb_target_group.desafio_target_group.arn
}

# Output que retorna o ARN do Target Group criado.
output "target_group_arn_output" {
  value = aws_lb_target_group.desafio_target_group.arn
}
