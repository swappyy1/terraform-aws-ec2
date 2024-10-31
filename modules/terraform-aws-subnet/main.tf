resource "aws_subnet" "public" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone[0]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "example-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone[1]
  map_public_ip_on_launch = var.map_public_ip_on_launch
  tags = {
    Name = "example-private-subnet"
  }
}