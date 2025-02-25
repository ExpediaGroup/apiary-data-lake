/**
 * Copyright (C) 2018-2025 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_lakeformation_resource" "apiary_data_bucket" {
  for_each              = { for bucket in aws_s3_bucket.apiary_data_bucket : bucket.arn => bucket }
  arn                   = bucket
  hybrid_access_enabled = true
}
