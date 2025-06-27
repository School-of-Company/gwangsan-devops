data "template_file" "apache" {
  template = <<-EOF
              #!/bin/bash
              sudo su
              yum update -y
              yum install -y httpd
              sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
              systemctl restart httpd
              systemctl enable httpd
              echo "Hello from ASG" > /var/www/html/index.html
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

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["137112412989"] # 공식 Amazon Linux 소유자 ID

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}