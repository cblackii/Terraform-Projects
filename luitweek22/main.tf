#Create custom VPC 
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = var.vpc_name
    Environment = "custom-two-tier-vpc"
    Terraform   = "true"
  }

  enable_dns_hostnames = true
}

#Select available AZs in the us-west-2 region
data "aws_availability_zones" "my-available" {}
data "aws_region" "current" {}

#Deploy the Public subnets
resource "aws_subnet" "public-subnets" {
  for_each          = var.public-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.my-available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Deploy the Private subnets
resource "aws_subnet" "private-subnets" {
  for_each          = var.private-subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.my-available.names)[each.value]

  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

#Create route table for Public subnets
resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }
  tags = {
    Name      = "tf-public-rtb"
    Terraform = "true"
  }
}

#Create route table for Private subnets
resource "aws_route_table" "private-route-table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gateway.id
  }
  tags = {
    Name      = "tf-private-rtb"
    Terraform = "true"
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

#Create Internet Gateway
resource "aws_internet_gateway" "internet-gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "tf-two-tier-igw"
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat-gateway-eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet-gateway]
  tags = {
    Name = "tf-two-tier-igw_eip"
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat-gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public-subnet-1"].id
  tags = {
    Name = "tf-nat-gateway"
  }
}

# create web-tier security group
resource "aws_security_group" "web-tier-security-group" {
  name        = "web-tier security group"
  description = "allow access via ssh and http"
  vpc_id      = aws_vpc.vpc.id

  # allow internet traffic
  ingress {
    description = "Allow all SSH"
    from_port   = var.SSH
    to_port     = var.SSH
    protocol    = var.tcp
    cidr_blocks = [var.cidr]
  }

  ingress {
    description = "Allow all HTTP"
    from_port   = var.HTTP
    to_port     = var.HTTP
    protocol    = var.tcp
    cidr_blocks = [var.cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = var.egress-all
    to_port     = var.egress-all
    protocol    = var.egress
    cidr_blocks = [var.cidr]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "tf-web-tier security group"
  }
}

#Create security group for database tier from the web-server tier
resource "aws_security_group" "data-tier-security-group" {
  name   = "tf-data-tier-security-group"
  vpc_id = aws_vpc.vpc.id

  ingress {
    description     = "Allow mySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = var.tcp
    security_groups = [aws_security_group.web-tier-security-group.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = var.egress-all
    to_port     = var.egress-all
    protocol    = var.egress
    cidr_blocks = [var.cidr]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "Tf data-tier security group"
  }
}

#Public subnets created in VPC
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  tags = {
    Tier = "public"
  }
}

#Private subnets created in VPC
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.vpc.id]
  }

  tags = {
    Tier = "private"
  }
}

#Launch one RDS MySQL instance in a private subnet 
resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  max_allocated_storage  = 50
  db_subnet_group_name   = aws_db_subnet_group.rds-mysql-subnet-group.id
  db_name                = "tf-rds"
  engine                 = "mysql"
  engine_version         = "8.0.32"
  instance_class         = "db.t3.micro"
  port                   = "3306"
  username               = var.username
  password               = var.password
  vpc_security_group_ids = [aws_security_group.tf-data-tier-security-group.id]
  availability_zone      = "us-west-2a"
  storage_encrypted      = true
  deletion_protection    = false
  skip_final_snapshot    = true

  tags = {
    name = "tf-rds-mysql"
  }
}

#Create database subnet group
resource "aws_db_subnet_group" "rds-mysql-subnet-group" {
  name       = "tf-db-subnet-group"
  subnet_ids = [for subnet in aws_subnet.private-subnets : subnet.id]

  tags = {
    Name = "tf-db-subnet-group"
  }
}

#Launch an EC2 instance with bootstrapped Apache in each public subnet
resource "aws_instance" "web-server" {
  for_each                    = toset(data.aws_subnets.public.ids)
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = each.value
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.tf-web-tier-security-group.id]
  user_data                   = file("apache.sh")
  user_data_replace_on_change = true
  associate_public_ip_address = true

  tags = {
    Name        = "web-server"
    Environment = "dev"
  }
}


