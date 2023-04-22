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