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
  "codestar-connection" : "arn:aws:codestar-connections:eu-central-1:886436923743:connection/c7101f23-38dc-45e8-81c2-d53ee3dbfa87",
  "codeconnection" : "arn:aws:codeconnections:eu-central-1:886436923743:connection/c7101f23-38dc-45e8-81c2-d53ee3dbfa87"
}
github_connections_for_policies = [
  "arn:aws:codestar-connections:eu-central-1:886436923743:connection/c7101f23-38dc-45e8-81c2-d53ee3dbfa87",
  "arn:aws:codeconnections:eu-central-1:886436923743:connection/c7101f23-38dc-45e8-81c2-d53ee3dbfa87"
]
github_repo       = "mahmoud-abuelnaga/AWS-CI-Pipeline"
codepipeline_name = "aws-ci-codepipeline"
