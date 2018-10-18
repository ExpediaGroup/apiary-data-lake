/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias         = "${ var.instance_name == "" ? "apiary" : format("apiary-%s",var.instance_name) }"
  enable_route53_records = "${ var.apiary_domain_name == "" ? "0" : "1" }"
  apiary_data_buckets    = "${ formatlist("%s-%s-%s-%s",local.instance_alias,data.aws_caller_identity.current.account_id,var.aws_region,var.apiary_managed_schemas) }"
  gluedb_prefix          = "${ var.instance_name == "" ? "" : "${var.instance_name}_" }"
}

data "aws_caller_identity" "current" {}

data "aws_vpc" "apiary_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "apiary_zone" {
  count  = "${local.enable_route53_records}"
  name   = "${var.apiary_domain_name}"
  vpc_id = "${var.vpc_id}"
}
