/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_db_subnet_group" "apiarydbsg" {
  count       = "${ var.external_database_host == "" ? 1 : 0 }"
  name        = "${local.instance_alias}-dbsg"
  subnet_ids  = ["${var.private_subnets}"]
  description = "Apiary DB Subnet Group"

  tags = "${merge(map("Name","Apiary DB Subnet Group"),var.apiary_tags)}"
}

resource "aws_security_group" "db_sg" {
  count  = "${ var.external_database_host == "" ? 1 : 0 }"
  name   = "${local.instance_alias}-db"
  vpc_id = "${var.vpc_id}"
  tags   = "${var.apiary_tags}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${data.aws_vpc.apiary_vpc.cidr_block}"]
    self        = true
  }

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = "${var.ingress_cidr}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
}

resource "random_id" "snapshot_id" {
  count       = "${ var.external_database_host == "" ? 1 : 0 }"
  byte_length = 8
}

resource "random_string" "db_master_password" {
  count = "${ var.external_database_host == "" ? 1 : 0 }"
  length  = 16
  special = false
}

resource "aws_rds_cluster" "apiary_cluster" {
  count                               = "${ var.external_database_host == "" ? 1 : 0 }"
  cluster_identifier                  = "${local.instance_alias}-cluster"
  database_name                       = "${var.apiary_database_name}"
  master_username                     = "${var.db_master_username}"
  master_password                     = "${random_string.db_master_password.result}"
  backup_retention_period             = "${var.db_backup_retention}"
  preferred_backup_window             = "${var.db_backup_window}"
  preferred_maintenance_window        = "${var.db_maintenance_window}"
  db_subnet_group_name                = "${aws_db_subnet_group.apiarydbsg.name}"
  vpc_security_group_ids              = ["${compact(concat(list(aws_security_group.db_sg.id), var.apiary_rds_additional_sg))}"]
  tags                                = "${var.apiary_tags}"
  final_snapshot_identifier           = "${local.instance_alias}-cluster-final-${random_id.snapshot_id.hex}"
  iam_database_authentication_enabled = true

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_rds_cluster_instance" "apiary_cluster_instance" {
  count                = "${ var.external_database_host == "" ? var.db_instance_count : 0 }"
  identifier           = "${local.instance_alias}-instance-${count.index}"
  cluster_identifier   = "${aws_rds_cluster.apiary_cluster.id}"
  instance_class       = "${var.db_instance_class}"
  db_subnet_group_name = "${aws_db_subnet_group.apiarydbsg.name}"
  publicly_accessible  = false
  tags                 = "${var.apiary_tags}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "null_resource" "db_iam_auth" {
  count      = "${ var.external_database_host == "" ? 1 : 0 }"
  depends_on = ["aws_rds_cluster_instance.apiary_cluster_instance"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/db-iam-auth.sh &> /dev/null"

    environment {
      MYSQL_HOST            = "${aws_rds_cluster.apiary_cluster.endpoint}"
      MYSQL_MASTER_USER     = "${aws_rds_cluster.apiary_cluster.master_username}"
      MYSQL_MASTER_PASSWORD = "${aws_rds_cluster.apiary_cluster.master_password}"
    }
  }
}

resource "null_resource" "mysql_rw_user" {
  count      = "${ var.external_database_host == "" ? 1 : 0 }"
  depends_on = ["aws_rds_cluster_instance.apiary_cluster_instance"]

  triggers {
    secret_string = "${md5(data.aws_secretsmanager_secret_version.db_rw_user.secret_string)}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/mysql-user.sh &> /dev/null"

    environment {
      MYSQL_HOST            = "${aws_rds_cluster.apiary_cluster.endpoint}"
      MYSQL_MASTER_USER     = "${aws_rds_cluster.apiary_cluster.master_username}"
      MYSQL_MASTER_PASSWORD = "${aws_rds_cluster.apiary_cluster.master_password}"
      MYSQL_DB              = "${var.apiary_database_name}"
      MYSQL_SECRET_ARN      = "${data.aws_secretsmanager_secret.db_rw_user.arn}"
      MYSQL_PERMISSIONS     = "ALL"
    }
  }
}

resource "null_resource" "mysql_ro_user" {
  count      = "${ var.external_database_host == "" ? 1 : 0 }"
  depends_on = ["aws_rds_cluster_instance.apiary_cluster_instance"]

  triggers {
    secret_string = "${md5(data.aws_secretsmanager_secret_version.db_ro_user.secret_string)}"
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/mysql-user.sh &> /dev/null"

    environment {
      MYSQL_HOST            = "${aws_rds_cluster.apiary_cluster.endpoint}"
      MYSQL_MASTER_USER     = "${aws_rds_cluster.apiary_cluster.master_username}"
      MYSQL_MASTER_PASSWORD = "${aws_rds_cluster.apiary_cluster.master_password}"
      MYSQL_DB              = "${var.apiary_database_name}"
      MYSQL_SECRET_ARN      = "${data.aws_secretsmanager_secret.db_ro_user.arn}"
      MYSQL_PERMISSIONS     = "SELECT"
    }
  }
}
