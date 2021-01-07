
# create nodejs app instance
resource "aws_instance" "nodejs_instance" {
	ami = var.ami_nodejs
	subnet_id = var.public_subnet_id
	instance_type = var.instance_type
	key_name = var.aws_key_name
	associate_public_ip_address = true
	vpc_security_group_ids = [var.nodejs_sg_id]
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
			"echo \"export DB_HOST=${var.mongodb_private_ip}\" >> /home/ubuntu/.bashrc",
			"export DB_HOST=${var.mongodb_private_ip}",
			"cd app/ && pm2 start app.js",
		]
	}

}