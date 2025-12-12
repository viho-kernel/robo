<<<<<<< HEAD
resource "aws_ssm_parameter" "web_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/web_alb_listener_arn"
=======
resource "aws_ssm_parameter" "frontend_alb_listener_arn" {
  name  = "/${var.project}/${var.environment}/frontend_alb_listener_arn"
>>>>>>> 41070bd (latest commit)
  type  = "String"
  value = aws_lb_listener.web.arn
}

resource "aws_ssm_parameter" "web_alb_dns_name" {
  name  = "/${var.project}/${var.environment}/web_alb_dns_name"
  type  = "String"
  value = aws_lb.web_alb.dns_name
}

