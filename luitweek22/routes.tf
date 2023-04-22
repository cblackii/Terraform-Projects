#Create route table for Public subnets
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name = "tf-public-rtb"
    Tier = "public"
  }
}

#Create route table for Private subnets
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.cidr
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags = {
    Name = "tf-private-rtb"
    Tier = "private"
  }
}

#Create Public and Private route table associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public-subnets]
  route_table_id = aws_route_table.public-route-table.id
  for_each       = aws_subnet.public-subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private-subnets]
  route_table_id = aws_route_table.private-route-table.id
  for_each       = aws_subnet.private-subnets
  subnet_id      = each.value.id
}