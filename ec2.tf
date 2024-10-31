# VPC Module
module "vpc" {
  source         = "./modules/terraform-aws-vpc"
  vpc_cidr_block = var.vpc_cidr_block
}

# Subnet Module - Public
module "public_subnet" {
  source                  = "./modules/terraform-aws-subnet"
  vpc_id                  = module.vpc.vpc_id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = true
}

# Subnet Module - Private
module "private_subnet" {
  source            = "./modules/terraform-aws-subnet"
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone[1]
}

# Route Table Module
module "route_table" {
  source    = "./modules/terraform-aws-route-table"
  vpc_id    = module.vpc.vpc_id
  subnet_id = [module.public_subnet.subnet_id]
}

# Ec2 in private subnet
module "ec2_instance" {
  source        = "./modules/terraform-aws-ec2-instance"
  subnet_id     = module.private_subnet.subnet_id
  ami_id        = var.ami_id
  instance_type = var.instance_type
}
