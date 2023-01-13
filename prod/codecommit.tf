resource "aws_codecommit_repository" "elkademy-frontend" {
  repository_name = "elkademy-frontend"
  description     = "This is the elkademy frontend repository"
}

resource "aws_codecommit_repository" "elkademy-backend" {
  repository_name = "elkademy-backend"
  description     = "This is the elkademy backend repository"
}
