data "template_file" "asg-user-data" {
  template = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx docker
              sudo systyemctl start nginx
              sudo systemctl start docker
              sudo usermod -aG docker ec2-user
              sudo newgrp docker
              sudo vi /etc/nginx/sites-available/default
              sudo systemctl restart nginx
            EOF
}

data "template_file" "mariadb" {
  template = <<-EOF
              #!/bin/bash
              sudo yum update -y 
              sudo yum install -y mariadb105-server
              sudo systemctl start mariadb
              sudo systemctl status mariadb
            EOF
}

data "template_file" "redis" {
  template = <<-EOF
              #!/bin/bash
              sudo yum update -y 
              sudo yum install -y redis
              sudo systemctl start redis
              sudo systemctl status redis
            EOF
  
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) 공식 소유자 ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
