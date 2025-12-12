resource "aws_lb" "web_alb" {
  name               = "${local.name}-${var.tags.Component}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.frontend_alb_sg_id.value]
  subnets            = split(",", data.aws_ssm_parameter.public_subnet_ids.value)

  #enable_deletion_protection = true

  tags = merge(
    var.common_tags,
     {
        Name = "${var.project}-${var.environment}-web-alb"
    }
  )
}

resource "aws_lb_listener" "web" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_ssm_parameter.acm_certificate_arn.value

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is from WEB ALB using HTTPS"
      status_code  = "200"
    }
  }
}

resource "aws_route53_record" "web" {
    zone_id = var.zone_id
    name = "${var.environment}.${var.zone_name}"
    type = "A"
    alias {
    name                   = resource.aws_lb.web_alb.dns_name
    zone_id                = resource.aws_lb.web_alb.zone_id # This is the ZONE ID of ALB
    evaluate_target_health = true
  }
  
}