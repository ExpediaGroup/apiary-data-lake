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
  bucket = aws_s3_bucket.apiary_inventory_bucket[0].bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = local.apiary_s3_logs_bucket
  acl    = "log-delivery-write"
  tags   = merge(map("Name", local.apiary_s3_logs_bucket), var.apiary_tags)

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    enabled = true

    abort_incomplete_multipart_upload_days = var.s3_lifecycle_abort_incomplete_multipart_upload_days

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    expiration {
      days = var.s3_log_expiry
    }
  }
}

resource "aws_s3_bucket_public_access_block" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = local.apiary_s3_hive_logs_bucket
  tags   = merge(map("Name", local.apiary_s3_hive_logs_bucket), var.apiary_tags)
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket" "apiary_system" {
  bucket = local.apiary_system_bucket
  tags   = merge(map("Name", local.apiary_system_bucket), var.apiary_tags)
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}
