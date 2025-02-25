/**
 * Copyright (C) 2018-2025 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_glue_catalog_database" "apiary_glue_database" {
  for_each = var.create_glue_databases ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  location_uri = "s3://${aws_s3_bucket.apiary_data_bucket[each.key].id}"
  name         = "${local.gluedb_prefix}${each.key}"
  description  = "Managed by Apiary terraform"
}
