/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_s3_bucket" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = local.s3_inventory_bucket
  acl    = "private"
  tags   = "${merge(map("Name", "${local.s3_inventory_bucket}"), "${var.apiary_tags}")}"
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"InventoryAndAnalyticsPolicy",
      "Effect":"Allow",
      "Principal": {"Service": "s3.amazonaws.com"},
      "Action":["s3:PutObject"],
      "Resource":["arn:aws:s3:::${local.s3_inventory_bucket}/*"],
      "Condition": {
          "ArnLike": {
              "aws:SourceArn": "arn:aws:s3:::${local.apiary_bucket_prefix}-*"
           },
         "StringEquals": {
             "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}",
             "s3:x-amz-acl": "bucket-owner-full-control"
          }
       }
    }
  ]
}
EOF
}

resource "aws_s3_bucket_public_access_block" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = local.s3_inventory_bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket" "apiary_managed_logs_bucket" {
  count  = var.apiary_log_bucket == "" ? 1 : 0
  bucket = "${local.apiary_bucket_prefix}-s3-logs"
  acl    = "log-delivery-write"
  tags   = "${merge(map("Name", "${local.apiary_bucket_prefix}-s3-logs"), "${var.apiary_tags}")}"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = var.s3_log_expiry
    }
  }
}
