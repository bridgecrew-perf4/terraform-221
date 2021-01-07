# Cloud provider required, in this case using AWS
provider "aws" {
	region = var.region
}

# create VPC
resource "aws_vpc" "main" {
	cidr_block = "13.7.0.0/16"
	
	tags = {
		Name = "eng74-leo-terra-vpc"
	}
}


# create IGW
resource "aws_internet_gateway" "main_igw" {
	vpc_id = aws_vpc.main.id
	tags = {
		Name = "eng74-leo-terra-igw"
	}
}