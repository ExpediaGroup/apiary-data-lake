/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

provider "mysql" {
  endpoint = "${aws_rds_cluster.apiary_cluster.endpoint}"
  username = "${aws_rds_cluster.apiary_cluster.master_username}"
  password = "${aws_rds_cluster.apiary_cluster.master_password}"
}

#manage rw,ro username&password
data "vault_generic_secret" "hive_rwuser" {
  path = "${local.vault_path}/hive_rwuser"
}

data "vault_generic_secret" "hive_rouser" {
  path = "${local.vault_path}/hive_rouser"
}

data "vault_generic_secret" "qubole_dbuser" {
  path = "${local.vault_path}/qubole_dbuser"
}

resource "mysql_user" "hiverw" {
  user               = "${data.vault_generic_secret.hive_rwuser.data["username"]}"
  plaintext_password = "${data.vault_generic_secret.hive_rwuser.data["password"]}"
  host               = "%"
}

resource "mysql_user" "hivero" {
  user               = "${data.vault_generic_secret.hive_rouser.data["username"]}"
  plaintext_password = "${data.vault_generic_secret.hive_rouser.data["password"]}"
  host               = "%"
}

resource "mysql_user" "qubole" {
  user               = "${data.vault_generic_secret.qubole_dbuser.data["username"]}"
  plaintext_password = "${data.vault_generic_secret.qubole_dbuser.data["password"]}"
  host               = "%"
}

resource "mysql_grant" "hiverw" {
  user       = "${mysql_user.hiverw.user}"
  host       = "${mysql_user.hiverw.host}"
  database   = "${aws_rds_cluster.apiary_cluster.database_name}"
  privileges = ["ALL"]
}

resource "mysql_grant" "hivero" {
  user       = "${mysql_user.hivero.user}"
  host       = "${mysql_user.hivero.host}"
  database   = "${aws_rds_cluster.apiary_cluster.database_name}"
  privileges = ["SELECT"]
}

resource "mysql_grant" "qubole" {
  user       = "${mysql_user.qubole.user}"
  host       = "${mysql_user.qubole.host}"
  database   = "${aws_rds_cluster.apiary_cluster.database_name}"
  privileges = ["SELECT"]
}
