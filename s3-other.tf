/**
 * Copyright (C) 2018-2020 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_s3_bucket" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = local.s3_inventory_bucket
  tags   = merge(tomap({ "Name" = "${local.s3_inventory_bucket}" }), var.apiary_tags)
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

resource "aws_s3_bucket_policy" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = aws_s3_bucket.apiary_inventory_bucket[0].bucket
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
}

resource "aws_s3_bucket_lifecycle_configuration" "apiary_inventory_bucket" {
  count  = var.s3_enable_inventory == true ? 1 : 0
  bucket = aws_s3_bucket.apiary_inventory_bucket[0].bucket
  rule {
    id = "cost_optimization_expiration"
    status = "Enabled"
    expiration {
      days = var.s3_inventory_expiration_days
    }
  }
  rule {
    id     = "expire-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_abort_incomplete_multipart_upload_days
    }
  }
  rule {
    id     = "expire-noncurrent-versions-days"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.s3_versioning_expiration_days
    }
  }
}

resource "aws_s3_bucket" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = local.apiary_s3_logs_bucket
  tags   = merge(tomap({ "Name" = local.apiary_s3_logs_bucket }), var.apiary_tags, var.apiary_extra_tags_s3)
}

resource "aws_s3_bucket_policy" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
%{if length(var.s3_logs_customer_accounts) > 0}
      {
          "Sid": "S3LogsReadOnlyAccess",
          "Effect": "Allow",
          "Principal": {
            "AWS": [ "${join("\",\"", formatlist("arn:aws:iam::%s:root", var.s3_logs_customer_accounts))}" ]
          },
          "Action": [
              "s3:List*",
              "s3:Get*"
          ],
          "Resource": [
              "arn:aws:s3:::${local.apiary_s3_logs_bucket}",
              "arn:aws:s3:::${local.apiary_s3_logs_bucket}/*"
          ]
      },
%{endif}
      {
          "Sid": "S3ServerAccessLogsPolicy",
          "Effect": "Allow",
          "Principal": {
              "Service": "logging.s3.amazonaws.com"
          },
          "Action": "s3:PutObject",
          "Resource": "arn:aws:s3:::${local.apiary_s3_logs_bucket}/*",
          "Condition": {
              "StringEquals": {
                  "aws:SourceAccount": "${data.aws_caller_identity.current.account_id}"
              },
              "ArnLike": {
                  "aws:SourceArn": "arn:aws:s3:::${local.apiary_bucket_prefix}-*"
              }
          }
      },
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
}

resource "aws_s3_bucket_public_access_block" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_notification" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket

  queue {
    queue_arn = aws_sqs_queue.apiary_managed_logs_queue[0].arn
    events    = ["s3:ObjectCreated:*"]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "apiary_managed_logs_bucket" {
  count  = local.enable_apiary_s3_log_management ? 1 : 0
  bucket = aws_s3_bucket.apiary_managed_logs_bucket[0].bucket
  rule {
    id = "cost_optimization_expiration"
    status = "Enabled"
    expiration {
      days = var.s3_log_expiry
    }
  }
  rule {
    id     = "expire-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_abort_incomplete_multipart_upload_days
    }
  }
  rule {
    id     = "expire-noncurrent-versions-days"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.s3_versioning_expiration_days
    }
  }
}

resource "aws_s3_bucket" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = local.apiary_s3_hive_logs_bucket
  tags   = merge(tomap({ "Name" = local.apiary_s3_hive_logs_bucket }), var.apiary_tags)
}

resource "aws_s3_bucket_public_access_block" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket
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
}

resource "aws_s3_bucket_lifecycle_configuration" "apiary_access_logs_hive" {
  count  = local.enable_apiary_s3_log_hive ? 1 : 0
  bucket = aws_s3_bucket.apiary_access_logs_hive[0].bucket
  rule {
    id     = "cost_optimization_expiration"
    status = "Enabled"
    expiration {
      days = var.s3_log_expiry
    }
  }
  rule {
    id     = "expire-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_abort_incomplete_multipart_upload_days
    }
  }
  rule {
    id     = "expire-noncurrent-versions-days"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.s3_versioning_expiration_days
    }
  }
}

resource "aws_s3_bucket" "apiary_system" {
  bucket = local.apiary_system_bucket
  tags   = merge(tomap({ "Name" = local.apiary_system_bucket }), var.apiary_tags)
}

resource "aws_s3_bucket_policy" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket
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
        "Sid": "system schema producer account permissions",
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
}

resource "aws_s3_bucket_public_access_block" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "apiary_system" {
  bucket = aws_s3_bucket.apiary_system.bucket
  rule {
    id     = "expire-incomplete-multipart-uploads"
    status = "Enabled"
    abort_incomplete_multipart_upload {
      days_after_initiation = var.s3_lifecycle_abort_incomplete_multipart_upload_days
    }
  }
  rule {
    id     = "expire-noncurrent-versions-days"
    status = "Enabled"
    noncurrent_version_expiration {
      noncurrent_days = var.s3_versioning_expiration_days
    }
  }
  rule {
    id     = "cost_optimization_transition"
    status = "Enabled"
    transition {
      days          = 0
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}
