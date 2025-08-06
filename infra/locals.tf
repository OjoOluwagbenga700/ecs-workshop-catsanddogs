locals {
  # Service definitions
  services = {
    cats = "cats"
    dogs = "dogs"
    web  = "web"
  }

  # Common tags
  common_tags = {
    Project     = "ecs-cats-and-dogs"
    Environment = "production"
    ManagedBy   = "terraform"
  }

  # Health check settings
  health_check = {
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
    path                = "/"
  }
}