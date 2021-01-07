output "nodejs_public_ip" {
	value = aws_instance.nodejs_instance.public_ip
}