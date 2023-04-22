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

#Launch an EC2 instance with bootstrapped Apache in each public subnet
resource "aws_instance" "web-server" {
  for_each                    = toset(keys(var.public-subnets))
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public-subnets[each.key].id
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.web-tier-security-group.id]
  user_data                   = file("apache.sh")
  user_data_replace_on_change = true
  associate_public_ip_address = true

  tags = {
    Name        = "web-server"
    Environment = "dev"
  }
}