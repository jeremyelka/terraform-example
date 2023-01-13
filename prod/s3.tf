#
# cache s3 bucket
#
resource "aws_s3_bucket" "codebuild-cache" {
  bucket = "elkademy-codebuild-cache-${random_string.random.result}"
}

resource "aws_s3_bucket" "artifact-elkademy" {
  bucket = "artifact-elkademy-${random_string.random.result}"
  
  # lifecycle moved to aws_s3_bucket_lifecycle_configuration (Change starting from AWS Provider 4.x)
}

resource "aws_s3_bucket" "FilesOfElkademyDev" {
  bucket = "files-elkademy-dev"
  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket" "FilesOfElkademyProd" {
  bucket = "files-elkademy-prod"
  tags = {
    Name        = "My bucket"
    Environment = "Prod"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact-elkademy-lifecycle" {
  bucket = aws_s3_bucket.artifact-elkademy.id

  rule {
    id     = "clean-up"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}


resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

