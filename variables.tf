variable "aws_region" {
  description = "AWS Region to deploy the infrastructure"
  default     = "us-west-2"
}

variable "s3_bucket_name" {
  description = "Unique S3 bucket name to store Terraform state"
  default     = "cblackii-luitw21-bucket"
}

variable "key_name" {
  type    = string
  default = "GeneralUseKeyPair"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "image_id" {
  type    = string
  default = "ami-0747e613a2a1ff483" # use the AMI for Amazon Linux 2
}

variable "my-dev-vpc" {
  type    = string
  default = "vpc-042c4102842beb813"
}

variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnet-public1-us-west-2a" {
  description = "The VPC subnet the instance(s) will be created in"
  default     = "subnet-0fb177b1051028c2a"
}

variable "subnet-public2-us-west-2b" {
  description = "The VPC subnet the instance(s) will be created in"
  default     = "subnet-09f98d789f54cdb33"
}

variable "subnet-private1-us-west-2a" {
  description = "The VPC subnet the instance(s) will be created in"
  default     = "subnet-021af5a30af937c9f"
}

variable "subnet-private2-us-west-2b" {
  description = "The VPC subnet the instance(s) will be created in"
  default     = "subnet-02574448c9ec3f0e0"
}
