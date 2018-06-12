locals {
  instance_alias         = "${ var.instance_name == "" ? "apiary" : format("apiary-%s",var.instance_name) }"
  vault_path             = "${ var.vault_path == "" ? format("secret/%s-%s",local.instance_alias,var.aws_region) : var.vault_path }"
  enable_route53_records = "${ var.apiary_domain_name == "" ? "0" : "1" }"
  apiary_data_buckets           = "${ formatlist("%s-%s-%s-%s",local.instance_alias,data.aws_caller_identity.current.account_id,var.aws_region,var.apiary_managed_schemas) }"
}

data "aws_vpc" "apiary_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "apiary_zone" {
  count  = "${local.enable_route53_records}"
  name   = "${var.apiary_domain_name}"
  vpc_id = "${var.vpc_id}"
}

data "aws_caller_identity" "current" {}
