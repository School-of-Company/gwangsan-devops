resource "aws_iam_role" "ec2_mariadb_role" {
  name = "ec2-basic-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "asg-ssm" {
  role       = aws_iam_role.ec2_mariadb_role.name
  policy_arn = "arn:aws:iam::aws:policy/Amazonasg-SSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_mariadb_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.prefix}-mariadb-profile"
  role = aws_iam_role.ec2_mariadb_role.name
}

resource "aws_instance" "mariadb_ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id = module.vpc.intra_subnets[0]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  user_data = data.template_file.mariadb.rendered

  vpc_security_group_ids = [ 
    aws_security_group.mariadb-sg.id
   ]

   tags = {
     Name = "${var.prefix}-mariadb"
   }

   depends_on = [ module.vpc ]
}

resource "aws_iam_role" "ec2_redis_role" {
  name = "${var.prefix}-basic-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_instance" "redis_ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id = module.vpc.intra_subnets[1]
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.id
  user_data = data.template_file.mariadb.rendered

  vpc_security_group_ids = [ 
    aws_security_group.mariadb-sg.id
   ]

   tags = {
     Name = "${var.prefix}-redis"
   }

   depends_on = [ module.vpc ]
}