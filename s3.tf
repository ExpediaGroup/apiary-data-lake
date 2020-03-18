/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

##
### Apiary S3 policy template
##

data "template_file" "bucket_policy" {
  count    = "${length(local.apiary_data_buckets)}"
  template = "${file("${path.module}/templates/apiary_bucket_policy.json")}"

  vars = {
    #if apiary_shared_schemas is empty or contains current schema, allow customer accounts to access this bucket.
    customer_principal = "${length(var.apiary_shared_schemas) == 0 || contains(var.apiary_shared_schemas, element(concat(local.apiary_managed_schema_names_original, list("")), count.index)) ?
      join("\",\"", formatlist("arn:aws:iam::%s:root", var.apiary_customer_accounts)) :
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"}"

    bucket_name       = "${local.apiary_data_buckets[count.index]}"
    producer_iamroles = "${replace(lookup(var.apiary_producer_iamroles, element(concat(local.apiary_managed_schema_names_original, list("")), count.index), "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"), ",", "\",\"")}"
  }
}

##
### Apiary S3 data buckets
##
resource "aws_s3_bucket" "apiary_data_bucket" {
  count         = "${length(local.apiary_data_buckets)}"
  bucket        = "${element(local.apiary_data_buckets, count.index)}"
  acl           = "private"
  request_payer = "BucketOwner"
  policy        = "${data.template_file.bucket_policy.*.rendered[count.index]}"
  tags          = "${merge(map("Name", "${element(local.apiary_data_buckets, count.index)}"), "${var.apiary_tags}")}"

  logging {
    target_bucket = var.apiary_log_bucket == "" ? aws_s3_bucket.apiary_managed_logs_bucket[0].id : var.apiary_log_bucket
    target_prefix = "${var.apiary_log_prefix}${local.apiary_data_buckets[count.index]}/"
  }

  lifecycle_rule {
    id      = "cost_optimization"
    enabled = true

    transition {
      days          = lookup(var.apiary_managed_schemas[count.index], "s3_lifecycle_policy_transition_period", var.s3_lifecycle_policy_transition_period)
      storage_class = lookup(var.apiary_managed_schemas[count.index], "s3_storage_class", var.s3_storage_class)
    }

    dynamic "expiration" {
    for_each = lookup(var.apiary_managed_schemas[count.index], "s3_bucket_expiry", null) != null ? [var.apiary_managed_schemas[count.index]] : []
    content {
      days = lookup(var.apiary_managed_schemas[count.index], "s3_bucket_expiry", null)
      }
    }
  }
}

resource "aws_s3_bucket_inventory" "apiary_bucket" {
  count  = var.s3_enable_inventory == true ? "${length(local.apiary_data_buckets)}" : 0
  bucket = "${aws_s3_bucket.apiary_data_bucket.*.id[count.index]}"

  name = "EntireBucketDaily"

  included_object_versions = "All"

  schedule {
    frequency = "Daily"
  }

  destination {
    bucket {
      format     = "${var.s3_inventory_format}"
      bucket_arn = "${aws_s3_bucket.apiary_inventory_bucket[0].arn}"
      encryption {
        sse_s3 {}
      }
    }
  }

  optional_fields = ["Size", "LastModifiedDate", "StorageClass", "ETag", "IntelligentTieringAccessTier"]
}

resource "aws_s3_bucket_public_access_block" "apiary_bucket" {
  count  = var.s3_block_public_access == true ? "${length(local.apiary_data_buckets)}" : 0
  bucket = "${aws_s3_bucket.apiary_data_bucket.*.id[count.index]}"

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_notification" "data_events" {
  count  = "${var.enable_data_events == "" ? 0 : length(local.apiary_data_buckets)}"
  bucket = "${aws_s3_bucket.apiary_data_bucket.*.id[count.index]}"

  topic {
    topic_arn = "${aws_sns_topic.apiary_data_events.*.arn[count.index]}"
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_metric" "paid_metrics" {
  count  = "${var.enable_s3_paid_metrics == "" ? 0 : length(local.apiary_data_buckets)}"
  bucket = "${aws_s3_bucket.apiary_data_bucket.*.id[count.index]}"
  name   = "EntireBucket"
}
