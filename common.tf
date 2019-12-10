/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias                       = "${var.instance_name == "" ? "apiary" : format("apiary-%s", var.instance_name)}"
  apiary_bucket_prefix                 = "${local.instance_alias}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  enable_route53_records               = "${var.apiary_domain_name == "" ? "0" : "1"}"
  apiary_managed_schema_names_original = [for schema in var.apiary_managed_schemas : "${schema.schema_name}"]
  apiary_managed_schema_names_replaced = [for schema in var.apiary_managed_schemas : "${replace(schema.schema_name, "_", "-")}"]
  apiary_data_buckets                  = [for schema in var.apiary_managed_schemas : "${local.apiary_bucket_prefix}-${replace(schema.schema_name, "_", "-")}"]
  gluedb_prefix                        = "${var.instance_name == "" ? "" : "${var.instance_name}_"}"
  cw_arn                               = "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
  assume_allowed_principals            = split(",", join(",", [for role in var.apiary_assume_roles : join(",", [for principal in role.principals : replace(principal, "/:role.*/", ":root")])]))
  producer_allowed_principals          = split(",", join(",", values(var.apiary_producer_iamroles)))
  final_atlas_cluster_name             = "${var.atlas_cluster_name == "" ? var.instance_name : var.atlas_cluster_name}"
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "apiary_vpc" {
  id = "${var.vpc_id}"
}

data "aws_route53_zone" "apiary_zone" {
  count  = "${local.enable_route53_records}"
  name   = "${var.apiary_domain_name}"
  vpc_id = "${var.vpc_id}"
}
