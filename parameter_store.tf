resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "/ci/database/url"
  type  = "String"
  value = aws_db_instance.rds_instance.endpoint
}

resource "aws_ssm_parameter" "rds_username" {
  name  = "/ci/database/username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "/ci/database/password"
  type  = "String"
  value = var.db_password
}