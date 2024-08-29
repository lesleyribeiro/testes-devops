# Configuração do módulo EKS (Elastic Kubernetes Service), utilizando um repositório específico no GitHub como fonte.
module "eks" {
  source  = "git::https://github.com/lesleyribeiro/terraform-aws-eks.git"

  # Nome do cluster EKS e configuração para permitir o acesso público ao endpoint do cluster.
  cluster_name                   = "desafio-cluster"
  cluster_endpoint_public_access = true

  # Configuração dos addons do EKS, garantindo que as versões mais recentes dos addons coredns, kube-proxy e vpc-cni sejam instaladas.
  cluster_addons = {
    #coredns = {
    #  most_recent = true
    #}
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }



  }

  # IDs da VPC e subnets que serão utilizadas pelo cluster EKS, incluindo as subnets do plano de controle.
  vpc_id                   = var.vpc_id
  subnet_ids               = var.subnet_ids
  control_plane_subnet_ids = var.control_plane_subnet_ids

  # Configuração padrão dos node groups gerenciados pelo EKS, incluindo tipo de instância e AMI (Amazon Machine Image) utilizada.
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["m5.large"]

    attach_cluster_primary_security_group = true
  }

  # Configuração comentada de um node group gerenciado pelo EKS. Esse bloco poderia definir um node group chamado `desavio_nodegroup` com parâmetros de escalabilidade e tags específicas.
  # eks_managed_node_groups = {
  #   desavio_nodegroup = {
  #     min_size     = 1
  #     max_size     = 4
  #     desired_size = 2

  #     instance_types = ["t3.large"]
  #     capacity_type  = "SPOT"

  #     tags = {
  #       ExtraTag = "desafio-devops"
  #     }
  #   }
  # }

  # Tags associadas ao cluster EKS.
  tags = {
    Example = "desafio-cluster"
  }
}

# Recurso que gera uma string aleatória de três caracteres, que pode ser usada para criar nomes únicos para recursos.
resource "random_string" "suffix" {
  length  = 3
  special = false
}
