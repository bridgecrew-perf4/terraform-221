# load balancer for app instances
resource "aws_lb" "app_lb" {
    name = "eng74-leo-terra-app_lb"
    internal = false
    load_balancer_type = "network"
    security_groups = [var.nodejs_app_sg_id]
    subnets = var.public_subnet_id


}

# target group

resource "aws_lb_target_group" "app_tg" {
    name = "eng74-leo-terra-app_tg"
    port = 80
    protocol = "TCP"
    vpc_id = var.vpc_id

    target_type = "instance"
}

# listener for port 80

resource "aws_lb_listener" "listener_80" {
    load_balancer_arn = aws_lb.app_lb.arn
    port = "80"
    protocol = "TCP"


}