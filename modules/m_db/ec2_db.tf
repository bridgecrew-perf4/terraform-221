# create mongodb instance and assign newly created security group
resource "aws_instance" "mongodb_instance" {
	ami = var.ami_mongo
	subnet_id = var.private_subnet_id
	instance_type = var.instance_type
	key_name = var.aws_key_name
	associate_public_ip_address = true
	vpc_security_group_ids = [var.mongodb_sg_id]
	tags = {
		Name = "eng74-leo-terraform-db"
	}
}
