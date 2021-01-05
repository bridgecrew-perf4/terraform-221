# # Cloud provider required, in this case using AWS
# resource "aws_instance" "mongodb_instance" {
# 	ami = "ami-03646b6976790491d"
# 	instance_type = "t2.micro"
# 	key_name = "eng74_leo_aws_key"
# 	associate_public_ip_address = true
# 	tags = {
# 		Name = "eng74-leo-terraform-db"
# 	}
# }