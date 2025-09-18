resource "aws_iam_role" "asg_instance_role" {
  name = "asg_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.asg_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "asg_instance_profile" {
  name = "asg_instance_profile"
  role = aws_iam_role.asg_instance_role.name
}

resource "aws_launch_template" "gwangsan-template" {
  name          = "${var.prefix}_template"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.medium"
  user_data     = base64encode(data.template_file.asg-user-data.rendered)
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile {
    name = aws_iam_instance_profile.asg_instance_profile.name
  }
  

  network_interfaces {
    associate_public_ip_address = false
    device_index = 0
    subnet_id = module.vpc.private_subnets[0]
    security_groups = [aws_security_group.app-sg.id]
  }
  

  lifecycle {
    create_before_destroy = false
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.prefix}-app-instance"
    }
  }
}  


resource "aws_autoscaling_group" "gwangsan-asg" {
  name = "${var.prefix}-asg"
  desired_capacity = 1
  max_size = 2
  min_size = 1
  vpc_zone_identifier = module.vpc.private_subnets
  launch_template {
    id = aws_launch_template.gwangsan-template.id
    version = "$Latest"
  }

  target_group_arns = [ aws_lb_target_group.gwangsan-tg.arn ]

  health_check_type = "EC2"
  health_check_grace_period = 300
  force_delete = true

  tag {
    key = "Name"
    value = "${var.prefix}-app"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
    module.vpc, 
    aws_lb_target_group.gwangsan-tg, 
    aws_launch_template.gwangsan-template ]
}
