## application load balancer security group
resource "aws_security_group" "alb-sg" {   
  name        = "${var.prefix}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  depends_on = [ module.vpc ]
}

## bastion ec2 security group
resource "aws_security_group" "bastion-sg" {
  name        = "${var.prefix}_bastion-sg"
  description = "Security group for bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
  }

  depends_on = [ module.vpc ]
}

## app ec2 security group
resource "aws_security_group" "app-sg" {
  name        = "${var.prefix}-app-sg"
  description = "Security group for application"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1" # All protocols
    security_groups = [ aws_security_group.alb-sg.id ]
    description      = "Allow all traffic from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    "Name" = "${var.prefix}_app-sg"
  }

  depends_on = [ module.vpc ]
}


## mariadb instance
resource "aws_security_group" "mariadb-sg" {
  name        = "${var.prefix}_mariadb-sg"
  description = "${var.prefix}-mariadb security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [ aws_security_group.app-sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  depends_on = [ module.vpc ]
}

## redis instance security group
resource "aws_security_group" "redis-sg" {
  name        = "${var.prefix}_redis-sg"
  description = "gwangsan redis security group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "tcp"
    security_groups = [ aws_security_group.app-sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  depends_on = [ module.vpc ]
}
