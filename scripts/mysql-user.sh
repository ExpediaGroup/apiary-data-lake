#!/bin/bash
MYSQL_OPTIONS="-h $MYSQL_HOST --user=$MYSQL_MASTER_USER --password=$MYSQL_MASTER_PASSWORD"
MYSQL_USER=$(aws secretsmanager get-secret-value --secret-id ${MYSQL_SECRET_ARN}|jq .SecretString -r|jq .username -r)
MYSQL_PASSWORD=$(aws secretsmanager get-secret-value --secret-id ${MYSQL_SECRET_ARN} --region ${AWS_REGION}|jq .SecretString -r|jq .password -r)

echo "GRANT $MYSQL_PERMISSIONS ON $MYSQL_DB.* TO '$MYSQL_USER'@\`%\` IDENTIFIED BY '$MYSQL_PASSWORD';"|mysql $MYSQL_OPTIONS
