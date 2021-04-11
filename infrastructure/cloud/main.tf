terraform {
    required_providers {
      aws = {
          version = ">= 3.0"
          source = "hashicorp/aws"
      }
    }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_lb_target_group" "dashboard" {
    name = "argos-dashboard-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc-id
    health_check {
      path = "/"
    }
}

resource "aws_lb_target_group" "analytics" {
    name = "argos-analytics-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc-id
    health_check {
      path = "/api/analytics-service/health"
    }
}

resource "aws_lb_target_group" "data" {
    name = "argos-data-tg"
    port = 80
    protocol = "HTTP"
    vpc_id = var.vpc-id
    health_check {
      path = "/api/data-service/health"
    }
}

resource "aws_ecs_task_definition" "data_task" {
  family = "vac-data"
  
  container_definitions = jsonencode([
      {
          name = "data-container"
          image = var.data-image,
          cpu = 1
          memory = 256
          portMappings = [
              {
                  containerPort = 8000
              }
          ]
      }

  ])
}

resource "aws_ecs_task_definition" "analytics_task" {
  family = "vac-analytics"

  container_definitions = jsonencode([
      {
          name = "analytics-container"
          image = var.analytics-image,
          cpu = 1
          memory = 256
          portMappings = [
              {
                  containerPort = 8000
              }
          ]
      }

  ])
}

resource "aws_ecs_task_definition" "dashboard_task" {
  family = "vac-dashboard"
  container_definitions = jsonencode([
      {
          name = "dashboard-container"
          image = var.dashboard-image,
          cpu = 1
          memory = 256
          portMappings = [
              {
                  containerPort = 5000
              }
          ]
      }

  ])
}

resource "aws_ecs_service" "dashboard_ecs_service" {
    name = "dashboard-ecs-service"
    cluster = var.ecs-cluster
    task_definition = aws_ecs_task_definition.dashboard_task.arn
    desired_count = 1
    iam_role = aws_iam_role.ecs_role.arn

    load_balancer {
        container_name = "dashboard-container"
        container_port = 5000
        target_group_arn = aws_lb_target_group.dashboard.arn
    }

    depends_on = [
      aws_alb_listener.service_listener
    ]
}

resource "aws_ecs_service" "analytics_ecs_service" {
    name = "analytics-ecs-service"
    cluster = var.ecs-cluster
    task_definition = aws_ecs_task_definition.analytics_task.arn
    desired_count = 1
    iam_role = aws_iam_role.ecs_role.arn

    load_balancer {
        container_name = "analytics-container"
        container_port = 8000
        target_group_arn = aws_lb_target_group.analytics.arn
    }

    depends_on = [
      aws_alb_listener.service_listener
    ]
}

resource "aws_ecs_service" "data_ecs_service" {
    name = "data-ecs-service"
    cluster = var.ecs-cluster
    task_definition = aws_ecs_task_definition.data_task.arn
    desired_count = 1
    iam_role = aws_iam_role.ecs_role.arn

    load_balancer {
        container_name = "data-container"
        container_port = 8000
        target_group_arn = aws_lb_target_group.data.arn
    }

    depends_on = [
      aws_alb_listener.service_listener
    ]
}