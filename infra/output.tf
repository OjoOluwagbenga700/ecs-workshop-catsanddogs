

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# Output ECR repository URLs
output "ecr_repository_urls" {
  value = {
    for k, v in aws_ecr_repository.repos : k => v.repository_url
  }
}

# Output ECS service names
output "ecs_service_names" {
  value = {
    for k, v in aws_ecs_service.ecs_services : k => v.name
  }
}

# Output CodePipeline names
output "codepipeline_names" {
  value = {
    for k, v in aws_codepipeline.e_commerce_pipelines : k => v.name
  }
}
