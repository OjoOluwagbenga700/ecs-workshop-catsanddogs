# Create an Application Load Balancer (ALB) for the e-commerce application
# This ALB is internet-facing (external) and deployed across 2 public subnets
resource "aws_lb" "alb" {
  name                       = "ecs-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_sg.id]
  subnets                    = [module.networking.public_subnets[0], module.networking.public_subnets[1]]
  enable_deletion_protection = false
  depends_on                 = [module.networking, aws_security_group.alb_sg]

  tags = {
    Name = "ecs-alb"
  }
}

# Create target groups for each service (cats, dogs, web)
resource "aws_lb_target_group" "alb_tg" {
  for_each = local.services

  name        = "e-commerce-tg-${each.key}"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id

  health_check {
    enabled             = true
    interval            = local.health_check.interval
    path                = local.health_check.path
    timeout             = local.health_check.timeout
    matcher             = local.health_check.matcher
    healthy_threshold   = local.health_check.healthy_threshold
    unhealthy_threshold = local.health_check.unhealthy_threshold
  }
  depends_on = [aws_lb.alb]
}

# Create blue target groups for blue/green deployment
resource "aws_lb_target_group" "alb_tg_blue" {
  for_each = local.services
  
  name        = "e-commerce-tg-blue-${each.key}"
  target_type = "ip"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.networking.vpc_id

  health_check {
    enabled             = true
    interval            = local.health_check.interval
    path                = local.health_check.path
    timeout             = local.health_check.timeout
    matcher             = local.health_check.matcher
    healthy_threshold   = local.health_check.healthy_threshold
    unhealthy_threshold = local.health_check.unhealthy_threshold
  }
  depends_on = [aws_lb.alb]
}

# Create HTTP listener on port 80 with path-based routing
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg["web"].arn
  }
}

# Create listener rules for path-based routing
resource "aws_lb_listener_rule" "cats_rule" {
  listener_arn = aws_lb_listener.alb_http_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg["cats"].arn
  }

  condition {
    path_pattern {
      values = ["/cats*"]
    }
  }
}

resource "aws_lb_listener_rule" "dogs_rule" {
  listener_arn = aws_lb_listener.alb_http_listener.arn
  priority     = 200

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg["dogs"].arn
  }

  condition {
    path_pattern {
      values = ["/dogs*"]
    }
  }
}