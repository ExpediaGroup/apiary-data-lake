/**
 * Copyright (C) 2018 Expedia Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 */

resource "aws_db_subnet_group" "apiarydbsg" {
  name        = "apiarydbsg"
  subnet_ids  = [ "${var.private_subnets}" ]
  description = "Apiary DB Subnet Group"

  tags = "${merge(map("Name","Apiary DB Subnet Group"),var.apiary_tags)}"
}

data "vault_generic_secret" "apiarydb_master_user" {
  path = "${var.vault_path}/db_master_user"
}

resource "aws_security_group" "db_sg" {
  name   = "apiary-db"
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

resource "aws_rds_cluster" "apiary_cluster" {

    cluster_identifier            = "apiary-cluster"
    database_name                 = "apiary"
    master_username               = "${data.vault_generic_secret.apiarydb_master_user.data["username"]}"
    master_password               = "${data.vault_generic_secret.apiarydb_master_user.data["password"]}"
    backup_retention_period       = "${var.db_backup_retention}"
    preferred_backup_window       = "${var.db_backup_window}"
    preferred_maintenance_window  = "${var.db_maintenance_window}"
    db_subnet_group_name          = "${aws_db_subnet_group.apiarydbsg.name}"
    vpc_security_group_ids        = ["${aws_security_group.db_sg.id}"]
    tags                          = "${var.apiary_tags}"
    final_snapshot_identifier     = "apiary-cluster-final"

    lifecycle {
        create_before_destroy = true
    }


}

resource "aws_rds_cluster_instance" "apiary_cluster_instance" {
    count                   = "${length(var.private_subnets)}"
    identifier              = "apiary-instance-${count.index}"
    cluster_identifier      = "${aws_rds_cluster.apiary_cluster.id}"
    instance_class          = "${var.db_instance_class}"
    db_subnet_group_name    = "${aws_db_subnet_group.apiarydbsg.name}"
    publicly_accessible     = false
    tags                    = "${var.apiary_tags}"

    lifecycle {
        create_before_destroy = true
    }
}

resource "aws_route53_record" "apiarydb_alias" {
  zone_id = "${aws_route53_zone.apiary_zone.zone_id}"
  name    = "apiary-metastore-db"
  type    = "A"

  alias {
    name                   = "${aws_rds_cluster.apiary_cluster.endpoint}"
    zone_id                = "${aws_rds_cluster.apiary_cluster.hosted_zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "apiarydb_ro_alias" {
  zone_id = "${aws_route53_zone.apiary_zone.zone_id}"
  name    = "apiary-metastore-db-reader"
  type    = "A"

  alias {
    name                   = "${aws_rds_cluster.apiary_cluster.reader_endpoint}"
    zone_id                = "${aws_rds_cluster.apiary_cluster.hosted_zone_id}"
    evaluate_target_health = true
  }
}
