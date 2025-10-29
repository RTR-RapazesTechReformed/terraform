resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id_alb]
  subnets            = var.subnet_ids_publicas

  tags = {
    Name = "app-lb"
  }
}

resource "aws_lb_target_group" "front_targets" {
  name     = "front-targets"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "front_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_targets.arn
  }
}

resource "aws_lb_target_group_attachment" "front_1" {
  target_group_arn = aws_lb_target_group.front_targets.arn
  target_id        = var.front_instance_ids["vm-front-pub-1"]
  port             = 80
}

resource "aws_lb_target_group_attachment" "front_2" {
  target_group_arn = aws_lb_target_group.front_targets.arn
  target_id        = var.front_instance_ids["vm-front-pub-2"]
  port             = 80
}