provider "aws" {
  region = var.aws_region
}

#create an s3 bucket to be used as remote backend
resource "aws_s3_bucket" "cblackii-luitw21-bucket" {
  bucket        = "cblackii-luitw21-bucket"
  force_destroy = true #this will help to destroy an s3 bucket that is not empty 
}

#enable versioning to keep record of any modifications made to s3 bucket files
resource "aws_s3_bucket_versioning" "cblackii-luitw21-bucket" {
  bucket = aws_s3_bucket.cblackii-luitw21-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#s3 bucket access control list will be private
resource "aws_s3_bucket_acl" "cblackii-luitw21-bucket" {
  bucket = aws_s3_bucket.cblackii-luitw21-bucket.id
  acl    = "private"
}

#block s3 bucket objects from public 
resource "aws_s3_bucket_public_access_block" "cblackii-luitw21-bucket" {
  bucket                  = aws_s3_bucket.cblackii-luitw21-bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#create dynamodb table for file-locking of s3 bucket backend
resource "aws_dynamodb_table" "my-tf-dbtable" {
  name           = "my-tf-dbtable"
  hash_key       = "LockID" #value "LockID" is required
  billing_mode   = "PROVISIONED"
  read_capacity  = 10 #free-tier eligible
  write_capacity = 10 #free-tier eligible

  attribute {
    name = "LockID" #name "LockID" is required 
    type = "S"
  }
}

resource "aws_security_group" "my-tf-sg" {
  name        = "my-tf-sg"
  description = "Security group for web server instances"
  vpc_id      = var.my-dev-vpc

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc" "my-dev-vpc" {
  cidr_block = "10.10.0.0/16"
}

resource "aws_autoscaling_group" "my-tf-asg" {
  name                = "my-tf-asg"
  min_size            = 2
  max_size            = 5
  desired_capacity    = 2
  vpc_zone_identifier = [var.subnet-public1-us-west-2a, var.subnet-public2-us-west-2b]

  launch_template {
    id      = aws_launch_template.my-tf-launch.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "my-tf-launch" {
  name_prefix   = "my-tf-launch"
  image_id      = "ami-0747e613a2a1ff483"
  instance_type = "t2.micro"
   key_name               = var.key_name
  user_data              = filebase64("${path.root}/installapache.sh")
  vpc_security_group_ids = [aws_security_group.my-tf-sg.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "terraform_auto_scaling"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "cblackii-luitw21-bucket"
    key    = "global/s3/terraform.tfstate"
    region = "us-west-2"
    # Add any additional backend-specific configuration options
  }
}
