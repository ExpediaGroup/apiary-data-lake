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
  arn = aws_s3_bucket.apiary_system.arn

  hybrid_access_enabled = var.lf_hybrid_access_enabled
}


#LF policy allowing cross account access
resource "aws_lakeformation_permissions" "glue_db_prems" {
  count = length(var.lf_customer_accounts)
  for_each = var.disable_glue_db_init ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}
  principal   = var.lf_customer_accounts[count.index]
  permissions = ["DESCRIBE"]

  database {
    name = each.key
  }
}
