variable "region" {
  type = string
  default = "eu-central-1"
  description = "The region to deploy the resources in"
}

variable "bucket_name" {
  type = string
  description = "The name of the bucket to create"
}

variable "root_volume_size" {
  type = string
  description = "The size of the root volume"
  default = "10"
}

variable "min_size" {
  type = string
  description = "The minimum number of instances"
}

variable "max_size" {
  type = string
  description = "The maximum number of instances"
}

variable "desired_capacity" {
  type = string
  description = "The desired capacity of the auto scaling group"
}

variable "associate_public_ip_to_beanstalk_ec2" {
  type = string
  description = "Boolean value to associate public IP to beanstalk ec2"
  default = "true"
}

variable "db_storage_size" {
  type = number
  description = "The size of the db storage"
  default = 20
}

variable "db_username" {
  type = string
  description = "The username for the database"
}

variable "db_password" {
  type = string
  description = "The password for the database"
}

variable "source_code_url" {
  type = string
  description = "The url of the source code"
}

variable "github_connections" {
  type = map(string)
  description = "The list of arn of the github connections"
}

variable "github_repo" {
  type = string
  description = "The name of the github repository: username/repo-name"
}

variable "github_branch" {
  type = string
  description = "The name of the github branch"
  default = "main"
}

variable "codepipeline_name" {
  type = string
  description = "The name of the codepipeline"
  default = "aws-ci-codepipeline"
}