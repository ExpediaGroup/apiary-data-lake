/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

##
### Apiary S3 policy template
##

locals {
  bucket_policy_map = {
    for schema in local.schemas_info : schema["schema_name"] => templatefile("${path.module}/templates/apiary-bucket-policy.json", {
      #if apiary_shared_schemas is empty or contains current schema, allow customer accounts to access this bucket.
      customer_principal            = (length(var.apiary_shared_schemas) == 0 || contains(var.apiary_shared_schemas, schema["schema_name"])) && schema["customer_accounts"] != "" ? join("\",\"", formatlist("arn:aws:iam::%s:root", split(",", schema["customer_accounts"]))) : ""
      customer_condition            = var.apiary_customer_condition
      bucket_name                   = schema["data_bucket"]
      encryption                    = schema["encryption"]
      kms_key_arn                   = schema["encryption"] == "aws:kms" ? aws_kms_key.apiary_kms[schema["schema_name"]].arn : ""
      consumer_iamroles             = join("\",\"", var.apiary_consumer_iamroles)
      conditional_consumer_iamroles = join("\",\"", var.apiary_conditional_consumer_iamroles)
      producer_iamroles             = replace(lookup(var.apiary_producer_iamroles, schema["schema_name"], ""), ",", "\",\"")
      deny_iamroles                 = join("\",\"", var.apiary_deny_iamroles)
      deny_iamrole_actions          = join("\",\"", var.apiary_deny_iamrole_actions)
      client_roles                  = replace(lookup(schema, "client_roles", ""), ",", "\",\"")
      governance_iamroles           = join("\",\"", var.apiary_governance_iamroles)
      consumer_prefix_roles         = lookup(var.apiary_consumer_prefix_iamroles, schema["schema_name"], {})
      common_producer_iamroles      = join("\",\"", var.apiary_common_producer_iamroles)
      deny_exception_iamroles       = lookup(schema, "deny_exception_iamroles", "") == "" ? "" : join("\",\"", compact(concat(split(",", schema["deny_exception_iamroles"]), var.apiary_managed_service_iamroles, var.apiary_governance_iamroles)))
    })
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
  request_payer = "BucketOwner"
  policy        = local.bucket_policy_map[each.key]
  tags = merge(tomap({"Name"=each.value["data_bucket"]}),
    var.apiary_tags,
  jsondecode(lookup(each.value, "tags", "{}")))

  logging {
    target_bucket = local.enable_apiary_s3_log_management ? aws_s3_bucket.apiary_managed_logs_bucket[0].id : var.apiary_log_bucket
    target_prefix = "${var.apiary_log_prefix}${each.value["data_bucket"]}/"
  }
}

resource "aws_s3_bucket_versioning" "apiary_data_bucket_versioning" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
    if lookup(schema, "s3_versioning_enabled", "") != ""
  }
  bucket = each.value["data_bucket"]
  versioning_configuration {
    status = lookup(each.value, "s3_versioning_enabled", "Disabled")
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "apiary_data_bucket_versioning_lifecycle" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket = each.value["data_bucket"]
  # Rule for s3 incomplete multipart upload expiration
  rule {
    id     = "expire-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_abort_incomplete_multipart_upload_days
    }
  }
  # Rule for s3 versioning expiration
  rule {
    id     = "expire-noncurrent-versions-days"
    status = lookup(each.value, "s3_versioning_enabled", "") != "" ? "Enabled" : "Disabled"

    noncurrent_version_expiration {
      noncurrent_days = tonumber(lookup(each.value, "s3_versioning_expiration_days", var.s3_versioning_expiration_days))
    }
  }
  # Rule s3 delete marker object expiration
  rule {
    id     = "expire-delete-marker"
    status = lookup(each.value, "s3_versioning_enabled", "") != "" ? "Enabled" : "Disabled"

    expiration {
      expired_object_delete_marker = "true"
    }
  }
  # Rule s3 intelligent tiering transition
  rule {
    id     = "cost_optimization_transition"
    status = each.value["s3_object_expiration_days_num"] == "-1" || each.value["s3_lifecycle_policy_transition_period"] < each.value["s3_object_expiration_days_num"] ? "Enabled" : "Disabled"

    transition {
      days          = each.value["s3_lifecycle_policy_transition_period"]
      storage_class = each.value["s3_storage_class"]
    }
  }
  # Rule s3 object expiration - days cannot be negative
  rule {
    id     = "cost_optimization_expiration"
    status = each.value["s3_object_expiration_days_num"] != "-1" ? "Enabled" : "Disabled"

    expiration {
      days = each.value["s3_object_expiration_days_num"] != "-1" ? each.value["s3_object_expiration_days_num"] : "0"
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

  optional_fields = var.s3_inventory_optional_fields
}

resource "aws_s3_bucket_public_access_block" "apiary_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  bucket = aws_s3_bucket.apiary_data_bucket[each.key].id

  rule {
    object_ownership = "BucketOwnerEnforced"
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
