# Cloud provider required, in this case using AWS

provider "aws" {
	region = "eu-west-1"
}


resource "aws_security_group" "mongo_access"{
	name = "eng74-leo-terra-mongo-access"
	description = "Allow traffic on port 27017 for mongoDB"
	vpc_id = "vpc-07e47e9d90d2076da"

	ingress {
		description = "27017 from app instance"
		from_port = 27017
		to_port = 27017
		protocol = "tcp"
		security_groups = ["sg-09daa57de1874642a"]
	}

	egress {
		description = "All traffic out"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]

	}

	tags = {
		Name = "eng74-leo-terra-mongo-access"
	}
}

resource "aws_instance" "mongodb_instance" {
	ami = "ami-03646b6976790491d"
	instance_type = "t2.micro"
	key_name = "eng74_leo_aws_key"
	associate_public_ip_address = true
	vpc_security_group_ids = [aws_security_group.mongo_access.id]
	tags = {
		Name = "eng74-leo-terraform-db"
	}
}

resource "aws_instance" "nodejs_instance" {
	ami = "ami-0651ff04b9b983c9f"
	instance_type = "t2.micro"
	key_name = "eng74_leo_aws_key"
	associate_public_ip_address = true
	vpc_security_group_ids = ["sg-09daa57de1874642a"]
	tags = {
		Name = "eng74-leo-terraform-app"
	}


	provisioner "remote-exec"{
	connection {
		type = "ssh"
		user = "ec2-user"
		private_key = "${file("/c/Users/daiji/.ssh/eng74_leo_aws_key")}"
		host = "${self.public_ip}"
	} 
		inline = [
			"export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
			"cd app/ && pm2 start app.js",
		]
	}
}