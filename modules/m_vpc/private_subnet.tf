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