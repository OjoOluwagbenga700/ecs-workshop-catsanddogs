# Name of the ECR repository
variable "dogs_repo_name" {
  type        = string
  description = "Dogs repository name"

}

# Name of the ECR repository
variable "cats_repo_name" {
  type        = string
  description = "Cats repository name"

}
# Name of the web ECR repository
variable "web_repo_name" {
  type        = string
  description = "Web ECR repository name"

}



# Name of the ECS cluster
variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"

}

# Name of the ECS service
variable "service_name" {
  type        = string
  description = "UI ECS service name"

}


# Task definition family name
variable "family" {
  type        = string
  description = "Task family name"
}


# CPU units allocated to the ECS task
variable "task_cpu" {
  type        = number
  description = "CPU units for the task"

}

# Memory allocated to the ECS task
variable "task_memory" {
  type        = number
  description = "Memory units for the task"

}

# AWS region where resources will be created
variable "aws_region" {
  type        = string
  description = "AWS region"
}

# CIDR range for the VPC
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
}

# Name tag for the VPC
variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

# Availability zones for VPC subnets
variable "azs" {
  type        = list(string)
  description = "Availability zones for the VPC"
}

# CIDR ranges for public subnets
variable "public_subnets" {
  type        = list(string)
  description = "Public subnets for the VPC"
}

# CIDR ranges for private subnets
variable "private_subnets" {
  type        = list(string)
  description = "Private subnets for the VPC"

}



variable "github_repo" {
  type        = string
  description = "GitHub repository for the source code (format: owner/repo)"
}

variable "github_branch" {
  type        = string
  description = "GitHub branch to use for the source code"
}

variable "codepipeline_bucket_name" {
  description = "Name of the S3 bucket for CodePipeline artifacts"
  type        = string
}

