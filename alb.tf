resource "aws_acm_certificate" "certificate_arn" {
  domain_name       = "gwangsan.kro.kr"
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }
}

resource "aws_lb" "gwagnsan-alb" {
  name = "${var.prefix}-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb-sg.id]
  subnets = module.vpc.public_subnets

  tags = {
    Name = "${var.prefix}-alb"
  }

  depends_on = [ module.vpc, aws_lb_target_group.gwangsan-tg ]
}

resource "aws_lb_target_group" "gwangsan-tg" {
  name = "${var.prefix}-tg"
  port = 8080
  protocol = "HTTP"
  vpc_id = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled = true
    healthy_threshold = 2
    interval = 30
    path = "/"
    port = "8080"
    protocol = "HTTP"
    timeout = 5
    unhealthy_threshold = 2
  }

  tags = {
    "Name" = "${var.prefix}-alb-tg"
  }
}

resource "aws_lb_listener" "HTTP" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.gwagnsan-alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.gwagnsan-alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.certificate_arn.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gwangsan-tg.arn
  }
}
