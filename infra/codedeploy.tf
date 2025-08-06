
# CodeDeploy applications for each service
resource "aws_codedeploy_app" "ecs_apps" {
  for_each = local.services

  name             = "ecs-app-${each.key}"
  compute_platform = "ECS"
}

# CodeDeploy deployment groups for each service
resource "aws_codedeploy_deployment_group" "ecs_deployment_groups" {
  for_each = local.services

  app_name               = aws_codedeploy_app.ecs_apps[each.key].name
  deployment_group_name  = "ecs-deployment-group-${each.key}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cluster.name
    service_name = aws_ecs_service.ecs_services[each.key].name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.alb_http_listener.arn]
      }

      target_group {
        name = aws_lb_target_group.alb_tg[each.key].name
      }

      target_group {
        name = aws_lb_target_group.alb_tg_blue[each.key].name
      }
    }
  }
}
