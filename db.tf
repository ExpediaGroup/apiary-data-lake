/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_db_subnet_group" "apiarydbsg" {
  name        = "${local.instance_alias}-dbsg"
  subnet_ids  = ["${var.private_subnets}"]
  description = "Apiary DB Subnet Group"

  tags = "${merge(map("Name","Apiary DB Subnet Group"),var.apiary_tags)}"
}

data "vault_generic_secret" "apiarydb_master_user" {
  path = "${local.vault_path}/db_master_user"
}

resource "aws_security_group" "db_sg" {
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
  byte_length = 8
}

resource "aws_rds_cluster" "apiary_cluster" {
  cluster_identifier                  = "${local.instance_alias}-cluster"
  database_name                       = "${var.apiary_database_name}"
  master_username                     = "${data.vault_generic_secret.apiarydb_master_user.data["username"]}"
  master_password                     = "${data.vault_generic_secret.apiarydb_master_user.data["password"]}"
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
  count                = "${var.db_instance_count}"
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
  depends_on = ["aws_rds_cluster_instance.apiary_cluster_instance"]

  provisioner "local-exec" {
    command = "${path.module}/scripts/db-iam-auth.sh ${aws_rds_cluster.apiary_cluster.endpoint} ${aws_rds_cluster.apiary_cluster.master_username} '${aws_rds_cluster.apiary_cluster.master_password}'"
  }
}

resource "aws_route53_record" "apiarydb_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-metastore-db"
  type    = "A"

  alias {
    name                   = "${aws_rds_cluster.apiary_cluster.endpoint}"
    zone_id                = "${aws_rds_cluster.apiary_cluster.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apiarydb_ro_alias" {
  count   = "${local.enable_route53_records}"
  zone_id = "${data.aws_route53_zone.apiary_zone.zone_id}"
  name    = "${local.instance_alias}-metastore-db-reader"
  type    = "A"

  alias {
    name                   = "${aws_rds_cluster.apiary_cluster.reader_endpoint}"
    zone_id                = "${aws_rds_cluster.apiary_cluster.hosted_zone_id}"
    evaluate_target_health = true
  }
}
