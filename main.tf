# Cloud provider required, in this case using AWS

provider "aws" {
	region = "eu-west-1"
}

resource "aws_instance" "nodejs_instance" {
	ami = "ami-0651ff04b9b983c9f"
	instance_type = "t2.micro"
	associate_public_ip_address = true
	tags = {
		Name = "eng74-leo-terraform-app"
	}
}