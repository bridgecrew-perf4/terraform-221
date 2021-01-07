output "nodejs_sg_id" {
    value = aws_security_group.nodejs_sg.id
}

output "mongodb_sg_id" {
    value = aws_security_group.mongodb_sg.id
}