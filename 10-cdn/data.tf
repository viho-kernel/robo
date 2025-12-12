data "aws_ssm_parameter" "acm_certificate_arn" {
  name = "/${var.project}/${var.environment}/acm_certificate_arn"
}

data "aws_cloudfront_cache_policy" "cache" {
  name = "Managed-CachingOptimized"
}

data "aws_cloudfront_cache_policy" "no_cache" {
  name = "Managed-CachingDisabled"
}

data "aws_ssm_parameter" "web_alb_dns_name" {
  name  = "/${var.project}/${var.environment}/web_alb_dns_name"

}
