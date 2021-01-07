# using variables tf instead of hardcoding in main.tf
variable "region" {
    default = "eu-west-1"
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
