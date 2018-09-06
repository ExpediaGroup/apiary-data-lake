#!/bin/sh
MYSQL_OPTIONS="-h $MYSQL_HOST --user=$MYSQL_MASTER_USER --password=$MYSQL_MASTER_PASSWORD"
RWUSER="iamrw"
ROUSER="iamro"

echo "CREATE USER $RWUSER IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';"|mysql $MYSQL_OPTIONS
echo "GRANT ALL ON \`%\`.* TO ${RWUSER}@\`%\`;"|mysql $MYSQL_OPTIONS

echo "CREATE USER $ROUSER IDENTIFIED WITH AWSAuthenticationPlugin AS 'RDS';"|mysql $MYSQL_OPTIONS
echo "GRANT SELECT ON \`%\`.* TO ${ROUSER}@\`%\`;"|mysql $MYSQL_OPTIONS
