/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

data "aws_secretsmanager_secret" "db_rw_user" {
  name = "${ var.db_rw_secret_name == "" ? format("%s-db-rw-user",local.instance_alias): var.db_rw_secret_name }"
}

data "aws_secretsmanager_secret" "db_ro_user" {
  name = "${ var.db_ro_secret_name == "" ? format("%s-db-ro-user",local.instance_alias): var.db_ro_secret_name }"
}

data "aws_secretsmanager_secret_version" "db_rw_user" {
  secret_id     = "${data.aws_secretsmanager_secret.db_rw_user.id}"
}

data "aws_secretsmanager_secret_version" "db_ro_user" {
  secret_id     = "${data.aws_secretsmanager_secret.db_ro_user.id}"
}

data "aws_secretsmanager_secret" "ldap_user" {
  count = "${ var.ldap_url == "" ? 0 : 1 }"
  name = "${ var.ldap_secret_name == "" ? format("%s-ldap-user",local.instance_alias): var.ldap_secret_name }"
}

data "aws_secretsmanager_secret_version" "ldap_user" {
  count = "${ var.ldap_url == "" ? 0 : 1 }"
  secret_id     = "${data.aws_secretsmanager_secret.ldap_user.id}"
}

data "aws_secretsmanager_secret" "ranger_audit" {
  count = "${ var.ranger_audit_db_url == "" ? 0 : 1 }"
  name = "${ var.ranger_audit_secret_name == "" ? format("%s-ranger-audit",local.instance_alias): var.ranger_audit_secret_name }"
}

data "aws_secretsmanager_secret_version" "ranger_audit" {
  count = "${ var.ranger_audit_db_url == "" ? 0 : 1 }"
  secret_id     = "${data.aws_secretsmanager_secret.ranger_audit.id}"
}
