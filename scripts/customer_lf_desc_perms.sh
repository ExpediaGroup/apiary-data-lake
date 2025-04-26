#!/bin/bash
# This script grants Lake Formation DESCRIBE permissions on a database to a specified principal account.

[[ -z "${DATABASE_NAME}" ]] && { echo "DATABASE_NAME is not set"; exit 1; }
[[ -z "${PRINCIPAL_ACCOUNT}" ]] && { echo "PRINCIPAL_ACCOUNT is not set"; exit 1; }
[[ -z "${AWS_REGION}" ]] && { echo "REGION is not set"; exit 1; }

# Grant Lake Formation DESCRIBE permissions on the database
aws lakeformation grant-permissions \
    --principal "DataLakePrincipalIdentifier=${PRINCIPAL_ACCOUNT}" \
    --permissions "DESCRIBE" \
    --permissions-with-grant-option "DESCRIBE" \
    --resource "{\"Table\":{\"DatabaseName\":\"${DATABASE_NAME}\",\"TableWildcard\":{}}}" \
    --region "${AWS_REGION}"

echo "DESCRIBE permissions granted to account ${PRINCIPAL_ACCOUNT} on database ${DATABASE_NAME}."