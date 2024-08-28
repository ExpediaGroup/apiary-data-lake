/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_s3_bucket" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = local.s3_inventory_bucket
  tags   = merge(tomap({"Name"="${local.s3_inventory_bucket}"}), var.apiary_tags)
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
             "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
          }
       }
    },
%{if length(var.s3_inventory_customer_accounts) > 0}
    {
        "Sid": "S3 inventory customer account permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root", var.s3_inventory_customer_accounts))}" ]
        },
        "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:GetBucketAcl",
            "s3:ListBucket"
        ],
        "Resource": [
            "arn:aws:s3:::${local.s3_inventory_bucket}",
            "arn:aws:s3:::${local.s3_inventory_bucket}/*"
        ]
    },
%{endif}
    {
      "Sid": "DenyUnSecureCommunications",
      "Effect": "Deny",
      "Principal": {"AWS": "*"},
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${local.s3_inventory_bucket}",
        "arn:aws:s3:::${local.s3_inventory_bucket}/*"
        ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
  lifecycle_rule {
    enabled = true

    abort_incomplete_multipart_upload_days = var.s3_lifecycle_abort_incomplete_multipart_upload_days
  }

}

resource "aws_s3_bucket_public_access_block" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = aws_s3_bucket.apiary_inventory_bucket[0].bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = aws_s3_bucket.apiary_inventory_bucket[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = local.apiary_s3_logs_bucket
  acl    = "log-delivery-write"
  tags   = merge(tomap({"Name"=local.apiary_s3_logs_bucket}), var.apiary_tags)
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "DenyUnSecureCommunications",
      "Effect": "Deny",
      "Principal": {"AWS": "*"},
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${local.apiary_s3_logs_bucket}",
        "arn:aws:s3:::${local.apiary_s3_logs_bucket}/*"
        ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
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

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_notification" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket

  queue {
    queue_arn = aws_sqs_queue.apiary_managed_logs_queue[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = local.apiary_s3_hive_logs_bucket
  tags   = merge(tomap({"Name"=local.apiary_s3_hive_logs_bucket}), var.apiary_tags)
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid": "DenyUnSecureCommunications",
      "Effect": "Deny",
      "Principal": {"AWS": "*"},
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${local.apiary_s3_hive_logs_bucket}",
        "arn:aws:s3:::${local.apiary_s3_hive_logs_bucket}/*"
        ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
  acl    = "private"
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
  }
}

resource "aws_s3_bucket_public_access_block" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "apiary_system" {
  bucket = local.apiary_system_bucket
  tags   = merge(tomap({"Name"=local.apiary_system_bucket}), var.apiary_tags)
  policy = <<EOF
{
  "Version":"2012-10-17",
  "Statement":[
%{if length(var.system_schema_customer_accounts) > 0}
    {
        "Sid": "system schema customer account permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root", var.system_schema_customer_accounts))}" ]
        },
        "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:GetBucketAcl",
            "s3:ListBucket"
        ],
        "Resource": [
            "arn:aws:s3:::${local.apiary_system_bucket}",
            "arn:aws:s3:::${local.apiary_system_bucket}/*"
        ]
    },
%{endif}
%{if length(var.system_schema_producer_iamroles) > 0}
    {
        "Sid": "system schema customer account permissions",
        "Effect": "Allow",
        "Principal": {
          "AWS": [ "${join("\",\"", var.system_schema_producer_iamroles)}" ]
        },
        "Action": [
            "s3:GetBucketLocation",
            "s3:GetObject",
            "s3:GetObjectAcl",
            "s3:GetBucketAcl",
            "s3:ListBucket",
            "s3:PutObject",
            "s3:PutObjectAcl",
            "s3:DeleteObject",
            "s3:GetBucketVersioning",
            "s3:PutBucketVersioning",
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ObjectOwnerOverrideToBucketOwner"
        ],
        "Resource": [
            "arn:aws:s3:::${local.apiary_system_bucket}",
            "arn:aws:s3:::${local.apiary_system_bucket}/*"
        ]
    },
%{endif}
    {
      "Sid": "DenyUnSecureCommunications",
      "Effect": "Deny",
      "Principal": {"AWS": "*"},
      "Action": "s3:*",
      "Resource": [
          "arn:aws:s3:::${local.apiary_system_bucket}",
          "arn:aws:s3:::${local.apiary_system_bucket}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    }
  ]
}
EOF
  acl    = "private"
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
  }
}

resource "aws_s3_bucket_public_access_block" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
