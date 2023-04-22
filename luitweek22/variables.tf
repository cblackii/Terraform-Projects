variable "private-subnets" {
  default = {
    "private-subnet-1" = 1
    "private-subnet-2" = 2
  }
}

variable "public-subnets" {
  default = {
    "public-subnet-1" = 1
    "public-subnet-2" = 2
  }
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "vpc_name" {
  type    = string
  default = "custom-two-tier-vpc"
}

variable "instance_type" {
  description = "Instance Type"
  type        = string
  default     = "t2.micro"
}

variable "image_id" {
  type    = string
  default = "ami-0747e613a2a1ff483" # region specific ami
}

variable "key_name" {
  type    = string
  default = "GeneralUseKeyPair"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "SSH" {
  type    = string
  default = "22"
}

variable "tcp" {
  type    = string
  default = "tcp"
}

variable "HTTP" {
  type    = string
  default = "80"
}

variable "egress-all" {
  type    = string
  default = "0"
}

variable "egress" {
  type    = string
  default = "-1"
}

variable "ami" {
  description = "AMI"
  type        = string
  default     = "ami-0747e613a2a1ff483"
}

variable "tenancy" {
  type    = string
  default = "default"
}

variable "true" {
  type    = bool
  default = true
}

variable "password" {}

variable "username" {}

