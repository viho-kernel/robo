data "aws_ami" "RHEL" {
  owners           = ["973714476881"]
  most_recent      = true

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name  = "/${var.project}/${var.environment}/vpc_id"

}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${var.project}/${var.environment}/public_subnet_ids"
}

data "aws_ssm_parameter" "frontend_alb_sg_id" {
  name = "/${var.project}/${var.environment}/frontend_alb_sg_id"
}

data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/${var.project}/${var.environment}/acm_certificate_arn"
}


data "aws_ssm_parameter" "private_subnet_ids" {
    name = "/${var.project}/${var.environment}/private_subnet_ids"
  
}

data "aws_ssm_parameter" "frontend_sg_id" {
  name  = "/${var.project}/${var.environment}/frontend_sg_id"
}

<<<<<<< HEAD
data "aws_ssm_parameter" "web_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/web_alb_listener_arn"
=======
data "aws_ssm_parameter" "frontend_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/frontend_alb_listener_arn"
>>>>>>> 41070bd (latest commit)
}