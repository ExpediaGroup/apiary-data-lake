/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias                       = "${var.instance_name == "" ? "apiary" : format("apiary-%s", var.instance_name)}"
  enable_route53_records               = "${var.apiary_domain_name == "" ? "0" : "1"}"
  apiary_managed_schema_names_original = ["${data.template_file.schema_names.*.rendered}"]
  apiary_managed_schema_names_replaced = ["${data.template_file.schema_names_replaced.*.rendered}"]
  apiary_data_buckets                  = "${formatlist("%s-%s-%s-%s", local.instance_alias, data.aws_caller_identity.current.account_id, var.aws_region, local.apiary_managed_schema_names_replaced)}"
  gluedb_prefix                        = "${var.instance_name == "" ? "" : "${var.instance_name}_"}"
  cw_arn                               = "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
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

data "template_file" "schema_names" {
  count    = "${length(var.apiary_managed_schemas)}"
  template = "${lookup(var.apiary_managed_schemas[count.index], "schema_name")}"
}

data "template_file" "schema_names_replaced" {
  count    = "${length(var.apiary_managed_schemas)}"
  template = "${replace(lookup(var.apiary_managed_schemas[count.index], "schema_name"), "_", "-")}"
}

data "template_file" "s3_lifecycle_policy_transition_period" {
  count    = "${length(var.apiary_managed_schemas)}"
  template = "${lookup(var.apiary_managed_schemas[count.index], "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period)}"
}

data "template_file" "s3_storage_class" {
  count    = "${length(var.apiary_managed_schemas)}"
  template = "${lookup(var.apiary_managed_schemas[count.index], "s3_storage_class", var.s3_storage_class)}"
}
