resource "aws_launch_template" "gwangsan-template" {
  name          = "${var.prefix}_template"
  image_id      = data.aws_ami.amazon-linux-2.id
  instance_type = "t3.small"
  user_data     = base64encode(data.template_file.apache.rendered)
  key_name = aws_key_pair.bastion-key-pair.key_name

  network_interfaces {
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
  desired_capacity = 2
  max_size = 3
  min_size = 2
  vpc_zone_identifier = module.vpc.public_subnets
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