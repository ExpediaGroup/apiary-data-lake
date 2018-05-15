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
  name   = "sg-apiary-db"
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

# Create database for hive
resource "aws_db_instance" "apiarydb" {
  allocated_storage       = "${var.db_size}"
  storage_type            = "${var.db_storage_type}"
  engine                  = "aurora"
  instance_class          = "${var.db_type}"
  name                    = "apiary-metastore-db"
  identifier_prefix       = "apiary"
  username                = "${data.vault_generic_secret.apiarydb_master_user.data["username"]}"
  password                = "${data.vault_generic_secret.apiarydb_master_user.data["password"]}"
  db_subnet_group_name    = "apiarydbsg"
  backup_retention_period = "${var.db_backup_retention}"
  publicly_accessible     = "false"
  multi_az                = "true"
  vpc_security_group_ids  = ["${aws_security_group.db_sg.id}"]
  tags                    = "${var.apiary_tags}"
}

resource "aws_route53_record" "apiarydb_alias" {
  zone_id = "${aws_route53_zone.apiary_zone.zone_id}"
  name    = "apiary-metastore-db"
  type    = "A"

  alias {
    name                   = "${aws_db_instance.apiarydb.address}"
    zone_id                = "${aws_db_instance.apiarydb.hosted_zone_id}"
    evaluate_target_health = true
  }
}
