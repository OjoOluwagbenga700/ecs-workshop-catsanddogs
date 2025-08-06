
# CodeBuild project
resource "aws_codebuild_project" "ecs_build" {
  name          = "ecs-build"
  description   = "Build project for ECS"
  service_role  = aws_iam_role.codebuild_role.arn
  build_timeout = 60

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type            = "LINUX_CONTAINER"
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.aws_region
    }

    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }

    environment_variable {
      name  = "CATS_REPO_NAME"
      value = var.cats_repo_name
    }

    environment_variable {
      name  = "DOGS_REPO_NAME"
      value = var.dogs_repo_name
    }

    environment_variable {
      name  = "WEB_REPO_NAME"
      value = var.web_repo_name
    }

    environment_variable {
      name  = "EXECUTION_ROLE_ARN"
      value = aws_iam_role.ecs_task_execution_role.arn
    }
    environment_variable {
      name  = "TASK_ROLE_ARN"
      value = aws_iam_role.ecs_task_role.arn
    }

    environment_variable {
      name  = "TASK_CPU"
      value = var.task_cpu
    }

    environment_variable {
      name  = "TASK_MEMORY"
      value = var.task_memory
    }

    environment_variable {
      name  = "TASK_FAMILY"
      value = var.family
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}