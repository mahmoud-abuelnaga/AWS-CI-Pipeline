resource "aws_security_group" "rds_sg" {
  name        = "aws-ci-rds-sg"
  description = "Security group for RDS"
  vpc_id      = data.aws_vpc.default_vpc.id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "Allow inbound traffic on port 3306 from beanstalk ec2"
  #   from_port   = 3306
  #   to_port     = 3306
  #   protocol    = "tcp"
  #   security_groups = [
  #     aws_security_group.beanstalk_ec2_sg.id
  #   ]

  # }

  ingress {
    description = "Allow inbound traffic on port 3306 from beanstalk ec2"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [
      data.aws_security_group.beanstalk_ec2_sg.id
    ]

  }
}

resource "aws_db_instance" "rds_instance" {
  identifier             = "aws-ci-rds-instance"
  engine                 = "mysql"
  engine_version         = "8.4.6"
  instance_class         = "db.t3.micro"
  allocated_storage      = var.db_storage_size
  storage_type           = "gp3"
  db_name                = "awscirdsdb"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
}

output "rds_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
