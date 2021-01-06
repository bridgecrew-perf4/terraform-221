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


# create public subnet
resource "aws_subnet" "public_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "13.7.1.0/24"
	map_public_ip_on_launch = true
	tags = {
		Name = "eng74-leo-terra-public_subnet"
	}
}

# create route table for public subnet IGW
resource "aws_route_table" "public_rt"{
	vpc_id = aws_vpc.main.id

	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.main_igw.id
	}

	tags = {
		Name = "eng74-leo-terra-public_rt"
	}
}

# configuring route table association
resource "aws_route_table_association" "public_subnet_assoc"{
	subnet_id = aws_subnet.public_subnet.id
	route_table_id = aws_route_table.public_rt.id
}

# create NACL for public subnet
resource "aws_network_acl" "public_nacl" {
	vpc_id = aws_vpc.main.id
	subnet_ids = [aws_subnet.public_subnet.id]

	# allow HTTP from all
	ingress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 80
		to_port = 80
	}

	# allow HTTPS from all
	ingress {
		protocol = "tcp"
		rule_no = 110
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 443
		to_port = 443
	}

	# allow SSH from home
	ingress {
		protocol = "tcp"
		rule_no = 120
		action = "allow"
		cidr_block = var.home_cidr
		from_port = 22
		to_port = 22
	}

	# allow ephemeral from all
	ingress {
		protocol = "tcp"
		rule_no = 130
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}
	
	# allow HTTP to all
	egress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 80
		to_port = 80
	}

	# allow HTTPS to all
	egress {
		protocol = "tcp"
		rule_no = 110
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 443
		to_port = 443
	}

	# allow SSH to home
	egress {
		protocol = "tcp"
		rule_no = 120
		action = "allow"
		cidr_block = var.home_cidr
		from_port = 22
		to_port = 22
	}

	# allow ephemeral to all
	egress {
		protocol = "tcp"
		rule_no = 130
		action = "allow"
		cidr_block = "0.0.0.0/0"
		from_port = 1024
		to_port = 65535
	}

	# allow 27017 to private subnet
	egress {
		protocol = "tcp"
		rule_no = 140
		action = "allow"
		cidr_block = "13.7.2.0/24"
		from_port = 27017
		to_port = 27017
	}

	tags = {
		Name = "eng74-leo-terra-public_nacl"
	}
}


# create private subnet
resource "aws_subnet" "private_subnet" {
	vpc_id = aws_vpc.main.id
	cidr_block = "13.7.2.0/24"
	tags = {
		Name = "eng74-leo-terra-private_subnet"
	}
}


# create NACL for private subnet
resource "aws_network_acl" "private_nacl" {
	vpc_id = aws_vpc.main.id
	subnet_ids = [aws_subnet.private_subnet.id]

	# allow SSH from public subnet
	ingress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = "13.7.1.0/24"
		from_port = 22
		to_port = 22
	}

	# allow 27017 from public subnet
	ingress {
		protocol = "tcp"
		rule_no = 110
		action = "allow"
		cidr_block = "13.7.1.0/24"
		from_port = 27017
		to_port = 27017
	}
	
	# allow ephemeral to public subnet
	egress {
		protocol = "tcp"
		rule_no = 100
		action = "allow"
		cidr_block = "13.7.1.0/24"
		from_port = 1024
		to_port = 65535
	}

	tags = {
		Name = "eng74-leo-terra-private_nacl"
	}
}

# create security group allowing access on port 27017
resource "aws_security_group" "nodejs_sg"{
	name = "eng74-leo-terra-nodejs_sg"
	description = "Allow public access for nodejs instnace"
	vpc_id = aws_vpc.main.id

	ingress {
		description = "HTTP from all"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}

	ingress {
		description = "HTTPS from all"
		from_port = 443
		to_port = 443
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
resource "aws_security_group" "mongodb_sg"{
	name = "eng74-leo-terra-mongodb_sg"
	description = "Allow traffic on port 27017 for mongoDB"
	vpc_id = aws_vpc.main.id

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
		Name = "eng74-leo-terra-mongodb_sg"
	}
}


# create mongodb instance and assign newly created security group
resource "aws_instance" "mongodb_instance" {
	ami = var.ami_mongo
	subnet_id = aws_subnet.private_subnet.id
	instance_type = var.instance_type
	key_name = var.aws_key_name
	associate_public_ip_address = true
	vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
	tags = {
		Name = "eng74-leo-terraform-db"
	}
}


# create nodejs app instance
resource "aws_instance" "nodejs_instance" {
	ami = var.ami_nodejs
	subnet_id = aws_subnet.public_subnet.id
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
			"echo \"export DB_HOST=${aws_instance.mongodb_instance.private_ip}\" >> /home/ubuntu/.bashrc",
			"export DB_HOST=${aws_instance.mongodb_instance.private_ip}",
			"cd app/ && pm2 start app.js",
		]
	}

}

output "nodejs_public_ip" {
	value = aws_instance.nodejs_instance.public_ip
}