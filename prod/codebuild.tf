# code build
resource "aws_codebuild_project" "elkademy" {
  name           = "elkademy-docker-build"
  description    = "elkademy docker build"
  build_timeout  = "30"
  service_role   = aws_iam_role.elkademy-codebuild.arn//from iam-codebuild.tf
  encryption_key = aws_kms_alias.artifact-elkademy.arn

  artifacts { 
    type = "CODEPIPELINE" //our artifact are coming from code pipeline, not from s3
  }

  #cache {
  #  type     = "S3"
  #  location = aws_s3_bucket.codebuild-cache.bucket
  #}

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"//environment we use to do the build
    image           = "aws/codebuild/docker:18.09.0"//the image of aws for execute a build
    type            = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.AWS_REGION
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.elkademy-repo.name//the image repository where we push our image
    }
  }

  source {
    type      = "CODEPIPELINE"//from codepipeline
    buildspec = "buildspec.yml"//here the commands to do the docker build
  }

  #depends_on      = [aws_s3_bucket.codebuild-cache]
}

