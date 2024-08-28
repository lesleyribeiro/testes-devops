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
