resource "aws_iam_role" "elkademy-codepipeline" {
  name = "elkademy-codepipeline"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "elkademy-codepipeline-role-policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
    ]
    resources = [
      aws_s3_bucket.artifact-elkademy.arn,
      "${aws_s3_bucket.artifact-elkademy.arn}/*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/elkademy-codepipeline",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt",
    ]
    resources = [
      aws_kms_key.artifact-elkademy.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codecommit:UploadArchive",
      "codecommit:Get*",
      "codecommit:BatchGet*",
      "codecommit:Describe*",
      "codecommit:BatchDescribe*",
      "codecommit:GitPull",
    ]
    resources = [
      aws_codecommit_repository.elkademy-frontend.arn,
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*",
      "ecs:*",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      aws_iam_role.ecs-task-execution-role.arn,
      aws_iam_role.ecs-elkademy-task-role.arn,
    ]
    condition {
      test     = "StringLike"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "elkademy-codepipeline" {
  name   = "codepipeline-policy"
  role   = aws_iam_role.elkademy-codepipeline.id
  policy = data.aws_iam_policy_document.elkademy-codepipeline-role-policy.json
}


