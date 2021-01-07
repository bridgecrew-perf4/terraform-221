output "mongodb_private_ip" {
    value = aws_instance.mongodb_instance.private_ip
}