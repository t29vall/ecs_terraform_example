
resource "aws_security_group" "argos_alb_sg" {
  name = "argos_sg"
  description = "Security group for ARGOS"
  vpc_id = var.vpc-id
}

resource "aws_security_group_rule" "argos_ingress_rule" {
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
    security_group_id = aws_security_group.argos_alb_sg.id
}

resource "aws_security_group_rule" "argos_egress_rule" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/24"]
    security_group_id = aws_security_group.argos_alb_sg.id
}

resource "aws_alb" "argos_alb" {
    name = "argos-alb"
    security_groups = [aws_security_group.argos_alb_sg.id]
    subnets = var.alb-subnets
    load_balancer_type = "application"
    internal = true
}

resource "aws_alb_listener" "service_listener" {
    load_balancer_arn = aws_alb.argos_alb.arn
    port = "80"
    protocol = "HTTP"

    default_action {
        type = "forward"
        forward {
          target_group {
              arn = aws_lb_target_group.dashboard.arn
          }

          target_group {
              arn = aws_lb_target_group.analytics.arn
          }

          target_group {
              arn = aws_lb_target_group.data.arn
          }
        }
    }
}

resource "aws_lb_listener_rule" "data_listener_rule" {
    listener_arn = aws_alb_listener.service_listener.arn
    priority = 1
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.data.arn
    }

    condition {
        path_pattern {
            values = ["/api/data-service/*"]
        }
    }
}

resource "aws_lb_listener_rule" "analytics_listener_rule" {
    listener_arn = aws_alb_listener.service_listener.arn
    priority = 2
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.analytics.arn
    }

    condition {
        path_pattern {
            values = ["/api/analytics-service/*"]
        }
    }
}

resource "aws_lb_listener_rule" "dashboard_listener_rule" {
    listener_arn = aws_alb_listener.service_listener.arn
    priority = 3
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.dashboard.arn
    }

    condition {
        path_pattern {
            values = ["*"]
        }
    }
}