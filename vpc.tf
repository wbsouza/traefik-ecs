module "vpc" {
  source         = "terraform-aws-modules/vpc/aws"
  version        = "2.39.0"
  name           = "api-vpc"
  cidr           = "10.0.0.0/16"
  azs            = ["sa-east-1a", "sa-east-1c"]
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    "env"       = "dev"
    "createdBy" = "anezio"
  }
}

data "aws_vpc" "main" {
  id      = module.vpc.vpc_id
}
