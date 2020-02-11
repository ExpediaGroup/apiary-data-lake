/**
 * Copyright (C) 2020 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_s3_bucket" "apiary_logs_bucket" {
  count  = var.apiary_log_bucket == "" ? 1 : 0
  bucket = "${local.apiary_bucket_prefix}-s3-logs"
  acl    = "log-delivery-write"
  tags   = "${merge(map("Name", "${local.apiary_bucket_prefix}-s3-logs"), "${var.apiary_tags}")}"
}
