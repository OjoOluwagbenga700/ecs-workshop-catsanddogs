
# CodeDeploy applications for each service
resource "aws_codedeploy_app" "e_commerce_apps" {
  for_each = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  name             = "e-commerce-app-${each.key}"
  compute_platform = "ECS"
}

# CodeDeploy deployment groups for each service
resource "aws_codedeploy_deployment_group" "e_commerce_deployment_groups" {
  for_each = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  app_name               = aws_codedeploy_app.e_commerce_apps[each.key].name
  deployment_group_name  = "e-commerce-deployment-group-${each.key}"
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.cluster.name
    service_name = aws_ecs_service.ecs_services[each.key].name
  }
}
