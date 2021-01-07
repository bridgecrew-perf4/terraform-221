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
		cidr_blocks = ["${module.myip.address}/32"]
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
