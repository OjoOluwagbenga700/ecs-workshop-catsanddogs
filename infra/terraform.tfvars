ecs_cluster_name = "ecs-cluster"
service_name     = "service"
family           = "def"
task_cpu         = 1024
task_memory      = 2048
cats_repo_name   = "cats"
dogs_repo_name   = "dogs"
web_repo_name    = "web"
aws_region       = "us-east-1"
vpc_cidr                 = "10.0.0.0/16"
vpc_name                 = "ecs-vpc"
azs                      = ["us-east-1a", "us-east-1b"]
public_subnets           = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets          = ["10.0.3.0/24", "10.0.4.0/24"]
github_repo              = "your-github-username/ecs-cats-and-dogs"
github_branch            = "main"
codepipeline_bucket_name = "ecs--cicd-artifacts"

