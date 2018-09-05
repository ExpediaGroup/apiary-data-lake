#!/bin/sh
MYSQL_OPTIONS="-h $1 --user=$2 --password=$3"

echo "GRANT $4 ON $5.* TO '$6'@\`%\` IDENTIFIED BY '$7';"|mysql $MYSQL_OPTIONS
