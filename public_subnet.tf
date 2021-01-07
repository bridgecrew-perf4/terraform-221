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
		cidr_block = "${module.myip.address}/32"
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
		cidr_block = "${module.myip.address}/32"
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