resource "aws_route_table" "main" {
  vpc_id = var.vpc_id
  tags = {
   Name = "example-route-table"
  }
}

resource "aws_route_table_association" "main" {
  subnet_id = var.subnet_id
  route_table_id = aws_route_table.main.id
}