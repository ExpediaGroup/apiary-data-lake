/**
 * Copyright (C) 2020 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

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
