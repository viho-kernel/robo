variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "tags" {
  default = {
    Component = "acm"
  }
}

variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}

variable "zone_id" {
    default = "Z0837413U5UCNNDSOD1K"
}

variable "zone_name" {
  default = "opsora.space"
}