

# ECS cluster definition
resource "aws_ecs_cluster" "cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Create CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "ecs_logs" {
  for_each = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  name              = "/ecs/${each.key}"
  retention_in_days = 7
}

# ECS task definitions for Fargate launch type
resource "aws_ecs_task_definition" "task_definitions" {
  for_each = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  family                   = "${each.key}-${var.family}"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  depends_on = [aws_iam_role.ecs_task_execution_role, docker_registry_image.images, aws_cloudwatch_log_group.ecs_logs]

  container_definitions = templatefile("${path.module}/${each.key}_taskdef.tpl", {
    container_name = each.key
    image          = docker_image.images[each.key].name
    log_group_name = aws_cloudwatch_log_group.ecs_logs[each.key].name
    aws_region     = var.aws_region
  })
}

# ECS services running on Fargate
resource "aws_ecs_service" "ecs_services" {
  for_each = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  name                   = "${each.key}-${var.service_name}"
  cluster                = aws_ecs_cluster.cluster.id
  task_definition        = aws_ecs_task_definition.task_definitions[each.key].arn
  desired_count          = 2
  launch_type            = "FARGATE"
  enable_execute_command = true

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  network_configuration {
    subnets          = module.networking.private_subnets
    security_groups  = [aws_security_group.ecs_task_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg[each.key].arn
    container_name   = each.key
    container_port   = 80
  }

  depends_on = [
    aws_lb_target_group.alb_tg,
    aws_security_group.ecs_task_sg,
    aws_ecs_task_definition.task_definitions,
    aws_lb_listener.alb_http_listener
  ]

  health_check_grace_period_seconds = 60

  lifecycle {
    ignore_changes = [
      task_definition,
      load_balancer
    ]
  }

  tags = {
    Name = "${var.service_name}-${each.key}"
  }
}
