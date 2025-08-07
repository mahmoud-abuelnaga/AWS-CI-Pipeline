resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/aws-ci/database/url"
  type  = "String"
  value = aws_db_instance.rds_instance.endpoint
}

resource "aws_ssm_parameter" "rds_username" {
  name  = "/aws-ci/database/username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "/aws-ci/database/password"
  type  = "String"
  value = var.db_password
}