# App
resource "aws_elastic_beanstalk_application" "beanstalk_app" {
  name        = "aws-ci-beanstalk-app"
  description = "The application for the aws-ci-beanstalk environment"
}

# Roles
resource "aws_iam_role" "beanstalk_service_role" {
  name = "aws-ci-beanstalk-service-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "elasticbeanstalk.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "beanstalk_service_role_enhanced_health_policy_attachment" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_role_policy_attachment" "beanstalk_service_role_managed_updates_policy_attachment" {
  role       = aws_iam_role.beanstalk_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_role" "beanstalk_ec2_role" {
  name = "aws-ci-beanstalk-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "beanstalk_ec2_role_beanstalk_webtier_policy_attachment" {
  role       = aws_iam_role.beanstalk_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "beanstalk_ec2_instance_profile" {
  name = "aws-ci-beanstalk-ec2-instance-profile"
  role = aws_iam_role.beanstalk_ec2_role.name
}

# Load balancer Security group
resource "aws_security_group" "beanstalk_lb_sg" {
  name        = "aws-ci-beanstalk-lb-sg"
  description = "Security group for beanstalk load balancer"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 80 from beanstalk ec2"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Security group
resource "aws_security_group" "beanstalk_ec2_sg" {
  name        = "aws-ci-beanstalk-ec2-sg"
  description = "Security group for beanstalk ec2"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound traffic on port 80 from beanstalk load balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [
      aws_security_group.beanstalk_lb_sg.id
    ]

  }
}

resource "aws_elastic_beanstalk_environment" "beanstalk_env" {
  name                = "aws-ci-beanstalk-env"
  application         = aws_elastic_beanstalk_application.beanstalk_app.name
  solution_stack_name = "64bit Amazon Linux 2023 v5.7.2 running Tomcat 11 Corretto 21"
  tier                = "WebServer"

  setting {
    namespace = "aws:autoScaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.beanstalk_service_role.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.beanstalk_ec2_instance_profile.name
  }

  # EC2 VPC settings
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = data.aws_vpc.default_vpc.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default_subnets.ids)
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = var.associate_public_ip_to_beanstalk_ec2
  }


  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "LoadBalanced"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "Scheme"
    value     = "internet-facing"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "Subnets"
    value     = join(",", data.aws_subnets.default_subnets.ids)
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "SecurityGroups"
    value     = aws_security_group.beanstalk_lb_sg.id
  }

  # Enable Stickiness for ALB Target Group
  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "TargetGroupStickinessEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "TargetGroupStickinessType"
    value     = "lb_cookie"
  }

  setting {
    namespace = "aws:elbv2:loadbalancer"
    name      = "TargetGroupStickinessDuration"
    value     = "3600"
  }


  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeSize"
    value     = var.root_volume_size
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "RootVolumeType"
    value     = "gp3"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.beanstalk_ec2_sg.id
  }

  # Auto Scaling Group Configuration
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_size
  }

  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_size
  }

  # Deployment policy
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "Rolling"
  }

  # Rolling update (change in configuration as instance type, vpc, etc.)
  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MaxBatchSize"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "MinInstancesInService"
    value     = "1"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "PauseTime"
    value     = "PT5M"
  }

  # Rolling Deployment (change in app version)
  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage" # This enables percentage-based batching
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "30" # 30% of instances per batch
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "cpu-target-tracking"
  autoscaling_group_name = aws_elastic_beanstalk_environment.beanstalk_env.autoscaling_groups[0]
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    target_value = 50.0

    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}

output "aws_elastic_beanstalk_endpoint" {
  value = aws_elastic_beanstalk_environment.beanstalk_env.endpoint_url
}
