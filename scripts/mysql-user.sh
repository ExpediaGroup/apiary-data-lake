#!/bin/sh
MYSQL_OPTIONS="-h $MYSQL_HOST --user=$MYSQL_MASTER_USER --password=$MYSQL_MASTER_PASSWORD"

echo "GRANT $MYSQL_PERMISSIONS ON $MYSQL_DB.* TO '$MYSQL_USER'@\`%\` IDENTIFIED BY '$MYSQL_PASSWORD';"|mysql $MYSQL_OPTIONS
