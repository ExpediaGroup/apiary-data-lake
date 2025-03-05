/**
 * Copyright (C) 2018-2025 Expedia, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_lakeformation_resource" "apiary_data_bucket" {
  for_each = var.create_lf_resource ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}
  arn = aws_s3_bucket.apiary_data_bucket[each.key].arn

  hybrid_access_enabled = var.lf_hybrid_access_enabled
}

resource "aws_lakeformation_resource" "apiary_system_bucket" {
  count = var.create_lf_resource ? 1 : 0
  arn   = aws_s3_bucket.apiary_system.arn

  hybrid_access_enabled = var.lf_hybrid_access_enabled
}

#Add LF permissions for metastore iam role
#required for gluesync to update glue tables when hybrid access is disabled
resource "aws_lakeformation_permissions" "hms_db_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  principal   = aws_iam_role.apiary_hms_readwrite.arn
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_glue_database[each.key].name
  }
}

resource "aws_lakeformation_permissions" "hms_system_db_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = aws_iam_role.apiary_hms_readwrite.arn
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_system_glue_database[0].name
  }
}

locals {
  catalog_client_schemas = [
    for pair in setproduct(local.schemas_info[*]["schema_name"], var.lf_catalog_client_arns) : {
      schema_name = pair[0]
      client_arn  = pair[1]
    }
  ]
}

resource "aws_lakeformation_permissions" "catalog_client_permissions" {
  for_each = var.create_lf_resource ? tomap({
    for schema in local.catalog_client_schemas : "${schema["schema_name"]}-${schema["client_arn"]}" => schema
  }) : {}

  principal   = each.value.client_arn
  permissions = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.value.schema_name].name
    wildcard      = true
  }
}
