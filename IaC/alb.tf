resource "aws_acm_certificate" "certificate_arn" {
  domain_name       = "gwangsan.io.kr"
  validation_method = "DNS"

  tags = {
    create_before_destroy = true
  }
}

resource "aws_lb" "gwagnsan-alb" {
  name               = "${var.prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = module.vpc.public_subnets

  tags = {
    Name = "${var.prefix}-alb"
  }

  depends_on = [module.vpc]
}

resource "aws_lb_target_group" "spring_tg" {
  name        = "${var.prefix}-spring-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.prefix}-spring-tg"
  }
}

resource "aws_lb_target_group" "nestjs_tg" {
  name        = "${var.prefix}-nestjs-tg"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    path                = "/api/health/check"
    port                = "8081"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.prefix}-nestjs-tg"
  }
}

resource "aws_lb_listener" "HTTP" {
  count = var.enable_http ? 1 : 0

  load_balancer_arn = aws_lb.gwagnsan-alb.arn
  port              = 80
  protocol          = "HTTP"

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
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }
}


resource "aws_lb_listener_rule" "nestjs_health" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/health/check"]
    }
  }
}

resource "aws_lb_listener_rule" "nestjs_chat" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/chat"]
    }
  }
}

resource "aws_lb_listener_rule" "nestjs_socket" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 30

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nestjs_tg.arn
  }

  condition {
    path_pattern {
      values = ["/socket.io/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_chat_subpath" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 40

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/chat/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_api" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 50

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_lb_listener_rule" "spring_default" {
  listener_arn = aws_lb_listener.https[0].arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.spring_tg.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}
