#!/bin/bash
[[ -z $ACCOUNT_ID ]] && exit 1
[[ -z $ROLE_ARN ]] && exit 1

aws glue update-catalog --cli-input-json "$(cat <<EOF
{
  "CatalogId": "${ACCOUNT_ID}",
  "CatalogInput": {
    "Description": "Enabling automatic Glue Stats collection",
    "CatalogProperties": {
      "CustomProperties": {
        "ColumnStatistics.RoleArn": "${ROLE_ARN}",
        "ColumnStatistics.Enabled": "true"
      }
    }
  }
}
EOF
)"
