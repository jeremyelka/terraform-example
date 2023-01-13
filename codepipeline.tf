#
# codepipeline - demo
#
resource "aws_codepipeline" "front" {
  name     = "front-docker-pipeline"
  role_arn = aws_iam_role.elkademy-codepipeline.arn//from file iam-codepipeline.tf

  artifact_store {//artifact is for store information and history
    location = aws_s3_bucket.artifact-elkademy.bucket
    type     = "S3"
    encryption_key {
      id   = aws_kms_alias.artifact-elkademy.arn
      type = "KMS"//encryption of type kms(key managment service)
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"//our code is on codecommit
      version          = "1"//version start from one
      output_artifacts = ["front-docker-source"]//save in s3

      configuration = {
        RepositoryName = aws_codecommit_repository.elkademy-frontend.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["front-docker-source"]
      output_artifacts = ["front-docker-build"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.elkademy.name//from codebuild.tf,run buildspec.yml file
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["front-docker-build"]//our input well be the output of the build stage
      version         = "1"

      configuration = {
        //from codedeploy.tf
        ApplicationName                = aws_codedeploy_app.elkademy.name
        DeploymentGroupName            = aws_codedeploy_deployment_group.elkademy.deployment_group_name
        TaskDefinitionTemplateArtifact = "front-docker-build" //where is the taskdefinition file,its a zip file
        AppSpecTemplateArtifact        = "front-docker-build"//where is the return of appspec.yaml file
      }
    }
  }
}


