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
resource "aws_db_instance" "mydbinstance" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "5.7"
  identifier             = "myrdsinstance"
  instance_class         = "db.t2.micro"
  username               = var.username
  password               = var.password
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = [aws_security_group.data-tier-security-group.id, aws_security_group.web-tier-security-group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds-mysql-subnet-group.id
  skip_final_snapshot    = true
  publicly_accessible    = true
}
#Create database subnet group
resource "aws_db_subnet_group" "rds-mysql-subnet-group" {
  name       = "tf-db-subnet-group"
  subnet_ids = [aws_subnet.private-subnets["private-subnet-1"].id, aws_subnet.private-subnets["private-subnet-2"].id]

  tags = {
    Name = "tf-db-subnet-group"
  }
}