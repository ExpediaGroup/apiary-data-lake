/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

##
### Apiary S3 policy template
##

data "template_file" "bucket_policy" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  template = file("${path.module}/templates/apiary-bucket-policy.json")

  vars = {
    #if apiary_shared_schemas is empty or contains current schema, allow customer accounts to access this bucket.
    customer_principal = (length(var.apiary_shared_schemas) == 0 || contains(var.apiary_shared_schemas, each.key)) && each.value["customer_accounts"] != "" ? join("\",\"", formatlist("arn:aws:iam::%s:root", split(",", each.value["customer_accounts"]))) : ""

    bucket_name       = each.value["data_bucket"]
    encryption        = each.value["encryption"]
    kms_key_arn       = each.value["encryption"] == "aws:kms" ? aws_kms_key.apiary_kms[each.key].arn : ""
    producer_iamroles = replace(lookup(var.apiary_producer_iamroles, each.key, ""), ",", "\",\"")
    deny_iamroles     = join("\",\"", var.apiary_deny_iamroles)
    client_roles      = replace(lookup(each.value, "client_roles", ""), ",", "\",\"")
  }
}


##
### Apiary S3 data buckets
##
resource "aws_s3_bucket" "apiary_data_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket        = each.value["data_bucket"]
  acl           = "private"
  request_payer = "BucketOwner"
  policy        = data.template_file.bucket_policy[each.key].rendered
  tags = merge(map("Name", each.value["data_bucket"]),
    var.apiary_tags,
  jsondecode(lookup(each.value, "tags", "{}")))

  logging {
    target_bucket = local.enable_apiary_s3_log_management ? aws_s3_bucket.apiary_managed_logs_bucket[0].id : var.apiary_log_bucket
    target_prefix = "${var.apiary_log_prefix}${each.value["data_bucket"]}/"
  }

  lifecycle_rule {
    id      = "cost_optimization"
    enabled = true

    abort_incomplete_multipart_upload_days = var.s3_lifecycle_abort_incomplete_multipart_upload_days

    dynamic "transition" {
      # The following line works with any integer value as the last part of the comparison - I am just using "30" as an example
      # for_each = lookup(each.value, "s3_object_expiration_days", null) == null || lookup(each.value, "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period) < 30 ? [1] : []
      #

      # The following line fails with this terraform error:
      #
      # on .terraform/modules/apiary/s3.tf line 58, in resource "aws_s3_bucket" "apiary_data_bucket":
      # 58:       for_each = lookup(each.value, "s3_object_expiration_days", null) == null || lookup(each.value, "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period) < tonumber(lookup(each.value, "s3_object_expiration_days", 0)) ? [1] : []
      # |----------------
      # | each.value is object with 8 attributes
      # | var.s3_lifecycle_policy_transition_period is "30"
	  #
      # Error during operation: argument must not be null.
      #
      for_each = each.value["s3_object_expiration_days"] == -1 || each.value["s3_lifecycle_policy_transition_period"] < each.value["s3_object_expiration_days"] ? [1] : []

      content {
        days          = each.value["s3_lifecycle_policy_transition_period"]
        storage_class = each.value["s3_storage_class"]
      }
    }

    dynamic "expiration" {
      for_each = each.value["s3_object_expiration_days"] != -1 ? [1] : []
      content {
        days = each.value["s3_object_expiration_days"]
      }
    }
  }
}

resource "aws_s3_bucket_inventory" "apiary_bucket" {
  for_each = var.s3_enable_inventory == true ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  name = local.s3_inventory_prefix

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = var.s3_inventory_format
      bucket_arn = aws_s3_bucket.apiary_inventory_bucket[0].arn
      encryption {
        sse_s3 {}
      }
    }
  }

  optional_fields = ["Size", "LastModifiedDate", "StorageClass", "ETag", "IntelligentTieringAccessTier"]
}

resource "aws_s3_bucket_public_access_block" "apiary_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_notification" "data_events" {
  for_each = var.enable_data_events ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema if lookup(schema, "enable_data_events_sqs", "0") == "0"
  } : {}
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  topic {
    topic_arn = aws_sns_topic.apiary_data_events[each.key].arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_notification" "data_queue_events" {
  for_each = { for schema in local.schemas_info : "${schema["schema_name"]}" => schema if lookup(schema, "enable_data_events_sqs", "0") == "1" }
  bucket   = aws_s3_bucket.apiary_data_bucket[each.key].id

  queue {
    queue_arn = aws_sqs_queue.apiary_data_event_queue[0].arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}


resource "aws_s3_bucket_metric" "paid_metrics" {
  for_each = var.enable_s3_paid_metrics ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id
  name   = "EntireBucket"
}
