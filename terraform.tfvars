bucket_name                          = "aws-ci-new-bucket"
root_volume_size                     = "10"
min_size                             = "1"
max_size                             = "4"
desired_capacity                     = "2"
associate_public_ip_to_beanstalk_ec2 = "true"
region                               = "eu-central-1"
db_storage_size                      = 20
source_code_url                      = "https://github.com/mahmoud-abuelnaga/AWS-CI-Pipeline"
github_connections = {
  "codestar-connection" : "arn:aws:codestar-connections:us-east-1:886436923743:connection/bf84a9fd-84cb-4621-9b4c-7b462cfd71ae",
  "codeconnection" : "arn:aws:codeconnections:us-east-1:886436923743:connection/bf84a9fd-84cb-4621-9b4c-7b462cfd71ae"
}
github_repo = "mahmoud-abuelnaga/AWS-CI-Pipeline"
codepipeline_name = "aws-ci-codepipeline"