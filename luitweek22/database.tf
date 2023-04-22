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
  db_name                = "cblackiitfrds"
  engine                 = "mysql"
  engine_version         = "8.0.32"
  instance_class         = "db.t3.micro"
  port                   = "3306"
  username               = var.username
  password               = var.password
  vpc_security_group_ids = [aws_security_group.data-tier-security-group.id]
  availability_zone      = "us-west-2b"
  storage_encrypted      = true
  deletion_protection    = false
  skip_final_snapshot    = true

  tags = {
    name = "cblackiitfrds"
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