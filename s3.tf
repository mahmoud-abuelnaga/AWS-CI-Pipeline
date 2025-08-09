resource "aws_s3_bucket" "codebuild" {
  bucket = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-${var.region}-${var.codepipeline_name}-bucket"
  force_destroy = true
}