locals {
  instance_alias         = "${ var.instance_name == "" ? "apiary" : format("apiary-%s",var.instance_name) }"
  vault_path             = "${ var.vault_path == "" ? format("secret/%s-%s",local.instance_alias,var.aws_region) : var.vault_path }"
  enable_route53_records = "${ var.apiary_domain_name == "" ? "0" : "1" }"
}

data "aws_vpc" "apiary_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "apiary_zone" {
  count  = "${local.enable_route53_records}"
  name   = "${var.apiary_domain_name}"
  vpc_id = "${var.vpc_id}"
}
