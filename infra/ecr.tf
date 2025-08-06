
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