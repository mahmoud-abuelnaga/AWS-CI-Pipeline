resource "aws_s3_bucket" "codebuild" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-${var.region}-${var.codepipeline_name}-bucket"
}