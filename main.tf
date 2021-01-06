# Cloud provider required, in this case using AWS
provider "aws" {
	region = var.region
}

# create security group allowing access on port 27017
resource "aws_security_group" "mongo_access"{
	name = "eng74-leo-terra-mongo-access"
	description = "Allow traffic on port 27017 for mongoDB"
	vpc_id = var.vpc_id

	ingress {
		description = "27017 from app instance"
		from_port = 27017
		to_port = 27017
		protocol = "tcp"
		security_groups = [var.app_sg_id]
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

# create mongodb instance and assign newly created security group
resource "aws_instance" "mongodb_instance" {
	ami = var.ami_mongo
	instance_type = var.instance_type
	key_name = var.aws_key_name
	associate_public_ip_address = true
	vpc_security_group_ids = [aws_security_group.mongo_access.id]
	tags = {
		Name = "eng74-leo-terraform-db"
	}
}

# create nodejs app instance
resource "aws_instance" "nodejs_instance" {
	ami = var.ami_nodejs
	instance_type = var.instance_type
	key_name = var.aws_key_name
	associate_public_ip_address = true
	vpc_security_group_ids = [var.app_sg_id]
	tags = {
		Name = "eng74-leo-terraform-app"
	}

	connection {
		type = "ssh"
		user = "ubuntu"
		private_key = "${file(var.aws_key_path)}"
		host = "${self.public_ip}"
	} 

	# export private ip of mongodb instance and start app
	provisioner "remote-exec"{
		inline = [
			"export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
			"cd app/ && pm2 start app.js",
		]
	}
}