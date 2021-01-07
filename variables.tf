# using variables tf instead of hardcoding in main.tf
module myip {
	source = "4ops/myip/http"
	version = "1.0.0"
}

variable "region" {
    default = "eu-west-1"
}

variable "vpc_id" {
    default = "vpc-07e47e9d90d2076da"
}

variable "ami_mongo" {
    default = "ami-03646b6976790491d"
}

variable "ami_nodejs" {
    default = "ami-0651ff04b9b983c9f"
}

variable "instance_type" {
    default = "t2.micro"
}

variable "aws_key_name" {
    default = "eng74_leo_aws_key"
}

variable "aws_key_path" {
    default = "~/.ssh/eng74_leo_aws_key.pem"
}
