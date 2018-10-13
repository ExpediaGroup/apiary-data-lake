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
