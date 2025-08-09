data "aws_iam_policy_document" "codebuild_role_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "aws-ci-codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_role_policy_document.json
}

data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]

    resources = ["arn:aws:ssm:${var.region}:886436923743:parameter/ci/*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "arn:aws:logs:${var.region}:886436923743:log-group:/aws-ci/codebuild/*",
      "arn:aws:logs:${var.region}:886436923743:log-group:/aws-ci/codebuild:*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::codepipeline-${var.region}-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]

    resources = [
      "arn:aws:codebuild:${var.region}:886436923743:report-group/aws-ci-codebuild-*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "codestar-connections:GetConnectionToken",
      "codestar-connections:GetConnection",
      "codeconnections:GetConnectionToken",
      "codeconnections:GetConnection",
      "codeconnections:UseConnection"
    ]

    resources = var.github_connections_for_policies
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role   = aws_iam_role.codebuild_role.name
  policy = data.aws_iam_policy_document.codebuild_policy_document.json
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "aws-ci-codebuild"
  description   = "Codebuild project for aws-ci"
  build_timeout = 10
  service_role  = aws_iam_role.codebuild_role.arn

  source {
    type     = "GITHUB"
    location = var.source_code_url
    git_submodules_config {
      fetch_submodules = true
    }
    
    buildspec = "buildspec.yml"
  }

  source_version = "main"

  artifacts {
    type     = "S3"
    location = var.bucket_name
    path     = "builds/"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:7.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws-ci/codebuild"
      stream_name = "aws-ci-codebuild"
    }
  }
}
