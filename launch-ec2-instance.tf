# Launch a EC2 Instance
resource "aws_instance" "my-tf-instance" {
  ami           = "ami-0747e613a2a1ff483"
  instance_type = "t2.micro"
  subnet_id     = "${aws_subnet.public_subnet1.id},${aws_subnet.public_subnet2.id}"

  # Use the security group created above
  vpc_security_group_ids = [aws_security_group.my-tf-sg.id]

  # Assign a public IP address to the instance
  associate_public_ip_address = true

  # Use the key pair for SSH access
  key_name = var.key_name

}

resource "aws_subnet" "public_subnet1" {
  vpc_id                  = aws_vpc.my-dev-vpc.id
  cidr_block              = "10.10.0.0/20"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.my-dev-vpc.id
  cidr_block              = "10.10.16.0/20"
  availability_zone       = "us-west-2b"
  map_public_ip_on_launch = true
}

  user_data = base64encode(<<-EOF
                #!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                echo "Hello, World!" > /var/www/html/index.html
                EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}
