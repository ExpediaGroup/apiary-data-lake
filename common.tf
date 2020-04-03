/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias                       = "${var.instance_name == "" ? "apiary" : format("apiary-%s", var.instance_name)}"
  apiary_bucket_prefix                 = "${local.instance_alias}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  apiary_assume_role_bucket_prefix     = [for assumerole in var.apiary_assume_roles : "${local.instance_alias}-${data.aws_caller_identity.current.account_id}-${lookup(assumerole, "allow_cross_region_access", false) ? "*" : data.aws_region.current.name}"]
  enable_route53_records               = "${var.apiary_domain_name == "" ? "0" : "1"}"
  #
  # Create a new list of maps with some extra attributes needed later
  #
  schemas_info = [
    for schema in var.apiary_managed_schemas: merge(
      {
        replaced_name : replace(schema["schema_name"], "_", "-"),
        data_bucket   : "${local.apiary_bucket_prefix}-${replace(schema["schema_name"], "_", "-")}"
      },
      schema)
  ]

  #
  # Create some string arrays of commonly-referenced values for things like join()
  #
  apiary_managed_schema_names_original = [for schema in local.schemas_info : schema["schema_name"]]
  apiary_managed_schema_names_replaced = [for schema in local.schemas_info : schema["replaced_name"]]
  apiary_data_buckets                  = [for schema in local.schemas_info : schema["data_bucket"]]

  gluedb_prefix                        = "${var.instance_name == "" ? "" : "${var.instance_name}_"}"
  cw_arn                               = "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
  assume_allowed_principals            = split(",", join(",", [for role in var.apiary_assume_roles : join(",", [for principal in role.principals : replace(principal, "/:role.*/", ":root")])]))
  producer_allowed_principals          = split(",", join(",", values(var.apiary_producer_iamroles)))
  final_atlas_cluster_name             = "${var.atlas_cluster_name == "" ? local.instance_alias : var.atlas_cluster_name}"
  s3_inventory_prefix                  = "EntireBucketDaily"
  s3_inventory_bucket                  = var.s3_enable_inventory ? "${local.apiary_bucket_prefix}-s3-inventory" : ""
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
