# Cloud provider required, in this case using AWS
provider "aws" {
	region = var.region
}

# # create VPC
# resource "aws_vpc" "main" {
# 	cidr_block = "13.7.0.0/16"
	
# 	tags = {
# 		Name = "eng74-leo-terra-vpc"
# 	}
# }

# # create IGW
# resource "aws_internet_gateway" "main_igw" {
# 	vpc_id = aws_vpc.main.id
# 	tags = {
# 		Name = "eng74-leo-terra-igw"
# 	}
# }

# # create public subnet
# resource "aws_subnet" "public_subnet" {
# 	vpc_id = aws_vpc.main.id
# 	cidr_block = "13.7.1.0/24"
# 	map_public_ip_on_launch = true
# 	tags = {
# 		Name = "eng74-leo-terra-public_subnet"
# 	}
# }

# # create NACL for public subnet
# resource "aws_network_acl" "public_nacl" {
# 	vpc_id = aws_vpc.main.id
# 	subnet_ids = [aws_subnet.public_subnet.id]

# 	# allow port 80 from all
# 	ingress {
# 		protocol = "tcp"
# 		rule_no = 100
# 		action = "allow"
# 		cidr_block = "0.0.0.0/0"
# 		from_port = 80
# 		to_port = 80
# 	}

# 	# allow SSH from home
# 	ingress {
# 		protocol = "tcp"
# 		rule_no = 110
# 		action = "allow"
# 		cidr_block = var.home_cidr
# 	}

# 	tags = {
# 		Name = "eng74-leo-terra-public_nacl"
# 	}
# }


# create security group allowing access on port 27017
resource "aws_security_group" "nodejs_sg"{
	name = "eng74-leo-terra-nodejs_sg"
	description = "Allow public access for nodejs instnace"
	vpc_id = var.vpc_id

	ingress {
		description = "80 from all"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "SSH from home"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [var.home_cidr]
	}

	egress {
		description = "All traffic out"
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}

	tags = {
		Name = "eng74-leo-terra-nodejs_sg"
	}
}


# create security group allowing access on port 27017
resource "aws_security_group" "db_sg"{
	name = "eng74-leo-terra-mongo-access"
	description = "Allow traffic on port 27017 for mongoDB"
	vpc_id = var.vpc_id

	ingress {
		description = "27017 from app instance"
		from_port = 27017
		to_port = 27017
		protocol = "tcp"
		security_groups = [aws_security_group.nodejs_sg.id]
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
	vpc_security_group_ids = [aws_security_group.db_sg.id]
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
	vpc_security_group_ids = [aws_security_group.nodejs_sg.id]
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