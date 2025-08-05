
# Docker provider configuration for ECR authentication
provider "docker" {
  registry_auth {

    # ECR registry address using AWS account ID and region
    address = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    # ECR authentication credentials from token
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password

  }
}

# Create ECR Repositories to store container images
resource "aws_ecr_repository" "repos" {
  for_each = {
    cats = var.cats_repo_name
    dogs = var.dogs_repo_name
    web  = var.web_repo_name
  }

  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}


# Build Docker images from local Dockerfiles
resource "docker_image" "images" {
  for_each = aws_ecr_repository.repos

  name = "${each.value.repository_url}:latest"
  build {
    context    = "${path.module}/src/${each.key}"
    dockerfile = "Dockerfile"
  }
}

# Push built Docker images to ECR repositories
resource "docker_registry_image" "images" {
  for_each = docker_image.images

  name       = each.value.name
  depends_on = [aws_ecr_repository.repos]
}

