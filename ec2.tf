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