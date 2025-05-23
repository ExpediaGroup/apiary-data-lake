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

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_glue_database[each.key].name
  }
}

resource "aws_lakeformation_permissions" "hms_tbl_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["ALL", "DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.key].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "hms_loc_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.apiary_data_bucket[each.key].arn
  }
}


resource "aws_lakeformation_permissions" "hms_system_db_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_system_glue_database[0].name
  }
}

resource "aws_lakeformation_permissions" "hms_system_tbl_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["ALL", "DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_system_glue_database[0].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "hms_sys_loc_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = local.lf_catalog_glue_sync_arn
  permissions = ["DATA_LOCATION_ACCESS"]

  data_location {
    arn = aws_lakeformation_resource.apiary_system_bucket[0].arn
  }
}

locals {
  # Read clients
  catalog_client_schemas = [
    for pair in setproduct(local.schemas_info[*]["schema_name"], var.lf_catalog_client_arns) : {
      schema_name = pair[0]
      client_arn  = pair[1]
    }
  ]
  # Read accounts
  customer_account_schemas = [
    for pair in setproduct(local.schemas_info[*]["schema_name"], var.lf_customer_accounts) : {
      schema_name      = pair[0]
      customer_account = pair[1]
    }
  ]
  # Write producers
  catalog_producer_schemas = [
    for pair in setproduct(local.schemas_info[*]["schema_name"], var.lf_catalog_producer_arns) : {
      schema_name  = pair[0]
      producer_arn = pair[1]
    }
  ]
}

resource "aws_lakeformation_permissions" "catalog_client_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? tomap({
    for schema in local.catalog_client_schemas : "${schema["schema_name"]}-${schema["client_arn"]}" => schema
  }) : {}

  principal   = each.value.client_arn
  permissions = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.value.schema_name].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "catalog_client_system_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? toset(var.lf_catalog_client_arns) : []

  principal   = each.key
  permissions = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_system_glue_database[0].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "customer_account_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? tomap({
    for schema in local.customer_account_schemas : "${schema["schema_name"]}-${schema["customer_account"]}" => schema
  }) : {}

  principal                     = each.value.customer_account
  permissions                   = ["DESCRIBE"]
  permissions_with_grant_option = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.value.schema_name].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "customer_account_system_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? toset(var.lf_customer_accounts) : []

  principal                     = each.key
  permissions                   = ["DESCRIBE"]
  permissions_with_grant_option = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_system_glue_database[0].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "all_principals_tbl_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? {
    for schema in local.schemas_info : "${schema["schema_name"]}" => schema
  } : {}

  principal   = "${data.aws_caller_identity.current.account_id}:IAMPrincipals"
  permissions = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.key].name
    wildcard      = true
  }

}

resource "aws_lakeformation_permissions" "all_principals_system_tbl_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = "${data.aws_caller_identity.current.account_id}:IAMPrincipals"
  permissions = ["DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_system_glue_database[0].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "all_principals_default_tbl_permissions" {
  count = var.disable_glue_db_init && var.create_lf_resource ? 1 : 0

  principal   = "${data.aws_caller_identity.current.account_id}:IAMPrincipals"
  permissions = ["DESCRIBE"]

  table {
    database_name = "default"
    wildcard      = true
  }
}


# Catalog Producer permissions

resource "aws_lakeformation_permissions" "catalog_producer_db_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? tomap({
    for schema in local.catalog_producer_schemas : "${schema["schema_name"]}-${schema["producer_arn"]}" => schema
  }) : {}

  principal   = each.value.producer_arn
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_glue_database[each.value.schema_name].name
  }
}

resource "aws_lakeformation_permissions" "catalog_producer_db_system_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? toset(var.lf_catalog_producer_arns) : []

  principal   = each.key
  permissions = ["DESCRIBE", "CREATE_TABLE"]

  database {
    name = aws_glue_catalog_database.apiary_system_glue_database[0].name
  }
}

resource "aws_lakeformation_permissions" "catalog_producer_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? tomap({
    for schema in local.catalog_producer_schemas : "${schema["schema_name"]}-${schema["producer_arn"]}" => schema
  }) : {}

  principal   = each.value.producer_arn
  permissions = ["ALL", "DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_glue_database[each.value.schema_name].name
    wildcard      = true
  }
}

resource "aws_lakeformation_permissions" "catalog_producer_system_permissions" {
  for_each = var.disable_glue_db_init && var.create_lf_resource ? toset(var.lf_catalog_producer_arns) : []

  principal   = each.key
  permissions = ["ALL", "DESCRIBE"]

  table {
    database_name = aws_glue_catalog_database.apiary_system_glue_database[0].name
    wildcard      = true
  }
}
