/**
 * Copyright (C) 2018-2025 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

locals {
  non_kms_glue_db_names = var.disable_glue_db_init ? [for schema in local.schemas_info : "${local.gluedb_prefix}${schema.schema_name}" if schema.encryption == "AES256"] : []
}

resource "aws_glue_catalog_database" "apiary_glue_database" {
  for_each = var.disable_glue_db_init ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  location_uri = "s3://${aws_s3_bucket.apiary_data_bucket[each.key].id}/"
  name         = "${local.gluedb_prefix}${each.key}"
  description  = "Managed by Apiary terraform"
}

resource "aws_glue_catalog_database" "apiary_system_glue_database" {
  count        = var.disable_glue_db_init ? 1 : 0
  location_uri = "s3://${aws_s3_bucket.apiary_system.id}/"
  name         = "${local.gluedb_prefix}${var.system_schema_name}"
  description  = "Managed by Apiary terraform"
}
