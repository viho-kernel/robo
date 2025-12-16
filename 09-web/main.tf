resource "aws_lb_target_group" "web" {
  name     = "${local.name}-${var.tags.Component}"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_ssm_parameter.vpc_id.value
  deregistration_delay = 60
  health_check {
    healthy_threshold = 2
    interval = 10
    matcher = "200-299"
    path = "/health"
    port = 80
    timeout = 5
    unhealthy_threshold = 3
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.RHEL.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_sg_id.value]
  subnet_id = element(split(",", data.aws_ssm_parameter.private_subnet_ids.value), 0)
  #iam_instance_profile = "EC2RoleToFetchSSMParams"
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project}-${var.environment}-web"
    }
  )
}

resource "terraform_data" "web" {
  triggers_replace = [
    aws_instance.web.id
  ]
  
  provisioner "file" {
    source      = "web.sh"
    destination = "/tmp/web.sh"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.web.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/web.sh",
      "sudo sh /tmp/web.sh web dev"
    ]
  }
}

resource "aws_ec2_instance_state" "web" {
  instance_id = aws_instance.web.id
  state       = "stopped"
  depends_on = [terraform_data.web]
}

resource "aws_ami_from_instance" "web" {
  name = "${local.name}-${var.tags.Component}-${local.current_time}"
  source_instance_id = aws_instance.web.id
  depends_on = [aws_ec2_instance_state.web]
}

resource "terraform_data" "web_delete" {
  triggers_replace = [
    aws_instance.web.id
  ]
  
  # make sure you have aws configure in your laptop
  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.web.id}"
  }

  depends_on = [aws_ami_from_instance.web]
}

resource "aws_launch_template" "web" {
  name = "${var.project}-${var.environment}-web"

  image_id = aws_ami_from_instance.web.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type = "t3.medium"
  vpc_security_group_ids = [data.aws_ssm_parameter.frontend_alb_sg_id.value]
  update_default_version = true # each time you update, new version will become default
  tag_specifications {
    resource_type = "instance"
    # EC2 tags created by ASG
    tags = merge(
      var.common_tags,
      {
        Name = "${var.project}-${var.environment}-web"
      }
    )
  }

  # volume tags created by ASG
  tag_specifications {
    resource_type = "volume"

    tags = merge(
      var.common_tags,
      {
        Name = "${var.project}-${var.environment}-web"
      }
    )
  }

  # launch template tags
  tags = merge(
      var.common_tags,
      {
        Name = "${var.project}-${var.environment}-web"
      }
  )

}

resource "aws_autoscaling_group" "web" {
  name                 = "${var.project}-${var.environment}-web"
  desired_capacity   = 2
  max_size           = 10
  min_size           = 1
  target_group_arns = [aws_lb_target_group.web.arn]
  vpc_zone_identifier  = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
  health_check_grace_period = 60
  health_check_type         = "ELB"

  launch_template {
    id      = aws_launch_template.web.id
    version = aws_launch_template.web.latest_version
  }

  dynamic "tag" {
    for_each = merge(
      var.common_tags,
      {
        Name = "${var.project}-${var.environment}-web"
      }
    )
    content{
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
    
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }
  tag {
    key                 = "Name"
    value               = "${local.name}-${var.tags.Component}"
    propagate_at_launch = true
  }

  timeouts{
    delete = "15m"
  }
}

resource "aws_lb_listener_rule" "web" {
  listener_arn = data.aws_ssm_parameter.frontend_alb_listener_arn.value

  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web.arn
  }

  condition {
    host_header {
      values = ["${var.tags.Component}.backend-${var.environment}.${var.zone_name}"]
    }
  }
}

resource "aws_autoscaling_policy" "web" {
  name                   = "${var.project}-${var.environment}-web"
  autoscaling_group_name = aws_autoscaling_group.web.name
  policy_type            = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 5.0
  }
}