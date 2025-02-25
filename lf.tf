/**
 * Copyright (C) 2018-2025 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_lakeformation_resource" "apiary_data_bucket" {
  for_each = {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  }
  arn = aws_s3_bucket.apiary_data_bucket[each.key].arn

  hybrid_access_enabled = true
}
