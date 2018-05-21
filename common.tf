locals {
  instance_alias     = "${ var.instance_name == "" ? "apiary" : format("apiary-%s",var.instance_name) }"
  apiary_domain_name = "${ var.apiary_domain_name == "" ? format("%s-%s.lcl",local.instance_alias,var.aws_region) : var.apiary_domain_name }"
  vault_path = "${ var.vault_path == "" ? format("secret/%s-%s",local.instance_alias,var.aws_region) : var.vault_path }"
}
