####################################
#              vpc id              #
####################################

output "vpc_id" {
  description = "VPC_ID"
  value = module.vpc.vpc_id
}

####################################
#              subnet              #
####################################

output "public_subnets" {
  description = "public subnets id"
  value = module.vpc.public_subnets
}

output "private_subnets" {
  description = "private subnets id"
  value = module.vpc.private_subnets
}

output "protected_subents" {
  description = "intra subents id"
  value = module.vpc.intra_subnets
}

####################################
#      security group              #
####################################
output "bastion-security_groups" {
    description = "bastion for security group"
    value = aws_security_group.bastion-sg.id
}

output "app-security_groups" {
  description = "app for security group"
  value = aws_security_group.app-sg.id
}

output "alb-security_groups" {
  description = "alb for security group"
  value = aws_security_group.alb-sg.id
}

output "mariadb-security_groups" {
  description = "mariadb instance for security group"
  value = aws_security_group.mariadb-sg
}

output "redis-security_groups" {
  description = "redis instance for seucirty group"
  value = aws_security_group.redis-sg
}

####################################
#         bastion eip              #
####################################

output "bastion_eip" {
  description = "Bastion ec2 for eip"
  value = aws_eip.bastion_eip.id
}

####################################
#           target group arn       #
####################################

output "target_group_arn" {
  description = "target group arn"
  value = aws_lb_target_group.gwangsan-tg.arn
}

####################################
#        amazon linux ami id       #
####################################

output "amazon-linux-2" {
  description = "amazon linux ami id"
  value = data.aws_ami.amazon-linux-2.id
}

####################################
#            user data             #
####################################

output "httpd" {
  description = "user data apache"
  value = data.template_file.apache.rendered
}

####################################
#            user data             #
####################################

output "aws_key_pair" {
  description = "key pair"
  value = aws_key_pair.bastion-key-pair.key_name
}