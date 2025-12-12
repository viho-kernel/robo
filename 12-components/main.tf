module "user" {
    for_each = var.components
    source = "git::https://github.com/viho-kernel/roboshop-app-dev.git?ref=main"
    component = each.key
    rule_priority = each.value.rule_priority
}