#!/bin/sh
DB_NAME=$2
VAULT_PATH=$3
TYPE=$4

MASTER_USER=$(vault read -field=username ${VAULT_PATH}/db_master_user)
MASTER_PASSWORD=$(vault read -field=password ${VAULT_PATH}/db_master_user)

MYSQL_OPTIONS="-h $1 --user=$MASTER_USER --password='$MASTER_PASSWORD'"

if [ $TYPE == "RW" ]
then
  RW_USER=$(vault read -field=username ${VAULT_PATH}/hive_rwuser)
  RW_PASSWORD=$(vault read -field=password ${VAULT_PATH}/hive_rwuser)
  echo "GRANT ALL ON $DB_NAME.* TO '${RW_USER}'@\`%\` IDENTIFIED BY '$RW_PASSWORD';"|mysql $MYSQL_OPTIONS

elif [ $TYPE == "RO" ]
then
  RO_USER=$(vault read -field=username ${VAULT_PATH}/hive_rouser)
  RO_PASSWORD=$(vault read -field=password ${VAULT_PATH}/hive_rouser)
  echo "GRANT SELECT ON $DB_NAME.* TO '${RO_USER}'@\`%\` IDENTIFIED BY '$RO_PASSWORD';"|mysql $MYSQL_OPTIONS

else
   echo "No condition met"
fi
