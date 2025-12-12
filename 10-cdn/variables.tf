variable "common_tags" {
  default = {
    Project     = "roboshop"
    Environment = "dev"
    Terraform   = "true"
  }
}

variable "tags" {
  default = {
    Component = "cdn"
  }
}

variable "project" {
  default = "roboshop"
}
variable "environment" {
  default = "dev"
}

variable "zone_name" {
  default = "opsora.space"
<<<<<<< HEAD
=======
}

variable "zone_id" {
    default = "Z0837413U5UCNNDSOD1K"
>>>>>>> 41070bd (latest commit)
}