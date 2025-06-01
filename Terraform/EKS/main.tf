module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets


  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true


  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true


  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets


  eks_managed_node_groups = {
    node_group = {
      min_size     = 2
      max_size     = 6
      desired_size = 2

      instance_types = ["t2.medium"]
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

#creat ecr
module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = "microservices-images"

  #repository_read_write_access_arns = ["arn:aws:iam::012345678901:role/terraform"]
  repository_read_write_access_arns = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/terraform"]
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Name        = "microservices-image"
    Terraform   = "true"
    Environment = "dev"
  }
}