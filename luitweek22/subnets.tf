#Select available AZs in the us-west-2 region
data "aws_availability_zones" "my-available" {
  state = "available"
}

#Deploy the Public subnets
resource "aws_subnet" "public-subnets" {
  for_each                = var.public-subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.my-available.names)[each.value]
  map_public_ip_on_launch = true

  tags = {
    Name      = "tf-subnet-public-${each.key}"
    Tier      = "public"
    Terraform = "true"
  }
}

#Deploy the Private subnets for RDS MySQL
resource "aws_subnet" "private-subnets" {
  for_each                = var.private-subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone       = tolist(data.aws_availability_zones.my-available.names)[each.value]
  map_public_ip_on_launch = false

  tags = {
    Name      = "tf-subnet-private-${each.key}"
    Tier      = "private"
    Terraform = "true"
  }
}