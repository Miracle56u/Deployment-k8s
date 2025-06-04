#VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                     = data.aws_availability_zones.available.names
  private_subnets         = var.private_subnets
  public_subnets          = var.public_subnets
  map_public_ip_on_launch = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
  enable_vpn_gateway   = true

  tags = {
    Name        = "microservices-vpc"
    Terraform   = "true"
    Environment = "dev"
  }
}


# CREATE SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "microservices-sg"
  description = "Security Group for microservices"
  vpc_id      = module.vpc.vpc_id
  #vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress_with_cidr_blocks = [
    {
      description = "SSH Port"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "HTTP Port"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "NPM Port"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Jenkins Port"
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "SonarQube Port"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Prometheus Port"
      from_port   = 9090
      to_port     = 9090
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Prometheus Metrics Port"
      from_port   = 9100
      to_port     = 9100
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  
egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    Name = "microservices-sg"
  }
}

# EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "microservices-instance"

  instance_type          = var.instance_type
  key_name               = "key-terraform"
  monitoring             = true
  vpc_security_group_ids = [module.sg.security_group_id]
  subnet_id              = module.vpc.public_subnets[0]
  #subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("tools.sh")
  availability_zone           = data.aws_availability_zones.available.names[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
