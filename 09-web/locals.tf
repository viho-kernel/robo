locals {
  name           = "${var.project}-${var.environment}"
  current_time = formatdate("YYYY-MM-DD-hh-mm", timestamp())

}