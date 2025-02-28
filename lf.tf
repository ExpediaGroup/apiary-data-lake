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

locals {
  lf_schema_customer_accounts = [
    for pair in setproduct(local.schemas_info[*]["schema_name"], var.lf_customer_accounts) : {
      schema_name = pair[0].key
      account_id  = pair[1].key
    }
  ]
}

#LF policy allowing cross account access
resource "aws_lakeformation_permissions" "glue_db_prems" {
  for_each = var.disable_glue_db_init ? tomap({
    for schema_account in local.lf_schema_customer_accounts : "${schema_account.schema_name}.${schema_account.account_id}" => schema_account
  }) : {}
  principal   = each.value.account_id
  permissions = ["DESCRIBE"]

  database {
    name = each.value.schema_name
  }
}
