module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.prefix}_vpc"
  cidr = "10.0.0.0/16"
  
  azs = ["${var.region}a", "${var.region}c"]

  public_subnets = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24", "10.0.3.0/24"]
  intra_subnets = ["10.0.4.0/24", "10.0.5.0/24"]

  enable_nat_gateway = true

  tags = {
    terraform = "true"
  }


}