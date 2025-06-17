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
  datadog_tags                     = join(" ", formatlist("%s:%s", keys(var.apiary_tags), values(var.apiary_tags)))
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
        s3_lifecycle_policy_transition_period : lookup(schema, "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period)
        # Need to change the default "null" value of s3_object_expiration_days to a number so we can compare it
        # later to s3_lifecycle_policy_transition_period without getting a TF error.  However, TF is doing weird things
        # when comparing them as actual "number" type (-1), so use a string type ("-1"), which works as expected.
        s3_object_expiration_days_num : coalesce(lookup(schema, "s3_object_expiration_days", "-1"), "-1")
        s3_storage_class = lookup(schema, "s3_storage_class", var.s3_storage_class)
      },
    schema)
  ]
  schemas_info_map = { for schema in local.schemas_info : "${schema["schema_name"]}" => schema }

  gluedb_prefix                   = var.disable_gluedb_prefix ? "" : var.instance_name == "" ? "" : "${var.instance_name}_"
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

  k8s_ro_cpu       = var.hms_ro_cpu / 1024
  k8s_ro_cpu_limit = (var.hms_ro_cpu / 1024) * 1.25

  k8s_rw_cpu       = var.hms_rw_cpu / 1024
  k8s_rw_cpu_limit = (var.hms_rw_cpu / 1024) * 1.25

  hms_alias = var.instance_name == "" ? "hms" : "hms-${var.instance_name}"

  ro_ingress_cidr            = var.ingress_cidr
  rw_ingress_cidr            = length(var.rw_ingress_cidr) == 0 ? var.ingress_cidr : var.rw_ingress_cidr

  // datadog metrics readwrite instance
  hms_metrics_readwrite = flatten([
    for m in var.datadog_metrics_hms_readwrite : 
      m.rename != null ? [{ (m.name) = m.rename }] : [m.name]
  ])

  hms_metrics_type_overrides_readwrite = {
    for m in var.datadog_metrics_hms_readwrite :
    (m.rename != null ? m.rename : m.name) => m.type
    if m.type != null
  }

  // datadog metrics readonly instance
  hms_metrics_readonly = flatten([
    for m in var.datadog_metrics_hms_readonly : 
      m.rename != null ? [{ (m.name) = m.rename }] : [m.name]
  ])

  hms_metrics_type_overrides_readonly = {
    for m in var.datadog_metrics_hms_readonly :
    (m.rename != null ? m.rename : m.name) => m.type
    if m.type != null
  }

  // datadog metrics housekeeper instance

  hms_metrics_housekeeper = flatten([
    for m in var.datadog_metrics_hms_housekeeper : 
      m.rename != null ? [{ (m.name) = m.rename }] : [m.name]
  ])

  hms_metrics_type_overrides_housekeeper = {
    for m in var.datadog_metrics_hms_housekeeper :
    (m.rename != null ? m.rename : m.name) => m.type
    if m.type != null
  }

  s3_log_buckets = compact(concat(["${local.apiary_s3_logs_bucket}"], var.additional_s3_log_buckets))

  lf_catalog_glue_sync_arn = var.lf_catalog_glue_sync_arn != "" ? var.lf_catalog_glue_sync_arn : aws_iam_role.apiary_hms_readwrite.arn
}

data "aws_iam_account_alias" "current" {}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "apiary_vpc" {
  id = var.vpc_id
}

data "aws_route53_zone" "apiary_zone" {
  count        = local.enable_route53_records ? 1 : 0
  name         = var.apiary_domain_name
  private_zone = var.apiary_domain_private_zone
}

data "aws_secretsmanager_secret" "datadog_key" {
  count = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  name  = var.datadog_key_secret_name
}

data "aws_secretsmanager_secret_version" "datadog_key" {
  count     = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  secret_id = data.aws_secretsmanager_secret.datadog_key[0].id
}

data "external" "datadog_key" {
  count   = length(var.datadog_key_secret_name) > 0 ? 1 : 0
  program = ["echo", "${data.aws_secretsmanager_secret_version.datadog_key[0].secret_string}"]
}

provider "datadog" {
  api_key = chomp(data.external.datadog_key[0].result["api_key"])
  app_key = chomp(data.external.datadog_key[0].result["app_key"])
}
