/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  instance_alias                   = var.instance_name == "" ? "apiary" : format("apiary-%s", var.instance_name)
  apiary_bucket_prefix             = "${local.instance_alias}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}"
  apiary_assume_role_bucket_prefix = [for assumerole in var.apiary_assume_roles : "${local.instance_alias}-${data.aws_caller_identity.current.account_id}-${lookup(assumerole, "allow_cross_region_access", false) ? "*" : data.aws_region.current.name}"]
  enable_route53_records           = var.apiary_domain_name == "" ? false : true
  #
  # Create a new list of maps with some extra attributes needed later
  #
  schemas_info = [
    for schema in var.apiary_managed_schemas : merge(
      {
        encryption : lookup(schema, "encryption", "AES256"),
        resource_suffix : replace(schema["schema_name"], "_", "-"),
        data_bucket : "${local.apiary_bucket_prefix}-${replace(schema["schema_name"], "_", "-")}"
        customer_accounts : lookup(schema, "customer_accounts", join(",", var.apiary_customer_accounts))
        s3_lifecycle_policy_transition_period: lookup(schema, "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period)
        s3_object_expiration_days: lookup(schema, "s3_object_expiration_days", -1)
        s3_storage_class = lookup(schema, "s3_storage_class", var.s3_storage_class)
      },
    schema)
  ]

  gluedb_prefix                   = var.instance_name == "" ? "" : "${var.instance_name}_"
  cw_arn                          = "arn:aws:swf:${var.aws_region}:${data.aws_caller_identity.current.account_id}:action/actions/AWS_EC2.InstanceId.Reboot/1.0"
  assume_allowed_principals       = split(",", join(",", [for role in var.apiary_assume_roles : join(",", [for principal in role.principals : replace(principal, "/:role.*/", ":root")])]))
  producer_allowed_principals     = split(",", join(",", values(var.apiary_producer_iamroles)))
  final_atlas_cluster_name        = var.atlas_cluster_name == "" ? local.instance_alias : var.atlas_cluster_name
  s3_inventory_prefix             = "EntireBucketDaily"
  s3_inventory_bucket             = var.s3_enable_inventory ? "${local.apiary_bucket_prefix}-s3-inventory" : ""
  create_sqs_data_event_queue     = contains([for schema in local.schemas_info : lookup(schema, "enable_data_events_sqs", "0")], "1") ? true : false
  enable_apiary_s3_log_management = var.apiary_log_bucket == "" ? true : false
  enable_apiary_s3_log_hive       = var.apiary_log_bucket == "" && var.enable_apiary_s3_log_hive ? true : false
  apiary_s3_logs_bucket           = local.enable_apiary_s3_log_management ? "${local.apiary_bucket_prefix}-s3-logs" : ""
  apiary_s3_hive_logs_bucket      = local.enable_apiary_s3_log_management ? "${local.apiary_s3_logs_bucket}-hive" : ""
  apiary_system_bucket            = "${local.apiary_bucket_prefix}-${replace(var.system_schema_name, "_", "-")}"

  hms_ro_heapsize   = ceil((var.hms_ro_heapsize * 85) / 100)
  hms_ro_minthreads = max(25, ceil((var.hms_ro_heapsize * 12.5) / 100))
  hms_ro_maxthreads = max(100, ceil((var.hms_ro_heapsize * 50) / 100))

  hms_rw_heapsize   = ceil((var.hms_rw_heapsize * 85) / 100)
  hms_rw_minthreads = max(25, ceil((var.hms_rw_heapsize * 12.5) / 100))
  hms_rw_maxthreads = max(100, ceil((var.hms_rw_heapsize * 50) / 100))

  hms_alias = var.instance_name == "" ? "hms" : "hms-${var.instance_name}"
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "apiary_vpc" {
  id = var.vpc_id
}

data "aws_route53_zone" "apiary_zone" {
  count  = local.enable_route53_records ? 1 : 0
  name   = var.apiary_domain_name
  vpc_id = var.vpc_id
}
